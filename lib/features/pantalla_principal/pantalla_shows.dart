import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/services/notification_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/pantalla_principal/pantalla_detalle_show_acuatico.dart';

/// Secciones principales disponibles para los shows
enum SeccionShows {
  horarios,
  reglas,
  escenarios,
}

/// Modelo de datos para las entradas reservadas de shows
class EntradaShow {
  final String id;
  final String showId;
  final String titulo;
  final String ubicacion;
  final String imagen;
  final String fechaTexto; // Ej: "Hoy, 11 Nov"
  final DateTime fecha;
  final String hora;
  final int cantidad;
  final String codigoBoleto;
  final Color colorTema;
  final bool esVigente;

  const EntradaShow({
    required this.id,
    required this.showId,
    required this.titulo,
    required this.ubicacion,
    required this.imagen,
    required this.fechaTexto,
    required this.fecha,
    required this.hora,
    required this.cantidad,
    required this.codigoBoleto,
    this.colorTema = AppColors.verdePrincipal,
    this.esVigente = true,
  });
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
  late final List<EntradaShow> _misEntradas;

  final Map<String, int> _cuposPorFuncion = {
    'show_marino_10:00 AM': 32,
    'show_marino_01:00 PM': 18,
    'show_marino_04:00 PM': 4,
    'show_aves_11:30 AM': 40,
    'show_aves_03:30 PM': 12,
    'show_pinguinos_12:00 PM': 22,
    'show_pinguinos_02:30 PM': 6,
    'show_felinos_02:00 PM': 25,
    'show_felinos_04:30 PM': 3,
  };

  int _obtenerCupos(String showId, String hora) {
    return _cuposPorFuncion['${showId}_$hora'] ?? 20;
  }

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

    _misEntradas = [
      EntradaShow(
        id: 'entrada_1',
        showId: 'show_marino',
        titulo: 'Show Acuático de Lobos & Focas',
        ubicacion: 'Anfiteatro Marino • Zona Costa',
        imagen: 'assets/images/animales_con_fondo/foca-card.jpg',
        fechaTexto: 'Hoy, ${hoy.day} de ${_obtenerNombreMes(hoy.month)}',
        fecha: hoy,
        hora: '10:00 AM',
        cantidad: 2,
        codigoBoleto: 'TKT-MAR-1049',
        colorTema: const Color(0xFF0077B6),
      ),
      EntradaShow(
        id: 'entrada_2',
        showId: 'show_aves',
        titulo: 'Vuelo Libre de Rapaces & Cóndores',
        ubicacion: 'Mirador Andino • Zona Sierra',
        imagen: 'assets/images/animales_con_fondo/aguila.jpg',
        fechaTexto:
            'Mañana, ${hoy.add(const Duration(days: 1)).day} de ${_obtenerNombreMes(hoy.add(const Duration(days: 1)).month)}',
        fecha: hoy.add(const Duration(days: 1)),
        hora: '11:30 AM',
        cantidad: 3,
        codigoBoleto: 'TKT-AVE-8214',
        colorTema: const Color(0xFF8D6E63),
      ),
    ];
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
                  const SizedBox(height: 16),

