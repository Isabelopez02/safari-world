import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import 'ruta_svg_painter.dart';

/// Widget que procesa trazos SVG y anima un marcador (icono) a lo largo
/// de la curva en tiempo real utilizando PathMetrics y getTangentForOffset.
class RecorridoAnimadoSvg extends StatefulWidget {
  /// String del atributo `d="..."` del path SVG, o contenido completo del archivo .svg
  final String svgPathData;

  /// Si es true, buscará todas las etiquetas `<path d="..." />` dentro del contenido SVG completo
  final bool esSvgCompleto;

  /// Dimensiones del mapa sobre el que se dibuja el trazo (por defecto 1920x1080)
  final double mapaAncho;
  final double mapaAlto;

  /// Duración del recorrido de inicio a fin
  final Duration duracion;

  /// Si la animación debe repetirse en bucle
  final bool repetirEnBucle;

  /// Si se debe incluir la imagen de fondo del mapa automáticamente
  final bool incluirImagenMapa;

  /// Widget personalizado para el marcador (por defecto Icon(Icons.location_on))
  final Widget? marcadorWidget;

  /// Tamaño visual del marcador (usado para centrar y alinear la punta)
  final double marcadorTamano;

  /// Callback opcional que notifica la posición actual (x, y) en cada fotograma
  final ValueChanged<Offset>? onPosicionActualizada;

  const RecorridoAnimadoSvg({
    super.key,
    required this.svgPathData,
    this.esSvgCompleto = false,
    this.mapaAncho = 1920.0,
    this.mapaAlto = 1080.0,
    this.duracion = const Duration(seconds: 4),
    this.repetirEnBucle = true,
    this.incluirImagenMapa = true,
    this.marcadorWidget,
    this.marcadorTamano = 40.0,
    this.onPosicionActualizada,
  });

  /// Utilidad para extraer todos los atributos d="..." de un archivo SVG completo
  /// y unificarlos en un solo objeto Path.
  static Path parsearSvgCompleto(String contenidoSvg) {
    final exp = RegExp(r'd="([^"]+)"');
    final matches = exp.allMatches(contenidoSvg);
    final combinedPath = Path();

    for (final match in matches) {
      final d = match.group(1);
      if (d != null && d.isNotEmpty) {
        try {
          final subPath = parseSvgPathData(d);
          combinedPath.addPath(subPath, Offset.zero);
        } catch (_) {
          // Ignorar trazos con sintaxis no compatible
        }
      }
    }
    return combinedPath;
  }

  @override
  State<RecorridoAnimadoSvg> createState() => _RecorridoAnimadoSvgState();
}

class _RecorridoAnimadoSvgState extends State<RecorridoAnimadoSvg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Path _path;
  late List<PathMetric> _metrics;
  double _longitudTotal = 0.0;

  // Coordenada (x, y) actual del marcador
  Offset _posicionActual = Offset.zero;

  @override
  void initState() {
    super.initState();

    // 1. Convertir el string SVG en objeto Path mediante path_drawing
    if (widget.esSvgCompleto) {
      _path = RecorridoAnimadoSvg.parsearSvgCompleto(widget.svgPathData);
    } else {
      _path = parseSvgPathData(widget.svgPathData);
    }

    // 2. Extraer PathMetrics y calcular la longitud total de la ruta
    _metrics = _path.computeMetrics().toList();
    _longitudTotal = _metrics.fold(0.0, (acc, m) => acc + m.length);

    // 3. Inicializar posición inicial (distancia 0)
    _posicionActual = _calcularPuntoEnDistancia(0.0);

    // 4. Implementar animación con AnimationController y Tween de 0.0 a 1.0
    _controller = AnimationController(
      vsync: this,
      duration: widget.duracion,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // 5. En cada frame, calcular la distancia recorrida y obtener (x, y) con getTangentForOffset
    _controller.addListener(() {
      final distanciaActual = _animation.value * _longitudTotal;
      final nuevoPunto = _calcularPuntoEnDistancia(distanciaActual);

      if (mounted) {
        setState(() {
          _posicionActual = nuevoPunto;
        });
        widget.onPosicionActualizada?.call(nuevoPunto);
      }
    });

    if (widget.repetirEnBucle) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  /// Calcula la coordenada exacta (x, y) recorriendo las métricas del Path
  Offset _calcularPuntoEnDistancia(double distancia) {
    if (_metrics.isEmpty || _longitudTotal == 0) return Offset.zero;

    double distanciaAcumulada = 0.0;
    for (final metric in _metrics) {
      if (distancia <= distanciaAcumulada + metric.length) {
        final distanciaLocal = distancia - distanciaAcumulada;
        final tangent = metric.getTangentForOffset(distanciaLocal);
        return tangent?.position ?? Offset.zero;
      }
      distanciaAcumulada += metric.length;
    }

    // Si la distancia alcanza o supera el final, retornar la posición terminal
    final ultimoTangent = _metrics.last.getTangentForOffset(_metrics.last.length);
    return ultimoTangent?.position ?? Offset.zero;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.mapaAncho,
      height: widget.mapaAlto,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Imagen del mapa si está habilitada
          if (widget.incluirImagenMapa)
            Positioned.fill(
              child: Image.asset(
                'assets/images/mapa_zoologico.png',
                width: widget.mapaAncho,
                height: widget.mapaAlto,
                fit: BoxFit.fill,
              ),
            ),

          // 2. CustomPainter que dibuja el Path en rojo semitransparente con 4px de grosor
          Positioned.fill(
            child: CustomPaint(
              painter: RutaSvgPainter(
                path: _path,
                color: const Color(0x80FF0000), // Rojo semitransparente
                grosor: 4.0, // 4px de grosor
              ),
            ),
          ),

          // 3. Marcador animado envuelto en Positioned que viaja sobre la ruta
          Positioned(
            left: _posicionActual.dx - (widget.marcadorTamano / 2),
            top: _posicionActual.dy - widget.marcadorTamano,
            child: widget.marcadorWidget ??
                Icon(
                  Icons.location_on,
                  size: widget.marcadorTamano,
                  color: Colors.redAccent,
                  shadows: const [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}
