import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tamaño de letra disponible para la app
enum TamanoTexto { pequeno, mediano, grande }

/// Servicio centralizado de Accesibilidad e Inclusión para personas con discapacidad:
/// - Modo Alto Contraste (Fondo oscuro profundo #000000, texto blanco puro #FFFFFF)
/// - Modo Daltonismo para Deuteranopía / Protanopía (Símbolos geométricos y texturas tácticas)
/// - Modo Zonas de Calma / Silencio (Regulación sensorial para TEA y sobrecarga acústica)
/// - Ajuste de tamaño de fuente (Pequeño, Mediano, Grande)
class AccesibilidadService extends ChangeNotifier {
  static const String _prefKeyAltoContraste = 'modo_alto_contraste_activo';
  static const String _prefKeyDaltonismo = 'modo_daltonismo_activo';
  static const String _prefKeyZonasCalma = 'mostrar_zonas_calma_activo';
  static const String _prefKeyTamanoTexto = 'tamano_texto_preferencia';

  AccesibilidadService._() {
    _inicializacionFuture = _cargarPreferencias();
  }

  static final AccesibilidadService instance = AccesibilidadService._();

  Future<void>? _inicializacionFuture;
  bool _modoAltoContraste = false;
  bool _modoDaltonismo = false;
  bool _mostrarZonasCalma = false;
  TamanoTexto _tamanoTexto = TamanoTexto.pequeno;

  bool get modoAltoContraste => _modoAltoContraste;
  bool get modoDaltonismo => _modoDaltonismo;
  bool get mostrarZonasCalma => _mostrarZonasCalma;
  TamanoTexto get tamanoTexto => _tamanoTexto;

  /// Multiplicador de escala:
  /// - Pequeño: 1.0 (Normal / Estándar)
  /// - Mediano: 1.15 (Un poco más grande)
  /// - Grande: 1.30 (Más grande)
  double get multiplicadorEscalaTexto {
    switch (_tamanoTexto) {
      case TamanoTexto.pequeno:
        return 1.0; // Normal
      case TamanoTexto.mediano:
        return 1.15; // Un poco más grande
      case TamanoTexto.grande:
        return 1.30; // Más grande
    }
  }

  /// Asegura que las preferencias almacenadas hayan terminado de cargarse
  Future<void> inicializar() async {
    if (_inicializacionFuture != null) {
      await _inicializacionFuture;
    }
  }

  /// Retorna si cualquiera de los modos visuales accesibles está activo
  bool get accesibilidadVisualActiva => _modoAltoContraste || _modoDaltonismo;

  Future<void> _cargarPreferencias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _modoAltoContraste = prefs.getBool(_prefKeyAltoContraste) ?? false;
      _modoDaltonismo = prefs.getBool(_prefKeyDaltonismo) ?? false;
      _mostrarZonasCalma = prefs.getBool(_prefKeyZonasCalma) ?? false;

      final tamanoGuardado = prefs.getString(_prefKeyTamanoTexto);
      if (tamanoGuardado != null) {
        _tamanoTexto = TamanoTexto.values.firstWhere(
          (t) => t.name == tamanoGuardado,
          orElse: () => TamanoTexto.pequeno,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar preferencias de accesibilidad: $e');
    }
  }

  Future<void> setTamanoTexto(TamanoTexto tamano) async {
    await inicializar();
    _tamanoTexto = tamano;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyTamanoTexto, tamano.name);
    } catch (e) {
      debugPrint('Error al guardar preferencia de tamaño de texto: $e');
    }
  }

  Future<void> setModoAltoContraste(bool activo) async {
    await inicializar();
    _modoAltoContraste = activo;
    // Si se activa/desactiva alto contraste, sincronizamos daltonismo
    _modoDaltonismo = activo;
    notifyListeners();
    await _guardarPref(_prefKeyAltoContraste, activo);
    await _guardarPref(_prefKeyDaltonismo, _modoDaltonismo);
  }

  Future<void> setModoDaltonismo(bool activo) async {
    await inicializar();
    _modoDaltonismo = activo;
    if (!activo) {
      _modoAltoContraste = false;
    }
    notifyListeners();
    await _guardarPref(_prefKeyDaltonismo, activo);
    await _guardarPref(_prefKeyAltoContraste, _modoAltoContraste);
  }

  Future<void> setMostrarZonasCalma(bool activo) async {
    await inicializar();
    _mostrarZonasCalma = activo;
    notifyListeners();
    await _guardarPref(_prefKeyZonasCalma, activo);
  }

  Future<void> toggleAltoContrasteYDaltonismo() async {
    await inicializar();
    final nuevoEstado = !accesibilidadVisualActiva;
    _modoAltoContraste = nuevoEstado;
    _modoDaltonismo = nuevoEstado;
    notifyListeners();
    await _guardarPref(_prefKeyAltoContraste, nuevoEstado);
    await _guardarPref(_prefKeyDaltonismo, nuevoEstado);
  }

  Future<void> toggleZonasCalma() async {
    _mostrarZonasCalma = !_mostrarZonasCalma;
    notifyListeners();
    _guardarPref(_prefKeyZonasCalma, _mostrarZonasCalma);
  }

  Future<void> _guardarPref(String key, bool valor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, valor);
    } catch (e) {
      debugPrint('Error al guardar preferencia $key: $e');
    }
  }

  // ===========================================================================
  // PALETAS Y SÍMBOLOS DE MÁXIMA DISTINCIÓN (DEUTERANOPÍA / PROTANOPÍA)
  // ===========================================================================

  /// Símbolo geométrico distintivo por zona (para que no dependa solo del color)
  IconData getIconoZona(String habitat) {
    switch (habitat) {
      case 'Granja Interactiva':
        return Icons.star_rounded; // ⭐ Estrella
      case 'Zona Internacional':
        return Icons.change_history_rounded; // 🔺 Triángulo
      case 'Zona Costa':
        return Icons.waves_rounded; // 🌊 Olas
      case 'Zona Sierra':
        return Icons.filter_hdr_rounded; // ⛰️ Montaña
      case 'Zona Selva':
        return Icons.yard_rounded; // 🌿 Hoja / Diamante
      default:
        return Icons.place_rounded;
    }
  }

  /// Código o sigla táctica visible para personas con daltonismo
  String getCodigoZona(String habitat) {
    switch (habitat) {
      case 'Granja Interactiva':
        return '★ GRN';
      case 'Zona Internacional':
        return '▲ INT';
      case 'Zona Costa':
        return '≈ CST';
      case 'Zona Sierra':
        return '▲▲ SRA';
      case 'Zona Selva':
        return '♣ SLV';
      default:
        return '● ZON';
    }
  }

  /// Color accesible de alto contraste optimizado para daltonismo
  /// (Evita confusiones entre rojos y verdes)
  Color getColorZona({required String habitat, required Color colorPorDefecto}) {
    if (!_modoDaltonismo && !_modoAltoContraste) {
      return colorPorDefecto;
    }

    switch (habitat) {
      case 'Granja Interactiva':
        return const Color(0xFFE879F9); // Magenta / Violeta eléctrico
      case 'Zona Internacional':
        // Reemplaza el rojo (invisible en protanopía) por Amarillo Solar de máxima luminancia
        return const Color(0xFFFDE047);
      case 'Zona Costa':
        return const Color(0xFF38BDF8); // Cian cielo de alto contraste
      case 'Zona Sierra':
        return const Color(0xFFF8FAFC); // Blanco puro con borde negro
      case 'Zona Selva':
        return const Color(0xFF4ADE80); // Verde lima fluorescente
      default:
        return Colors.white;
    }
  }
}
