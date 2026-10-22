import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/recorrido_animado_svg.dart';

/// Pantalla interactiva con InteractiveViewer para verificar visualmente
/// que los trazos de assets/images/trazo.svg calzan exactamente sobre el mapa.
class PantallaVerificacionTrazo extends StatefulWidget {
  const PantallaVerificacionTrazo({super.key});

  @override
  State<PantallaVerificacionTrazo> createState() =>
      _PantallaVerificacionTrazoState();
}

class _PantallaVerificacionTrazoState extends State<PantallaVerificacionTrazo> {
  String _svgCompleto = '';
  bool _cargando = true;
  String _posicionTexto = 'Iniciando...';

  // Ejemplo de un trazo curvo específico de trazo.svg (Camino hacia la zona oeste)
  static const String trazoEjemploOeste =
      'M885.709,667.783C885.709,667.783 814.017,685.338 799.724,690.678'
      'C784.969,696.191 747.185,731.376 724.557,737.197'
      'C696.972,744.292 615.077,734.95 610.691,731.409'
      'C610.691,731.409 567.312,690.512 567.196,628.788'
      'C567.094,574.777 616.81,511.365 616.81,511.365';

  bool _mostrarTodosLosTrazos = false;

  @override
  void initState() {
    super.initState();
    _cargarSvgDesdeAssets();
  }

  Future<void> _cargarSvgDesdeAssets() async {
    try {
      final contenido =
          await rootBundle.loadString('assets/images/trazo_mapa.svg');
      if (mounted) {
        setState(() {
          _svgCompleto = contenido;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pathData = _mostrarTodosLosTrazos && _svgCompleto.isNotEmpty
        ? _svgCompleto
        : trazoEjemploOeste;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación Visual de Trazo'),
        backgroundColor: const Color(0xFF2D5A27),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: _mostrarTodosLosTrazos
                ? 'Ver ruta específica animada'
                : 'Ver todos los trazos de trazo.svg',
            icon: Icon(
              _mostrarTodosLosTrazos ? Icons.route : Icons.alt_route,
            ),
            onPressed: () {
              setState(() {
                _mostrarTodosLosTrazos = !_mostrarTodosLosTrazos;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mapa interactivo con soporte de Zoom y Paneo
          InteractiveViewer(
            minScale: 0.2,
            maxScale: 4.0,
            boundaryMargin: const EdgeInsets.all(500),
            constrained: false,
            child: RecorridoAnimadoSvg(
              key: ValueKey(_mostrarTodosLosTrazos),
              svgPathData: pathData,
              esSvgCompleto: _mostrarTodosLosTrazos,
              mapaAncho: 1920,
              mapaAlto: 1080,
              duracion: const Duration(seconds: 5),
              repetirEnBucle: true,
              incluirImagenMapa: true,
              onPosicionActualizada: (pos) {
                setState(() {
                  _posicionTexto =
                      'X: ${pos.dx.toStringAsFixed(1)} | Y: ${pos.dy.toStringAsFixed(1)}';
                });
              },
            ),
          ),

          // Indicador HUD flotante con las coordenadas en tiempo real
          Positioned(
            left: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Posición Marcador: $_posicionTexto\nModo: ${_mostrarTodosLosTrazos ? "Todos los caminos" : "Ruta individual animada"}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
