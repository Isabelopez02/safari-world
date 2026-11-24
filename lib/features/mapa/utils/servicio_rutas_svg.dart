import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';

import '../data/datos_trazos_svg.dart';

export '../data/datos_trazos_svg.dart' show SegmentoTrazoSvg;

/// Alias de compatibilidad
typedef SegmentoCurvoSvg = SegmentoTrazoSvg;

/// Arista dirigida en el grafo de senderos SVG
class AristaSvg {
  final int desde;
  final int hasta;
  final SegmentoTrazoSvg segmento;
  final bool invertido;
  final double peso;

  AristaSvg({
    required this.desde,
    required this.hasta,
    required this.segmento,
    required this.invertido,
    required this.peso,
  });
}

/// Servicio singleton que gestiona el grafo topológico de curvas a partir de `trazo.svg`.
/// Encuentra el nodo más cercano y calcula la ruta más corta (Dijkstra) a lo largo
/// de las curvas reales del zoológico.
class ServicioRutasSvg {
  ServicioRutasSvg._() {
    _inicializarGrafo(DatosTrazosSvg.rawSvg);
  }

  static final ServicioRutasSvg instance = ServicioRutasSvg._();

  // Punto de partida oficial (Ubicación actual del usuario: 58% X, 58% Y)
  static const Offset puntoEntradaOficial = Offset(1113.6, 626.4);

  final List<Offset> _nodos = [];
  final List<List<AristaSvg>> _adyacencia = [];
  final List<SegmentoTrazoSvg> _segmentos = [];
  bool _inicializado = false;

  List<Offset> get nodos => List.unmodifiable(_nodos);
  List<SegmentoTrazoSvg> get segmentos => List.unmodifiable(_segmentos);
  bool get estaInicializado => _inicializado;

  /// Método de acceso rápido para obtener la ruta curva más cercana hacia un animal
  static Path obtenerRutaHacia(MarcadorMapa destino, {Offset? origen}) {
    return instance.encontrarRuta(
      origen ?? puntoEntradaOficial,
      Offset(destino.x, destino.y),
    );
  }

  /// Carga opcional desde asset en tiempo de ejecución
  Future<void> cargarDesdeAsset([
    String assetPath = DatosTrazosSvg.assetPath,
  ]) async {
    try {
      final contenido = await rootBundle.loadString(assetPath);
      _inicializarGrafo(contenido);
    } catch (_) {
      // Si falla, conserva el grafo base precompilado
    }
  }

  void _inicializarGrafo(String svgContent) {
    _nodos.clear();
    _adyacencia.clear();
    _segmentos.clear();

    final segmentosExtraidos = DatosTrazosSvg.extraerSegmentos(svgContent);

    for (final seg in segmentosExtraidos) {
      _segmentos.add(seg);

      final u = _obtenerOCrearNodo(seg.start);
      final v = _obtenerOCrearNodo(seg.end);

      _adyacencia[u].add(
        AristaSvg(
          desde: u,
          hasta: v,
          segmento: seg,
          invertido: false,
          peso: seg.length,
        ),
      );
      _adyacencia[v].add(
        AristaSvg(
          desde: v,
          hasta: u,
          segmento: seg,
          invertido: true,
          peso: seg.length,
        ),
      );
    }

    _inicializado = true;
  }

  int _obtenerOCrearNodo(Offset p) {
    for (int i = 0; i < _nodos.length; i++) {
      if ((_nodos[i] - p).distance < 18.0) {
        return i;
      }
    }
    _nodos.add(p);
    _adyacencia.add([]);
    return _nodos.length - 1;
  }

  /// Retorna el índice del nodo de la red SVG más cercano a la coordenada dada
  int encontrarNodoMasCercano(Offset p) {
    if (_nodos.isEmpty) return 0;
    int mejorIndex = 0;
    double menorDistancia = double.infinity;
    for (int i = 0; i < _nodos.length; i++) {
      final dist = (_nodos[i] - p).distance;
      if (dist < menorDistancia) {
        menorDistancia = dist;
        mejorIndex = i;
      }
    }
    return mejorIndex;
  }

