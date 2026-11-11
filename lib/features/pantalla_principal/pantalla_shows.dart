import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/pantalla_principal/pantalla_detalle_show_acuatico.dart';

/// Secciones principales disponibles para los shows
enum SeccionShows {
  horarios,
  reglas,
  escenarios,
}

/// Modelo de datos para un show de la cartelera
class ShowItemData {
  final String id;
  final String titulo;
  final String ubicacion;
  final String duracion;
  final String imagen;
  final String formato; // Ej: 2D Regular / Anfiteatro Abierto
  final String clasificacion; // Ej: APT (Apta para todos)
  final String etiqueta;
  final Color colorEtiqueta;
  final List<String> horarios;
  final bool esDestacado;

  const ShowItemData({
    required this.id,
    required this.titulo,
    required this.ubicacion,
    required this.duracion,
    required this.imagen,
    required this.formato,
    required this.clasificacion,
    required this.etiqueta,
    required this.colorEtiqueta,
    required this.horarios,
    this.esDestacado = false,
  });
}

/// Pantalla de Shows estilo Cineplanet:
/// - Selector de fecha superior (Día + Número grande)
/// - Activación de notificaciones
/// - Cartelera con póster a la izquierda, título y datos a la derecha,
///   y pastillas de funciones/horarios interactivos debajo.
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
  bool _notificacionesActivas = true;
  int _diaSeleccionadoIndex = 0;
  late final List<DateTime> _diasCalendario;

  final List<ShowItemData> _todosLosShows = const [
    ShowItemData(
      id: 'show_marino',
      titulo: 'Show Acuático de Lobos & Focas',
      ubicacion: 'Anfiteatro Marino • Zona Costa',
      duracion: '35 min',
      imagen: 'assets/images/animales_con_fondo/foca-card.jpg',
      formato: 'Anfiteatro Acuático',
      clasificacion: 'APT',
      etiqueta: '⭐ SHOW ESTELAR',
      colorEtiqueta: Color(0xFF0077B6),
      horarios: ['10:00 AM', '01:00 PM', '04:00 PM'],
      esDestacado: true,
    ),
    ShowItemData(
      id: 'show_aves',
      titulo: 'Vuelo Libre de Rapaces & Cóndores',
      ubicacion: 'Mirador Andino • Zona Sierra',
      duracion: '25 min',
      imagen: 'assets/images/animales_con_fondo/aguila.jpg',
      formato: 'Campo Abierto',
      clasificacion: 'APT',
      etiqueta: '🦅 AL AIRE LIBRE',
      colorEtiqueta: Color(0xFF8D6E63),
      horarios: ['11:30 AM', '03:30 PM'],
    ),
    ShowItemData(
      id: 'show_pinguinos',
      titulo: 'Alimentación de Pingüinos Humboldt',
      ubicacion: 'Piscina Humboldt • Zona Costa',
      duracion: '20 min',
      imagen: 'assets/images/animales_con_fondo/pinguino-card.jpg',
      formato: 'Interactivo',
      clasificacion: 'APT',
      etiqueta: '🐟 INTERACTIVO',
      colorEtiqueta: Color(0xFF0E6568),
      horarios: ['12:00 PM', '02:30 PM'],
    ),
    ShowItemData(
      id: 'show_felinos',
      titulo: 'Charla & Enriquecimiento con Leones',
      ubicacion: 'Refugio de Fieras • Zona Internacional',
      duracion: '30 min',
      imagen: 'assets/images/animales_con_fondo/leon-card.jpg',
      formato: 'Charla Biológica',
      clasificacion: 'APT',
      etiqueta: '🦁 CHARLA CON CUIDADORES',
      colorEtiqueta: Color(0xFFD97706),
      horarios: ['02:00 PM', '04:30 PM'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _diasCalendario = List.generate(
      14,
      (i) => hoy.add(Duration(days: i)),
    );
  }

  String _obtenerNombreDia(DateTime fecha, int index) {
    if (index == 0) return 'Hoy';
    if (index == 1) return 'Mañana';
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return dias[fecha.weekday - 1];
  }

  String _obtenerNombreMes(int mes) {
    const meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Set', 'Oct', 'Nov', 'Dic'
    ];
    return meses[mes - 1];
  }

  void _seleccionarFuncion(ShowItemData show, String hora) {
    SoundService.instance.playButtonTap();
    final fechaSeleccionada = _diasCalendario[_diaSeleccionadoIndex];
    final String fechaFormateada =
        '${_obtenerNombreDia(fechaSeleccionada, _diaSeleccionadoIndex)} ${fechaSeleccionada.day} de ${_obtenerNombreMes(fechaSeleccionada.month)}';

    _mostrarModalConfirmacionFuncion(show, hora, fechaFormateada);
  }

  void _mostrarModalConfirmacionFuncion(
    ShowItemData show,
    String hora,
    String fechaTexto,
  ) {
    int cantidadEntradas = 2;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra de agarre
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // RESUMEN DEL SHOW SELECCIONADO (ESTILO CINEPLANET)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          show.imagen,
                          width: 60,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: show.colorEtiqueta.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                show.etiqueta,
                                style: GoogleFonts.urbanist(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: show.colorEtiqueta,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              show.titulo,
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textoOscuro,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              show.ubicacion,
                              style: GoogleFonts.urbanist(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textoGris,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // FUNCIÓN Y FECHA ELEGIDA
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.verdePrincipal.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.verdePrincipal.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: AppColors.verdePrincipal,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              fechaTexto,
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textoOscuro,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.verdePrincipal,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time_filled_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hora,
                                style: GoogleFonts.urbanist(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // SELECTOR DE CUPOS / ENTRADAS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cantidad de asistentes',
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textoOscuro,
                            ),
                          ),
                          Text(
                            'Incluido en tu entrada general',
                            style: GoogleFonts.urbanist(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textoGris,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: cantidadEntradas > 1
                                ? () {
                                    SoundService.instance.playButtonTap();
                                    setModalState(() => cantidadEntradas--);
                                  }
                                : null,
                            icon: const Icon(Icons.remove_circle_outline_rounded),
                            color: AppColors.verdePrincipal,
                          ),
                          Text(
                            '$cantidadEntradas',
                            style: GoogleFonts.urbanist(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textoOscuro,
                            ),
                          ),
                          IconButton(
                            onPressed: cantidadEntradas < 8
                                ? () {
                                    SoundService.instance.playButtonTap();
                                    setModalState(() => cantidadEntradas++);
                                  }
                                : null,
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            color: AppColors.verdePrincipal,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // BOTÓN CONFIRMAR RESERVA
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        SoundService.instance.playButtonTap();
                        Navigator.pop(ctx);
                        _mostrarBoletoDigital(show, hora, fechaTexto, cantidadEntradas);
                      },
                      icon: const Icon(Icons.confirmation_number_rounded,
                          color: Colors.white, size: 20),
                      label: Text(
                        'Reservar Función ($hora)',
                        style: GoogleFonts.urbanist(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verdePrincipal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarBoletoDigital(
    ShowItemData show,
    String hora,
    String fechaTexto,
    int cantidad,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.verdePrincipal.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.verdePrincipal,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '¡Función Reservada!',
                  style: GoogleFonts.urbanist(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textoOscuro,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Presenta este pase en el ingreso del anfiteatro',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: AppColors.textoGris,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),

                // TARJETA DE PASE
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        show.titulo,
                        style: GoogleFonts.urbanist(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textoOscuro,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$fechaTexto • $hora',
                        style: GoogleFonts.urbanist(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.verdePrincipal,
                        ),
                      ),
                      Text(
                        'Pases: $cantidad personas • ${show.ubicacion}',
                        style: GoogleFonts.urbanist(
                          fontSize: 11.5,
                          color: AppColors.textoGris,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Código de barras / QR simulado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.qr_code_2_rounded, size: 54),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PASE-ZOO-2026',
                                  style: GoogleFonts.urbanist(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Acceso Rápido',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 11,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdePrincipal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Listo, entendido',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
      _seleccionarFuncion(show, show.horarios.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: !widget.esTabEmbedido,
        leading: widget.esTabEmbedido
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textoOscuro,
                  size: 20,
                ),
                onPressed: () {
                  SoundService.instance.playButtonTap();
                  Navigator.pop(context);
                },
              ),
        title: Text(
          'Cartelera de Shows',
          style: GoogleFonts.urbanist(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textoOscuro,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),

            // 1. BANNER PRINCIPAL INDICANDO "Mira todo esto para tus shows"
            _buildBannerShows(),

            const SizedBox(height: 14),

            // 2. TRES SECCIONES TIPO CARDS INTERACTIVAS
            _buildSeccionesCards(),

            const SizedBox(height: 18),

            // 3. CONTENIDO SEGÚN LA SECCIÓN ACTIVA
            if (_seccionActiva == SeccionShows.horarios) ...[
              _buildNotificacionesSwitch(),
              const SizedBox(height: 16),
              _buildEncabezadoFechas(),
              const SizedBox(height: 12),
              _buildCalendarioCineplanet(),
              const SizedBox(height: 20),
              _buildEncabezadoShowsDisponibles(),
              const SizedBox(height: 14),
              _buildListaShows(),
            ] else if (_seccionActiva == SeccionShows.reglas) ...[
              _buildSeccionReglas(),
            ] else ...[
              _buildSeccionEscenarios(),
            ],

            // Margen inferior para que la barra de navegación no tape nada
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  /// Banner llamativo superior
  Widget _buildBannerShows() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.verdePrincipal,
              Color(0xFF1E3A2F),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.verdePrincipal.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '✨ CARTELERA VIVA',
                      style: GoogleFonts.urbanist(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mira todo esto para tus shows',
                    style: GoogleFonts.urbanist(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Reserva horarios, consulta normas de convivencia y conoce la ubicación de cada escenario.',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.theater_comedy_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Las 3 secciones interactivas tipo cards debajo del banner
  Widget _buildSeccionesCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          _buildItemCardSeccion(
            seccion: SeccionShows.horarios,
            emoji: '📅',
            titulo: 'Horarios',
            subtitulo: '& Fechas',
          ),
          const SizedBox(width: 10),
          _buildItemCardSeccion(
            seccion: SeccionShows.reglas,
            emoji: '📋',
            titulo: 'Reglas',
            subtitulo: 'del Show',
          ),
          const SizedBox(width: 10),
          _buildItemCardSeccion(
            seccion: SeccionShows.escenarios,
            emoji: '📍',
            titulo: 'Escenarios',
            subtitulo: '& Info',
          ),
        ],
      ),
    );
  }

  Widget _buildItemCardSeccion({
    required SeccionShows seccion,
    required String emoji,
    required String titulo,
    required String subtitulo,
  }) {
    final bool activa = _seccionActiva == seccion;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          SoundService.instance.playButtonTap();
          setState(() {
            _seccionActiva = seccion;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: activa
                ? AppColors.verdePrincipal.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: activa
                  ? AppColors.verdePrincipal
                  : Colors.black.withValues(alpha: 0.08),
              width: activa ? 1.8 : 1.0,
            ),
            boxShadow: activa
                ? [
                    BoxShadow(
                      color: AppColors.verdePrincipal.withValues(alpha: 0.14),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 6),
              Text(
                titulo,
                style: GoogleFonts.urbanist(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: activa ? AppColors.verdePrincipal : AppColors.textoOscuro,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitulo,
                style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: activa ? FontWeight.w800 : FontWeight.w600,
                  color: activa ? AppColors.verdePrincipal : AppColors.textoGris,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEncabezadoFechas() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Selecciona el día',
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textoOscuro,
              letterSpacing: -0.2,
            ),
          ),
          Text(
            '${_obtenerNombreMes(_diasCalendario[_diaSeleccionadoIndex].month)} ${_diasCalendario[_diaSeleccionadoIndex].year}',
            style: GoogleFonts.urbanist(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.verdePrincipal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncabezadoShowsDisponibles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Text(
            'Shows disponibles',
            style: GoogleFonts.urbanist(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.textoOscuro,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.verdePrincipal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_todosLosShows.length} en cartelera',
              style: GoogleFonts.urbanist(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.verdePrincipal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaShows() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _todosLosShows.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final show = _todosLosShows[index];
        return _buildShowCardCineplanet(show);
      },
    );
  }

  /// Vista de la sección de Reglas del Show
  Widget _buildSeccionReglas() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de bienestar animal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF86EFAC).withValues(alpha: 0.6),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: Color(0xFF16A34A),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienestar Animal Primero',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF166534),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Nuestros shows son educativos y respetan los ritmos biológicos de cada ejemplar.',
                        style: GoogleFonts.urbanist(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF15803D),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Normas y Recomendaciones',
            style: GoogleFonts.urbanist(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.textoOscuro,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),

          _buildItemRegla(
            icono: Icons.no_flash_rounded,
            colorIcono: const Color(0xFFDC2626),
            titulo: 'Prohibido usar flash en fotos',
            descripcion:
                'La luz intensa puede asustar o desorientar a lobos marinos y aves rapaces durante las maniobras.',
          ),
          const SizedBox(height: 10),
          _buildItemRegla(
            icono: Icons.no_food_rounded,
            colorIcono: const Color(0xFFEA580C),
            titulo: 'No arrojar comida al escenario',
            descripcion:
                'Los animales reciben dietas balanceadas pesadas por gramaje diario con estricto control veterinario.',
          ),
          const SizedBox(height: 10),
          _buildItemRegla(
            icono: Icons.access_time_filled_rounded,
            colorIcono: const Color(0xFF0284C7),
            titulo: 'Llegada 15 minutos antes',
            descripcion:
                'El aforo en graderías es controlado por seguridad. Se cierran accesos puntualmente al iniciar.',
          ),
          const SizedBox(height: 10),
          _buildItemRegla(
            icono: Icons.volume_off_rounded,
            colorIcono: const Color(0xFF7C3AED),
            titulo: 'Silencio y respeto durante el show',
            descripcion:
                'Evita ruidos estridentes o levantarte bruscamente durante los vuelos o ejercicios en vivo.',
          ),
          const SizedBox(height: 10),
          _buildItemRegla(
            icono: Icons.accessible_rounded,
            colorIcono: const Color(0xFF0D9488),
            titulo: 'Zonas de acceso preferente',
            descripcion:
                'Espacios reservados de fácil acceso para personas con movilidad reducida y cochecitos de bebé.',
          ),
          const SizedBox(height: 10),
          _buildItemRegla(
            icono: Icons.wb_sunny_rounded,
            colorIcono: const Color(0xFFD97706),
            titulo: 'Protección solar y clima',
            descripcion:
                'Los anfiteatros al aire libre disponen de zonas sombreadas. Se recomienda uso de gorra e hidratación.',
          ),
        ],
      ),
    );
  }

  Widget _buildItemRegla({
    required IconData icono,
    required Color colorIcono,
    required String titulo,
    required String descripcion,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: colorIcono.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icono,
              color: colorIcono,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.urbanist(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textoOscuro,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descripcion,
                  style: GoogleFonts.urbanist(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textoGris,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Vista de la sección de Escenarios & Info
  Widget _buildSeccionEscenarios() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Escenarios del Parque',
                style: GoogleFonts.urbanist(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textoOscuro,
                  letterSpacing: -0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.verdePrincipal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '4 locaciones',
                  style: GoogleFonts.urbanist(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.verdePrincipal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildCardEscenario(
            nombre: 'Anfiteatro Acuático Marino',
            zonaTag: 'ZONA COSTA',
            capacidad: '450 personas (Techado)',
            showPrincipal: 'Show Acuático de Lobos & Focas',
            descripcion:
                'Piscina oceánica de agua salada con graderías techadas, sonido envolvente y vista submarina.',
            colorAcento: const Color(0xFF0077B6),
            habitatMapa: 'costa',
            imagenAsset: 'assets/images/animales_con_fondo/foca-card.jpg',
          ),
          const SizedBox(height: 14),
          _buildCardEscenario(
            nombre: 'Mirador Andino de Rapaces',
            zonaTag: 'ZONA SIERRA',
            capacidad: '300 personas (Campo abierto)',
            showPrincipal: 'Vuelo Libre de Rapaces & Cóndores',
            descripcion:
                'Ubicado en la ladera alta del zoológico, aprovecha las corrientes térmicas andinas para vuelos naturales.',
            colorAcento: const Color(0xFF8D6E63),
            habitatMapa: 'sierra',
            imagenAsset: 'assets/images/animales_con_fondo/aguila.jpg',
          ),
          const SizedBox(height: 14),
          _buildCardEscenario(
            nombre: 'Piscina Humboldt',
            zonaTag: 'ZONA COSTA',
            capacidad: '200 personas (Semi-techado)',
            showPrincipal: 'Alimentación de Pingüinos Humboldt',
            descripcion:
                'Plataforma cercana de observación con cristales sumergidos y charlas biológicas interactivas.',
            colorAcento: const Color(0xFF0E6568),
            habitatMapa: 'costa',
            imagenAsset: 'assets/images/animales_con_fondo/pinguino-card.jpg',
          ),
          const SizedBox(height: 14),
          _buildCardEscenario(
            nombre: 'Refugio de la Sabana & Felinos',
            zonaTag: 'ZONA INTERNACIONAL',
            capacidad: '350 personas (Pasarela)',
            showPrincipal: 'Charla & Enriquecimiento con Leones',
            descripcion:
                'Pasarela elevada con vista a la pradera africana y ventanales de máxima seguridad para charlas guiadas.',
            colorAcento: const Color(0xFFD97706),
            habitatMapa: 'internacional',
            imagenAsset: 'assets/images/animales_con_fondo/leon-card.jpg',
          ),
        ],
      ),
    );
  }

  Widget _buildCardEscenario({
    required String nombre,
    required String zonaTag,
    required String capacidad,
    required String showPrincipal,
    required String descripcion,
    required Color colorAcento,
    required String habitatMapa,
    required String imagenAsset,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  imagenAsset,
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 68,
                    height: 68,
                    color: colorAcento.withValues(alpha: 0.1),
                    child: Icon(Icons.theater_comedy_rounded, color: colorAcento),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: colorAcento.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            zonaTag,
                            style: GoogleFonts.urbanist(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: colorAcento,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.people_outline_rounded, size: 13, color: AppColors.textoGris),
                            const SizedBox(width: 3),
                            Text(
                              capacidad,
                              style: GoogleFonts.urbanist(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textoGris,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      nombre,
                      style: GoogleFonts.urbanist(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textoOscuro,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFEAB308)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            showPrincipal,
                            style: GoogleFonts.urbanist(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.verdePrincipal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            descripcion,
            style: GoogleFonts.urbanist(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textoGris,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: () {
                SoundService.instance.playButtonTap();
                if (widget.onVerEnMapa != null) {
                  widget.onVerEnMapa!(habitatMapa);
                }
              },
              icon: const Icon(Icons.explore_outlined, size: 16),
              label: Text(
                'Ver escenario en el mapa',
                style: GoogleFonts.urbanist(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.verdePrincipal,
                side: BorderSide(
                  color: AppColors.verdePrincipal.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppColors.verdePrincipal.withValues(alpha: 0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Barra superior de activación de notificaciones
  Widget _buildNotificacionesSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _notificacionesActivas
                ? AppColors.verdePrincipal.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.06),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _notificacionesActivas
                    ? AppColors.verdePrincipal.withValues(alpha: 0.12)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _notificacionesActivas
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_outlined,
                color: _notificacionesActivas
                    ? AppColors.verdePrincipal
                    : Colors.grey.shade500,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activar notificaciones de shows',
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textoOscuro,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Te avisamos 15 min antes de cada función',
                    style: GoogleFonts.urbanist(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textoGris,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _notificacionesActivas,
              activeThumbColor: AppColors.verdePrincipal,
              activeTrackColor: AppColors.verdePrincipal.withValues(alpha: 0.35),
              onChanged: (val) {
                SoundService.instance.playButtonTap();
                setState(() {
                  _notificacionesActivas = val;
                });
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.verdePrincipal,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    content: Text(
                      val
                          ? '🔔 Notificaciones de shows activadas'
                          : '🔕 Notificaciones de shows pausadas',
                      style: GoogleFonts.urbanist(fontWeight: FontWeight.w700),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Calendario horizontal estilo Cineplanet (Día de la semana + Fecha grande)
  Widget _buildCalendarioCineplanet() {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _diasCalendario.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final fecha = _diasCalendario[index];
          final bool seleccionado = _diaSeleccionadoIndex == index;
          final String diaSemana = _obtenerNombreDia(fecha, index);
          final String numeroDia = fecha.day.toString();

          return InkWell(
            onTap: () {
              SoundService.instance.playButtonTap();
              setState(() {
                _diaSeleccionadoIndex = index;
              });
            },
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 68,
              decoration: BoxDecoration(
                color: seleccionado
                    ? AppColors.verdePrincipal
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: seleccionado
                      ? AppColors.verdePrincipal
                      : Colors.black.withValues(alpha: 0.07),
                  width: seleccionado ? 1.6 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: seleccionado
                        ? AppColors.verdePrincipal.withValues(alpha: 0.28)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: seleccionado ? 12 : 6,
                    offset: Offset(0, seleccionado ? 5 : 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    diaSemana.toUpperCase(),
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: seleccionado
                          ? Colors.white.withValues(alpha: 0.9)
                          : AppColors.textoGris,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    numeroDia,
                    style: GoogleFonts.urbanist(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      color: seleccionado
                          ? Colors.white
                          : AppColors.textoOscuro,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Tarjeta de Show estilo Cineplanet:
  /// - A la izquierda: Póster vertical pequeño (imagen)
  /// - A la derecha: Título, ubicación, badge, clasificación
  /// - Debajo: Bloque de funciones con botones horarios interactivos
  Widget _buildShowCardCineplanet(ShowItemData show) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: show.esDestacado
              ? AppColors.verdePrincipal.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.06),
          width: show.esDestacado ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FILA PRINCIPAL: IMAGEN PEQUEÑA A LA IZQUIERDA + TÍTULO Y DETALLES A LA DERECHA
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGEN PÓSTER PEQUEÑA TIPO CINEPLANET
              GestureDetector(
                onTap: () => _abrirDetalleShow(show),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Image.asset(
                        show.imagen,
                        width: 88,
                        height: 116,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 88,
                          height: 116,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.theater_comedy, color: Colors.grey),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            show.duracion,
                            style: GoogleFonts.urbanist(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // DATOS A LA DERECHA: BADGES, TÍTULO Y UBICACIÓN
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges superiores
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: show.colorEtiqueta.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            show.etiqueta,
                            style: GoogleFonts.urbanist(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: show.colorEtiqueta,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Text(
                            show.clasificacion,
                            style: GoogleFonts.urbanist(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textoOscuro,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // TÍTULO DEL SHOW
                    GestureDetector(
                      onTap: () => _abrirDetalleShow(show),
                      child: Text(
                        show.titulo,
                        style: GoogleFonts.urbanist(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textoOscuro,
                          height: 1.2,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // UBICACIÓN Y FORMATO
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textoGris,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            show.ubicacion,
                            style: GoogleFonts.urbanist(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textoGris,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),
                    Text(
                      show.formato,
                      style: GoogleFonts.urbanist(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.verdePrincipal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // SECCIÓN DE FUNCIONES DEBAJO (ESTILO CINEPLANET)
          Row(
            children: [
              Text(
                'FUNCIONES:',
                style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textoGris,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Toca para reservar horario',
                style: GoogleFonts.urbanist(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textoGris.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // CHIPS DE HORARIOS / FUNCIONES
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: show.horarios.map((hora) {
              return InkWell(
                onTap: () => _seleccionarFuncion(show, hora),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.verdePrincipal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.verdePrincipal.withValues(alpha: 0.28),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: AppColors.verdePrincipal,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hora,
                        style: GoogleFonts.urbanist(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.verdePrincipal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
