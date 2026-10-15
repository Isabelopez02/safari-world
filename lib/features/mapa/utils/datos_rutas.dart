import 'package:flutter/material.dart';

import '../../../core/data/datos_marcadores.dart';
import 'pathfinding.dart';

/// Grafo provisional sobre el mapa ilustrado actual. Las conexiones entre el
/// sendero y cada recinto son aproximadas hasta contar con el plano vectorial.
final GrafoZoolologico grafoMapa = _crearGrafoMapa();

GrafoZoolologico _crearGrafoMapa() {
  final grafo = GrafoZoolologico();

  // Caminos y cruces del plano de referencia de la aplicación.
  const caminos = <String, Offset>{
    'entrada': Offset(900, 770),
    'plaza_principal': Offset(900, 680),
    'camino_izq_1': Offset(700, 700),
    'camino_izq_2': Offset(400, 720),
    'camino_izq_3': Offset(180, 650),
    'camino_izq_4': Offset(200, 450),
    'camino_izq_5': Offset(380, 450),
    'camino_c_izq_1': Offset(650, 450),
    'camino_c_izq_2': Offset(650, 360),
    'camino_centro_1': Offset(950, 600),
    'camino_centro_2': Offset(950, 450),
    'camino_der_1': Offset(1150, 700),
    'camino_der_2': Offset(1350, 680),
    'camino_der_3': Offset(1350, 560),
    'camino_der_4': Offset(1250, 400),
  };
  for (final camino in caminos.entries) {
    grafo.agregarNodo(camino.key, camino.value.dx, camino.value.dy);
  }

  const tramos = [
    ('entrada', 'plaza_principal'),
    ('plaza_principal', 'camino_izq_1'),
    ('camino_izq_1', 'camino_izq_2'),
    ('camino_izq_2', 'camino_izq_3'),
    ('camino_izq_3', 'camino_izq_4'),
    ('camino_izq_4', 'camino_izq_5'),
    ('camino_izq_1', 'camino_c_izq_1'),
    ('camino_izq_5', 'camino_c_izq_1'),
    ('camino_c_izq_1', 'camino_c_izq_2'),
    ('plaza_principal', 'camino_centro_1'),
    ('camino_centro_1', 'camino_centro_2'),
    ('camino_centro_2', 'camino_c_izq_2'),
    ('camino_centro_2', 'camino_der_4'),
    ('plaza_principal', 'camino_der_1'),
    ('camino_der_1', 'camino_der_2'),
    ('camino_der_2', 'camino_der_3'),
    ('camino_der_3', 'camino_der_4'),
  ];
  for (final (desde, hasta) in tramos) {
    grafo.agregarArista(desde, hasta);
  }

  for (final marcador in marcadoresZoologico) {
    if (!marcador.tieneUbicacionMapa) continue;
    grafo.agregarNodo(marcador.id, marcador.x, marcador.y);
    var caminoCercano = caminos.entries.first;
    var distanciaMenor = double.infinity;
    for (final camino in caminos.entries) {
      final distancia =
          (camino.value - Offset(marcador.x, marcador.y)).distance;
      if (distancia < distanciaMenor) {
        distanciaMenor = distancia;
        caminoCercano = camino;
      }
    }
    grafo.agregarArista(caminoCercano.key, marcador.id);
  }

  for (final banio in baniosZoologico) {
    grafo.agregarNodo(banio.id, banio.x, banio.y);
    final caminoCercano = banio.id == 'B01'
        ? 'camino_izq_2'
        : banio.id == 'B02'
        ? 'camino_centro_2'
        : 'camino_der_1';
    grafo.agregarArista(caminoCercano, banio.id);
  }

  return grafo;
}
