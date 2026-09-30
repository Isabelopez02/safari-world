import 'package:flutter/material.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_mapa.dart';

class PantallaLayout extends StatefulWidget {
  const PantallaLayout({super.key});

  @override
  State<PantallaLayout> createState() => _PantallaLayoutState();
}

class _PantallaLayoutState extends State<PantallaLayout> {
  int _indiceSeleccionado = 1; // 1 = Mapa por defecto

  // La lista DEBE tener 3 elementos para coincidir con los 3 botones del footer
  final List<Widget> _pantallas = [
    const Scaffold(body: Center(child: Text('Inicio - En construcción'))), // Índice 0
    const PantallaMapa(),                                                  // Índice 1
    const Scaffold(body: Center(child: Text('Perfil - En construcción'))), // Índice 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pantallas[_indiceSeleccionado], 
      
    );
  }
}