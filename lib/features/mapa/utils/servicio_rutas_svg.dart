import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';

/// Segmento curvo individual del mapa SVG
class SegmentoCurvoSvg {
  final int index;
  final String d;
  final Path path;
  final Offset start;
  final Offset end;
  final double length;

  SegmentoCurvoSvg({
    required this.index,
    required this.d,
    required this.path,
    required this.start,
    required this.end,
    required this.length,
  });
}

/// Arista dirigida en el grafo de senderos SVG
class AristaSvg {
  final int desde;
  final int hasta;
  final SegmentoCurvoSvg segmento;
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

/// Servicio singleton que gestiona el grafo topológico de curvas a partir de `trazo_mapa.svg`.
/// Encuentra el nodo más cercano y calcula la ruta más corta (Dijkstra) a lo largo
/// de las curvas reales del zoológico.
class ServicioRutasSvg {
  ServicioRutasSvg._() {
    _inicializarGrafo(_rawSvgTrazoMapa);
  }

  static final ServicioRutasSvg instance = ServicioRutasSvg._();

  // Punto de partida oficial (Entrada principal del zoológico)
  static const Offset puntoEntradaOficial = Offset(878.4, 852.3);

  final List<Offset> _nodos = [];
  final List<List<AristaSvg>> _adyacencia = [];
  final List<SegmentoCurvoSvg> _segmentos = [];
  bool _inicializado = false;

  List<Offset> get nodos => List.unmodifiable(_nodos);
  List<SegmentoCurvoSvg> get segmentos => List.unmodifiable(_segmentos);
  bool get estaInicializado => _inicializado;

  /// Método de acceso rápido para obtener la ruta curva más cercana hacia un animal
  static Path obtenerRutaHacia(MarcadorMapa destino, {Offset? origen}) {
    return instance.encontrarRuta(
      origen ?? puntoEntradaOficial,
      Offset(destino.x, destino.y),
    );
  }

  /// Carga opcional desde asset en tiempo de ejecución
  Future<void> cargarDesdeAsset(String assetPath) async {
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

    final exp = RegExp(r'd="([^"]+)"');
    final matches = exp.allMatches(svgContent).toList();

    for (int i = 0; i < matches.length; i++) {
      final d = matches[i].group(1);
      if (d == null || d.isEmpty) continue;

      try {
        final path = parseSvgPathData(d);
        final metrics = path.computeMetrics().toList();
        if (metrics.isEmpty) continue;

        final metric = metrics.first;
        final pStart = metric.getTangentForOffset(0)!.position;
        final pEnd = metric.getTangentForOffset(metric.length)!.position;

        final seg = SegmentoCurvoSvg(
          index: i,
          d: d,
          path: path,
          start: pStart,
          end: pEnd,
          length: metric.length,
        );
        _segmentos.add(seg);

        final u = _obtenerOCrearNodo(pStart);
        final v = _obtenerOCrearNodo(pEnd);

        _adyacencia[u].add(
          AristaSvg(
            desde: u,
            hasta: v,
            segmento: seg,
            invertido: false,
            peso: metric.length,
          ),
        );
        _adyacencia[v].add(
          AristaSvg(
            desde: v,
            hasta: u,
            segmento: seg,
            invertido: true,
            peso: metric.length,
          ),
        );
      } catch (_) {
        // Ignorar segmentos incompatibles
      }
    }

    _inicializado = true;
  }

