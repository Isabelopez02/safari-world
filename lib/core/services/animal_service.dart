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

  /// Total de marcadores actuales que el usuario ha visitado.
  int get totalVisitados =>
      marcadoresZoologico.where((m) => _visitadosIds.contains(m.id)).length;

  /// Total de animales registrados en el parque.
  int get totalAnimales => marcadoresZoologico.length;

  /// Porcentaje de progreso de visitas entre 0.0 y 1.0.
  double get porcentajeVisitados =>
      totalAnimales == 0 ? 0.0 : (totalVisitados / totalAnimales);

  /// Retorna la ficha documentada. Un nombre sin ficha no se rellena con datos
  /// inventados; la pantalla puede mostrarlo como pendiente de validación.
  DatosAnimal obtenerDatos(String nombre) =>
      baseDatosAnimales[nombre] ??
      const DatosAnimal(
        dieta: 'Información pendiente de validar',
        alimentos: ['No publicados'],
        horaApertura: '9:00 a. m.',
        horaCierre: '5:00 p. m.',
        habitat: 'Por confirmar',
        comportamiento:
            'Esta ficha está pendiente de validación con el equipo del parque.',
        nombreCientifico: 'Por confirmar',
        curiosidad: 'Consulta la señalética del recinto para obtener información específica.',
        estadoConservacion: 'Por verificar',
        narracionAudioguia: 'La información detallada de este animal está pendiente de validación.',
        distribucion: 'Por confirmar',
        fuente: 'Ficha pendiente de validación con el Parque de las Leyendas.',
      );

  /// Retorna todos los marcadores de animales del parque.
  List<MarcadorMapa> obtenerTodosLosAnimales() {
    return marcadoresZoologico;
  }

  /// El catálogo puede contener registros cuya ubicación actual no se conoce.
  List<MarcadorMapa> obtenerAnimalesEnMapa() => marcadoresZoologico
      .where((animal) => animal.tieneUbicacionMapa)
      .toList(growable: false);

  /// Filtra los animales por hábitat ('Todos', 'Sabana Africana', 'Selva Tropical', etc.)
  List<MarcadorMapa> obtenerPorHabitat(String habitat) {
    if (habitat == 'Todos') {
      return marcadoresZoologico;
    }
    return marcadoresZoologico
        .where((animal) => animal.habitat == habitat)
        .toList();
  }

  /// Retorna las zonas que aparecen en el catálogo de Huachipa.
  List<String> obtenerHabitats() {
    const orden = [
      'Costa',
      'Sierra',
      'Selva',
      'Selva-Internacional',
      'Felinario',
      'Zona Marina',
      'Bosque de Aves',
      'Serpentario',
      'Mundo Anfibio',
    ];
    final presentes = marcadoresZoologico.map((m) => m.habitat).toSet();
    return orden.where(presentes.contains).toList(growable: false);
  }

  /// Retorna todos los paraderos de baños disponibles.
  List<MarcadorMapa> obtenerBanios() {
    return List.unmodifiable(baniosZoologico);
  }

  /// Busca animales por nombre o hábitat.
  List<MarcadorMapa> buscarAnimales(String query) {
    final q = _normalizar(query);
    if (q.isEmpty) return obtenerTodosLosAnimales();
    return marcadoresZoologico
        .where(
          (a) =>
              _normalizar(a.nombre).contains(q) ||
              _normalizar(a.habitat).contains(q) ||
              _normalizar(obtenerDatos(a.nombre).nombreCientifico).contains(q),
        )
        .toList();
  }

  String _normalizar(String texto) {
    var valor = texto.trim().toLowerCase();
    const cambios = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
    };
    cambios.forEach((desde, hasta) => valor = valor.replaceAll(desde, hasta));
    return valor;
  }
}
