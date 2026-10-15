import '../models/datos_animal.dart';
import 'catalogo_fauna.dart';

/// Un único catálogo respalda tanto las fichas como sus fotografías y marcadores.
final Map<String, DatosAnimal> baseDatosAnimales = Map.unmodifiable({
  for (final registro in catalogoFauna) registro.nombre: registro.datos,
});
