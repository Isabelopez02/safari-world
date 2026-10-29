import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Barra superior simplificada y despejada (Regresar, Guía y Emergencia SOS)
class BarraSuperiorMapa extends StatelessWidget {
  final VoidCallback onRegresar;
  final VoidCallback onSOS;
  final int tutorialStep;
  final VoidCallback onToggleGuia;
  final GlobalKey keyComoFunciona;
  final GlobalKey? keyHelp;

  const BarraSuperiorMapa({
    super.key,
    required this.onRegresar,
    required this.onSOS,
    required this.tutorialStep,
    required this.onToggleGuia,
    required this.keyComoFunciona,
    this.keyHelp,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        child: Row(
          children: [
            // BOTÓN REGRESAR CON EFECTO CRISTAL ELEVADO
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onRegresar();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFCBD5E1),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 14,
                          color: AppColors.verdeAzulado,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Regresar',
                          style: GoogleFonts.urbanist(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // BOTÓN GUÍA RÁPIDA CON CRISTAL
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: GestureDetector(
                  key: keyComoFunciona,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    SoundService.instance.playButtonTap();
                    onToggleGuia();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: tutorialStep > 0
                          ? const Color(0xFFF59E0B)
                          : Colors.white.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: tutorialStep > 0
                            ? const Color(0xFFD97706)
                            : const Color(0xFFCBD5E1),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb_rounded,
                          size: 16,
                          color: tutorialStep > 0
                              ? Colors.white
                              : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          tutorialStep > 0 ? 'Cerrar Guía' : 'Guía',
                          style: GoogleFonts.urbanist(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: tutorialStep > 0
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // BOTÓN EMERGENCIA SOS INTEGRADO EN CABECERA (Despeja el mapa)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: GestureDetector(
                  key: keyHelp,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    SoundService.instance.playButtonTap();
                    onSOS();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626), // Rojo emergencia nítido
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.phone_in_talk_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'SOS',
                          style: GoogleFonts.urbanist(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
