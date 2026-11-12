import 'package:flutter/material.dart';

/// Modelo descriptivo de un hábitat / zona para la página de rutas
class HabitatRutaItem {
  final String id;
  final String nombre;
  final String etiqueta;
  final Color colorEtiqueta;
  final String animalesTexto;
  final String duracion;
  final String caracteristicas;
  final String imagen;
  final String habitatFiltro;
  final Color colorFondo;
  final Color colorBorde;
  final Color colorAcento;

  const HabitatRutaItem({
    required this.id,
    required this.nombre,
    required this.etiqueta,
    required this.colorEtiqueta,
    required this.animalesTexto,
    required this.duracion,
    required this.caracteristicas,
    required this.imagen,
    required this.habitatFiltro,
    required this.colorFondo,
    required this.colorBorde,
    required this.colorAcento,
  });
}
