import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return GestureDetector(
      onTap: () {},
      child: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: HolePainter(holeRect: targetRect),
          ),
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: ArrowPainter(targetRect: targetRect, step: step),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 80,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (step > 1)
                      TextButton(
                        onPressed: onPrev,
                        child: Text(
                          'Anterior',
                          style: GoogleFonts.urbanist(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 80),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(totalSteps, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: step == index + 1
                                ? AppColors.verdeAzulado
                                : Colors.white38,
                          ),
                        );
                      }),
                    ),

                    ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verdeAzulado,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        step == totalSteps ? 'Finalizar' : 'Siguiente',
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (step < totalSteps)
                  TextButton(
                    onPressed: onSkip,
                    child: Text(
                      'Saltar tutorial',
                      style: GoogleFonts.urbanist(
                        color: Colors.white54,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
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
        Paint()..color = Colors.black.withValues(alpha: 0.75),
      );
      return;
    }

    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRRect(
        RRect.fromRectAndRadius(
          holeRect.inflate(12),
          const Radius.circular(30),
        ),
      ),
    );
    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.75),
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
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2 + 30);

    if (step == 1) {
      // Bottom bar
      path.moveTo(center.dx, center.dy);
      path.quadraticBezierTo(
        center.dx,
        targetRect.top - 40,
        targetRect.center.dx,
        targetRect.top - 10,
      );
    } else if (step == 2) {
      // Search
      path.moveTo(center.dx, center.dy);
      path.quadraticBezierTo(
        center.dx + 40,
        targetRect.top - 40,
        targetRect.left - 10,
        targetRect.center.dy,
      );
    } else if (step == 3) {
      // Help
      path.moveTo(center.dx, center.dy);
      path.quadraticBezierTo(
        center.dx + 40,
        center.dy + 40,
        targetRect.left - 10,
        targetRect.center.dy,
      );
    } else if (step == 4) {
      // Como funciona
      final start = Offset(size.width / 2, size.height / 2 - 100);
      path.moveTo(start.dx, start.dy);
      path.quadraticBezierTo(
        start.dx + 60,
        targetRect.bottom + 40,
        targetRect.center.dx,
        targetRect.bottom + 10,
      );
    } else if (step == 5) {
      // FAB (Mi ubicación)
      path.moveTo(center.dx, center.dy);
      path.quadraticBezierTo(
        center.dx - 40,
        targetRect.top - 40,
        targetRect.center.dx,
        targetRect.top - 10,
      );
    }

    for (PathMetric measurePath in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < measurePath.length) {
        final double nextDistance = distance + 8.0;
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
        arrowPath.lineTo(-14, -8);
        arrowPath.quadraticBezierTo(-10, 0, -14, 8);
        arrowPath.close();

        canvas.drawPath(arrowPath, arrowPaint);

        final splashPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          const Offset(6, -6),
          const Offset(12, -10),
          splashPaint,
        );
        canvas.drawLine(const Offset(8, 0), const Offset(14, 0), splashPaint);
        canvas.drawLine(const Offset(6, 6), const Offset(12, 10), splashPaint);

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) =>
      oldDelegate.step != step;
}
