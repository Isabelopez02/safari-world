import 'package:flutter/services.dart';

/// Servicio centralizado de sonidos y feedback háptico del Zoológico.
/// Proporciona respuesta táctil inmediata, sonidos del sistema y la arquitectura
/// lista para conectar audios reales (.mp3) de animales.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  // Diccionario de onomatopeyas y expresiones sonoras por animal
  static const Map<String, String> _onomatopeyas = {
    'Elefante': '¡Paoooh! 🐘',
    'León': '¡Groaaar! 🦁',
    'Tigre': '¡Grrr! 🐯',
    'Leopardo': '¡Rrrhh! 🐆',
    'Mono': '¡Uh-uh ah-ah! 🐒',
    'Chimpancé': '¡Uh-ah-ah! 🦧',
    'Oso Pardo': '¡Gromph! 🐻',
    'Oso Frontino': '¡Groar! 🐻',
    'Pingüino': '¡Honk honk! 🐧',
    'Foca': '¡Arf arf! 🦭',
    'Delfín': '¡Click-click! 🐬',
    'Nutria': '¡Squeak! 🦦',
    'Cebra': '¡Hiin-hiin! 🦓',
    'Jirafa': '¡Huuuum! 🦒',
    'Camello': '¡Grumph! 🐪',
    'Cocodrilo': '¡Snap! 🐊',
    'Pelícano': '¡Clack! 🪶',
    'Vaca': '¡Muuu! 🐮',
    'Oveja': '¡Beee! 🐑',
    'Cerdo': '¡Oink! 🐷',
  };

  /// Obtiene la onomatopeya o expresión característica del animal
  String getSoundReaction(String animalNombre) {
    return _onomatopeyas[animalNombre] ?? '¡Hola! 🐾';
  }

  /// Feedback al seleccionar un marcador o animal
  Future<void> playAnimalTap(String animalNombre) async {
    // 1. Feedback háptico agradable (vibración física que se siente en mano)
    await HapticFeedback.mediumImpact();

    // 2. Click táctil de sistema
    await SystemSound.play(SystemSoundType.click);

    // NOTA PARA EL DESARROLLADOR:
    // Para reproducir un archivo de audio real de animal (.mp3):
    // 1. Agrega 'audioplayers: ^6.0.0' en tu pubspec.yaml
    // 2. Coloca tus archivos en assets/audio/ (ej. assets/audio/elefante.mp3)
    // 3. Descomenta:
    // final player = AudioPlayer();
    // await player.play(AssetSource('audio/${animalNombre.toLowerCase()}.mp3'));
  }

  /// Feedback al interactuar con botones o navegación
  Future<void> playButtonTap() async {
    await HapticFeedback.lightImpact();
    await SystemSound.play(SystemSoundType.click);
  }

  /// Feedback especial al presionar 'Mi Ubicación' (radar)
  Future<void> playRadarPulse() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.lightImpact();
  }
}
