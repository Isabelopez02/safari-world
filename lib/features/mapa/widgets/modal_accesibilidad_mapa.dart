import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';

/// Modal de Accesibilidad rediseñado: visual, compacto e intuitivo.
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
        final Color fondo =
            oscuro ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
        final Color superficie =
            oscuro ? const Color(0xFF1E293B) : Colors.white;
        final Color textoColor =
            oscuro ? Colors.white : const Color(0xFF0F172A);
        final Color subtituloColor =
            oscuro ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.78,
          ),
          decoration: BoxDecoration(
            color: fondo,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: oscuro
                  ? const Color(0xFFFDE047)
                  : const Color(0xFFE2E8F0),
              width: oscuro ? 2.0 : 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // MANIJA
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: oscuro ? Colors.white30 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // CABECERA
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: oscuro
                            ? const Color(0xFFFDE047)
                            : const Color(0xFF0E6568).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.accessibility_new_rounded,
                        color: oscuro ? Colors.black : const Color(0xFF0E6568),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Accesibilidad',
                          style: GoogleFonts.urbanist(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: textoColor,
                          ),
                        ),
                        Text(
                          'Adapta el mapa a tus necesidades',
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            color: subtituloColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: oscuro
                              ? Colors.white12
                              : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: subtituloColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: oscuro ? Colors.white12 : Colors.grey.shade200),

              // CONTENIDO SCROLLABLE
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    // ─────────────── SECCIÓN 1: OPCIONES VISUALES ───────────────
                    _buildSectionLabel('Visión', Icons.remove_red_eye_rounded,
                        textoColor),
                    const SizedBox(height: 10),

                    // TARJETA: ALTO CONTRASTE & DALTONISMO
                    _buildOpcionCard(
                      oscuro: oscuro,
                      superficie: superficie,
                      textoColor: textoColor,
                      subtituloColor: subtituloColor,
                      activo: a11y.accesibilidadVisualActiva,
                      icono: Icons.contrast_rounded,
                      colorIcono: const Color(0xFFFDE047),
                      titulo: 'Daltonismo',
                      descripcion:
                          'Cambia colores por formas y símbolos únicos por zona',
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        SoundService.instance.playButtonTap();
                        a11y.toggleAltoContrasteYDaltonismo();
                      },
                    ),

                    // LEYENDA DE SÍMBOLOS (solo si activo)
                    if (a11y.accesibilidadVisualActiva) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: oscuro
                              ? Colors.black
                              : const Color(0xFFFFFBE6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFFDE047),
                            width: 1.4,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 14,
                                  color: Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Símbolos por zona',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: oscuro
                                        ? Colors.white
                                        : const Color(0xFF78350F),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSimboloZona(
                                    '▲', 'Intl.',
                                    const Color(0xFFFDE047), oscuro),
                                _buildSimboloZona(
                                    '≈', 'Costa',
                                    const Color(0xFF38BDF8), oscuro),
                                _buildSimboloZona(
                                    '▲▲', 'Sierra',
                                    Colors.white70, oscuro),
                                _buildSimboloZona(
                                    '♣', 'Selva',
                                    const Color(0xFF4ADE80), oscuro),
                                _buildSimboloZona(
                                    '★', 'Granja',
                                    const Color(0xFFE879F9), oscuro),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ─────────────── SECCIÓN 2: ZONAS DE CALMA ───────────────
                    _buildSectionLabel(
                        'Zonas de Descanso', Icons.spa_rounded, textoColor),
                    const SizedBox(height: 10),

                    // TARJETA: MOSTRAR ZONAS DE CALMA
                    _buildOpcionCard(
                      oscuro: oscuro,
                      superficie: superficie,
                      textoColor: textoColor,
                      subtituloColor: subtituloColor,
                      activo: a11y.mostrarZonasCalma,
                      icono: Icons.spa_rounded,
                      colorIcono: const Color(0xFF10B981),
                      titulo: 'Zonas de Calma',
                      descripcion:
                          'Muestra áreas tranquilas, con sombra y poco ruido',
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        SoundService.instance.playButtonTap();
                        a11y.setMostrarZonasCalma(!a11y.mostrarZonasCalma);
                      },
                    ),

                    const SizedBox(height: 12),

                    // LISTADO COMPACTO DE ZONAS DE CALMA
                    ..._zonasCalma.map((zona) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: superficie,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.5),
                            width: 1.2,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF10B981).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              zona.icono,
                              color: const Color(0xFF10B981),
                              size: 18,
                            ),
                          ),
                          title: Text(
                            zona.nombre,
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textoColor,
                            ),
                          ),
                          subtitle: zona.nivelRuido != null
                              ? Text(
                                  '🔇 ${zona.nivelRuido}  🌿 Sombra natural',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 11,
                                    color: const Color(0xFF10B981),
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : null,
                          trailing: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              widget.onSeleccionarZonaCalma?.call(zona);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Ir →',
                                style: GoogleFonts.urbanist(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
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

  Widget _buildSectionLabel(
      String label, IconData icono, Color textoColor) {
    return Row(
      children: [
        Icon(icono, size: 15, color: textoColor.withValues(alpha: 0.5)),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.urbanist(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: textoColor.withValues(alpha: 0.45),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  /// Tarjeta de opción tipo "toggle visual" – toque en toda la tarjeta activa/desactiva
  Widget _buildOpcionCard({
    required bool oscuro,
    required Color superficie,
    required Color textoColor,
    required Color subtituloColor,
    required bool activo,
    required IconData icono,
    required Color colorIcono,
    required String titulo,
    required String descripcion,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: activo
              ? colorIcono.withValues(alpha: oscuro ? 0.18 : 0.1)
              : superficie,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: activo ? colorIcono : (oscuro ? Colors.white12 : Colors.grey.shade200),
            width: activo ? 2.0 : 1.2,
          ),
          boxShadow: activo
              ? [
                  BoxShadow(
                    color: colorIcono.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // ICONO GRANDE
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: activo
                    ? colorIcono
                    : colorIcono.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icono,
                color: activo ? Colors.white : colorIcono,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // TEXTO
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
                  const SizedBox(height: 2),
                  Text(
                    descripcion,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: subtituloColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // INDICADOR ON/OFF
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: activo ? colorIcono : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: activo ? colorIcono : subtituloColor.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Text(
                activo ? 'ON' : 'OFF',
                style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: activo ? Colors.white : subtituloColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimboloZona(
      String simbolo, String nombre, Color color, bool oscuro) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: oscuro ? 0.2 : 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            simbolo,
            style: TextStyle(
              fontSize: simbolo.length > 1 ? 9 : 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          nombre,
          style: GoogleFonts.urbanist(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: oscuro ? Colors.white70 : const Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}
