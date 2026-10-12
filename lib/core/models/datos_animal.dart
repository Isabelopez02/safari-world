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
}