  /// Calcula la ruta curva óptima mediante Dijkstra entre dos puntos geográficos
  /// siguiendo la red de caminos de `trazo.svg`.
  Path encontrarRuta(Offset inicio, Offset destino) {
    if (_nodos.isEmpty) {
      final p = Path();
      p.moveTo(inicio.dx, inicio.dy);
      p.lineTo(destino.dx, destino.dy);
      return p;
    }

    // 1. Identificar los nodos más cercanos al origen y al destino
    final nodoInicio = encontrarNodoMasCercano(inicio);
    final nodoDestino = encontrarNodoMasCercano(destino);

    // 2. Algoritmo de Dijkstra para encontrar el camino más corto
    final distancias = List<double>.filled(_nodos.length, double.infinity);
    final anteriores = List<AristaSvg?>.filled(_nodos.length, null);
    final visitados = List<bool>.filled(_nodos.length, false);

    distancias[nodoInicio] = 0;

    for (int i = 0; i < _nodos.length; i++) {
      int u = -1;
      double minD = double.infinity;
      for (int j = 0; j < _nodos.length; j++) {
        if (!visitados[j] && distancias[j] < minD) {
          minD = distancias[j];
          u = j;
        }
      }

      if (u == -1 || u == nodoDestino) break;
      visitados[u] = true;

      for (final arista in _adyacencia[u]) {
        final v = arista.hasta;
        if (!visitados[v]) {
          final nuevaDist = distancias[u] + arista.peso;
          if (nuevaDist < distancias[v]) {
            distancias[v] = nuevaDist;
            anteriores[v] = arista;
          }
        }
      }
    }

    // 3. Reconstruir la secuencia de aristas
    final caminoAristas = <AristaSvg>[];
    int? actual = nodoDestino;
    while (actual != null && actual != nodoInicio) {
      final arista = anteriores[actual];
      if (arista == null) break;
      caminoAristas.insert(0, arista);
      actual = arista.desde;
    }

    final pathFinal = Path();
    pathFinal.moveTo(inicio.dx, inicio.dy);

    // Conectar el punto de inicio con el primer nodo si existe distancia
    final primerPuntoNodo = _nodos[nodoInicio];
    if ((inicio - primerPuntoNodo).distance > 2.0) {
      pathFinal.lineTo(primerPuntoNodo.dx, primerPuntoNodo.dy);
    }

    // Agregar cada segmento curvo respetando la dirección de avance
    for (final arista in caminoAristas) {
      final subPath = _extraerSubPathOrientado(
        arista.segmento.path,
        arista.invertido,
      );
      pathFinal.addPath(subPath, Offset.zero);
    }

    // Conectar el último nodo con el recinto o destino del animal
    final ultimoPuntoNodo = _nodos[nodoDestino];
    if ((destino - ultimoPuntoNodo).distance > 2.0) {
      // Curva cuadrática suave hacia el destino para evitar quiebres bruscos
      final midX = (ultimoPuntoNodo.dx + destino.dx) / 2;
      final midY = (ultimoPuntoNodo.dy + destino.dy) / 2;
      pathFinal.quadraticBezierTo(midX, midY, destino.dx, destino.dy);
    }

    return pathFinal;
  }

  /// Invierte la orientación de un subpath si se recorre de destino hacia origen
  Path _extraerSubPathOrientado(Path original, bool invertido) {
    if (!invertido) return original;

    final dest = Path();
    final metrics = original.computeMetrics().toList();
    if (metrics.isEmpty) return original;

    final m = metrics.first;
    const int pasos = 35;
    final pFinal = m.getTangentForOffset(m.length)!.position;
    dest.moveTo(pFinal.dx, pFinal.dy);

    for (int i = pasos - 1; i >= 0; i--) {
      final dist = (i / pasos) * m.length;
      final tangent = m.getTangentForOffset(dist);
      if (tangent != null) {
        dest.lineTo(tangent.position.dx, tangent.position.dy);
      }
    }
    return dest;
  }
}