  int _obtenerOCrearNodo(Offset p) {
    for (int i = 0; i < _nodos.length; i++) {
      if ((_nodos[i] - p).distance < 15.0) {
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
  /// siguiendo la red de caminos de `trazo_mapa.svg`.
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

  // Contenido completo de assets/images/trazo_mapa.svg embebido para disponibilidad instantánea
  static const String _rawSvgTrazoMapa = '''<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg viewBox="0 0 1920 1080">
    <path d="M898.748,511.365C962.844,500.817 1024.915,498.19 1081.999,507.735C1144.062,518.112 1226.461,546.243 1271.129,573.631" />
    <path d="M610.691,474.776L298.157,465.788" />
    <path d="M412.139,224.374C366.158,240.159 327.417,281.589 327.417,281.589" />
    <path d="M537.105,217.784C537.105,217.784 461.568,211.073 412.139,224.374" />
    <path d="M833.964,215.288C833.964,215.288 735.49,177.14 663.797,179.058C593.088,180.95 537.105,217.784 537.105,217.784" />
    <path d="M560.168,281.589L537.105,217.784" />
    <path d="M704.196,429.355C679.315,390.373 612.477,392.887 592.841,364.653C578.367,343.84 560.168,281.589 560.168,281.589" />
    <path d="M704.196,429.355L609.778,474.776" />
    <path d="M817.49,417.681L704.196,429.355" />
    <path d="M616.81,511.365L609.778,474.776" />
    <path d="M298.157,465.788C264.05,415.835 299.831,310.757 326.875,281.589" />
    <path d="M220.272,611.656C231.172,571.035 266.547,512.057 298.157,465.788" />
    <path d="M369.124,771.28C196.189,771.729 199.758,672.865 220.272,611.656" />
    <path d="M461.832,771.28L369.124,771.28" />
    <path d="M610.691,731.409C568.33,772.907 493.838,772.613 461.832,771.28" />
    <path d="M825.727,281.589L833.964,215.288" />
    <path d="M817.49,417.681L825.727,281.589" />
    <path d="M1105.802,235.567C1105.802,235.567 1079.674,223.834 960,219.042C917.905,217.357 833.964,215.288 833.964,215.288" />
    <path d="M1357.596,281.589C1357.596,281.589 1293.969,264.622 1250.969,242.4C1181.863,206.685 1105.802,235.576 1105.802,235.576" />
    <path d="M1102.84,281.589L1105.802,235.567" />
    <path d="M1092.368,431.521L1102.84,281.589" />
    <path d="M1092.368,431.521L817.49,417.681" />
    <path d="M1238.163,473.682L1092.368,431.521" />
    <path d="M1375.224,372.709C1375.224,372.709 1365.066,305.185 1357.728,281.589" />
    <path d="M1375.224,372.709C1357.789,378.627 1238.163,473.682 1238.163,473.682" />
    <path d="M1271.129,573.631L1238.163,473.682" />
    <path d="M1604.499,504.13C1606.275,449.398 1577.446,384.544 1456.558,383.312" />
    <path d="M1498.119,608.65C1550.93,597.667 1601.814,552.224 1604.499,504.13" />
    <path d="M610.691,731.409C610.691,731.409 567.312,690.512 567.196,628.788C567.094,574.777 616.81,511.365 616.81,511.365" />
    <path d="M885.709,667.783C885.709,667.783 814.017,685.338 799.724,690.678C784.969,696.191 747.185,731.376 724.557,737.197C697.963,744.037 620.889,735.6 611.457,731.812C611.106,731.671 610.848,731.536 610.691,731.409" />
    <path d="M663.878,520.802C626.75,531.857 616.81,511.365 616.81,511.365" />
    <path d="M885.709,667.783L898.748,511.365C898.748,511.365 838.941,500.344 757.038,501.834C717.868,502.547 663.878,520.779 663.878,520.779" />
    <path d="M1228.302,637.407L1271.129,573.631" />
    <path d="M1309.732,580.981L1271.129,573.631" />
    <path d="M1498.119,608.65C1481.554,603.082 1309.732,580.981 1309.732,580.981" />
    <path d="M1456.558,383.312C1435,383.479 1391.9,374.057 1375.224,372.709" />
    <path d="M1504.914,640.299C1502.744,620.944 1498.197,608.837 1498.197,608.837" />
    <path d="M1147.767,743.018C1147.767,743.018 1195.595,787.591 1228.302,792.783C1276.665,800.46 1404.178,799.094 1437.944,789.079C1490.791,773.405 1509.527,661.489 1503.839,637.407" />
    <path d="M1147.767,743.018C1147.767,743.018 1185.728,701.025 1191.39,692.406C1195.688,685.863 1228.302,637.407 1228.302,637.407" />
    <path d="M978.898,699.408C978.898,699.408 1025.666,735.228 1053.522,742.312C1081.667,749.469 1147.767,743.018 1147.767,743.018" />
    <path d="M885.709,667.783C885.709,667.783 917.281,681.745 933.457,684.458C948.801,687.032 978.898,699.408 978.898,699.408" />
    <path d="M878.429,852.26L885.709,667.783" />
    <path d="M171.84,909.717L478.886,912.232C478.886,912.232 765.881,914.408 781.793,914.207C850.011,913.345 871.586,852.26 871.586,852.26" />
    <path d="M171.84,909.717L453.75,912.033C453.75,912.033 764.953,914.42 781.793,914.207C850.011,913.345 878.429,852.26 878.429,852.26" />
</svg>''';
}