                  // DISPONIBILIDAD DE CUPOS EN VIVO
                  Builder(
                    builder: (context) {
                      final cupos = _obtenerCupos(show.id, hora);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: cupos <= 5
                              ? Colors.red.shade50
                              : (cupos <= 15 ? Colors.orange.shade50 : Colors.green.shade50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cupos <= 5
                                ? Colors.red.shade200
                                : (cupos <= 15 ? Colors.orange.shade200 : Colors.green.shade200),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  cupos <= 5 ? Icons.warning_amber_rounded : Icons.people_alt_rounded,
                                  size: 16,
                                  color: cupos <= 5
                                      ? Colors.red.shade700
                                      : (cupos <= 15 ? Colors.orange.shade800 : Colors.green.shade800),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  cupos <= 5
                                      ? '¡Solo quedan $cupos cupos disponibles!'
                                      : '$cupos cupos disponibles para esta función',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: cupos <= 5
                                        ? Colors.red.shade900
                                        : (cupos <= 15 ? Colors.orange.shade900 : Colors.green.shade900),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: cupos <= 5 ? Colors.red : Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

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
                            onPressed: cantidadEntradas < min(8, _obtenerCupos(show.id, hora))
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
                      onPressed: _obtenerCupos(show.id, hora) > 0
                          ? () {
                              SoundService.instance.playButtonTap();
                              final nuevaEntrada = EntradaShow(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                showId: show.id,
                                titulo: show.titulo,
                                ubicacion: show.ubicacion,
                                imagen: show.imagen,
                                fechaTexto: fechaTexto,
                                fecha: _diasCalendario[_diaSeleccionadoIndex],
                                hora: hora,
                                cantidad: cantidadEntradas,
                                codigoBoleto:
                                    'TKT-${show.id.replaceAll('show_', '').toUpperCase()}-${1000 + Random().nextInt(9000)}',
                                colorTema: show.colorEtiqueta,
                              );
                              setState(() {
                                _misEntradas.insert(0, nuevaEntrada);
                                final key = '${show.id}_$hora';
                                final actual = _cuposPorFuncion[key] ?? 20;
                                _cuposPorFuncion[key] = max(0, actual - cantidadEntradas);
                              });

                              // Notificación nativa con el texto exacto pedido
                              NotificationService.instance.mostrarNotificacion(
                                id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                                titulo: '🎟️ Parque de las Leyendas',
                                cuerpo: 'Te registraste a un show a las $hora',
                              );

                              Navigator.pop(ctx);
                              _mostrarBoletoDigital(show, hora, fechaTexto, cantidadEntradas);
                            }
                          : null,
                      icon: const Icon(Icons.confirmation_number_rounded,
                          color: Colors.white, size: 20),
                      label: Text(
                        _obtenerCupos(show.id, hora) > 0
                            ? 'Reservar Función ($hora)'
                            : 'Función Agotada',
                        style: GoogleFonts.urbanist(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _obtenerCupos(show.id, hora) > 0
                            ? AppColors.verdePrincipal
                            : Colors.grey,
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
    if (_notificacionesActivas) {
      NotificationService.instance.mostrarNotificacion(
        id: show.id.hashCode,
        titulo: '🎟️ Boleto Confirmado: ${show.titulo}',
        cuerpo: 'Función $hora ($fechaTexto). ¡Te esperamos en ${show.ubicacion}!',
      );
    }
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          SoundService.instance.playButtonTap();
                          Navigator.pop(ctx);
                          _mostrarModalMisEntradas();
                        },
                        icon: const Icon(
                          Icons.confirmation_number_outlined,
                          size: 16,
                          color: AppColors.verdePrincipal,
                        ),
                        label: Text(
                          'Ver mis entradas',
                          style: GoogleFonts.urbanist(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: AppColors.verdePrincipal,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.verdePrincipal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.verdePrincipal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Listo',
                          style: GoogleFonts.urbanist(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
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

  /// Modal que despliega las entradas reservadas indicando el día y detalles
  void _mostrarModalMisEntradas({DateTime? diaFiltro}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        DateTime? diaSeleccionado = diaFiltro;

        return StatefulBuilder(
          builder: (context, setModalState) {
            // Filtrar entradas según el día seleccionado si aplica
            final entradasAMostrar = diaSeleccionado == null
                ? _misEntradas
                : _misEntradas.where((e) {
                    return e.fecha.year == diaSeleccionado!.year &&
                        e.fecha.month == diaSeleccionado!.month &&
                        e.fecha.day == diaSeleccionado!.day;
                  }).toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFFBF9F6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tirador superior (Handle)
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ENCABEZADO MODAL
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.verdePrincipal.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.confirmation_number_rounded,
                                color: AppColors.verdePrincipal,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mis Entradas de Shows',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textoOscuro,
                                  ),
                                ),
                                Text(
                                  'Pases activos para ingresar a funciones',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textoGris,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded),
                          color: AppColors.textoGris,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // SELECTOR HORIZONTAL DE DÍAS (FILTRO)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildChipFiltroDia(
                          etiqueta: 'Todas (${_misEntradas.length})',
                          seleccionado: diaSeleccionado == null,
                          onTap: () {
                            SoundService.instance.playButtonTap();
                            setModalState(() => diaSeleccionado = null);
                          },
                        ),
                        const SizedBox(width: 8),
                        ...List.generate(7, (i) {
                          final fecha = _diasCalendario[i];
                          final bool sel = diaSeleccionado != null &&
                              diaSeleccionado!.year == fecha.year &&
                              diaSeleccionado!.month == fecha.month &&
                              diaSeleccionado!.day == fecha.day;
                          final String nombreDia = _obtenerNombreDia(fecha, i);
                          final String label = '$nombreDia ${fecha.day}';

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _buildChipFiltroDia(
                              etiqueta: label,
                              seleccionado: sel,
                              onTap: () {
                                SoundService.instance.playButtonTap();
                                setModalState(() => diaSeleccionado = fecha);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1),

                  // LISTA DE ENTRADAS
                  Flexible(
                    child: entradasAMostrar.isEmpty
                        ? _buildEstadoSinEntradas(diaSeleccionado, ctx)
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                            itemCount: entradasAMostrar.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final entrada = entradasAMostrar[index];
                              return _buildTarjetaBoletoShow(entrada, ctx);
                            },
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

  Widget _buildChipFiltroDia({
    required String etiqueta,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.verdePrincipal : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? AppColors.verdePrincipal : Colors.black12,
          ),
          boxShadow: seleccionado
              ? [
                  BoxShadow(
                    color: AppColors.verdePrincipal.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          etiqueta,
          style: GoogleFonts.urbanist(
            fontSize: 12,
            fontWeight: seleccionado ? FontWeight.w900 : FontWeight.w700,
            color: seleccionado ? Colors.white : AppColors.textoOscuro,
          ),
        ),
      ),
    );
  }

  /// Abre el visor con el código QR en grande para escaneo en puerta
  void _mostrarModalDetalleQR(EntradaShow entrada) {
    SoundService.instance.playButtonTap();
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: entrada.colorTema.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'BOLETO DIGITAL',
                        style: GoogleFonts.urbanist(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: entrada.colorTema,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  entrada.titulo,
                  style: GoogleFonts.urbanist(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textoOscuro,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${entrada.fechaTexto} • ${entrada.hora}',
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: entrada.colorTema,
                  ),
                ),
                Text(
                  '${entrada.cantidad} pases • ${entrada.ubicacion}',
                  style: GoogleFonts.urbanist(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoGris,
                  ),
                ),
                const SizedBox(height: 20),

                // CÓDIGO QR EN GRANDE
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black12, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.qr_code_2_rounded,
                        size: 190,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entrada.codigoBoleto,
                        style: GoogleFonts.urbanist(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: AppColors.textoOscuro,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF9F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.brightness_high_rounded,
                          size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Presenta este código en la entrada del show',
                        style: GoogleFonts.urbanist(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textoOscuro,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // BOTÓN CERRAR / ENTENDIDO
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
                      'Listo, cerrar',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
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

  Widget _buildTarjetaBoletoShow(EntradaShow entrada, BuildContext modalCtx) {
    return InkWell(
      onTap: () => _mostrarModalDetalleQR(entrada),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: entrada.colorTema.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CABECERA DEL BOLETO CON FECHA Y ESTADO
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: entrada.colorTema.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: entrada.colorTema,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        entrada.fechaTexto,
                        style: GoogleFonts.urbanist(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: entrada.colorTema,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'PASE VÁLIDO',
                          style: GoogleFonts.urbanist(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // CUERPO DEL SHOW
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      entrada.imagen,
                      width: 64,
                      height: 78,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entrada.titulo,
                          style: GoogleFonts.urbanist(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textoOscuro,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 13,
                              color: AppColors.textoGris,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                entrada.ubicacion,
                                style: GoogleFonts.urbanist(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textoGris,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: entrada.colorTema,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_filled_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    entrada.hora,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.people_alt_rounded,
                                    size: 12,
                                    color: AppColors.textoOscuro,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${entrada.cantidad} pases',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textoOscuro,
                                    ),
                                  ),
                                ],
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

            // LÍNEA PERFORADA DE BOLETO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFBF9F6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final boxWidth = constraints.constrainWidth();
                        const dashWidth = 5.0;
                        const dashSpace = 4.0;
                        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
                        return Flex(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          direction: Axis.horizontal,
                          children: List.generate(dashCount, (_) {
                            return SizedBox(
                              width: dashWidth,
                              height: 1.2,
                              child: DecoratedBox(
                                decoration: BoxDecoration(color: Colors.grey.shade300),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFBF9F6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),

            // PARTE INFERIOR: CÓDIGO, QR Y BOTÓN MAPA
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => _mostrarModalDetalleQR(entrada),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.qr_code_2_rounded,
                            size: 26,
                            color: AppColors.textoOscuro,
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entrada.codigoBoleto,
                                style: GoogleFonts.urbanist(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: AppColors.textoOscuro,
                                ),
                              ),
                              Text(
                                'Toca para ver QR 🔍',
                                style: GoogleFonts.urbanist(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.verdePrincipal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      SoundService.instance.playButtonTap();
                      Navigator.pop(modalCtx);
                      widget.onVerEnMapa?.call(entrada.ubicacion);
                    },
                    icon: const Icon(Icons.near_me_rounded, size: 14, color: Colors.white),
                    label: Text(
                      'Ir al Escenario',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdePrincipal,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoSinEntradas(DateTime? diaSeleccionado, BuildContext modalCtx) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.confirmation_number_outlined,
                size: 40,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              diaSeleccionado == null
                  ? 'No tienes entradas reservadas'
                  : 'Sin entradas para este día',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textoOscuro,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Selecciona un show en la cartelera y reserva tus asientos de forma gratuita.',
              style: GoogleFonts.urbanist(
                fontSize: 12.5,
                color: AppColors.textoGris,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => Navigator.pop(modalCtx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verdePrincipal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Explorar Cartelera',
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
          'cartelera_shows'.tr,
          style: GoogleFonts.urbanist(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textoOscuro,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {
                SoundService.instance.playButtonTap();
                _mostrarModalMisEntradas();
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.verdePrincipal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.verdePrincipal.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.confirmation_number_rounded,
                      size: 15,
                      color: AppColors.verdePrincipal,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${'ver_mis_entradas'.tr} (${_misEntradas.length})',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.verdePrincipal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final bool esTablet = MediaQuery.of(context).size.width >= 720;
          final Widget content = Column(
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
          );

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: esTablet
                ? SizedBox(
                    width: double.infinity,
                    child: Center(
                      heightFactor: 1.0,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: content,
                      ),
                    ),
                  )
                : content,
          );
        },
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
                    'mira_todo_shows'.tr,
                    style: GoogleFonts.urbanist(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'banner_shows_sub'.tr,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      SoundService.instance.playButtonTap();
                      _mostrarModalMisEntradas();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.confirmation_number_rounded,
                            size: 14,
                            color: AppColors.verdePrincipal,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${'ver_entradas_btn'.tr} (${_misEntradas.length})',
                            style: GoogleFonts.urbanist(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.verdePrincipal,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 10,
                            color: AppColors.verdePrincipal,
                          ),
                        ],
                      ),
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
            habitatMapa: 'C05',
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
            habitatMapa: 'S03',
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
            habitatMapa: 'C08',
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
            habitatMapa: 'I02',
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
            child: ElevatedButton.icon(
              onPressed: () {
                SoundService.instance.playButtonTap();
                if (widget.onVerEnMapa != null) {
                  widget.onVerEnMapa!(habitatMapa);
                }
              },
              icon: const Icon(Icons.near_me_rounded, size: 16),
              label: Text(
                'Trazar ruta al escenario',
                style: GoogleFonts.urbanist(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verdePrincipal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                if (val) {
                  NotificationService.instance.mostrarNotificacion(
                    id: 101,
                    titulo: '🔔 Parque de las Leyendas',
                    cuerpo: 'Las notificaciones han sido activadas',
                  );
                }
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
                          ? '🔔 Las notificaciones han sido activadas'
                          : '🔕 Notificaciones de shows desactivadas',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
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
              final cupos = _obtenerCupos(show.id, hora);
              final bool pocosCupos = cupos <= 5;
              final bool agotado = cupos == 0;

              return InkWell(
                onTap: agotado ? null : () => _seleccionarFuncion(show, hora),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: agotado
                        ? Colors.grey.shade100
                        : (pocosCupos
                            ? Colors.red.shade50
                            : AppColors.verdePrincipal.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: agotado
                          ? Colors.grey.shade300
                          : (pocosCupos
                              ? Colors.red.shade300
                              : AppColors.verdePrincipal.withValues(alpha: 0.28)),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: agotado
                                ? Colors.grey
                                : (pocosCupos
                                    ? Colors.red.shade700
                                    : AppColors.verdePrincipal),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            hora,
                            style: GoogleFonts.urbanist(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: agotado
                                  ? Colors.grey
                                  : (pocosCupos
                                      ? Colors.red.shade900
                                      : AppColors.verdePrincipal),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        agotado
                            ? 'Agotado'
                            : (pocosCupos
                                ? '¡$cupos cupos!'
                                : '$cupos cupos'),
                        style: GoogleFonts.urbanist(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: agotado
                              ? Colors.grey
                              : (pocosCupos
                                  ? Colors.red.shade700
                                  : Colors.green.shade800),
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
