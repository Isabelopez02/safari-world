import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

class TutorialOverlay extends StatelessWidget {
  final Rect targetRect;
  final String text;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onSkip;
  final int step;
  final int totalSteps;

  const TutorialOverlay({
    super.key,
    required this.targetRect,
    required this.text,
    required this.onNext,
    required this.onPrev,
    required this.onSkip,
    required this.step,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isTargetInTopHalf =
        targetRect != Rect.zero &&
        targetRect.center.dy < (screenSize.height / 2);

    return GestureDetector(
      onTap: () {}, // Bloquea clics accidentales detrás
      child: Stack(
        children: [
          // 1. MÁSCARA OSCURA CON RECORTE Y ANILLO LUMINOSO
          CustomPaint(
            size: screenSize,
            painter: HolePainter(holeRect: targetRect),
          ),

          // 2. FLECHA ORGÁNICA DIRIGIDA AL OBJETIVO
          CustomPaint(
            size: screenSize,
            painter: ArrowPainter(targetRect: targetRect, step: step),
          ),

          // 3. TARJETA MODERNA DE TUTORIAL (SAFARI GUIDE CARD)
          // Se posiciona inteligentemente arriba o abajo según la posición del objetivo
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: isTargetInTopHalf ? null : (screenSize.height * 0.18),
            bottom: isTargetInTopHalf ? (screenSize.height * 0.14) : null,
            left: 20,
            right: 20,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.verdeAzulado.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ENCABEZADO CON BADGE SAFARI
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.verdeAzulado.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.explore_rounded,
                                  size: 15,
                                  color: AppColors.verdeAzulado,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'GUÍA DE SAFARI · PASO $step DE $totalSteps',
                                  style: GoogleFonts.urbanist(
                                    color: AppColors.verdeAzulado,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (step < totalSteps)
                            TextButton(
                              onPressed: () {
                                SoundService.instance.playButtonTap();
                                onSkip();
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Saltar',
                                style: GoogleFonts.urbanist(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // TEXTO EXPLICATIVO
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.urbanist(
                          color: AppColors.textoOscuro,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // BARRA DE PROGRESO Y BOTONES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botón Anterior
                          if (step > 1)
                            OutlinedButton.icon(
                              onPressed: () {
                                SoundService.instance.playButtonTap();
                                onPrev();
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 13,
                              ),
                              label: Text(
                                'Atrás',
                                style: GoogleFonts.urbanist(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.verdePrincipal,
                                side: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.3),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 80),

                          // Indicador de pasos con puntitos
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(totalSteps, (index) {
                              final isActive = (step == index + 1);
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: isActive ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: isActive
                                      ? AppColors.verdeAzulado
                                      : Colors.grey.withValues(alpha: 0.3),
                                ),
                              );
                            }),
                          ),

                          // Botón Siguiente / Empezar
                          ElevatedButton(
                            onPressed: () {
                              SoundService.instance.playButtonTap();
                              onNext();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.verdeAzulado,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  step == totalSteps ? '¡Listo!' : 'Siguiente',
                                  style: GoogleFonts.urbanist(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  step == totalSteps
                                      ? Icons.check_circle_rounded
                                      : Icons.arrow_forward_ios_rounded,
                                  size: 13,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HolePainter extends CustomPainter {
  final Rect holeRect;
  HolePainter({required this.holeRect});

  @override
  void paint(Canvas canvas, Size size) {
    if (holeRect == Rect.zero) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.black.withValues(alpha: 0.65),
      );
      return;
    }

    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRRect(
        RRect.fromRectAndRadius(
          holeRect.inflate(10),
          const Radius.circular(24),
        ),
      ),
    );
    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.65),
    );

    // Borde brillante suave alrededor del elemento enfocado
    final borderPaint = Paint()
      ..color = AppColors.verdeAzulado
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(holeRect.inflate(10), const Radius.circular(24)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant HolePainter oldDelegate) =>
      oldDelegate.holeRect != holeRect;
}

class ArrowPainter extends CustomPainter {
  final Rect targetRect;
  final int step;

  ArrowPainter({required this.targetRect, required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    if (targetRect == Rect.zero) return;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);

    if (step == 1) {
      // Bottom bar
      path.moveTo(center.dx, center.dy + 40);
      path.quadraticBezierTo(
        center.dx,
        targetRect.top - 30,
        targetRect.center.dx,
        targetRect.top - 6,
      );
    } else if (step == 2 || step == 3 || step == 5) {
      // FABs a la derecha
      path.moveTo(center.dx, targetRect.center.dy);
      path.quadraticBezierTo(
        center.dx + 40,
        targetRect.center.dy,
        targetRect.left - 8,
        targetRect.center.dy,
      );
    } else if (step == 4) {
      // Top bar
      path.moveTo(center.dx, center.dy - 60);
      path.quadraticBezierTo(
        startAndEnd(center.dx, targetRect.center.dx),
        targetRect.bottom + 40,
        targetRect.center.dx,
        targetRect.bottom + 8,
      );
    }

    for (PathMetric measurePath in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < measurePath.length) {
        final double nextDistance = distance + 7.0;
        canvas.drawPath(measurePath.extractPath(distance, nextDistance), paint);
        distance = nextDistance + 6.0;
      }

      final tangent = measurePath.getTangentForOffset(measurePath.length);
      if (tangent != null) {
        final arrowPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.translate(tangent.position.dx, tangent.position.dy);
        canvas.rotate(tangent.angle);

        final arrowPath = Path();
        arrowPath.moveTo(0, 0);
        arrowPath.lineTo(-12, -6);
        arrowPath.quadraticBezierTo(-8, 0, -12, 6);
        arrowPath.close();

        canvas.drawPath(arrowPath, arrowPaint);
        canvas.restore();
      }
    }
  }

  double startAndEnd(double a, double b) => (a + b) / 2;

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) =>
      oldDelegate.step != step;
}
