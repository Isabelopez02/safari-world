import 'package:flutter/material.dart';

/// CustomPainter que dibuja un [Path] curvo proveniente de un SVG
/// con color rojo semitransparente y grosor de 4px para superponer
/// sobre la imagen del mapa y verificar visualmente que calza con exactitud.
class RutaSvgPainter extends CustomPainter {
  final Path path;
  final Color color;
  final double grosor;

  RutaSvgPainter({
    required this.path,
    this.color = const Color(0x80FF0000), // Rojo semitransparente (50% opacidad)
    this.grosor = 4.0, // Grosor solicitado de 4px
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant RutaSvgPainter oldDelegate) {
    return oldDelegate.path != path ||
        oldDelegate.color != color ||
        oldDelegate.grosor != grosor;
  }
}
