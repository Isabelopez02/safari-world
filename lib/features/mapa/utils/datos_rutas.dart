import 'dart:ui';
import 'pathfinding.dart';
import '../../../../core/data/datos_marcadores.dart';

// Este es el grafo (red de caminos) que representa tu mapa
final GrafoZoolologico grafoMapa = () {
  final grafo = GrafoZoolologico()
    // 1. NODOS PRINCIPALES DE LOS CAMINOS Y CRUCES DEL PARQUE
    ..agregarNodo('entrada', 878.4, 852.3)
    ..agregarNodo('plaza_principal', 900.0, 680.0)
    // Caminos hacia Costa y Granja (Oeste / Suroeste)
    ..agregarNodo('camino_costa_1', 750.0, 500.0)
    ..agregarNodo('camino_costa_2', 850.0, 480.0)
    ..agregarNodo('camino_costa_norte', 720.0, 400.0)
    ..agregarNodo('camino_caballeriza', 650.0, 300.0)
    // Caminos Granja y Norte
    ..agregarNodo('camino_granja', 1150.0, 200.0)
    // Caminos Internacional (Norte / Este)
    ..agregarNodo('camino_inter_1', 1150.0, 320.0)
    ..agregarNodo('camino_inter_2', 1250.0, 320.0)
    ..agregarNodo('camino_inter_3', 1350.0, 300.0)
    ..agregarNodo('camino_inter_este', 1400.0, 260.0)
    // Caminos Selva (Centro - Este)
    ..agregarNodo('camino_selva_1', 1280.0, 450.0)
    ..agregarNodo('camino_selva_2', 1350.0, 520.0)
    ..agregarNodo('camino_selva_3', 1300.0, 600.0)
    // Caminos Sierra (Sur - Este)
    ..agregarNodo('camino_sierra_1', 1200.0, 680.0)
    ..agregarNodo('camino_sierra_2', 1280.0, 750.0)
    // 2. CONEXIONES DE CAMINOS PRINCIPALES
    ..agregarArista('entrada', 'plaza_principal')
    ..agregarArista('plaza_principal', 'camino_costa_1')
    ..agregarArista('camino_costa_1', 'camino_costa_2')
    ..agregarArista('camino_costa_1', 'camino_costa_norte')
    ..agregarArista('camino_costa_norte', 'camino_caballeriza')
    ..agregarArista('plaza_principal', 'camino_selva_1')
    ..agregarArista('camino_costa_2', 'camino_inter_1')
    ..agregarArista('camino_inter_1', 'camino_granja')
    ..agregarArista('camino_inter_1', 'camino_inter_2')
    ..agregarArista('camino_inter_2', 'camino_inter_3')
    ..agregarArista('camino_inter_3', 'camino_inter_este')
    ..agregarArista('camino_inter_2', 'camino_selva_1')
    ..agregarArista('camino_selva_1', 'camino_selva_2')
    ..agregarArista('camino_selva_2', 'camino_selva_3')
    ..agregarArista('camino_selva_3', 'camino_sierra_1')
    ..agregarArista('camino_sierra_1', 'camino_sierra_2')
    ..agregarArista('plaza_principal', 'camino_sierra_1');

  // 1. Agregar todos los marcadores de animales
  for (final marcador in marcadoresZoologico) {
    grafo.agregarNodo(marcador.id, marcador.x, marcador.y);

    String? nodoMasCercano;
    double distMin = double.infinity;

    for (final caminoId in [
      'entrada',
      'plaza_principal',
      'camino_costa_1',
      'camino_costa_2',
      'camino_costa_norte',
      'camino_caballeriza',
      'camino_granja',
      'camino_inter_1',
      'camino_inter_2',
      'camino_inter_3',
      'camino_inter_este',
      'camino_selva_1',
      'camino_selva_2',
      'camino_selva_3',
      'camino_sierra_1',
      'camino_sierra_2',
    ]) {
      final caminoNodo = grafo.nodos[caminoId];
      if (caminoNodo != null) {
        final dist = (caminoNodo.posicion - Offset(marcador.x, marcador.y)).distance;
        if (dist < distMin) {
          distMin = dist;
          nodoMasCercano = caminoId;
        }
      }
    }

    if (nodoMasCercano != null) {
      grafo.agregarArista(nodoMasCercano, marcador.id);
    }
  }

  // 2. Agregar los baños al grafo
  for (final banio in baniosZoologico) {
    grafo.agregarNodo(banio.id, banio.x, banio.y);

    String? nodoMasCercano;
    double distMin = double.infinity;

    for (final caminoId in [
      'plaza_principal',
      'camino_costa_1',
      'camino_costa_2',
      'camino_inter_1',
      'camino_selva_2',
      'camino_sierra_1',
    ]) {
      final caminoNodo = grafo.nodos[caminoId];
      if (caminoNodo != null) {
        final dist = (caminoNodo.posicion - Offset(banio.x, banio.y)).distance;
        if (dist < distMin) {
          distMin = dist;
          nodoMasCercano = caminoId;
        }
      }
    }

    if (nodoMasCercano != null) {
      grafo.agregarArista(nodoMasCercano, banio.id);
    }
  }

  return grafo;
}();
