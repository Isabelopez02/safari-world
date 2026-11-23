import 'package:flutter_test/flutter_test.dart';
import 'package:zoologico_front/core/di/injection_container.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/audioguia_service.dart';
import 'package:zoologico_front/core/services/emergency_service.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/services/notification_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pruebas de Inyección de Dependencias (GetIt Service Locator)', () {
    setUp(() async {
      await initDependencies();
    });

    test('Verifica que todos los servicios esenciales están registrados en el contenedor', () {
      expect(sl.isRegistered<AccesibilidadService>(), isTrue);
      expect(sl.isRegistered<IdiomaService>(), isTrue);
      expect(sl.isRegistered<NotificationService>(), isTrue);
      expect(sl.isRegistered<AnimalService>(), isTrue);
      expect(sl.isRegistered<SoundService>(), isTrue);
      expect(sl.isRegistered<AudioGuiaService>(), isTrue);
      expect(sl.isRegistered<EmergencyService>(), isTrue);
    });

    test('Verifica que las instancias resueltas por el Service Locator son válidas y únicas (Singleton)', () {
      final animalService1 = sl<AnimalService>();
      final animalService2 = sl<AnimalService>();
      expect(identical(animalService1, animalService2), isTrue);

      final accesibilidad1 = sl<AccesibilidadService>();
      final accesibilidad2 = sl<AccesibilidadService>();
      expect(identical(accesibilidad1, accesibilidad2), isTrue);

      final idioma1 = sl<IdiomaService>();
      final idioma2 = sl<IdiomaService>();
      expect(identical(idioma1, idioma2), isTrue);
    });
  });
}
