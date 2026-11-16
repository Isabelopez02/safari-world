import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Idiomas disponibles en la aplicación
enum AppIdioma {
  es, // Español
  en, // English
  qu, // Runasimi / Quechua
  ay, // Aymar aru / Aimara
}

/// Servicio global reactivo de traducción y localización para el zoológico.
/// Permite alternar entre Español, Inglés, Quechua y Aimara instantáneamente en toda la app.
class IdiomaService extends ChangeNotifier {
  static const String _prefKeyIdioma = 'idioma_seleccionado_app';

  IdiomaService._() {
    _cargarPreferencia();
  }

  static final IdiomaService instance = IdiomaService._();

  AppIdioma _idioma = AppIdioma.es;

  AppIdioma get idioma => _idioma;

  String get codigoIdioma {
    switch (_idioma) {
      case AppIdioma.es:
        return 'es';
      case AppIdioma.en:
        return 'en';
      case AppIdioma.qu:
        return 'qu';
      case AppIdioma.ay:
        return 'ay';
    }
  }

  String get nombreIdioma {
    switch (_idioma) {
      case AppIdioma.es:
        return 'Español';
      case AppIdioma.en:
        return 'English';
      case AppIdioma.qu:
        return 'Quechua (Runasimi)';
      case AppIdioma.ay:
        return 'Aimara (Aymar aru)';
    }
  }

  String get banderaIdioma {
    switch (_idioma) {
      case AppIdioma.es:
        return '🇵🇪 ES';
      case AppIdioma.en:
        return '🇺🇸 EN';
      case AppIdioma.qu:
        return '🏔️ QU';
      case AppIdioma.ay:
        return '☀️ AY';
    }
  }

  Future<void> _cargarPreferencia() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guardado = prefs.getString(_prefKeyIdioma);
      if (guardado != null) {
        _idioma = AppIdioma.values.firstWhere(
          (e) => e.name == guardado,
          orElse: () => AppIdioma.es,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al cargar idioma: $e');
    }
  }

