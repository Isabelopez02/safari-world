import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

class TutorialOverlay extends StatelessWidget {
  final Rect targetRect;
  final String text;
  final VoidCallback onNext;
  final int step;

  const TutorialOverlay({
    super.key,
    required this.targetRect,
    required this.text,
    required this.onNext,
    required this.step,
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
            top: MediaQuery.of(context).size.height / 2 - 60,
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
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdeAzulado,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Entendido',
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
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
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2 + 50);

    if (step == 1) {
      path.moveTo(center.dx, center.dy);
      path.quadraticBezierTo(
        center.dx,
        targetRect.top - 40,
        targetRect.center.dx,
        targetRect.top - 10,
      );
    } else if (step == 2) {
      path.moveTo(center.dx, center.dy);
      path.quadraticBezierTo(
        center.dx,
        targetRect.top - 40,
        targetRect.left - 10,
        targetRect.center.dy,
      );
    } else if (step == 3) {
      path.moveTo(center.dx, center.dy);
      path.quadraticBezierTo(
        center.dx + 40,
        center.dy + 40,
        targetRect.left - 10,
        targetRect.center.dy,
      );
    } else if (step == 4) {
      final start = Offset(size.width / 2, size.height / 2 - 80);
      path.moveTo(start.dx, start.dy);
      path.quadraticBezierTo(
        start.dx + 60,
        targetRect.bottom + 40,
        targetRect.center.dx,
        targetRect.bottom + 10,
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
