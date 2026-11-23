import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/services/notification_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

import '../data/datos_cartelera_shows.dart';
import '../data/show_models.dart';
import '../utils/shows_date_utils.dart';
import '../widgets/banner_destacado_shows.dart';
import '../widgets/calendario_dias_shows.dart';
import '../widgets/pestanas_seccion_shows.dart';
import '../widgets/seccion_escenarios_shows.dart';
import '../widgets/seccion_reglas_shows.dart';
import '../widgets/tarjeta_show_cartelera.dart';
import 'pantalla_detalle_show_acuatico.dart';

/// Pantalla de Shows estilo Cineplanet con alertas y recordatorios por horario
class PantallaShows extends StatefulWidget {
  final bool esTabEmbedido;
  final VoidCallback? onIrAlInicio;
  final ValueChanged<String>? onVerEnMapa;

  const PantallaShows({
    super.key,
    this.esTabEmbedido = false,
    this.onIrAlInicio,
    this.onVerEnMapa,
  });

  @override
  State<PantallaShows> createState() => _PantallaShowsState();
}

class _PantallaShowsState extends State<PantallaShows> {
  SeccionShows _seccionActiva = SeccionShows.horarios;
  int _diaSeleccionadoIndex = 0;
  late final List<DateTime> _diasCalendario;

  // Claves de horarios con recordatorio activo: 'showId_hora_diaIndex'
  final Set<String> _alertasProgramadas = {};
  static const String _prefKeyShowsAlertas = 'shows_alertas_programadas';

  @override
  void initState() {
    super.initState();
    _diasCalendario = ShowsDateUtils.generarProximosDias(14);
    _cargarAlertasGuardadas();
  }

  Future<void> _cargarAlertasGuardadas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guardadas = prefs.getStringList(_prefKeyShowsAlertas);
      if (guardadas != null && mounted) {
        setState(() {
          _alertasProgramadas.addAll(guardadas);
        });
      }
    } catch (_) {}
  }

  Future<void> _guardarAlertas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _prefKeyShowsAlertas,
        _alertasProgramadas.toList(),
      );
    } catch (_) {}
  }

  String _construirClaveAlerta(String showId, String hora) {
    return '${showId}_${hora}_$_diaSeleccionadoIndex';
  }

  bool _isHoraNotificada(String showId, String hora) {
    return _alertasProgramadas.contains(_construirClaveAlerta(showId, hora));
  }

  void _toggleNotificacion(ShowItemData show, String hora) {
    final key = _construirClaveAlerta(show.id, hora);
    final bool yaActivo = _alertasProgramadas.contains(key);

    setState(() {
      if (yaActivo) {
        _alertasProgramadas.remove(key);
      } else {
        _alertasProgramadas.add(key);
      }
    });
    _guardarAlertas();

    final fechaSeleccionada = _diasCalendario[_diaSeleccionadoIndex];
    final String diaTexto = ShowsDateUtils.obtenerNombreDia(
      fechaSeleccionada,
      _diaSeleccionadoIndex,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (!yaActivo) {
      NotificationService.instance.mostrarNotificacion(
        id: (show.id.hashCode + hora.hashCode).abs() % 100000,
        titulo: '🔔 Recordatorio fijado: ${show.titulo}',
        cuerpo:
            'Te avisaremos 15 minutos antes de la función de las $hora ($diaTexto).',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF15803D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '¡Listo! Te avisaremos para ${show.titulo} a las $hora',
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.grey.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(
                Icons.notifications_off_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Aviso cancelado para las $hora',
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _abrirDetalleShow(ShowItemData show) {
    SoundService.instance.playButtonTap();
    if (show.id == 'show_marino') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PantallaDetalleShowAcuatico(),
        ),
      );
    } else {
      _toggleNotificacion(show, show.horarios.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: IdiomaService.instance,
      builder: (context, _) {
        final bool esTablet = MediaQuery.of(context).size.width >= 720;

        final Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. BANNER DESTACADO DE RECORDATORIOS
            BannerDestacadoShows(cantidadAlertas: _alertasProgramadas.length),

            const SizedBox(height: 18),

            // 2. PESTAÑAS DE SECCIÓN (HORARIOS, REGLAS, ESCENARIOS)
            PestanasSeccionShows(
              seccionActiva: _seccionActiva,
              onCambiarSeccion: (sec) => setState(() => _seccionActiva = sec),
            ),

            const SizedBox(height: 18),

            // 3. CONTENIDO SEGÚN SECCIÓN
            if (_seccionActiva == SeccionShows.horarios) ...[
              // CALENDARIO DE DÍAS (14 DÍAS)
              CalendarioDiasShows(
                diasCalendario: _diasCalendario,
                diaSeleccionadoIndex: _diaSeleccionadoIndex,
                onSeleccionarDia: (idx) =>
                    setState(() => _diaSeleccionadoIndex = idx),
              ),

              const SizedBox(height: 20),

              // ENCABEZADO "SHOWS DISPONIBLES"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'cartelera_shows'.tr,
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textoOscuro,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      '${DatosCarteleraShows.todosLosShows.length} espectáculos',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.verdePrincipal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // LISTA DE SHOWS EN CARTELERA CON RECORDATORIOS
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: DatosCarteleraShows.todosLosShows.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final show = DatosCarteleraShows.todosLosShows[index];
                  return TarjetaShowCartelera(
                    show: show,
                    onToggleNotificacion: _toggleNotificacion,
                    onAbrirDetalle: _abrirDetalleShow,
                    isHoraNotificada: _isHoraNotificada,
                  );
                },
              ),
            ] else if (_seccionActiva == SeccionShows.reglas) ...[
              const SeccionReglasShows(),
            ] else ...[
              SeccionEscenariosShows(onVerEnMapa: widget.onVerEnMapa),
            ],

            const SizedBox(height: 90),
          ],
        );

        return Scaffold(
          backgroundColor: const Color(0xFFFBF9F6),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            automaticallyImplyLeading: false,
            leading: !widget.esTabEmbedido && widget.onIrAlInicio != null
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textoOscuro,
                      size: 20,
                    ),
                    onPressed: () {
                      SoundService.instance.playButtonTap();
                      widget.onIrAlInicio!();
                    },
                  )
                : null,
            title: Text(
              'shows_eventos'.tr,
              style: GoogleFonts.urbanist(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textoOscuro,
                letterSpacing: -0.4,
              ),
            ),
            actions: [
              if (_alertasProgramadas.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF22C55E)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.notifications_active_rounded,
                            size: 14,
                            color: Color(0xFF15803D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_alertasProgramadas.length}',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: esTablet
                ? Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: content,
                    ),
                  )
                : content,
          ),
        );
      },
    );
  }
}
