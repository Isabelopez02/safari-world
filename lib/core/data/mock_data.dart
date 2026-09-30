import 'package:flutter/material.dart';
import 'package:zoologico_front/core/models/area.dart';

class MockData {
  static const List<Area> areas = [
    Area(nombre: 'Africa', icono: Icons.pets),
    Area(nombre: 'Granja', icono: Icons.agriculture),
    Area(nombre: 'Mar', icono: Icons.water),
    Area(nombre: 'Jungla', icono: Icons.forest),
  ];
}