  Future<void> cambiarIdioma(AppIdioma nuevoIdioma) async {
    if (_idioma == nuevoIdioma) return;
    _idioma = nuevoIdioma;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyIdioma, nuevoIdioma.name);
    } catch (e) {
      debugPrint('Error al guardar idioma: $e');
    }
  }

  /// Traducción directa por clave
  String translate(String key) {
    final mapaActual = _diccionario[_idioma] ?? _diccionario[AppIdioma.es]!;
    return mapaActual[key] ?? _diccionario[AppIdioma.es]?[key] ?? key;
  }

  /// Helper estático para traducir
  static String tr(String key) => instance.translate(key);

  // Diccionario completo de textos en los 4 idiomas (Español, English, Quechua, Aimara)
  static final Map<AppIdioma, Map<String, String>> _diccionario = {
    AppIdioma.es: {
      // Navegación
      'nav_inicio': 'Inicio',
      'nav_mapa': 'Mapa',
      'nav_shows': 'Shows',
      'nav_ruta': 'Tu Ruta',
      'nav_perfil': 'Perfil',
      'nav_animales': 'Animales',
      'nav_ayuda': 'Ayuda',
      'nav_menu': 'Menú',

      // Barra de Shows y Banners
      'cartelera_shows': 'Cartelera de Shows',
      'mira_todo_shows': 'Mira todo esto para tus shows',
      'banner_shows_sub':
          'Reserva horarios, consulta normas de convivencia y conoce la ubicación de cada escenario.',
      'ver_mis_entradas': 'Mis Entradas',
      'ver_entradas_btn': 'Ver mis entradas',
      'activar_notificaciones': 'Activar notificaciones de shows',
      'notif_sub': 'Te avisamos 15 min antes de cada función',
      'horarios_fechas': 'Horarios & Fechas',
      'reglas_show': 'Reglas del Show',
      'escenarios_info': 'Escenarios & Info',
      'cupos_disponibles': 'cupos disponibles',
      'ultimos_cupos': '¡Últimos cupos!',
      'agotado': 'Agotado',
      'reservar_funcion': 'Reservar Función',
      'cantidad_asistentes': 'Cantidad de asistentes',
      'incluido_entrada': 'Incluido en tu entrada general',
      'pase_valido': 'PASE VÁLIDO',
      'ir_al_escenario': 'Ir al Escenario',
      'codigo_ingreso': 'CÓDIGO DE INGRESO',
      'escanear_qr': 'Toca para ver QR',
      'te_registraste': 'Te registraste a un show a las',
      'show_estelar_hoy': 'SHOW ESTELAR HOY',
      'ver_detalles': 'Ver detalles',
      'completado': 'COMPLETADO',

      // Modal QR
      'tu_pase_digital': 'Tu Boleto Digital',
      'sube_brillo_qr': 'Muestra este QR en el acceso del anfiteatro',
      'descargar_boleto': 'Guardar Pase',
      'cerrar': 'Cerrar',

      // Tu Ruta
      'rutas_habitats': 'Rutas & Hábitats',
      'conoce_habitats': 'CONOCE LOS HÁBITATS DEL PARQUE',
      'conoce_habitats_sub':
          'Elige qué animales deseas visitar hoy y traza el sendero en el mapa.',
      'trazar_ruta': 'Trazar ruta hacia esta zona',
      'animales_explorados': 'explorados',

      // Perfil
      'perfil_titulo': 'Perfil del Explorador',
      'idioma_titulo': 'IDIOMA DE LA APP',
      'seleccionar_idioma': 'Selecciona tu idioma preferido',
      'notificaciones_titulo': 'NOTIFICACIONES',
      'alertas_shows': 'Alertas de Shows',
      'modo_daltonismo': 'Modo Daltonismo & Alto Contraste',
      'tamano_texto': 'TAMAÑO DE TEXTO',
      'cambiar_idioma': 'Cambiar Idioma',
      'idioma_espanol': 'Español',
      'idioma_ingles': 'English',
      'idioma_quechua': 'Runasimi / Quechua',
      'idioma_aimara': 'Aymar aru / Aimara',

      // Mapa
      'mi_ubicacion': 'Mi Ubicación',
      'capas_mapa': 'Capas del Mapa',
      'zonas_calma': 'Zonas de Calma & Silencio',
      'puntos_encuentro': 'Puntos de encuentro y guías',
      'filtro_banios': 'Baños',
      'filtro_salida': 'Salida',
      'filtro_calma': 'Z. Tranquila',
      'buscar_animales': 'Buscar animales o servicios...',
      'ver_ficha': 'Ver Ficha',
      'iniciar_guia': 'Iniciar Guía',
      'visto': 'Visto',
      'marcar': 'Marcar',

      // Inicio
      'tu_aventura': 'Tu aventura empieza aquí',
      'parque_nombre': 'Parque de las Leyendas',
      'shows_actividades': 'Shows y Actividades',
      'descubre_funciones': 'Descubre funciones acuáticas y aves',
      'animales_observados': 'Animales observados hoy',
      'toca_para_explorar': 'Toca para ver la lista completa',
      'que_quieres_hacer': '¿Qué quieres hacer hoy?',
      'accion_shows': 'Shows en vivo',
      'accion_mapa': 'Ver Mapa',
      'accion_tiendas': 'Snacks y Tiendas',
      'accion_te_perdiste': '¿Te perdiste?',

      // Perfil Adicional
      'modo_daltonismo_tit': 'Modo Daltonismo',
      'modo_daltonismo_sub': 'Paleta de alto contraste adaptada para visión de color',
      'modo_facil_tit': 'Modo Fácil (Adulto Mayor)',
      'modo_facil_sub': 'Interfaz simplificada, letras grandes y lectura guiada por voz',
      'alertas_shows_sub': 'Recordatorios 15 minutos antes de iniciar cada función',
      'sonido_haptica': 'Sonidos y Háptica',
      'sonido_haptica_sub': 'Efectos sonoros y vibración al interactuar',
      'preguntas_frecuentes': 'Preguntas Frecuentes',
      'llamar_emergencia': 'Llamar a Emergencias',

      // Modo Fácil
      'modo_facil': 'Modo Fácil',
      'letra_grande_sub': 'Letra grande y lectura guiada',
      'salir': 'Salir',
      'volver_al_menu': 'Volver al Menú',
      'salir_modo_facil': 'Salir del Modo Fácil\n(Modo Normal)',
      'bienvenido_parque': '¡Bienvenido al Parque! 🦁',
      'bienvenido_sub':
          'Toque cualquiera de los botones grandes de abajo para usar el parque de forma fácil y sin complicaciones.',
      'escanear_placa_guia': 'Escanear Placa QR / Guía',
      'escanear_camara_sub':
          'Abra la cámara y apunte al letrero de cualquier animal para escuchar su historia',
      'mapa_zoologico': 'Mapa del Zoológico',
      'mapa_facil_sub':
          'Mapa interactivo con botones gigantes para Baños, Salida y Zona Tranquila',
      'shows_hoy': 'Shows de Hoy',
      'shows_facil_sub':
          'Cartelera grande con guardado en 1 toque y efecto de confirmación',
      'pedir_ayuda': 'Pedir Ayuda / Tópico',
      'pedir_ayuda_sub':
          'Contactar a un orientador o asistencia médica del parque',
      'marcar_visitado': '✅ Marcar como Visitado',
      'visitado_listo': 'Visitado ✓ (Toque para desmarcar)',
      'apunte_camara':
          'Apunte la cámara a la placa QR o letrero físico de cualquier animal del parque.',
      'catalogo_animales': '🐾 Elegir de la Lista Completa de Animales',
      'historia_animal': '🎙️ Historia del Animal',
      'dieta_alimentacion': 'Alimentación y Dieta',
      'escanear_otra_placa': '📷 Escanear otra placa QR',
      'audioguia': 'Audioguía',
      'pausar': 'Pausar',
      'explorado_pasaporte': 'Explorado en tu Pasaporte ✓ (Desmarcar)',
      'marcar_pasaporte': 'Marcar en mi pasaporte de visitas 🐾',
      'sabias_que': '¿Sabías que?',
      'comportamiento_habitat': 'Comportamiento en el hábitat',
      'alimentacion_dieta_diaria': 'Alimentación y dieta diaria',
      'horarios_alimentacion': 'Horarios de alimentación',
      'repetir_narracion': 'Repetir narración',
      'felicitaciones_visitado': '¡Felicitaciones! Ha marcado como visitado a',
      'busqueda_por_voz': 'Búsqueda por Voz',
      'alerta_sos': 'Alerta SOS',
      'trazar_en_mapa_real': 'Trazar sendero en el Mapa',
      'llamar_topico': 'Llamar al Tópico Central',
      'llamar_guardaparques': 'Llamar a Guardaparques',
      'llamar_samu': 'Llamar a Ambulancia (106)',
      'desactivar_sos': 'Desactivar Alerta SOS',

      // Nombres de Animales
      'Vacas Holstein': 'Vacas Holstein',
      'Ovejas': 'Ovejas',
      'Rinoceronte': 'Rinoceronte',
      'Leones': 'Leones',
      'Avestruz': 'Avestruz',
      'Búfalos de agua': 'Búfalos de agua',
      'Hipopótamos del Nilo': 'Hipopótamos del Nilo',
      'Dromedarios': 'Dromedarios',
      'Tigre de Bengala': 'Tigre de Bengala',
      'Oso de Anteojos (Zona Internacional)': 'Oso de Anteojos (Zona Internacional)',
      'Cebra de Grant': 'Cebra de Grant',
      'Tortugas': 'Tortugas',
      'Tigre Blanco': 'Tigre Blanco',
      'Jirafa': 'Jirafa',
      'Canguros': 'Canguros',
      'Suricatas': 'Suricatas',
      'Gallos (Villa Carmelo)': 'Gallos (Villa Carmelo)',
      'Pavo Real (Villa Carmelo)': 'Pavo Real (Villa Carmelo)',
      'Pelícanos / Aves Guaneras': 'Pelícanos / Aves Guaneras',
      'Peces (Acuario)': 'Peces (Acuario)',
      'Lobos de Mar': 'Lobos de Mar',
      'Cocodrilo de Tumbes': 'Cocodrilo de Tumbes',
      'Flamencos': 'Flamencos',
      'Pingüinos de Humboldt': 'Pingüinos de Humboldt',
      'Caballos (Caballeriza)': 'Caballos (Caballeriza)',
      'Venados': 'Venados',
      'Cóndor Andino': 'Cóndor Andino',
      'Alpacas': 'Alpacas',
      'Zorro Andino': 'Zorro Andino',
      'Puma': 'Puma',
      'Águila Mora': 'Águila Mora',
      'Vicuñas': 'Vicuñas',
      'Reptiles / Serpientes (Herpetario)': 'Reptiles / Serpientes (Herpetario)',
      'Guacamayos': 'Guacamayos',
      'Tapir (Sachavaca)': 'Tapir (Sachavaca)',
      'Isla de Monos': 'Isla de Monos',
      'Otorongo': 'Otorongo',
      'Nutria Gigante (Lobo de río)': 'Nutria Gigante (Lobo de río)',
      'Anaconda': 'Anaconda',
      'Sajino': 'Sajino',
      'Oso Perezoso / Mamíferos menores': 'Oso Perezoso / Mamíferos menores',

      // Hábitats directos
      'Granja Interactiva': 'Granja Interactiva',
      'Zona Internacional': 'Zona Internacional',
      'Zona Costa': 'Zona Costa',
      'Zona Sierra': 'Zona Sierra',
      'Zona Selva': 'Zona Selva',

      // Dietas y Conservación
      'Herbívoro': 'Herbívoro',
      'Carnívoro': 'Carnívoro',
      'Omnívoro': 'Omnívoro',
      'Piscívoro': 'Piscívoro',
      'Carroñero': 'Carroñero',
      'Frugívoro / Herbívoro': 'Frugívoro / Herbívoro',
      'Insectívoro / Omnívoro': 'Insectívoro / Omnívoro',
      'Piscívoro / Herbívoro': 'Piscívoro / Herbívoro',
      'Carnívoro / Piscívoro': 'Carnívoro / Piscívoro',
      'Filtrador / Planctívoro': 'Filtrador / Planctívoro',
      'Omnívoro / Carnívoro': 'Omnívoro / Carnívoro',
      'Frugívoro / Granívoro': 'Frugívoro / Granívoro',
      'Frugívoro / Omnívoro': 'Frugívoro / Omnívoro',
      'Piscívoro / Carnívoro': 'Piscívoro / Carnívoro',
      'Omnívoro / Frugívoro': 'Omnívoro / Frugívoro',
      'Folívoro': 'Folívoro',
      'Domesticado': 'Domesticado',
      'Casi amenazado': 'Casi amenazado',
      'Vulnerable': 'Vulnerable',
      'Preocupación menor': 'Preocupación menor',
      'En peligro (salvaje)': 'En peligro (salvaje)',
      'En peligro': 'En peligro',
      'En peligro crítico (en santuarios)': 'En peligro crítico (en santuarios)',
      'En peligro crítico en Perú': 'En peligro crítico en Perú',
      'Diversos estados': 'Diversos estados',
      'Patrimonio Cultural de la Nación': 'Patrimonio Cultural de la Nación',
      'Recuperada / Protegida': 'Recuperada / Protegida',
      'Protegido': 'Protegido',
    },

    AppIdioma.en: {
      // Navigation
      'nav_inicio': 'Home',
      'nav_mapa': 'Map',
      'nav_shows': 'Shows',
      'nav_ruta': 'Your Route',
      'nav_perfil': 'Profile',
      'nav_animales': 'Animals',
      'nav_ayuda': 'Help',
      'nav_menu': 'Menu',

      // Shows
      'cartelera_shows': 'Shows Billboard',
      'mira_todo_shows': 'Explore all for your shows',
      'banner_shows_sub':
          'Book times, check park rules, and locate every amphitheater easily.',
      'ver_mis_entradas': 'My Tickets',
      'ver_entradas_btn': 'View my tickets',
      'activar_notificaciones': 'Enable show notifications',
      'notif_sub': 'Get notified 15 min before each show starts',
      'horarios_fechas': 'Schedules & Dates',
      'reglas_show': 'Show Rules',
      'escenarios_info': 'Venues & Info',
      'cupos_disponibles': 'spots left',
      'ultimos_cupos': 'Few spots left!',
      'agotado': 'Sold out',
      'reservar_funcion': 'Book Show',
      'cantidad_asistentes': 'Number of attendees',
      'incluido_entrada': 'Included with general admission',
      'pase_valido': 'VALID PASS',
      'ir_al_escenario': 'Go to Venue',
      'codigo_ingreso': 'ENTRY CODE',
      'escanear_qr': 'Tap to view QR',
      'te_registraste': 'You registered for a show at',
      'show_estelar_hoy': 'STAR SHOW TODAY',
      'ver_detalles': 'View details',
      'completado': 'COMPLETED',

      // Modal QR
      'tu_pase_digital': 'Your Digital Ticket',
      'sube_brillo_qr': 'Scan this QR code at the venue gate',
      'descargar_boleto': 'Save Pass',
      'cerrar': 'Close',

      // Your Route
      'rutas_habitats': 'Routes & Habitats',
      'conoce_habitats': 'EXPLORE PARK HABITATS',
      'conoce_habitats_sub':
          'Choose the animals you want to visit and trace your trail on the map.',
      'trazar_ruta': 'Trace trail to this zone',
      'animales_explorados': 'explored',

      // Profile
      'perfil_titulo': 'Explorer Profile',
      'idioma_titulo': 'APP LANGUAGE',
      'seleccionar_idioma': 'Choose your preferred language',
      'notificaciones_titulo': 'NOTIFICATIONS',
      'alertas_shows': 'Show Alerts',
      'modo_daltonismo': 'Color Blind & High Contrast',
      'tamano_texto': 'TEXT SIZE',
      'cambiar_idioma': 'Change Language',
      'idioma_espanol': 'Español',
      'idioma_ingles': 'English',
      'idioma_quechua': 'Runasimi / Quechua',
      'idioma_aimara': 'Aymar aru / Aimara',

      // Map
      'mi_ubicacion': 'My Location',
      'capas_mapa': 'Map Layers',
      'zonas_calma': 'Calm & Sensory Zones',
      'puntos_encuentro': 'Meeting points and guides',
      'filtro_banios': 'Restrooms',
      'filtro_salida': 'Exit',
      'filtro_calma': 'Calm Zone',
      'buscar_animales': 'Search animals or services...',
      'ver_ficha': 'View Details',
      'iniciar_guia': 'Start Guide',
      'visto': 'Seen',
      'marcar': 'Mark',

      // Home
      'tu_aventura': 'Your adventure starts here',
      'parque_nombre': 'Parque de las Leyendas Zoo',
      'shows_actividades': 'Shows & Activities',
      'descubre_funciones': 'Discover aquatic shows and birds',
      'animales_observados': 'Animals visited today',
      'toca_para_explorar': 'Tap to explore full list',
      'que_quieres_hacer': 'What do you want to do today?',
      'accion_shows': 'Live Shows',
      'accion_mapa': 'View Map',
      'accion_tiendas': 'Snacks & Stores',
      'accion_te_perdiste': 'Are you lost?',

      // Profile Additional
      'modo_daltonismo_tit': 'Color Blind Mode',
      'modo_daltonismo_sub': 'High contrast palette adapted for color vision',
      'modo_facil_tit': 'Easy Mode (Senior)',
      'modo_facil_sub': 'Simplified UI, large fonts, and guided voice readout',
      'alertas_shows_sub': 'Reminders 15 minutes before each show',
      'sonido_haptica': 'Sounds & Haptics',
      'sonido_haptica_sub': 'Sound effects and vibration feedback',
      'preguntas_frecuentes': 'Frequently Asked Questions',
      'llamar_emergencia': 'Emergency Hotline',

      // Easy Mode
      'modo_facil': 'Easy Mode',
      'letra_grande_sub': 'Large print & voice guidance',
      'salir': 'Exit',
      'volver_al_menu': 'Back to Menu',
      'salir_modo_facil': 'Exit Easy Mode\n(Normal Mode)',
      'bienvenido_parque': 'Welcome to the Zoo! 🦁',
      'bienvenido_sub':
          'Tap any of the big buttons below to explore the zoo easily and comfortably.',
      'escanear_placa_guia': 'Scan QR Sign / Guide',
      'escanear_camara_sub':
          'Open the camera and point at any animal sign to hear its story',
      'mapa_zoologico': 'Zoo Map',
      'mapa_facil_sub':
          'Interactive map with giant buttons for Restrooms, Exit, and Calm Zone',
      'shows_hoy': 'Today\'s Shows',
      'shows_facil_sub':
          'Large billboard with 1-tap save and confirmation feedback',
      'pedir_ayuda': 'Get Help / First Aid',
      'pedir_ayuda_sub':
          'Contact a guide or park medical first aid assistance',
      'marcar_visitado': '✅ Mark as Visited',
      'visitado_listo': 'Visited ✓ (Tap to unmark)',
      'apunte_camara':
          'Point the camera at the physical QR sign or board of any zoo animal.',
      'catalogo_animales': '🐾 Choose from Full Animal List',
      'historia_animal': '🎙️ Animal Story',
      'dieta_alimentacion': 'Diet & Feeding',
      'escanear_otra_placa': '📷 Scan another QR sign',
      'audioguia': 'Audio Guide',
      'pausar': 'Pause',
      'explorado_pasaporte': 'Explored in your Passport ✓ (Unmark)',
      'marcar_pasaporte': 'Mark in my visits passport 🐾',
      'sabias_que': 'Did you know?',
      'comportamiento_habitat': 'Habitat Behavior',
      'alimentacion_dieta_diaria': 'Daily feeding and diet',
      'horarios_alimentacion': 'Feeding schedules',
      'repetir_narracion': 'Replay narration',
      'felicitaciones_visitado': 'Congratulations! You marked as visited:',
      'busqueda_por_voz': 'Voice Search',
      'alerta_sos': 'SOS Alert',
      'trazar_en_mapa_real': 'Trace path on Map',
      'llamar_topico': 'Call Medical Clinic',
      'llamar_guardaparques': 'Call Park Rangers',
      'llamar_samu': 'Call Ambulance (106)',
      'desactivar_sos': 'Disable SOS Alert',

      // Animal Names
      'Vacas Holstein': 'Holstein Cows',
      'Ovejas': 'Sheep',
      'Rinoceronte': 'Rhinoceros',
      'Leones': 'Lions',
      'Avestruz': 'Ostrich',
      'Búfalos de agua': 'Water Buffaloes',
      'Hipopótamos del Nilo': 'Nile Hippos',
      'Dromedarios': 'Dromedaries',
      'Tigre de Bengala': 'Bengal Tiger',
      'Oso de Anteojos (Zona Internacional)': 'Spectacled Bear (Int. Zone)',
      'Cebra de Grant': 'Grant\'s Zebra',
      'Tortugas': 'Tortoises',
      'Tigre Blanco': 'White Tiger',
      'Jirafa': 'Giraffe',
      'Canguros': 'Kangaroos',
      'Suricatas': 'Meerkats',
      'Gallos (Villa Carmelo)': 'Roosters (Villa Carmelo)',
      'Pavo Real (Villa Carmelo)': 'Peacock (Villa Carmelo)',
      'Pelícanos / Aves Guaneras': 'Pelicans / Guano Birds',
      'Peces (Acuario)': 'Fishes (Aquarium)',
      'Lobos de Mar': 'Sea Lions',
      'Cocodrilo de Tumbes': 'Tumbes Crocodile',
      'Flamencos': 'Flamingos',
      'Pingüinos de Humboldt': 'Humboldt Penguins',
      'Caballos (Caballeriza)': 'Horses (Stables)',
      'Venados': 'Deers',
      'Cóndor Andino': 'Andean Condor',
      'Alpacas': 'Alpacas',
      'Zorro Andino': 'Andean Fox',
      'Puma': 'Andean Puma',
      'Águila Mora': 'Black-chested Buzzard-Eagle',
      'Vicuñas': 'Vicuñas',
      'Reptiles / Serpientes (Herpetario)': 'Reptiles & Snakes',
      'Guacamayos': 'Macaws',
      'Tapir (Sachavaca)': 'Tapir (Sachavaca)',
      'Isla de Monos': 'Monkey Island',
      'Otorongo': 'Jaguar (Otorongo)',
      'Nutria Gigante (Lobo de río)': 'Giant River Otter',
      'Anaconda': 'Green Anaconda',
      'Sajino': 'Collared Peccary (Sajino)',
      'Oso Perezoso / Mamíferos menores': 'Sloth / Small Mammals',

      // Direct Habitats
      'Granja Interactiva': 'Interactive Farm',
      'Zona Internacional': 'International Zone',
      'Zona Costa': 'Coast Zone',
      'Zona Sierra': 'Andes / Highlands Zone',
      'Zona Selva': 'Amazon / Jungle Zone',

      // Diet & Conservation
      'Herbívoro': 'Herbivore',
      'Carnívoro': 'Carnivore',
      'Omnívoro': 'Omnivore',
      'Piscívoro': 'Piscivore',
      'Carroñero': 'Scavenger',
      'Frugívoro / Herbívoro': 'Frugivore / Herbivore',
      'Insectívoro / Omnívoro': 'Insectivore / Omnivore',
      'Piscívoro / Herbívoro': 'Piscivore / Herbivore',
      'Carnívoro / Piscívoro': 'Carnivore / Piscivore',
      'Filtrador / Planctívoro': 'Filter feeder',
      'Omnívoro / Carnívoro': 'Omnivore / Carnivore',
      'Frugívoro / Granívoro': 'Frugivore / Granivore',
      'Frugívoro / Omnívoro': 'Frugivore / Omnivore',
      'Piscívoro / Carnívoro': 'Piscivore / Carnivore',
      'Omnívoro / Frugívoro': 'Omnivore / Frugivore',
      'Folívoro': 'Folivore',
      'Domesticado': 'Domesticated',
      'Casi amenazado': 'Near Threatened',
      'Vulnerable': 'Vulnerable',
      'Preocupación menor': 'Least Concern',
      'En peligro (salvaje)': 'Endangered (Wild)',
      'En peligro': 'Endangered',
      'En peligro crítico (en santuarios)': 'Critically Endangered',
      'En peligro crítico en Perú': 'Critically Endangered in Peru',
      'Diversos estados': 'Various statuses',
      'Patrimonio Cultural de la Nación': 'National Cultural Heritage',
      'Recuperada / Protegida': 'Recovered / Protected',
      'Protegido': 'Protected',

      // Localized Animal Narrations & Curiosities
      'Leones_curiosidad': 'A male lion\'s roar can be heard more than 8 kilometers away across the savannah.',
      'Leones_comportamiento': 'The only felid that lives in cooperative family prides. They sleep up to 20 hours a day to save energy.',
      'Leones_audioguia': 'Welcome to the King of the African Savannah in the International Zone. Notice the male\'s thick mane that shields his neck during battles.',
      'Cóndor Andino_curiosidad': 'With wings spanning over 3 meters, it is one of the largest flying birds in the world.',
      'Cóndor Andino_comportamiento': 'Soars gracefully on thermal wind currents for hours without flapping its enormous wings.',
      'Cóndor Andino_audioguia': 'You are standing before the sacred Andean Condor, emblem of South American mountain skies and guardian of the peaks.',
      'Vacas Holstein_curiosidad': 'They have a stomach with four chambers and can chew up to 50 times per minute while ruminating.',
      'Vacas Holstein_comportamiento': 'Gentle, sociable and friendly. They form strong friendship bonds within their herd.',
      'Vacas Holstein_audioguia': 'Welcome to the Interactive Farm. Holstein cows are famous worldwide for their black and white patches and calm demeanor.',
      'Alpacas_curiosidad': 'Their hypoallergenic wool is one of the softest and warmest fibers on Earth.',
      'Alpacas_comportamiento': 'Peaceful herd animals that communicate through gentle humming sounds and ear gestures.',
      'Alpacas_audioguia': 'The alpaca is an Andean camelid domesticated thousands of years ago in Peru. Admire their soft fleece.',
      'Otorongo_curiosidad': 'It has the strongest bite of all big cats, capable of piercing turtle shells and reptile scales.',
      'Otorongo_comportamiento': 'Solitary, stealthy hunter and an exceptional swimmer that loves water streams.',
      'Otorongo_audioguia': 'The jaguar or Otorongo is the majestic king of the Amazon rainforest. Observe its rosette-spotted coat.',
      'Pingüinos de Humboldt_curiosidad': 'They can dive up to 30 meters deep and swim at speeds of 20 km/h chasing anchovies.',
      'Pingüinos de Humboldt_comportamiento': 'Very social and energetic swimmers that nest in rocky guano burrows along the Pacific coast.',
      'Pingüinos de Humboldt_audioguia': 'These beloved penguins live along the cold Humboldt Current of the Peruvian coast.',
    },

    AppIdioma.qu: {
      // Navigation
      'nav_inicio': 'Qallariy',
      'nav_mapa': 'Saywiti',
      'nav_shows': 'Rikuchiykuna',
      'nav_ruta': 'Ñanniyki',
      'nav_perfil': 'Kikin',
      'nav_animales': 'Uywakuna',
      'nav_ayuda': 'Yanapay',
      'nav_menu': 'Muyu',

      // Shows
      'cartelera_shows': 'Rikuchiykuna Muyu',
      'mira_todo_shows': 'Tukuyta qhaway rikuchiykikunapaq',
      'banner_shows_sub':
          'Pachata akllay, kamachikuykunata yachay, maypim kan chayta tariy.',
      'ver_mis_entradas': 'Yankayniykuna',
      'ver_entradas_btn': 'Yankayniykunata qhaway',
      'activar_notificaciones': 'Willaykunata kachariy',
      'notif_sub': '15 k\'iti ñawpaqta willasaykiku',
      'horarios_fechas': 'Pachakuna & P\'unchawkuna',
      'reglas_show': 'Kamachikuykuna',
      'escenarios_info': 'Kancha & Willakuy',
      'cupos_disponibles': 'tiyanakuna kashan',
      'ultimos_cupos': '¡Asllallañam kashan!',
      'agotado': 'Tukusqañam',
      'reservar_funcion': 'Rikuchiyta Akllay',
      'cantidad_asistentes': 'Hayk\'a runakuna',
      'incluido_entrada': 'Yankaynikipi kashanña',
      'pase_valido': 'ALLIN YANKAY',
      'ir_al_escenario': 'Kanchaman Riy',
      'codigo_ingreso': 'YAYKUNA CHIP',
      'escanear_qr': 'QR qhaway',
      'te_registraste': 'Rikuchiyman qillqakurqanki kay pachapi',
      'show_estelar_hoy': 'KUNAN HATUN RIKUCHIY',
      'ver_detalles': 'Astawan qhaway',
      'completado': 'TUKUSQA',

      // Modal QR
      'tu_pase_digital': 'Anta Yankayniyki',
      'sube_brillo_qr': 'Kay QR kanchapi rikuchiy',
      'descargar_boleto': 'Yankayta Waqaychay',
      'cerrar': 'Wichq\'ay',

      // Your Route
      'rutas_habitats': 'Ñankuna & Tiqsimuyukuna',
      'conoce_habitats': 'UYWACHAKUNAPA WASINTA RIQSIY',
      'conoce_habitats_sub':
          'Mayqen uywakunatataq watukuyta munanki, saywitipi ñanta maskay.',
      'trazar_ruta': 'Kay kanchaman ñanta qillqay',
      'animales_explorados': 'riqsisqa',

      // Profile
      'perfil_titulo': 'Puriqpa Kikin',
      'idioma_titulo': 'SIMIKUNA',
      'seleccionar_idioma': 'Munashqayki simita akllay',
      'notificaciones_titulo': 'WILLAYKUNA',
      'alertas_shows': 'Rikuchiy Willaykuna',
      'modo_daltonismo': 'Llimp\'ikuna Allichay',
      'tamano_texto': 'SANANPAKUNA SAYAYNIN',
      'cambiar_idioma': 'Simita Tiyachiy',
      'idioma_espanol': 'Español',
      'idioma_ingles': 'English',
      'idioma_quechua': 'Runasimi / Quechua',
      'idioma_aimara': 'Aymar aru / Aimara',

      // Map
      'mi_ubicacion': 'Maypim Kani',
      'capas_mapa': 'Saywitipa Qatan',
      'zonas_calma': 'Ch\'in & Qasikay Kanchakuna',
      'puntos_encuentro': 'Tinkuna kiti & Yanapaq',
      'filtro_banios': 'Hisp\'ana Wasi',
      'filtro_salida': 'Lluqsina',
      'filtro_calma': 'Qasikay',
      'buscar_animales': 'Uywakunata maskay...',
      'ver_ficha': 'Uywamanta Qhaway',
      'iniciar_guia': 'Ñanta Qallariy',
      'visto': 'Riqsisqa',
      'marcar': 'Churay',

      // Home
      'tu_aventura': 'Puriyniyki kaypim qallarin',
      'parque_nombre': 'Leyendakuna Parki',
      'shows_actividades': 'Rikuchiykuna & Ruraykuna',
      'descubre_funciones': 'Yaku uywakunata & pisqukunata riqsiy',
      'animales_observados': 'Uywakuna watukusqa kunan',
      'toca_para_explorar': 'Tukuy uywakunata qhaway',
      'que_quieres_hacer': '¿Imatataq kunan rurayta munanki?',
      'accion_shows': 'Kawsay rikuchiykuna',
      'accion_mapa': 'Saywitita qhaway',
      'accion_tiendas': 'Mikhuna & Qhatu',
      'accion_te_perdiste': '¿Chinkarqunkichu?',

      // Profile Additional
      'modo_daltonismo_tit': 'Llimp\'ikuna Allichay',
      'modo_daltonismo_sub': 'K\'anchaq llimp\'ikuna ñawipaq allin qhawanapaq',
      'modo_facil_tit': 'Ch\'uya Ñan (Machu Runa)',
      'modo_facil_sub': 'Hatun sananpakuna, simiwan willasqa',
      'alertas_shows_sub': '15 k\'iti ñawpaqta willay',
      'sonido_haptica': 'Uywakunapa T\'uqyaynin',
      'sonido_haptica_sub': 'T\'uqyaykuna hinaspa kuyuykuna',
      'preguntas_frecuentes': 'Tapukuykuna',
      'llamar_emergencia': 'Waqyay Yanapaqta',

      // Easy Mode
      'modo_facil': 'Ch\'uya Ñan',
      'letra_grande_sub': 'Hatun sananpa, simiwan willasqa',
      'salir': 'Lluqsiy',
      'volver_al_menu': 'Kutiy Muyuman',
      'salir_modo_facil': 'Lluqsiy Ch\'uya Ñanmanta\n(Tukuy Ñan)',
      'bienvenido_parque': '¡Allin hamusqayki Parkiman! 🦁',
      'bienvenido_sub':
          'Kay hatun ñit\'inakunata ñit\'iy parkipi mana sasachakuspa purinaykipaq.',
      'escanear_placa_guia': 'QR Chipta Qhaway / Pusariq',
      'escanear_camara_sub':
          'Kamarata kicharispam uywapa letreronman churay willayninta uyarinaykipaq',
      'mapa_zoologico': 'Parkipa Saywitin',
      'mapa_facil_sub':
          'Hisp\'ana Wasi, Lluqsina, Qasikay kanchakuna hatun ñit\'inawan',
      'shows_hoy': 'Kunan Rikuchiykuna',
      'shows_facil_sub':
          'Rikuchiykuna huk ñit\'illawan waqaychanapaq',
      'pedir_ayuda': 'Yanapayta Mañakuy',
      'pedir_ayuda_sub':
          'Pusariqta utaq hanpiqta waqyay',
      'marcar_visitado': '✅ Watukusqañam',
      'visitado_listo': 'Watukusqañam ✓ (Takyay llipipipananpaq)',
      'apunte_camara':
          'Kamarata uywapa letreronman churay willayninta uyarinaykipaq.',
      'catalogo_animales': '🐾 Tukuy Uywakunamanta Akllay',
      'historia_animal': '🎙️ Uywapa Willakuynin',
      'dieta_alimentacion': 'Mikhuy & Kawsay',
      'escanear_otra_placa': '📷 Huk QR chipta qhaway',
      'audioguia': 'Uyariq Pusariq',
      'pausar': 'Sayachiy',
      'explorado_pasaporte': 'Watukusqañam ✓ (Takyay)',
      'marcar_pasaporte': 'Watukusqata pasaportiman churay 🐾',
      'sabias_que': '¿Yacharqankichu?',
      'comportamiento_habitat': 'Uywapa Kawsaynin',
      'alimentacion_dieta_diaria': 'P\'unchaw mikhuynin',
      'horarios_alimentacion': 'Mikhuna pachakuna',
      'repetir_narracion': 'Kutipay willakuyta',
      'felicitaciones_visitado': '¡Allillam! Kay uywata watukurqankim:',
      'busqueda_por_voz': 'Rimaywan Mask\'ay',
      'alerta_sos': 'Yanapay SOS',
      'trazar_en_mapa_real': 'Saywitipi Ñanta Qhaway',
      'llamar_topico': 'Hampi Wasiwan Rimay',
      'llamar_guardaparques': 'Parki Kamayuqwan Rimay',
      'llamar_samu': 'Ambulansiyaman Qayay (106)',
      'desactivar_sos': 'SOS Yanapayta Sayachiy',

      // Nombres de Animales
      'Vacas Holstein': 'Holstein Wakakuna',
      'Ovejas': 'Uwijakuna',
      'Rinoceronte': 'Rinusirunti',
      'Leones': 'Liyunkuna',
      'Avestruz': 'Suri',
      'Búfalos de agua': 'Yaku Wufalukuna',
      'Hipopótamos del Nilo': 'Nilo Hipuputamukuna',
      'Dromedarios': 'Drumidaryukuna',
      'Tigre de Bengala': 'Bengala Tikri',
      'Oso de Anteojos (Zona Internacional)': 'Ukumari (Hawamanta K\'iti)',
      'Cebra de Grant': 'Grant Sibra',
      'Tortugas': 'Charapakuna',
      'Tigre Blanco': 'Yuraq Tikri',
      'Jirafa': 'Jirafa',
      'Canguros': 'Kankurukuna',
      'Suricatas': 'Surikatakuna',
      'Gallos (Villa Carmelo)': 'K\'ank\'akuna (Villa Carmelo)',
      'Pavo Real (Villa Carmelo)': 'Pawu Riyal (Villa Carmelo)',
      'Pelícanos / Aves Guaneras': 'Alkatraskuna / Wanu Pisqukuna',
      'Peces (Acuario)': 'Challwakuna (Challwawasi)',
      'Lobos de Mar': 'Mamaqucha Allqukuna',
      'Cocodrilo de Tumbes': 'Tumpis Kayman',
      'Flamencos': 'Pariwanakuna',
      'Pingüinos de Humboldt': 'Humboldt Pikuynikuna',
      'Caballos (Caballeriza)': 'Kawallukuna',
      'Venados': 'Tarukakuna / Luychukuna',
      'Cóndor Andino': 'Antikuna Kuntur',
      'Alpacas': 'Allpakakuna',
      'Zorro Andino': 'Antikuna Atuq',
      'Puma': 'Antikuna Puma',
      'Águila Mora': 'Anka',
      'Vicuñas': 'Wik\'uñakuna',
      'Reptiles / Serpientes (Herpetario)': 'Mach\'aqwaykuna',
      'Guacamayos': 'Wakamayukuna',
      'Tapir (Sachavaca)': 'Sach\'awaka',
      'Isla de Monos': 'K\'usillukuna Wamani',
      'Otorongo': 'Uturunku',
      'Nutria Gigante (Lobo de río)': 'Hatun Mayu Allqu',
      'Anaconda': 'Yaku Mama',
      'Sajino': 'Sach\'akuchi (Sajinu)',
      'Oso Perezoso / Mamíferos menores': 'Alli-allillamanta Ukumari',

      // Direct Habitats
      'Granja Interactiva': 'Kallpa Chakra',
      'Zona Internacional': 'Hawamanta K\'iti',
      'Zona Costa': 'Chala K\'iti',
      'Zona Sierra': 'Antikuna K\'iti',
      'Zona Selva': 'Yunka K\'iti',

      // Diet & Conservation
      'Herbívoro': 'Qura mikhuq',
      'Carnívoro': 'Aycha mikhuq',
      'Omnívoro': 'Tukuy mikhuq',
      'Piscívoro': 'Challwa mikhuq',
      'Carroñero': 'Wañusqa aycha mikhuq',
      'Frugívoro / Herbívoro': 'Ruru / Qura mikhuq',
      'Insectívoro / Omnívoro': 'Kuru / Tukuy mikhuq',
      'Piscívoro / Herbívoro': 'Challwa / Qura mikhuq',
      'Carnívoro / Piscívoro': 'Aycha / Challwa mikhuq',
      'Filtrador / Planctívoro': 'Yaku suysuq mikhuq',
      'Omnívoro / Carnívoro': 'Tukuy / Aycha mikhuq',
      'Frugívoro / Granívoro': 'Ruru / Muju mikhuq',
      'Frugívoro / Omnívoro': 'Ruru / Tukuy mikhuq',
      'Piscívoro / Carnívoro': 'Challwa / Aycha mikhuq',
      'Omnívoro / Frugívoro': 'Tukuy / Ruru mikhuq',
      'Folívoro': 'Raphi mikhuq',
      'Domesticado': 'Uywasqa',
      'Casi amenazado': 'Llakipayasqaña',
      'Vulnerable': 'Waqaychanapaq',
      'Preocupación menor': 'Allillan kashan',
      'En peligro (salvaje)': 'Chinkananpaq kashan',
      'En peligro': 'Chinkananpaq kashan',
      'En peligro crítico (en santuarios)': 'Ancha llakipi',
      'En peligro crítico en Perú': 'Piruwpi ancha llakipi',
      'Diversos estados': 'Tukuy rikch\'aqkuna',
      'Patrimonio Cultural de la Nación': 'Mama Llaqtapa Kawsaynin',
      'Recuperada / Protegida': 'Allinchasqa / Waqaychasqa',
      'Protegido': 'Waqaychasqa',

      // Localized Animal Narrations & Curiosities
      'Leones_curiosidad': 'Liyunpa qapariyninqa pusaq kilumitrukama uyarikun k\'itikunapi.',
      'Leones_comportamiento': 'Ayllupuralla tiyanku. Iskay chunka urastam puñunku kallpata waqaychaspa.',
      'Leones_audioguia': 'Hawamanta K\'itipi liyunkunaman chayamurqanki. Urqu liyunpa sapranqa kunkatam amachan awqanakuypi.',
      'Cóndor Andino_curiosidad': 'Kimsa mitrukama rapran mast\'arikun, teqsimuyuntinpi aswan hatun phawaq pisqum.',
      'Cóndor Andino_comportamiento': 'Wayrapa kallpanwan hanaqpachapi muyun, mana raprankunata kuyuchispalla unayta.',
      'Cóndor Andino_audioguia': 'Antikunapa apun kunturwan kashanki. Urqukunapa k\'anchaynin hinaspa chinkana urqukunapa amachaqnin.',
      'Vacas Holstein_curiosidad': 'Tawa wisq\'asqa wiksayuqmi kanku, sapa minutupi pichqa chunka kutita kutipanku k\'uturuspa.',
      'Vacas Holstein_comportamiento': 'Sampakuna, runawan pukllaqkuna. Wakinkunawan sumaqta munanakuspa tiyanku.',
      'Vacas Holstein_audioguia': 'Kallpa Chakraman allinmi hamusqayki. Yuraq yana millwayuq wakakunam kaypi kawsanku.',
      'Alpacas_curiosidad': 'Millwanqa llanllallam hinaspa q\'uñilla, pachantinpi ancha munakusqam.',
      'Alpacas_comportamiento': 'Hawka ayllupi kawsanku, sumaq kunkayuq kuskalla purinku.',
      'Alpacas_audioguia': 'Allpakaqa unay watakunamanta piruw suyupi uywasqam. Sumaq millwanta qhaway.',
      'Otorongo_curiosidad': 'Tukuy michi rikch\'aqkunamanta aswan sinchi kiruyuqmi, charapapa qarantapas p\'akiyta atin.',
      'Otorongo_comportamiento': 'Sapallan puriq, sumaq tuytuq yaku mayukunapi puriq.',
      'Otorongo_audioguia': 'Uturunkuqa Amasunya sach\'a sach\'akunapa qhapaq apunmi. Quri q\'illu t\'ikachasqa qarantam qhaway.',
      'Pingüinos de Humboldt_curiosidad': 'Kimsa chunka mitru yakuman chinkaykuyta atinku challwakunata hapispa.',
      'Pingüinos de Humboldt_comportamiento': 'Quchapatapi tiyaq, kusisqa tuytuqkuna rumikunapa chawpinpi q\'isachanku.',
      'Pingüinos de Humboldt_audioguia': 'Piruw mamaquchapa chiri yaku Humboldt nisqanpi kawsanku kay sumaq pikuynikuna.',
    },

    AppIdioma.ay: {
      // Navigation
      'nav_inicio': 'Qallta',
      'nav_mapa': 'Saywiti',
      'nav_shows': 'Uñachäwinaka',
      'nav_ruta': 'Thakhima',
      'nav_perfil': 'Uñacht’äwi',
      'nav_animales': 'Uywanaka',
      'nav_ayuda': 'Yanapt’a',
      'nav_menu': 'Menu',

      // Shows
      'cartelera_shows': 'Uñachäwinaka Qhantawi',
      'mira_todo_shows': 'Uñachäwinakataki taqpacha uñjam',
      'banner_shows_sub':
          'Pachanak ajllim, kamachinaka yatiqam, kawkinkisa uk jikxatam.',
      'ver_mis_entradas': 'Mantawinakaja',
      'ver_entradas_btn': 'Mantawinakaja uñjam',
      'activar_notificaciones': 'Yatiyäwinak jist’aram',
      'notif_sub': '15 k’ata nayra yatiyapxäma',
      'horarios_fechas': 'Pachanak & Urunak',
      'reglas_show': 'Uñacht’äw Kamachinaka',
      'escenarios_info': 'Kancha & Yatiyäwi',
      'cupos_disponibles': 'jakhuwix utjiwa',
      'ultimos_cupos': '¡Qhipa jakhuwixa!',
      'agotado': 'Tukusiriwa',
      'reservar_funcion': 'Uñacht’äwi Imantaña',
      'cantidad_asistentes': 'Qawqha jaqinakasa',
      'incluido_entrada': 'Mantawiman utjiwa',
      'pase_valido': 'WALIKISKI MANTAWI',
      'ir_al_escenario': 'Kancharu Saraña',
      'codigo_ingreso': 'MANTAWI CHIMP',
      'escanear_qr': 'QR uñjañataki liwxatam',
      'te_registraste': 'Uñacht’äwiru qillqayasitawa akapachana',
      'show_estelar_hoy': 'JICHHURU JACH’A UÑACHÄWI',
      'ver_detalles': 'Juk’amp uñjaña',
      'completado': 'TUKUYATA',

      // Modal QR
      'tu_pase_digital': 'Anta Mantawima',
      'sube_brillo_qr': 'Aka QR uñacht’ayam kancha mantawina',
      'descargar_boleto': 'Mantawi Imantaña',
      'cerrar': 'Jist’antaña',

      // Your Route
      'rutas_habitats': 'Thakhinaka & Uywawasinaka',
      'conoce_habitats': 'PARKINA UYWANAKAPA WASINTA UÑT’AM',
      'conoce_habitats_sub':
          'Kawkiri uywanakas tumpañ munta ajllim, maparu thakhi luraña.',
      'trazar_ruta': 'Aka kitiñaru thakhi luraña',
      'animales_explorados': 'uñt’ata',

      // Profile
      'perfil_titulo': 'Sartiririn Uñacht’äwipa',
      'idioma_titulo': 'APP ARUNAKA',
      'seleccionar_idioma': 'Munat aruma ajllim',
      'notificaciones_titulo': 'YATIYÄWINAKA',
      'alertas_shows': 'Uñacht’äw Yatiyäwinaka',
      'modo_daltonismo': 'Saminak Mayjt’ayaña',
      'tamano_texto': 'QILLQANAKAN JACH’APA',
      'cambiar_idioma': 'Aru Mayjt’ayaña',
      'idioma_espanol': 'Español',
      'idioma_ingles': 'English',
      'idioma_quechua': 'Runasimi / Quechua',
      'idioma_aimara': 'Aymar aru / Aimara',

      // Map
      'mi_ubicacion': 'Kawkinktansa',
      'capas_mapa': 'Saywitina Qalltanaka',
      'zonas_calma': 'Amuki & Samart’awi Kitinaka',
      'puntos_encuentro': 'Jikisïwi kiti & Yanapiri',
      'filtro_banios': 'Ikiña Wasi / Ch’usaña',
      'filtro_salida': 'Mistuña',
      'filtro_calma': 'Samart’awi',
      'buscar_animales': 'Uywanaka jan ukax yanapanaka thaqhaña...',
      'ver_ficha': 'Uñacht’äwi Uñjaña',
      'iniciar_guia': 'Thakhi Qalltaña',
      'visto': 'Uñjata',
      'marcar': 'Chimpuntaña',

      // Home
      'tu_aventura': 'Sartasiwimax akana qallti',
      'parque_nombre': 'Leyendanak Parki',
      'shows_actividades': 'Uñachäwinaka & Luräwinaka',
      'descubre_funciones': 'Uma uywanaka & jamach’inaka uñt’am',
      'animales_observados': 'Jichhuru uñjat uywanaka',
      'toca_para_explorar': 'Taqpacha uywanaka uñjañataki liwxatam',
      'que_quieres_hacer': '¿Jichhuru kuns lurañ munta?',
      'accion_shows': 'Kusist’awi Shows',
      'accion_mapa': 'Saywiti Uñjaña',
      'accion_tiendas': 'Manq’anaka & Qhatu',
      'accion_te_perdiste': '¿Chhaqhatätati?',

      // Profile Additional
      'modo_daltonismo_tit': 'Saminak Mayjt’ayawi',
      'modo_daltonismo_sub': 'K’aja saminaka nayrataki sum uñjañataki',
      'modo_facil_tit': 'Modo Fácil (Jach’a Jaqi)',
      'modo_facil_sub': 'Jach’a qillqanaka, aruwan aruskipat uñacht’äwi',
      'alertas_shows_sub': '15 k’ata nayraqata yatiyäwi',
      'sonido_haptica': 'Uywanakan Istawipa',
      'sonido_haptica_sub': 'Ist’äwinaka ukhamaraki qhathatäwinaka',
      'preguntas_frecuentes': 'Jiskt’anaka',
      'llamar_emergencia': 'Yanapiriru Jawsaña',

      // Easy Mode
      'modo_facil': 'Modo Fácil',
      'letra_grande_sub': 'Jach’a qillqanaka, aruwan uñacht’äwi',
      'salir': 'Mistuña',
      'volver_al_menu': 'Menu-ru Kutiña',
      'salir_modo_facil': 'Modo Fácil-tat mistuña\n(Modo Normal)',
      'bienvenido_parque': '¡Suma purt’äwix Parkiru! 🦁',
      'bienvenido_sub':
          'Aka jach’a chimpunakamp parkina suma sarnaqañataki jasaki.',
      'escanear_placa_guia': 'QR Letrero Uñjaña / Irpiri',
      'escanear_camara_sub':
          'Kamarata jist’aram uywapa chimpuparu ist’añataki',
      'mapa_zoologico': 'Parkina Saywitipa',
      'mapa_facil_sub':
          'Ikiña Wasi, Mistuña, Samart’awi jach’a chimpunakampi',
      'shows_hoy': 'Jichhuru Uñachäwinaka',
      'shows_facil_sub':
          'Uñacht’äwinak mä liwxatawimp imantañataki',
      'pedir_ayuda': 'Yanapt’a Mayisiña',
      'pedir_ayuda_sub':
          'Irpiriru jan ukax qulliriru jawsaña',
      'marcar_visitado': '✅ Uñjatäxiwa',
      'visitado_listo': 'Uñjatäxiwa ✓ (Mayamp liwxatañani)',
      'apunte_camara':
          'Kamarata uywapa qillqataru chimpumpi uñacht’ayam ist’añataki.',
      'catalogo_animales': '🐾 Taqpacha Uywanakat Ajlliña',
      'historia_animal': '🎙️ Uywapan Sarnaqäwipa',
      'dieta_alimentacion': 'Manq’äwi & Kawsay',
      'escanear_otra_placa': '📷 Yaqha QR chimp uñjaña',
      'audioguia': 'Ist’iri Irpiri',
      'pausar': 'Samart’ayaña',
      'explorado_pasaporte': 'Uñjatäxiwa Pasaportemana ✓ (Mayamp)',
      'marcar_pasaporte': 'Pasaportiru chimpunta imantaña 🐾',
      'sabias_que': '¿Yattati?',
      'comportamiento_habitat': 'Uywapan Sarnaqäwipa',
      'alimentacion_dieta_diaria': 'Uru uruta manq’äwipa',
      'horarios_alimentacion': 'Manq’añ pachanakapa',
      'repetir_narracion': 'Wasitat ist’aña',
      'felicitaciones_visitado': '¡Kusisiñawa! Aka uywaru uñjatäxiwa sasaw chimpuntata:',
      'busqueda_por_voz': 'Arupi Thaqhaña',
      'alerta_sos': 'Yanapaña SOS',
      'trazar_en_mapa_real': 'Saywitina Thakhi Uñjaña',
      'llamar_topico': 'Qullañ Utaru Jawst\'aña',
      'llamar_guardaparques': 'Parkina Awatirir Jawst\'aña',
      'llamar_samu': 'Ambulansiyaru Jawst\'aña (106)',
      'desactivar_sos': 'SOS Yanapa Sayt\'ayaña',

      // Nombres de Animales
      'Vacas Holstein': 'Holstein Wakanaka',
      'Ovejas': 'Uwisanaka',
      'Rinoceronte': 'Rinusirunti',
      'Leones': 'Liyunnaka',
      'Avestruz': 'Suri',
      'Búfalos de agua': 'Uma Wufalunaka',
      'Hipopótamos del Nilo': 'Nilo Hipuputamunaka',
      'Dromedarios': 'Drumidaryunaka',
      'Tigre de Bengala': 'Bengala Tikri',
      'Oso de Anteojos (Zona Internacional)': 'Jukumari (Anqäxa K\'iti)',
      'Cebra de Grant': 'Grant Sibra',
      'Tortugas': 'Asukaranaka',
      'Tigre Blanco': 'Janq\'u Tikri',
      'Jirafa': 'Jirafa',
      'Canguros': 'Kankurunaka',
      'Suricatas': 'Surikatanaka',
      'Gallos (Villa Carmelo)': 'K\'ank\'anaka (Villa Carmelo)',
      'Pavo Real (Villa Carmelo)': 'Pawu Riyal (Villa Carmelo)',
      'Pelícanos / Aves Guaneras': 'Alkatrasnaka / Jamach\'inaka',
      'Peces (Acuario)': 'Challwanaka (Challwawasi)',
      'Lobos de Mar': 'Quta Allqunaka',
      'Cocodrilo de Tumbes': 'Tumpis Kayman',
      'Flamencos': 'Pariwananaka',
      'Pingüinos de Humboldt': 'Humboldt Jamach\'inaka',
      'Caballos (Caballeriza)': 'Kawallunaka',
      'Venados': 'Tarukanaka',
      'Cóndor Andino': 'Antinaka Kunturi',
      'Alpacas': 'Allpakanaka',
      'Zorro Andino': 'Antinaka Qamaqi',
      'Puma': 'Titi / Puma',
      'Águila Mora': 'Pakani',
      'Vicuñas': 'Wik\'uñanaka',
      'Reptiles / Serpientes (Herpetario)': 'Katari / Asirunaka',
      'Guacamayos': 'Wakamayunaka',
      'Tapir (Sachavaca)': 'Sach\'awaka',
      'Isla de Monos': 'K\'usillunaka Isla',
      'Otorongo': 'Uturunku',
      'Nutria Gigante (Lobo de río)': 'Jach\'a Jawira Allqu',
      'Anaconda': 'Jach\'a Katari',
      'Sajino': 'Kuchi (Sajinu)',
      'Oso Perezoso / Mamíferos menores': 'K\'ari Jukumari',

      // Direct Habitats
      'Granja Interactiva': 'Chiqpacha Chakra',
      'Zona Internacional': 'Anqäxa K\'iti',
      'Zona Costa': 'Quta Thaya K\'iti',
      'Zona Sierra': 'Qullu K\'iti',
      'Zona Selva': 'Muntanya K\'iti',

      // Diet & Conservation
      'Herbívoro': 'Ch\'illi manq\'iri',
      'Carnívoro': 'Aycha manq\'iri',
      'Omnívoro': 'Taqpach manq\'iri',
      'Piscívoro': 'Challwa manq\'iri',
      'Carroñero': 'Jiwayata aycha manq\'iri',
      'Frugívoro / Herbívoro': 'Achu / Ch\'illi manq\'iri',
      'Insectívoro / Omnívoro': 'Chhuxu / Taqpach manq\'iri',
      'Piscívoro / Herbívoro': 'Challwa / Ch\'illi manq\'iri',
      'Carnívoro / Piscívoro': 'Aycha / Challwa manq\'iri',
      'Filtrador / Planctívoro': 'Uma susuyiri manq\'iri',
      'Omnívoro / Carnívoro': 'Taqpach / Aycha manq\'iri',
      'Frugívoro / Granívoro': 'Achu / Jatha manq\'iri',
      'Frugívoro / Omnívoro': 'Achu / Taqpach manq\'iri',
      'Piscívoro / Carnívoro': 'Challwa / Aycha manq\'iri',
      'Omnívoro / Frugívoro': 'Taqpach / Achu manq\'iri',
      'Folívoro': 'Laphinaka manq\'iri',
      'Domesticado': 'Uywayata',
      'Casi amenazado': 'Mulljata',
      'Vulnerable': 'Waqaychatañawa',
      'Preocupación menor': 'Walikiskiwa',
      'En peligro (salvaje)': 'Chhaqtasiñatakiwa',
      'En peligro': 'Chhaqtasiñatakiwa',
      'En peligro crítico (en santuarios)': 'Sinti mulljayata',
      'En peligro crítico en Perú': 'Piruwana sinti mulljayata',
      'Diversos estados': 'Kunanay status',
      'Patrimonio Cultural de la Nación': 'Markasan Qillqañapata',
      'Recuperada / Protegida': 'Askichata / Waqaychata',
      'Protegido': 'Waqaychata',

      // Localized Animal Narrations & Curiosities
      'Leones_curiosidad': 'Urqu liyunan warariñapaxa kimsaqallqu kilumitrunakaruwa ist\'asi.',
      'Leones_comportamiento': 'Wila masi p\'iqinchata jakasipxi. Pätunka urasawa ikipxi ch\'ama waqaychañataki.',
      'Leones_audioguia': 'Anqäxa K\'itin liyunnakar uñjañataki purisïtawa. Urqu liyunan sunkhapaxa kunkaparuwa jark\'i ch\'axwawina.',
      'Cóndor Andino_curiosidad': 'Chhinqhllapaxa kimsa mitrunakawa, aka uraqpachan jach\'a jaliri jamach\'iwa.',
      'Cóndor Andino_comportamiento': 'Thayanakampiwa alayaru jali, jan chhinqhllanakapa kuyt\'ayasasa unjtasipxi.',
      'Cóndor Andino_audioguia': 'Antinakan jach\'a kunturipar uñjtasïtawa. Qullunakana awatiri ukhamaraki jark\'aqiriwa.',
      'Vacas Holstein_curiosidad': 'Pusi purakaniwa, sapa minutuna phisqha tunka kutimpiwa k\'uturapxi.',
      'Vacas Holstein_comportamiento': 'K\'uchiki, jaqinakampi sumaki aruskipiri. Mayninakampi sumaki jakasipxi.',
      'Vacas Holstein_audioguia': 'Chiqpacha Chakraru purisïtawa. Janq\'ump ch\'iyarampi wakanakaxa wali uñt\'atawa.',
      'Alpacas_curiosidad': 'T\'arwapaxa junt\'ukiwa ukhamaraki llamp\'ukiwa, taqpacha markanakan munatawa.',
      'Alpacas_comportamiento': 'Qhantati jakasiri tama uywanakawa, suma kunkampiwa aruskipapxi.',
      'Alpacas_audioguia': 'Allpakaxa nayra maranakatpacha Piruw markana uywatawa. Llamp\'u t\'arwapa uñjam.',
      'Otorongo_curiosidad': 'Taqpach phisinakat sipansa jach\'a lakar ch\'amaniwa, asukaranakasa laphapxarakiwa.',
      'Otorongo_comportamiento': 'Sapaki sarnaqiri, jawiranakana sumaki tuyuri.',
      'Otorongo_audioguia': 'Uturunkuxa muntanya k\'itin jach\'a jilaqatawa. Quri samana qalluñaparu uñjam.',
      'Pingüinos de Humboldt_curiosidad': 'Kimsa tunka mitrunaka umaru mantasawa challwanaka katusipxi.',
      'Pingüinos de Humboldt_comportamiento': 'Quta thiyana kusisita tuyuripxi, qalanak taypina tapachasipxi.',
      'Pingüinos de Humboldt_audioguia': 'Aka munata jamach\'inakaxa thaya Humboldt qutan jakasipxi.',
    },
  };
}

/// Extensión cómoda para strings: `'nav_inicio'.tr`
extension StringTranslationX on String {
  String get tr => IdiomaService.tr(this);
}
