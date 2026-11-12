/// Utilidades auxiliares para formateo de fechas y calendarios de shows
class ShowsDateUtils {
  const ShowsDateUtils._();

  static String obtenerNombreDia(DateTime fecha, int index) {
    if (index == 0) return 'Hoy';
    if (index == 1) return 'Mañana';
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return dias[fecha.weekday - 1];
  }

  static String obtenerNombreMes(int mes) {
    const meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Set', 'Oct', 'Nov', 'Dic'
    ];
    return meses[mes - 1];
  }

  static List<DateTime> generarProximosDias([int cantidad = 14]) {
    final hoy = DateTime.now();
    return List.generate(cantidad, (i) => hoy.add(Duration(days: i)));
  }

  static String formatearFechaTexto(DateTime fecha, int index) {
    return '${obtenerNombreDia(fecha, index)} ${fecha.day} de ${obtenerNombreMes(fecha.month)}';
  }
}
