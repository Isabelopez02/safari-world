import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Modal interactivo de Accesibilidad e Inclusión:
/// - Control del Modo Alto Contraste y Daltonismo (Deuteranopía / Protanopía)
/// - Control de Zonas de Calma y Silencio (Regulación Sensorial)
class ModalAccesibilidadMapa extends StatefulWidget {
  final ValueChanged<MarcadorMapa>? onSeleccionarZonaCalma;

  const ModalAccesibilidadMapa({
    super.key,
    this.onSeleccionarZonaCalma,
  });

  static Future<void> mostrar(
    BuildContext context, {
    ValueChanged<MarcadorMapa>? onSeleccionarZonaCalma,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalAccesibilidadMapa(
        onSeleccionarZonaCalma: onSeleccionarZonaCalma,
      ),
    );
  }

  @override
  State<ModalAccesibilidadMapa> createState() => _ModalAccesibilidadMapaState();
}

class _ModalAccesibilidadMapaState extends State<ModalAccesibilidadMapa> {
  final a11y = AccesibilidadService.instance;
  late final List<MarcadorMapa> _zonasCalma =
      AnimalService.instance.obtenerZonasCalma();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: a11y,
      builder: (context, _) {
        final bool oscuro = a11y.modoAltoContraste;
        final Color fondo = oscuro ? const Color(0xFF0F172A) : Colors.white;
        final Color textoColor = oscuro ? Colors.white : const Color(0xFF0F172A);
        final Color subtituloColor =
            oscuro ? const Color(0xFFCBD5E1) : const Color(0xFF475569);

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: fondo,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: oscuro ? const Color(0xFFFDE047) : const Color(0xFFE2E8F0),
              width: oscuro ? 2.0 : 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // MANIJA DE ARRASTRE
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: oscuro ? Colors.white54 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // CABECERA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: oscuro
                            ? const Color(0xFFFDE047)
                            : AppColors.verdeAzulado.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.accessibility_new_rounded,
                        color: oscuro ? Colors.black : AppColors.verdeAzulado,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Accesibilidad e Inclusión',
                            style: GoogleFonts.urbanist(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: textoColor,
                            ),
                          ),
                          Text(
                            'Herramientas inclusivas para todos los visitantes',
                            style: GoogleFonts.urbanist(
                              fontSize: 12.5,
                              color: subtituloColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: textoColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // CONTENIDO SCROLLABLE
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  children: [
                    // ========================================================
                    // 1. SWITCH ALTO CONTRASTE Y DALTONISMO
                    // ========================================================
                    _buildTarjetaOpcion(
                      oscuro: oscuro,
                      titulo: 'Modo Alto Contraste y Daltonismo',
                      subtitulo:
                          'Texto blanco puro sobre fondo oscuro (#000000). Diferencia las zonas por símbolos geométricos (🔺, 🌊, ⛰️, 🌿, ⭐) útil para deuteranopía y protanopía.',
                      icono: Icons.contrast_rounded,
                      colorIcono: const Color(0xFFFDE047),
                      activo: a11y.accesibilidadVisualActiva,
                      onChanged: (val) {
                        HapticFeedback.mediumImpact();
                        SoundService.instance.playButtonTap();
                        a11y.setModoAltoContraste(val);
                      },
                    ),

                    // LEYENDA VISUAL DE SÍMBOLOS PARA DALTONISMO
                    if (a11y.accesibilidadVisualActiva) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: oscuro
                              ? Colors.black
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: oscuro
                                ? const Color(0xFFFDE047)
                                : const Color(0xFFCBD5E1),
                            width: 1.4,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guía de Símbolos por Hábitat (Sin depender del color):',
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: textoColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildBadgeZona(
                                  simbolo: '▲',
                                  nombre: 'Internacional',
                                  color: const Color(0xFFFDE047),
                                  oscuro: oscuro,
                                ),
                                _buildBadgeZona(
                                  simbolo: '≈',
                                  nombre: 'Costa',
                                  color: const Color(0xFF38BDF8),
                                  oscuro: oscuro,
                                ),
                                _buildBadgeZona(
                                  simbolo: '▲▲',
                                  nombre: 'Sierra',
                                  color: const Color(0xFFF8FAFC),
                                  oscuro: oscuro,
                                ),
                                _buildBadgeZona(
                                  simbolo: '♣',
                                  nombre: 'Selva',
                                  color: const Color(0xFF4ADE80),
                                  oscuro: oscuro,
                                ),
                                _buildBadgeZona(
                                  simbolo: '★',
                                  nombre: 'Granja',
                                  color: const Color(0xFFE879F9),
                                  oscuro: oscuro,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // ========================================================
                    // 2. SWITCH ZONAS DE CALMA Y SILENCIO
                    // ========================================================
                    _buildTarjetaOpcion(
                      oscuro: oscuro,
                      titulo: 'Destacar Zonas de Calma / Silencio',
                      subtitulo:
                          'Resalta áreas con sombra natural al 100%, poco ruido (<35 dB) y bajo flujo de personas para autorregulación sensorial (TEA y neurodivergencia).',
                      icono: Icons.spa_rounded,
                      colorIcono: const Color(0xFF10B981),
                      activo: a11y.mostrarZonasCalma,
                      onChanged: (val) {
                        HapticFeedback.mediumImpact();
                        SoundService.instance.playButtonTap();
                        a11y.setMostrarZonasCalma(val);
                      },
                    ),

                    const SizedBox(height: 12),

                    // LISTADO DE LAS 4 ZONAS DE CALMA
                    Text(
                      'Puntos de Autorregulación Sensorial en el Parque:',
                      style: GoogleFonts.urbanist(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: textoColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ..._zonasCalma.map((zona) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: oscuro
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.6),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.spa_rounded,
                                color: Color(0xFF10B981),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    zona.nombre,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: textoColor,
                                    ),
                                  ),
                                  Text(
                                    '${zona.nivelRuido ?? "Silencioso"} · 100% Sombra',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                  if (zona.descripcionCalma != null)
                                    Text(
                                      zona.descripcionCalma!,
                                      style: GoogleFonts.urbanist(
                                        fontSize: 11,
                                        color: subtituloColor,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onSeleccionarZonaCalma?.call(zona);
                              },
                              icon: const Icon(Icons.explore_rounded, size: 14),
                              label: Text(
                                'Ir',
                                style: GoogleFonts.urbanist(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTarjetaOpcion({
    required bool oscuro,
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Color colorIcono,
    required bool activo,
    required ValueChanged<bool> onChanged,
  }) {
    final Color textoColor = oscuro ? Colors.white : const Color(0xFF0F172A);
    final Color subtituloColor =
        oscuro ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: oscuro ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: activo
              ? colorIcono
              : (oscuro ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: activo ? 1.8 : 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorIcono.withValues(alpha: activo ? 0.25 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: colorIcono, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.urbanist(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: textoColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitulo,
                  style: GoogleFonts.urbanist(
                    fontSize: 11.5,
                    color: subtituloColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: activo,
            activeTrackColor: colorIcono,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeZona({
    required String simbolo,
    required String nombre,
    required Color color,
    required bool oscuro,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: oscuro ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            simbolo,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            nombre,
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: oscuro ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
