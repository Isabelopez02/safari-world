import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Idiomas disponibles en la aplicación
enum AppIdioma {
  es, // Español
  en, // English
  qu, // Runasimi / Quechua
}

/// Servicio global reactivo de traducción y localización para el zoológico.
/// Permite alternar entre Español, Inglés y Quechua instantáneamente en toda la app.
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

  // Diccionario completo de textos en los 3 idiomas
  static final Map<AppIdioma, Map<String, String>> _diccionario = {
    AppIdioma.es: {
      // Navegación
      'nav_inicio': 'Inicio',
      'nav_mapa': 'Mapa',
      'nav_shows': 'Shows',
      'nav_ruta': 'Tu Ruta',
      'nav_perfil': 'Perfil',

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

      // Mapa
      'mi_ubicacion': 'Mi Ubicación',
      'capas_mapa': 'Capas del Mapa',
      'zonas_calma': 'Zonas de Calma & Silencio',
      'puntos_encuentro': 'Puntos de encuentro y guías',
      'filtro_banios': 'Baños',
      'filtro_salida': 'Salida',
      'filtro_calma': 'Z. Tranquila',

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
      'volver_al_menu': '← Volver al Menú',
      'salir_modo_facil': 'Salir del Modo Fácil\n(Modo Normal)',
      'escanear_placa_guia': 'Escanear Placa QR / Guía',
      'mapa_zoologico': 'Mapa del Zoológico',
      'shows_hoy': 'Shows de Hoy',
      'pedir_ayuda': 'Pedir Ayuda / Tópico',
      'marcar_visitado': '✅ Marcar como Visitado',
      'visitado_listo': 'Visitado ✓ (Toque para desmarcar)',
    },

    AppIdioma.en: {
      // Navigation
      'nav_inicio': 'Home',
      'nav_mapa': 'Map',
      'nav_shows': 'Shows',
      'nav_ruta': 'Your Route',
      'nav_perfil': 'Profile',

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

      // Map
      'mi_ubicacion': 'My Location',
      'capas_mapa': 'Map Layers',
      'zonas_calma': 'Calm & Sensory Zones',
      'puntos_encuentro': 'Meeting points and guides',
      'filtro_banios': 'Restrooms',
      'filtro_salida': 'Exit',
      'filtro_calma': 'Calm Zone',

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
      'volver_al_menu': '← Back to Menu',
      'salir_modo_facil': 'Exit Easy Mode\n(Normal Mode)',
      'escanear_placa_guia': 'Scan QR Sign / Guide',
      'mapa_zoologico': 'Zoo Map',
      'shows_hoy': 'Today\'s Shows',
      'pedir_ayuda': 'Get Help / First Aid',
      'marcar_visitado': '✅ Mark as Visited',
      'visitado_listo': 'Visited ✓ (Tap to unmark)',
    },

    AppIdioma.qu: {
      // Navigation
      'nav_inicio': 'Qallariy',
      'nav_mapa': 'Saywiti',
      'nav_shows': 'Rikuchiykuna',
      'nav_ruta': 'Ñanniyki',
      'nav_perfil': 'Kikin',

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

      // Map
      'mi_ubicacion': 'Maypim Kani',
      'capas_mapa': 'Saywitipa Qatan',
      'zonas_calma': 'Ch\'in & Qasikay Kanchakuna',
      'puntos_encuentro': 'Tinkuna kiti & Yanapaq',
      'filtro_banios': 'Hisp\'ana Wasi',
      'filtro_salida': 'Lluqsina',
      'filtro_calma': 'Qasikay',

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
      'volver_al_menu': '← Kutiy Muyuman',
      'salir_modo_facil': 'Lluqsiy Ch\'uya Ñanmanta\n(Tukuy Ñan)',
      'escanear_placa_guia': 'QR Chipta Qhaway / Pusariq',
      'mapa_zoologico': 'Parkipa Saywitin',
      'shows_hoy': 'Kunan Rikuchiykuna',
      'pedir_ayuda': 'Yanapayta Mañakuy',
      'marcar_visitado': '✅ Watukusqañam',
      'visitado_listo': 'Watukusqañam ✓ (Takyay llipipipananpaq)',
    },
  };
}

/// Extensión cómoda para strings: `'nav_inicio'.tr`
extension StringTranslationX on String {
  String get tr => IdiomaService.tr(this);
}
