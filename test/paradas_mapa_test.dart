import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoologico_front/core/data/datos_marcadores.dart';
import 'package:zoologico_front/core/services/animal_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Verificación de Paradas y Nodos del Mapa', () {
    test('Verifica que existen exactamente las 41 paradas solicitadas', () {
      expect(marcadoresZoologico.length, equals(41));
    });

    test('Verifica que las coordenadas corresponden exactamente a los porcentajes (x%, y%)', () {
      const double mapaAncho = 1920.0;
      const double mapaAlto = 1080.0;

      for (final m in marcadoresZoologico) {
        final expectedX = (m.porcentajeX / 100.0) * mapaAncho;
        final expectedY = (m.porcentajeY / 100.0) * mapaAlto;

        expect(
          m.x,
          closeTo(expectedX, 0.01),
          reason: 'Coordenada X incorrecta para ${m.nombre}',
        );
        expect(
          m.y,
          closeTo(expectedY, 0.01),
          reason: 'Coordenada Y incorrecta para ${m.nombre}',
        );
      }
    });

    test('Verifica paradas de Granja Interactiva (Morado)', () {
      final vacas = marcadoresZoologico.firstWhere(
        (m) => m.nombre == 'Vacas Holstein',
      );
      final ovejas = marcadoresZoologico.firstWhere(
        (m) => m.nombre == 'Ovejas',
      );

      expect(vacas.porcentajeX, equals(60.0));
      expect(vacas.porcentajeY, equals(14.0));
      expect(vacas.colorZona, equals(ColoresZonas.granja));

      expect(ovejas.porcentajeX, equals(60.0));
      expect(ovejas.porcentajeY, equals(17.0));
      expect(ovejas.colorZona, equals(ColoresZonas.granja));
    });

    test('Verifica paradas de Zona Internacional (Rojo)', () {
      final rino = marcadoresZoologico.firstWhere(
        (m) => m.nombre == 'Rinoceronte',
      );
      final leones = marcadoresZoologico.firstWhere(
        (m) => m.nombre == 'Leones',
      );
      final jirafa = marcadoresZoologico.firstWhere(
        (m) => m.nombre == 'Jirafa',
      );

      expect(rino.porcentajeX, equals(69.0));
      expect(rino.porcentajeY, equals(17.0));
      expect(rino.colorZona, equals(ColoresZonas.internacional));

      expect(leones.porcentajeX, equals(72.0));
      expect(leones.porcentajeY, equals(23.0));

      expect(jirafa.porcentajeX, equals(71.0));
      expect(jirafa.porcentajeY, equals(34.0));
    });

    test('Verifica paradas de Zona Costa (Azul)', () {
      final gallos = marcadoresZoologico.firstWhere(
        (m) => m.nombre == 'Gallos (Villa Carmelo)',
      );
      final pinguinos = marcadoresZoologico.firstWhere(
        (m) => m.nombre == 'Pingüinos de Humboldt',
      );

      expect(gallos.porcentajeX, equals(38.0));
      expect(gallos.porcentajeY, equals(38.0));
      expect(gallos.colorZona, equals(ColoresZonas.costa));

      expect(pinguinos.porcentajeX, equals(49.0));
      expect(pinguinos.porcentajeY, equals(49.0));
    });

    test('Verifica paradas de Zona Sierra (Marrón)', () {
      final caballos = marcadoresZoologico.firstWhere(
        (m) => m.nombre == 'Caballos (Caballeriza)',
      );
      final condor = marcadoresZoologico.firstWhere(
        (m) => m.nombre == 'Cóndor Andino',
      );

      expect(caballos.porcentajeX, equals(34.0));
      expect(caballos.porcentajeY, equals(27.0));
      expect(caballos.colorZona, equals(ColoresZonas.sierra));

      expect(condor.porcentajeX, equals(64.0));
      expect(condor.porcentajeY, equals(66.0));
    });

    test('Verifica paradas de Zona Selva (Verde)', () {
      final otorongo = marcadoresZoologico.firstWhere(
        (m) => m.nombre == 'Otorongo',
      );
      final anaconda = marcadoresZoologico.firstWhere(
        (m) => m.nombre == 'Anaconda',
      );

      expect(otorongo.porcentajeX, equals(72.0));
      expect(otorongo.porcentajeY, equals(50.0));
      expect(otorongo.colorZona, equals(ColoresZonas.selva));

      expect(anaconda.porcentajeX, equals(69.0));
      expect(anaconda.porcentajeY, equals(56.0));
    });

    test(
      'AnimalService obtiene fichas detalladas para cada una de las 41 paradas',
      () {
        for (final m in marcadoresZoologico) {
          final datos = AnimalService.instance.obtenerDatos(m.nombre);
          expect(datos.dieta.isNotEmpty, isTrue);
          expect(datos.narracionAudioguia.isNotEmpty, isTrue);
        }
      },
    );
  });
}
