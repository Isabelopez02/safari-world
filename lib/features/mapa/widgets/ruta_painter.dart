import 'package:flutter/material.dart';

class RutaPainter extends CustomPainter {
  final List<Offset> ruta;
  final Path? rutaSvg;
  final bool isNavigating;
  final double progress; // 0.0 to 1.0 para dibujo progresivo

  RutaPainter(
    this.ruta,
    this.isNavigating, {
    this.rutaSvg,
    this.progress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if ((ruta.isEmpty && rutaSvg == null) || progress <= 0.0) return;

    // Pintura del fondo o sombra de la línea para contraste sobre el mapa
    final paintBorde = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = isNavigating ? 10.0 : 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintPista = Paint()
      ..color = isNavigating
          ? const Color(0xFF0E6568) // Verde azulado safari activo
          : const Color(0xFFE65100) // Naranja safari notorio
      ..strokeWidth = isNavigating ? 7.0 : 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path pathParaDibujar;
    if (rutaSvg != null) {
      pathParaDibujar = rutaSvg!;
    } else {
      pathParaDibujar = Path();
      pathParaDibujar.moveTo(ruta[0].dx, ruta[0].dy);
      for (int i = 1; i < ruta.length; i++) {
        pathParaDibujar.lineTo(ruta[i].dx, ruta[i].dy);
      }
    }

    // Dibujar progresivamente
    _drawDashedProgressive(canvas, pathParaDibujar, paintBorde, progress, isBorder: true);
    _drawDashedProgressive(canvas, pathParaDibujar, paintPista, progress, isBorder: false);
  }

  void _drawDashedProgressive(
    Canvas canvas,
    Path path,
    Paint paint,
    double progress, {
    required bool isBorder,
  }) {
    for (var measurePath in path.computeMetrics()) {
      final totalLength = measurePath.length;
      final currentLength = totalLength * progress;

      double distance = 0.0;
      while (distance < currentLength) {
        final double nextDistance = (distance + 14.0) > currentLength
            ? currentLength
            : (distance + 14.0);
        canvas.drawPath(measurePath.extractPath(distance, nextDistance), paint);
        distance += 24.0; // 14 dibujado + 10 espacio
      }
    }
  }

  @override
  bool shouldRepaint(covariant RutaPainter oldDelegate) =>
      oldDelegate.ruta != ruta ||
      oldDelegate.rutaSvg != rutaSvg ||
      oldDelegate.isNavigating != isNavigating ||
      oldDelegate.progress != progress;
}
