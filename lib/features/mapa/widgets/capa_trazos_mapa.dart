import 'package:flutter/material.dart';
import 'ruta_painter.dart';

/// Componente visual reutilizable para renderizar los trazos vectoriales del zoológico
/// sobre el mapa interactivo.
///
/// Encapsula:
/// 1. El dibujo progresivo y punteado de la ruta activa en curvas reales SVG.
/// 2. El marcador guía de navegación animado que se traslada dinámicamente por la curva.
/// 3. Opcionalmente, la red completa de trazos de caminos del parque como guía visual.
class CapaTrazosMapa extends StatelessWidget {
  /// Ruta calculada en coordenadas discretas (fallback de compatibilidad)
  final List<Offset> rutaCoordenadas;

  /// Trazo curvo vectorial SVG activo hacia el animal o baño
  final Path? rutaSvg;

  /// Progreso de animación del trazado (0.0 a 1.0)
  final double progreso;

  /// Indica si hay una navegación en curso (modifica colores a verde safari o naranja)
  final bool estaNavegando;

  /// Si es true, dibuja suavemente todos los caminos del SVG en el mapa
  final bool mostrarTodosLosTrazos;

  /// Path precompilado con la totalidad de los senderos del zoológico
  final Path? todosLosTrazosPath;

  const CapaTrazosMapa({
    super.key,
    required this.progreso,
    this.rutaCoordenadas = const [],
    this.rutaSvg,
    this.estaNavegando = false,
    this.mostrarTodosLosTrazos = false,
    this.todosLosTrazosPath,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Trazos base de toda la red de caminos (opcional para verificación visual)
        if (mostrarTodosLosTrazos && todosLosTrazosPath != null)
          Positioned.fill(
            child: CustomPaint(
              painter: _TrazosBasePainter(todosLosTrazosPath!),
            ),
          ),

        // 2. Trazo animado de la ruta activa hacia el destino seleccionado
        Positioned.fill(
          child: CustomPaint(
            painter: RutaPainter(
              rutaCoordenadas,
              estaNavegando,
              rutaSvg: rutaSvg,
              progress: progreso,
            ),
          ),
        ),

        // 3. Marcador guía animado que se desplaza exactamente sobre la curva SVG (solo durante navegación activa)
        if (estaNavegando && rutaSvg != null && progreso > 0.0)
          _buildMarcadorGuiaAnimado(),
      ],
    );
  }

  Widget _buildMarcadorGuiaAnimado() {
    final metrics = rutaSvg!.computeMetrics().toList();
    if (metrics.isEmpty) return const SizedBox.shrink();

    final totalLength = metrics.fold(0.0, (acc, m) => acc + m.length);
    final targetDist = progreso * totalLength;

    Offset puntoGuia = Offset.zero;
    double distAcumulada = 0.0;
    for (final metric in metrics) {
      if (targetDist <= distAcumulada + metric.length) {
        final localDist = targetDist - distAcumulada;
        puntoGuia =
            metric.getTangentForOffset(localDist)?.position ?? Offset.zero;
        break;
      }
      distAcumulada += metric.length;
    }

    if (puntoGuia == Offset.zero && metrics.isNotEmpty) {
      puntoGuia =
          metrics.last.getTangentForOffset(metrics.last.length)?.position ??
          Offset.zero;
    }

    return Positioned(
      left: puntoGuia.dx - 16,
      top: puntoGuia.dy - 30,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: estaNavegando
              ? const Color(0xFF0E6568)
              : const Color(0xFFE65100),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.navigation_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

/// Painter para dibujar suavemente todos los caminos del zoológico
class _TrazosBasePainter extends CustomPainter {
  final Path path;

  _TrazosBasePainter(this.path);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x334CAF50)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrazosBasePainter oldDelegate) =>
      oldDelegate.path != path;
}
