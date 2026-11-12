import 'package:flutter/material.dart';

/// Secciones principales disponibles para los shows
enum SeccionShows {
  horarios,
  reglas,
  escenarios,
}

/// Modelo de datos para un show de la cartelera
class ShowItemData {
  final String id;
  final String titulo;
  final String ubicacion;
  final String duracion;
  final String imagen;
  final String formato; // Ej: Anfiteatro Acuático / Campo Abierto
  final String clasificacion; // Ej: APT (Apta para todos)
  final String etiqueta;
  final Color colorEtiqueta;
  final List<String> horarios;
  final bool esDestacado;

  const ShowItemData({
    required this.id,
    required this.titulo,
    required this.ubicacion,
    required this.duracion,
    required this.imagen,
    required this.formato,
    required this.clasificacion,
    required this.etiqueta,
    required this.colorEtiqueta,
    required this.horarios,
    this.esDestacado = false,
  });
}

/// Modelo para los escenarios del zoológico
class EscenarioShowData {
  final String nombre;
  final String zonaTag;
  final String capacidad;
  final String showPrincipal;
  final String descripcion;
  final Color colorAcento;
  final String habitatMapa;
  final String imagenAsset;

  const EscenarioShowData({
    required this.nombre,
    required this.zonaTag,
    required this.capacidad,
    required this.showPrincipal,
    required this.descripcion,
    required this.colorAcento,
    required this.habitatMapa,
    required this.imagenAsset,
  });
}

/// Modelo para las reglas de convivencia
class ReglaShowData {
  final IconData icono;
  final Color colorIcono;
  final String titulo;
  final String descripcion;

  const ReglaShowData({
    required this.icono,
    required this.colorIcono,
    required this.titulo,
    required this.descripcion,
  });
}
