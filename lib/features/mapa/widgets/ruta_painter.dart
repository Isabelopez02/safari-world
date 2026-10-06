import 'dart:ui';

import 'package:flutter/material.dart';

class RutaPainter extends CustomPainter {
  final List<Offset> ruta;
  final bool isNavigating;

  RutaPainter(this.ruta, this.isNavigating);

  @override
  void paint(Canvas canvas, Size size) {
    if (ruta.isEmpty) return;

    final paintPista = Paint()
      ..color = isNavigating ? Colors.blueAccent : Colors.white
      ..strokeWidth = isNavigating ? 8.0 : 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pathPista = Path();
    pathPista.moveTo(ruta[0].dx, ruta[0].dy);

    for (int i = 1; i < ruta.length; i++) {
      pathPista.lineTo(ruta[i].dx, ruta[i].dy);
    }

    _drawDashed(canvas, pathPista, paintPista);
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    for (var measurePath in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < measurePath.length) {
        final double nextDistance = distance + 12.0;
        canvas.drawPath(measurePath.extractPath(distance, nextDistance), paint);
        distance = nextDistance + 12.0;
      }
    }
  }

  @override
  bool shouldRepaint(covariant RutaPainter oldDelegate) => true;
}
