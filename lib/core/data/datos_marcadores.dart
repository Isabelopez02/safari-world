import 'package:flutter/material.dart';

import '../models/marcador_mapa.dart';
import 'catalogo_fauna.dart';

/// Las fichas históricas sin ubicación documentada se consultan desde el catálogo.
/// Los puntos conservados del plano son referencias aproximadas por zona.
final List<MarcadorMapa> marcadoresZoologico = [
  for (final registro in catalogoFauna)
    MarcadorMapa(
      id: registro.id,
      nombre: registro.nombre,
      x: registro.x,
      y: registro.y,
      habitat: registro.zona,
      imagen: registro.datos.imagen,
      tieneUbicacionMapa: registro.enMapa,
    ),
];

/// Baños actualmente cargados en el mapa del prototipo.
final List<MarcadorMapa> baniosZoologico = [
  MarcadorMapa(
    id: 'B01',
    nombre: 'Baño',
    x: 420,
    y: 580,
    icono: Icons.wc_rounded,
    esBanio: true,
  ),
  MarcadorMapa(
    id: 'B02',
    nombre: 'Baño',
    x: 900,
    y: 520,
    icono: Icons.wc_rounded,
    esBanio: true,
  ),
  MarcadorMapa(
    id: 'B03',
    nombre: 'Baño',
    x: 1300,
    y: 720,
    icono: Icons.wc_rounded,
    esBanio: true,
  ),
];
