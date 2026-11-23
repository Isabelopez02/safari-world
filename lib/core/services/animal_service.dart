import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/base_datos_animales.dart';
import '../data/datos_marcadores.dart';
import '../models/datos_animal.dart';
import '../models/marcador_mapa.dart';

/// Servicio centralizado para la consulta de información zoológica,
/// gestión reactiva de animales visitados con persistencia,
/// filtros por hábitat, búsqueda y paraderos del parque.
class AnimalService extends ChangeNotifier {
  static const String _prefKeyVisitados = 'animales_visitados_ids';

  AnimalService._() {
    _cargarVisitados();
  }

  static final AnimalService instance = AnimalService._();

  final Set<String> _visitadosIds = {};
  bool _inicializado = false;

  /// Indica si el servicio ya cargó el estado local de visitas.
  bool get estaInicializado => _inicializado;

  /// Carga los IDs de animales visitados guardados en almacenamiento local.
  Future<void> _cargarVisitados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guardados = prefs.getStringList(_prefKeyVisitados);
      if (guardados != null) {
        _visitadosIds.clear();
        _visitadosIds.addAll(guardados);
      } else {
        // Inicializar con los que vienen por defecto en datos
        for (final m in marcadoresZoologico) {
          if (m.visitado) {
            _visitadosIds.add(m.id);
          }
        }
      }
      _sincronizarEstados();
      _inicializado = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar animales visitados: $e');
    }
  }

  /// Sincroniza la propiedad visitado en los objetos en memoria.
  void _sincronizarEstados() {
    for (final m in marcadoresZoologico) {
      m.visitado = _visitadosIds.contains(m.id);
    }
  }

  /// Indica si un animal ha sido marcado como visitado por su ID.
  bool esVisitado(String id) {
    return _visitadosIds.contains(id);
  }

  /// Alterna el estado de visita de un animal y lo persiste localmente.
  Future<bool> toggleVisitado(String id) async {
    final nuevoEstado = !_visitadosIds.contains(id);
    await marcarVisitado(id, nuevoEstado);
    return nuevoEstado;
  }

  /// Marca explícitamente un animal como visitado o no visitado.
  Future<void> marcarVisitado(String id, bool visitado) async {
    if (visitado) {
      _visitadosIds.add(id);
    } else {
      _visitadosIds.remove(id);
    }
    _sincronizarEstados();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKeyVisitados, _visitadosIds.toList());
    } catch (e) {
      debugPrint('Error al guardar estado de visita: $e');
    }
  }

  /// Total de animales que el usuario ha visitado.
  int get totalVisitados => _visitadosIds.length;

  /// Total de animales registrados en el parque.
  int get totalAnimales => marcadoresZoologico.length;

  /// Porcentaje de progreso de visitas entre 0.0 y 1.0.
  double get porcentajeVisitados =>
      totalAnimales == 0 ? 0.0 : (_visitadosIds.length / totalAnimales);

  /// Retorna la información educativa detallada de un animal por su nombre.
  /// Si no existe, retorna una ficha predeterminada segura.
  DatosAnimal obtenerDatos(String nombre) {
    return baseDatosAnimales[nombre] ??
        const DatosAnimal(
          dieta: 'Omnívoro',
          alimentos: [
            '🌿 Vegetales frescos',
            '🍖 Proteínas nutritivas',
            '🍎 Frutas',
          ],
          horaApertura: '9:00 AM',
          horaCierre: '5:00 PM',
          habitat: 'Zoológico',
          comportamiento: 'Animal amigable y activo que disfruta de la compañía de los visitantes.',
          nombreCientifico: 'Animalia sp.',
          curiosidad: '¡Cada animal del zoológico es único, especial y vital para el equilibrio ecológico del planeta!',
          estadoConservacion: 'Protegido',
          narracionAudioguia: 'Te encuentras en una de las zonas más fascinantes del parque natural. Nuestros biólogos y veterinarios cuidan de cada ejemplar diariamente con dietas balanceadas y enriquecimiento ambiental.',
        );
  }

  /// Retorna todos los marcadores de animales del parque.
  List<MarcadorMapa> obtenerTodosLosAnimales() {
    return marcadoresZoologico;
  }

  /// Filtra los animales por hábitat ('Todos', 'Sabana Africana', 'Selva Tropical', etc.)
  List<MarcadorMapa> obtenerPorHabitat(String habitat) {
    if (habitat == 'Todos') {
      return marcadoresZoologico;
    }
    return marcadoresZoologico
        .where((animal) => animal.habitat == habitat)
        .toList();
  }

  /// Retorna la lista de hábitats y zonas disponibles en el zoológico.
  List<String> obtenerHabitats() {
    return const [
      'Todos',
      'Granja Interactiva',
      'Zona Internacional',
      'Zona Costa',
      'Zona Sierra',
      'Zona Selva',
    ];
  }

  /// Retorna exclusivamente la lista de los 5 hábitats principales sin 'Todos'.
  List<String> obtenerHabitatsPrincipales() {
    return const [
      'Granja Interactiva',
      'Zona Internacional',
      'Zona Costa',
      'Zona Sierra',
      'Zona Selva',
    ];
  }

  /// Retorna la cantidad total de animales en un hábitat específico.
  int totalEnHabitat(String habitat) {
    if (habitat == 'Todos') return totalAnimales;
    return marcadoresZoologico.where((a) => a.habitat == habitat).length;
  }

  /// Retorna la cantidad de animales visitados en un hábitat específico.
  int totalVisitadosEnHabitat(String habitat) {
    if (habitat == 'Todos') return totalVisitados;
    return marcadoresZoologico
        .where((a) => a.habitat == habitat && _visitadosIds.contains(a.id))
        .length;
  }

  /// Retorna el porcentaje de avance (0.0 a 1.0) en un hábitat específico.
  double porcentajeVisitadosEnHabitat(String habitat) {
    final total = totalEnHabitat(habitat);
    if (total == 0) return 0.0;
    return totalVisitadosEnHabitat(habitat) / total;
  }

  /// Retorna todos los paraderos de baños disponibles (4 en total).
  List<MarcadorMapa> obtenerBanios() {
    return List.unmodifiable(baniosZoologico);
  }

  /// Retorna los puntos de acceso, entradas, salidas y estacionamientos.
  List<MarcadorMapa> obtenerAccesos() {
    return List.unmodifiable(accesosZoologico);
  }

  /// Retorna las Zonas de Calma y Silencio para personas con hipersensibilidad sensorial (4 en total).
  List<MarcadorMapa> obtenerZonasCalma() {
    return List.unmodifiable(zonasCalmaZoologico);
  }

  /// Retorna la lista consolidada de absolutamente todos los marcadores y pines del mapa
  /// (animales, baños, accesos, salidas, estacionamientos, tópico médico, juegos y zonas de calma).
  List<MarcadorMapa> obtenerTodosLosPines() {
    return [
      ...marcadoresZoologico,
      ...baniosZoologico,
      ...accesosZoologico,
      ...zonasCalmaZoologico,
    ];
  }

  /// Normaliza texto para búsqueda insensible a acentos, mayúsculas y caracteres especiales.
  static String normalizarTexto(String s) {
    return s
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Extrae la raíz simplificada de palabras en español e inglés (manejo de plurales y singulares).
  static String extraerRaiz(String palabra) {
    if (palabra.length > 4 && palabra.endsWith('es')) {
      return palabra.substring(0, palabra.length - 2);
    }
    if (palabra.length > 3 && palabra.endsWith('s')) {
      return palabra.substring(0, palabra.length - 1);
    }
    return palabra;
  }

  /// Busca de manera inteligente y flexible cualquier pin del zoológico a partir de lenguaje natural
  /// por audio o texto (ej. "quiero ir a un leon", "llevame a los leones", "donde esta el baño", "salida", "jirafa").
  MarcadorMapa? buscarPinInteligente(String consulta) {
    final qNorm = normalizarTexto(consulta);
    if (qNorm.isEmpty) return null;

    final todosLosPines = obtenerTodosLosPines();

    // 1. Coincidencia directa por ID (ej. 'i02', 'g01', 'b01', 'sal_01', 'calma_01')
    for (final p in todosLosPines) {
      final pIdNorm = normalizarTexto(p.id);
      if (pIdNorm == qNorm || p.id.toLowerCase() == qNorm) {
        return p;
      }
    }

    final tokens = qNorm.split(' ').where((t) => t.isNotEmpty).toList();
    const palabrasRelleno = {
      'quiero', 'quisiera', 'deseo', 'ir', 'a', 'al', 'un', 'una', 'unos', 'unas',
      'el', 'la', 'los', 'las', 'del', 'de', 'en', 'por', 'favor',
      'llevame', 'guiame', 'orientame', 'conduceme', 'donde', 'esta', 'estan',
      'queda', 'quedan', 'como', 'llego', 'voy', 'ver', 'buscar', 'busca',
      'mostrar', 'muestrame', 'dime', 'necesito', 'saber', 'conocer', 'hacia',
      'camino', 'sendero', 'ruta', 'para', 'hasta', 'cerca',
      // Inglés
      'i', 'want', 'to', 'go', 'take', 'me', 'where', 'is', 'are', 'find', 'show',
      // Quechua
      'munani', 'rinayta', 'maypim', 'kashan',
    };

    final tokensLimpios = tokens.where((t) => !palabrasRelleno.contains(t)).toList();
    final tokensBusqueda = tokensLimpios.isNotEmpty ? tokensLimpios : tokens;

    // 2. Mapeos prioritarios por sinónimos directos para servicios críticos y traducciones
    final sinonimosDirectos = <List<String>, String>{
      // Baños
      ['bano', 'banos', 'sshh', 'wc', 'sanitario', 'sanitarios', 'inodoro', 'toilet', 'restroom', 'hispana']: 'B01',
      // Tópico / Salud / SOS
      ['topico', 'medico', 'doctor', 'enfermeria', 'auxilio', 'primeros auxilios', 'herida', 'accidente', 'ambulancia', 'salud', 'first aid']: 'AYUDA_02',
      // Salida
      ['salida', 'salir', 'retorno', 'exit']: 'SAL_01',
      // Entrada / Boletería
      ['entrada', 'entrar', 'boleteria', 'boletos', 'tickets', 'ingreso', 'ticket', 'entrance']: 'ENT_01',
      // Estacionamiento
      ['estacionamiento', 'estacionar', 'parqueo', 'cochera', 'parking', 'auto', 'carro', 'vehiculo']: 'EST_01',
      // Juegos infantiles
      ['juego', 'juegos', 'carrusel', 'infantil', 'columpios', 'ninos', 'playground']: 'JUE_01',
      // Zonas de Calma / Silencio
      ['calma', 'silencio', 'descanso', 'tranquilo', 'tranquila', 'sensorial', 'relajo', 'quiet']: 'CALMA_01',
      // Guardaparques / Punto de encuentro
      ['guardaparque', 'guardaparques', 'guardia', 'guia', 'informes', 'orientador']: 'AYUDA_01',
      // Traducciones y alias de animales frecuentes en inglés
      ['lion', 'lions']: 'I02',
      ['giraffe', 'giraffes']: 'I12',
      ['penguin', 'penguins']: 'C08',
      ['condor']: 'S03',
      ['tiger', 'tigers']: 'I07',
      ['bear', 'bears']: 'I08',
      ['monkey', 'monkeys']: 'V04',
      ['rhino', 'rhinoceros']: 'I01',
      ['hippo', 'hippopotamus']: 'I05',
    };

    for (final entry in sinonimosDirectos.entries) {
      final palabrasClave = entry.key;
      final targetId = entry.value;
      if (palabrasClave.any((clave) =>
          qNorm.contains(clave) ||
          tokensBusqueda.any((t) => t == clave || extraerRaiz(t) == extraerRaiz(clave)))) {
        for (final p in todosLosPines) {
          if (p.id == targetId) return p;
        }
      }
    }

    // 3. Puntuación inteligente sobre todos los pines del parque
    MarcadorMapa? mejorMarcador;
    int mejorPuntaje = 0;

    for (final pin in todosLosPines) {
      int score = 0;
      final pId = normalizarTexto(pin.id);
      final pNom = normalizarTexto(pin.nombre);
      final pTokens = pNom.split(' ').where((t) => t.isNotEmpty).toList();
      final pStems = pTokens.map(extraerRaiz).toList();

      // Coincidencia exacta o contenida del nombre
      if (qNorm == pNom) {
        score += 1000;
      } else if (pNom.contains(qNorm) || qNorm.contains(pNom)) {
        score += 400;
      }

      for (final t in tokensBusqueda) {
        final tStem = extraerRaiz(t);
        if (t == pId) {
          score += 500;
        } else if (pTokens.contains(t)) {
          score += 200;
        } else if (pStems.contains(tStem)) {
          score += 180;
        } else if (pTokens.any((pt) => (pt.startsWith(t) || t.startsWith(pt)) && pt.length >= 3 && t.length >= 3)) {
          score += 120;
        } else if (pStems.any((ps) => (ps.startsWith(tStem) || tStem.startsWith(ps)) && ps.length >= 3 && tStem.length >= 3)) {
          score += 100;
        } else if (pNom.contains(t) || pNom.contains(tStem)) {
          score += 60;
        }
      }

      if (score > mejorPuntaje) {
        mejorPuntaje = score;
        mejorMarcador = pin;
      }
    }

    if (mejorPuntaje >= 60) {
      return mejorMarcador;
    }

    return null;
  }

  /// Busca animales por nombre o hábitat.
  List<MarcadorMapa> buscarAnimales(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return obtenerTodosLosAnimales();
    return marcadoresZoologico
        .where(
          (a) =>
              a.nombre.toLowerCase().contains(q) ||
              a.habitat.toLowerCase().contains(q) ||
              a.categoria.toLowerCase().contains(q),
        )
        .toList();
  }
}
