import 'package:flutter/material.dart';

class AppColors {
  // Colores principales solicitados
  static const verdePrincipal = Color(0xFF2B5142);
  static const verdeAzulado   = Color(0xFF0E6568);
  static const verdeClaro     = Color(0xFFA6CDAE);

  // Colores secundarios extraídos del diseño
  static const amarilloMostaza = Color(0xFFDF9F1D);
  static const fondoAmarillo   = Color(0xFFFDE1A9);
  static const rojoEmergencia  = Color(0xFFFF4B4B);
  
  static const fondoGris       = Color(0xFFD6D6D6);
  static const fondoGrisClaro  = Color(0xFFE5E5E5);
  
  static const textoOscuro     = Color(0xFF1E1E1E);
  static const textoGris       = Color(0xFF8B7D6B);
  static const fondoApp        = Color(0xFFFDF6EC);

  // Alias para mantener compatibilidad con la Pantalla de Mapa
  static const fondo       = fondoApp;
  static const verde       = verdePrincipal;
  static const verdeOscuro = verdeAzulado;
  static const textoOsc    = textoOscuro;
  static const cardBlanco  = Colors.white;
}
