import 'package:flutter/material.dart';

/// Modelo de datos para un punto de interés o paradero en el mapa interactivo.
class MarcadorMapa {
  final String id;
  final String nombre;
  final double x;
  final double y;
  final IconData icono;
  bool visitado;
  final String categoria;
  final String habitat;
  final String? imagen;
  final bool esBanio;

  MarcadorMapa({
    required this.id,
    required this.nombre,
    required this.x,
    required this.y,
    this.icono = Icons.pets,
    this.visitado = false,
    this.categoria = 'Todos',
    this.habitat = 'Todos',
    this.imagen,
    this.esBanio = false,
  });
}
