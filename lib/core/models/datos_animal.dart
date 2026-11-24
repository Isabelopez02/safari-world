import '../services/idioma_service.dart';

/// Modelo de datos para la información zoológica y educativa de un animal.
class DatosAnimal {
  final String dieta;
  final List<String> alimentos;
  final String horaApertura;
  final String horaCierre;
  final String habitat;
  final String comportamiento;
  final String nombreCientifico;
  final String curiosidad;
  final String estadoConservacion;
  final String narracionAudioguia;

  const DatosAnimal({
    required this.dieta,
    required this.alimentos,
    required this.horaApertura,
    required this.horaCierre,
    required this.habitat,
    required this.comportamiento,
    required this.nombreCientifico,
    required this.curiosidad,
    required this.estadoConservacion,
    required this.narracionAudioguia,
  });

  /// Retorna la curiosidad localizada si existe en el diccionario activo, o la versión por defecto.
  String getCuriosidad(String animalNombre) {
    final key = '${animalNombre}_curiosidad';
    final trad = IdiomaService.tr(key);
    return trad != key ? trad : curiosidad;
  }

  /// Retorna el comportamiento localizado si existe en el diccionario activo, o la versión por defecto.
  String getComportamiento(String animalNombre) {
    final key = '${animalNombre}_comportamiento';
    final trad = IdiomaService.tr(key);
    return trad != key ? trad : comportamiento;
  }

  /// Retorna la narración de audioguía localizada si existe en el diccionario activo, o la versión por defecto.
  String getNarracion(String animalNombre) {
    final key = '${animalNombre}_audioguia';
    final trad = IdiomaService.tr(key);
    return trad != key ? trad : narracionAudioguia;
  }
}
