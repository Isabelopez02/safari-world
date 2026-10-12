import 'package:flutter/material.dart';

class RutaPainter extends CustomPainter {
  final List<Offset> ruta;
  final bool isNavigating;
  final double progress; // 0.0 to 1.0 para dibujo progresivo

  RutaPainter(this.ruta, this.isNavigating, {this.progress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    if (ruta.isEmpty || progress == 0.0) return;

    final paintPista = Paint()
      ..color = isNavigating
          ? const Color(0xFF0E6568)
          : Colors
                .white // amarilloMostaza
      ..strokeWidth = isNavigating ? 8.0 : 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pathPista = Path();
    pathPista.moveTo(ruta[0].dx, ruta[0].dy);

    for (int i = 1; i < ruta.length; i++) {
      pathPista.lineTo(ruta[i].dx, ruta[i].dy);
    }

    // Dibujar progresivamente
    _drawDashedProgressive(canvas, pathPista, paintPista, progress);
  }

  void _drawDashedProgressive(
    Canvas canvas,
    Path path,
    Paint paint,
    double progress,
  ) {
    for (var measurePath in path.computeMetrics()) {
      final totalLength = measurePath.length;
      final currentLength = totalLength * progress;

      double distance = 0.0;
      while (distance < currentLength) {
        final double nextDistance = (distance + 12.0) > currentLength
            ? currentLength
            : (distance + 12.0);
        canvas.drawPath(measurePath.extractPath(distance, nextDistance), paint);
        distance += 24.0; // 12 dibujado + 12 espacio
      }
    }
  }

  @override
  bool shouldRepaint(covariant RutaPainter oldDelegate) =>
      oldDelegate.ruta != ruta ||
      oldDelegate.isNavigating != isNavigating ||
      oldDelegate.progress != progress;
}
