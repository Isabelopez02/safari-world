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

  /// Retorna la lista de hábitats disponibles en el zoológico.
  List<String> obtenerHabitats() {
    return const [
      'Todos',
      'Sabana Africana',
      'Selva Tropical',
      'Mundo Acuático',
      'La Granja',
      'Bosque & Montaña',
    ];
  }

  /// Retorna todos los paraderos de baños disponibles.
  List<MarcadorMapa> obtenerBanios() {
    return List.unmodifiable(baniosZoologico);
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
