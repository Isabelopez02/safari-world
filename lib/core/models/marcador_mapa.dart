import 'package:flutter/material.dart';

/// Modelo de datos para un punto de interés o paradero en el mapa interactivo.
class MarcadorMapa {
  static const double mapaAnchoPorDefecto = 1920.0;
  static const double mapaAltoPorDefecto = 1080.0;

  final String id;
  final String nombre;
  final double x;
  final double y;
  final double porcentajeX;
  final double porcentajeY;
  final IconData icono;
  bool visitado;
  final String categoria;
  final String habitat;
  final String? imagen;
  final bool esBanio;
  final Color? colorZona;

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
    this.colorZona,
    double? porcentajeX,
    double? porcentajeY,
  })  : porcentajeX = porcentajeX ?? (x / mapaAnchoPorDefecto * 100.0),
        porcentajeY = porcentajeY ?? (y / mapaAltoPorDefecto * 100.0);

  /// Constructor de conveniencia a partir de porcentajes directos (x%, y%)
  factory MarcadorMapa.desdePorcentaje({
    required String id,
    required String nombre,
    required double porcentajeX,
    required double porcentajeY,
    IconData icono = Icons.pets,
    bool visitado = false,
    String categoria = 'Todos',
    required String habitat,
    String? imagen,
    bool esBanio = false,
    Color? colorZona,
    double anchoBase = mapaAnchoPorDefecto,
    double altoBase = mapaAltoPorDefecto,
  }) {
    return MarcadorMapa(
      id: id,
      nombre: nombre,
      x: (porcentajeX / 100.0) * anchoBase,
      y: (porcentajeY / 100.0) * altoBase,
      icono: icono,
      visitado: visitado,
      categoria: categoria,
      habitat: habitat,
      imagen: imagen,
      esBanio: esBanio,
      colorZona: colorZona,
      porcentajeX: porcentajeX,
      porcentajeY: porcentajeY,
    );
  }
}
