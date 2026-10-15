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
  final String distribucion;
  final String fuente;
  final String descripcion;
  final String reconocimiento;
  final String reproduccion;
  final String rolEcologico;
  final List<String> recomendaciones;
  final List<String> amenazas;
  final String referenciaPresencia;
  final bool registroHistorico;
  final List<ReferenciaAnimal> fuentes;
  final String imagen;
  final String autorImagen;
  final String licenciaImagen;
  final String urlImagen;
  final String notaImagen;

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
    this.distribucion = 'Información pendiente de confirmar',
    this.fuente = 'Parque de las Leyendas · sede Huachipa',
    this.descripcion = '',
    this.reconocimiento = '',
    this.reproduccion = '',
    this.rolEcologico = '',
    this.recomendaciones = const [],
    this.amenazas = const [],
    this.referenciaPresencia = '',
    this.registroHistorico = false,
    this.fuentes = const [],
    this.imagen = '',
    this.autorImagen = '',
    this.licenciaImagen = '',
    this.urlImagen = '',
    this.notaImagen = '',
  });
}

class ReferenciaAnimal {
  final String titulo;
  final String url;

  const ReferenciaAnimal({required this.titulo, required this.url});
}
