import 'dart:ui';
import 'dart:math';

class NodoRuta {
  final String id;
  final Offset posicion;

  NodoRuta(this.id, this.posicion);
}

class Arista {
  final String desde;
  final String hasta;
  final double distancia;

  Arista(this.desde, this.hasta, this.distancia);
}

class GrafoZoolologico {
  final Map<String, NodoRuta> nodos = {};
  final Map<String, List<Arista>> listaAdyacencia = {};

  void agregarNodo(String id, double x, double y) {
    nodos[id] = NodoRuta(id, Offset(x, y));
    listaAdyacencia[id] = [];
  }

  void agregarArista(String id1, String id2) {
    if (!nodos.containsKey(id1) || !nodos.containsKey(id2)) {
      print('Error: Intentando conectar nodos inexistentes $id1 o $id2');
      return;
    }

    final n1 = nodos[id1]!;
    final n2 = nodos[id2]!;

    // Calcula la distancia real (Euclidiana) entre los dos puntos
    final double distancia = (n1.posicion - n2.posicion).distance;

    listaAdyacencia[id1]!.add(Arista(id1, id2, distancia));
    listaAdyacencia[id2]!.add(
      Arista(id2, id1, distancia),
    ); // Caminos de doble sentido
  }

  // Implementación del Algoritmo de Dijkstra para la ruta más corta
  List<Offset> encontrarRutaMasCorta(String inicioId, String destinoId) {
    if (!nodos.containsKey(inicioId) || !nodos.containsKey(destinoId))
      return [];

    final distancias = <String, double>{};
    final anteriores = <String, String?>{};
    final noVisitados = <String>{};

    for (var id in nodos.keys) {
      distancias[id] = double.infinity;
      anteriores[id] = null;
      noVisitados.add(id);
    }

    distancias[inicioId] = 0;

    while (noVisitados.isNotEmpty) {
      // 1. Encontrar el nodo no visitado con la menor distancia
      String? nodoActual;
      double minDistancia = double.infinity;

      for (var id in noVisitados) {
        if (distancias[id]! < minDistancia) {
          minDistancia = distancias[id]!;
          nodoActual = id;
        }
      }

      // Si no encontramos un nodo alcanzable o llegamos al destino, paramos
      if (nodoActual == null || nodoActual == destinoId) {
        break;
      }

      noVisitados.remove(nodoActual);

      // 2. Revisar los vecinos del nodo actual
      for (var arista in listaAdyacencia[nodoActual]!) {
        if (!noVisitados.contains(arista.hasta)) continue;

        double nuevaDistancia = distancias[nodoActual]! + arista.distancia;
        if (nuevaDistancia < distancias[arista.hasta]!) {
          distancias[arista.hasta] = nuevaDistancia;
          anteriores[arista.hasta] = nodoActual;
        }
      }
    }

    // 3. Reconstruir la ruta desde el destino hacia el inicio
    List<Offset> ruta = [];
    String? paso = destinoId;

    if (anteriores[paso] == null && paso != inicioId) {
      return []; // No se encontró una ruta
    }

    while (paso != null) {
      ruta.insert(0, nodos[paso]!.posicion);
      paso = anteriores[paso];
    }

    return ruta;
  }
}
