import 'package:flutter/services.dart';

/// Servicio centralizado de sonidos y feedback háptico del Zoológico.
/// Proporciona respuesta táctil inmediata, sonidos del sistema y la arquitectura
/// lista para conectar audios reales (.mp3) de animales.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  // Diccionario de onomatopeyas y expresiones sonoras por animal
  static const Map<String, String> _onomatopeyas = {
    // Granja Interactiva
    'Vacas Holstein': '¡Muuu! 🐮',
    'Vaca': '¡Muuu! 🐮',
    'Ovejas': '¡Beee! 🐑',
    'Oveja': '¡Beee! 🐑',

    // Zona Internacional
    'Rinoceronte': '¡Snort-snort! 🦏',
    'Leones': '¡Groaaar! 🦁',
    'León': '¡Groaaar! 🦁',
    'Avestruz': '¡Boom-boom! 🦤',
    'Búfalos de agua': '¡Mruuuh! 🐃',
    'Hipopótamos del Nilo': '¡Grunt-grunt! 🦛',
    'Dromedarios': '¡Grumph! 🐪',
    'Camello': '¡Grumph! 🐪',
    'Tigre de Bengala': '¡Grrr-roaaar! 🐯',
    'Tigre': '¡Grrr! 🐯',
    'Oso de Anteojos (Zona Internacional)': '¡Groar! 🐻',
    'Oso Frontino': '¡Groar! 🐻',
    'Cebra de Grant': '¡Hiin-hiin! 🦓',
    'Cebra': '¡Hiin-hiin! 🦓',
    'Tortugas': '¡Hiss-clack! 🐢',
    'Tigre Blanco': '¡Roaaar! 🐯',
    'Jirafa': '¡Huuuum! 🦒',
    'Canguros': '¡Boing-boing! 🦘',
    'Suricatas': '¡Pip-pip-chirp! 🐾',

    // Zona Costa
    'Gallos (Villa Carmelo)': '¡Ki-kiri-kiii! 🐓',
    'Pavo Real (Villa Carmelo)': '¡May-awe! 🦚',
    'Pelícanos / Aves Guaneras': '¡Clack-clack! 🪶',
    'Pelícano': '¡Clack! 🪶',
    'Peces (Acuario)': '¡Glup-glup! 🐠',
    'Lobos de Mar': '¡Arf-arf-ouh! 🦭',
    'Foca': '¡Arf arf! 🦭',
    'Cocodrilo de Tumbes': '¡Snap-croc! 🐊',
    'Cocodrilo': '¡Snap! 🐊',
    'Flamencos': '¡Honk-honk! 🦩',
    'Pingüinos de Humboldt': '¡Honk-honk! 🐧',
    'Pingüino': '¡Honk honk! 🐧',

    // Zona Sierra
    'Caballos (Caballeriza)': '¡Hiiiiin! 🐴',
    'Venados': '¡Snort! 🦌',
    'Cóndor Andino': '¡Swoosh! 🦅',
    'Alpacas': '¡Hummm-hummm! 🦙',
    'Zorro Andino': '¡Yap-yap! 🦊',
    'Puma': '¡Purrr-hiss! 🐆',
    'Águila Mora': '¡Kreee-kreee! 🦅',
    'Vicuñas': '¡Kweee-kweee! 🦙',

    // Zona Selva
    'Reptiles / Serpientes (Herpetario)': '¡Tssss-hiss! 🐍',
    'Guacamayos': '¡Rrrraaa-caw! 🦜',
    'Tapir (Sachavaca)': '¡Pheeew! 🦛',
    'Isla de Monos': '¡Uh-uh ah-ah! 🐒',
    'Mono': '¡Uh-uh ah-ah! 🐒',
    'Otorongo': '¡Grrrr-uh! 🐆',
    'Nutria Gigante (Lobo de río)': '¡Hahaha-squeak! 🦦',
    'Nutria': '¡Squeak! 🦦',
    'Anaconda': '¡Ssssss! 🐍',
    'Sajino': '¡Chomp-oink! 🐗',
    'Cerdo': '¡Oink! 🐷',
    'Oso Perezoso / Mamíferos menores': '¡Zzzz-ah! 🦥',
    'Elefante': '¡Paoooh! 🐘',
    'Chimpancé': '¡Uh-ah-ah! 🦧',
    'Delfín': '¡Click-click! 🐬',
  };

  /// Obtiene la onomatopeya o expresión característica del animal
  String getSoundReaction(String animalNombre) {
    return _onomatopeyas[animalNombre] ?? '¡Hola! 🐾';
  }

  /// Feedback al seleccionar un marcador o animal
  Future<void> playAnimalTap(String animalNombre) async {
    await HapticFeedback.mediumImpact();
    await SystemSound.play(SystemSoundType.click);
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
