import 'package:get_it/get_it.dart';

import '../services/accesibilidad_service.dart';
import '../services/animal_service.dart';
import '../services/audioguia_service.dart';
import '../services/emergency_service.dart';
import '../services/idioma_service.dart';
import '../services/notification_service.dart';
import '../services/sound_service.dart';

/// Instancia global del Service Locator (Contenedor de Inyección de Dependencias)
final sl = GetIt.instance;

/// Inicializa y registra todas las dependencias y servicios de la aplicación.
/// Este método debe ser invocado en el `main()` antes de `runApp()`.
Future<void> initDependencies() async {
  // 1. Servicios de Infraestructura y Preferencias de Usuario
  if (!sl.isRegistered<AccesibilidadService>()) {
    sl.registerLazySingleton<AccesibilidadService>(
      () => AccesibilidadService.instance,
    );
  }

  if (!sl.isRegistered<IdiomaService>()) {
    sl.registerLazySingleton<IdiomaService>(() => IdiomaService.instance);
  }

  if (!sl.isRegistered<NotificationService>()) {
    sl.registerLazySingleton<NotificationService>(
      () => NotificationService.instance,
    );
  }

  // 2. Servicios de Dominio y Negocio
  if (!sl.isRegistered<AnimalService>()) {
    sl.registerLazySingleton<AnimalService>(() => AnimalService.instance);
  }

  // 3. Servicios Multimedia y Audio
  if (!sl.isRegistered<SoundService>()) {
    sl.registerLazySingleton<SoundService>(() => SoundService.instance);
  }

  if (!sl.isRegistered<AudioGuiaService>()) {
    sl.registerLazySingleton<AudioGuiaService>(() => AudioGuiaService.instance);
  }

  // 4. Servicios de Seguridad y Emergencia
  if (!sl.isRegistered<EmergencyService>()) {
    sl.registerLazySingleton<EmergencyService>(() => EmergencyService.instance);
  }
}
