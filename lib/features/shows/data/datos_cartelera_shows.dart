import 'package:flutter/material.dart';
import 'show_models.dart';

/// Catálogo de espectáculos, escenarios y reglas del zoológico
class DatosCarteleraShows {
  const DatosCarteleraShows._();

  static const List<ShowItemData> todosLosShows = [
    ShowItemData(
      id: 'show_marino',
      titulo: 'Show Acuático de Lobos & Focas',
      ubicacion: 'Anfiteatro Marino • Zona Costa',
      duracion: '35 min',
      imagen: 'assets/images/animales_con_fondo/foca-card.jpg',
      formato: 'Anfiteatro Acuático',
      clasificacion: 'APT',
      etiqueta: '⭐ SHOW ESTELAR',
      colorEtiqueta: Color(0xFF0077B6),
      horarios: ['10:00 AM', '01:00 PM', '04:00 PM'],
      esDestacado: true,
    ),
    ShowItemData(
      id: 'show_aves',
      titulo: 'Vuelo Libre de Rapaces & Cóndores',
      ubicacion: 'Mirador Andino • Zona Sierra',
      duracion: '25 min',
      imagen: 'assets/images/animales_con_fondo/aguila.jpg',
      formato: 'Campo Abierto',
      clasificacion: 'APT',
      etiqueta: '🦅 AL AIRE LIBRE',
      colorEtiqueta: Color(0xFF8D6E63),
      horarios: ['11:30 AM', '03:30 PM'],
    ),
    ShowItemData(
      id: 'show_pinguinos',
      titulo: 'Alimentación de Pingüinos Humboldt',
      ubicacion: 'Piscina Humboldt • Zona Costa',
      duracion: '20 min',
      imagen: 'assets/images/animales_con_fondo/pinguino-card.jpg',
      formato: 'Interactivo',
      clasificacion: 'APT',
      etiqueta: '🐟 INTERACTIVO',
      colorEtiqueta: Color(0xFF0E6568),
      horarios: ['12:00 PM', '02:30 PM'],
    ),
    ShowItemData(
      id: 'show_felinos',
      titulo: 'Charla & Enriquecimiento con Leones',
      ubicacion: 'Refugio de Fieras • Zona Internacional',
      duracion: '30 min',
      imagen: 'assets/images/animales_con_fondo/leon-card.jpg',
      formato: 'Charla Biológica',
      clasificacion: 'APT',
      etiqueta: '🦁 CHARLA CON CUIDADORES',
      colorEtiqueta: Color(0xFFD97706),
      horarios: ['02:00 PM', '04:30 PM'],
    ),
  ];

  static const List<EscenarioShowData> escenarios = [
    EscenarioShowData(
      nombre: 'Anfiteatro Acuático Marino',
      zonaTag: 'ZONA COSTA',
      capacidad: '450 personas (Techado)',
      showPrincipal: 'Show Acuático de Lobos & Focas',
      descripcion:
          'Piscina oceánica de agua salada con graderías techadas, sonido envolvente y vista submarina.',
      colorAcento: Color(0xFF0077B6),
      habitatMapa: 'C05',
      imagenAsset: 'assets/images/animales_con_fondo/foca-card.jpg',
    ),
    EscenarioShowData(
      nombre: 'Mirador Andino de Rapaces',
      zonaTag: 'ZONA SIERRA',
      capacidad: '300 personas (Campo abierto)',
      showPrincipal: 'Vuelo Libre de Rapaces & Cóndores',
      descripcion:
          'Ubicado en la ladera alta del zoológico, aprovecha las corrientes térmicas andinas para vuelos naturales.',
      colorAcento: Color(0xFF8D6E63),
      habitatMapa: 'S03',
      imagenAsset: 'assets/images/animales_con_fondo/aguila.jpg',
    ),
    EscenarioShowData(
      nombre: 'Piscina Humboldt',
      zonaTag: 'ZONA COSTA',
      capacidad: '200 personas (Semi-techado)',
      showPrincipal: 'Alimentación de Pingüinos Humboldt',
      descripcion:
          'Plataforma cercana de observación con cristales sumergidos y charlas biológicas interactivas.',
      colorAcento: Color(0xFF0E6568),
      habitatMapa: 'C08',
      imagenAsset: 'assets/images/animales_con_fondo/pinguino-card.jpg',
    ),
    EscenarioShowData(
      nombre: 'Refugio de la Sabana & Felinos',
      zonaTag: 'ZONA INTERNACIONAL',
      capacidad: '350 personas (Pasarela)',
      showPrincipal: 'Charla & Enriquecimiento con Leones',
      descripcion:
          'Pasarela elevada con vista a la pradera africana y ventanales de máxima seguridad para charlas guiadas.',
      colorAcento: Color(0xFFD97706),
      habitatMapa: 'I02',
      imagenAsset: 'assets/images/animales_con_fondo/leon-card.jpg',
    ),
  ];

  static const List<ReglaShowData> reglas = [
    ReglaShowData(
      icono: Icons.no_flash_rounded,
      colorIcono: Color(0xFFDC2626),
      titulo: 'Prohibido usar flash en fotos',
      descripcion:
          'La luz intensa puede asustar o desorientar a lobos marinos y aves rapaces durante las maniobras.',
    ),
    ReglaShowData(
      icono: Icons.no_food_rounded,
      colorIcono: Color(0xFFEA580C),
      titulo: 'No arrojar comida al escenario',
      descripcion:
          'Los animales reciben dietas balanceadas pesadas por gramaje diario con estricto control veterinario.',
    ),
    ReglaShowData(
      icono: Icons.access_time_filled_rounded,
      colorIcono: Color(0xFF0284C7),
      titulo: 'Llegada 15 minutos antes',
      descripcion:
          'El aforo en graderías es controlado por seguridad. Se cierran accesos puntualmente al iniciar.',
    ),
    ReglaShowData(
      icono: Icons.volume_off_rounded,
      colorIcono: Color(0xFF7C3AED),
      titulo: 'Silencio y respeto durante el show',
      descripcion:
          'Evita ruidos estridentes o levantarte bruscamente durante los vuelos o ejercicios en vivo.',
    ),
    ReglaShowData(
      icono: Icons.accessible_rounded,
      colorIcono: Color(0xFF0D9488),
      titulo: 'Zonas de acceso preferente',
      descripcion:
          'Espacios reservados de fácil acceso para personas con movilidad reducida y cochecitos de bebé.',
    ),
    ReglaShowData(
      icono: Icons.wb_sunny_rounded,
      colorIcono: Color(0xFFD97706),
      titulo: 'Protección solar y clima',
      descripcion:
          'Los anfiteatros al aire libre disponen de zonas sombreadas. Se recomienda uso de gorra e hidratación.',
    ),
  ];
}
