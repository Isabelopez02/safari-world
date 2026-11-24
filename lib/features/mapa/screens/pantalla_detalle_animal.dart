import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/models/datos_animal.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/audioguia_service.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';

import 'detalle_animal_movil.dart';
import 'detalle_animal_tablet.dart';

/// Tema visual específico de cada hábitat para una experiencia inmersiva
class HabitatThemeData {
  final Color background;
  final Color cardBackground;
  final Color gradientStart;
  final Color gradientEnd;
  final Color accent;
  final Color badgeBg;
  final Color badgeText;
  final String emoji;
  final String nombreHabitat;

  const HabitatThemeData({
    required this.background,
    required this.cardBackground,
    required this.gradientStart,
    required this.gradientEnd,
    required this.accent,
    required this.badgeBg,
    required this.badgeText,
    required this.emoji,
    required this.nombreHabitat,
  });
}

/// Asigna paleta cromática, emoji y nombre real según el hábitat del animal
HabitatThemeData getHabitatTheme(String habitat, [Color? colorZona]) {
  final h = habitat.toLowerCase();

  // 1. ZONA COSTA & MUNDO ACUÁTICO
  if (h.contains('costa') ||
      h.contains('mar') ||
      h.contains('acua') ||
      h.contains('foca') ||
      h.contains('pinguino') ||
      h.contains('delfin') ||
      h.contains('pelicano')) {
    return const HabitatThemeData(
      background: Color(0xFFF3F8FC),
      cardBackground: Colors.white,
      gradientStart: Color(0xFFBAE6FD),
      gradientEnd: Color(0xFFE0F2FE),
      accent: Color(0xFF0284C7), // Azul oceánico
      badgeBg: Color(0xFFE0F2FE),
      badgeText: Color(0xFF0369A1),
      emoji: '🌊',
      nombreHabitat: 'Zona Costa',
    );
  }

  // 2. ZONA SIERRA & CORDILLERA DE LOS ANDES
  if (h.contains('sierra') ||
      h.contains('montaña') ||
      h.contains('andes') ||
      h.contains('condor') ||
      h.contains('vicuña') ||
      h.contains('alpaca')) {
    return const HabitatThemeData(
      background: Color(0xFFFBF8F5),
      cardBackground: Colors.white,
      gradientStart: Color(0xFFFED7AA),
      gradientEnd: Color(0xFFFFEDD5),
      accent: Color(0xFFC2410C), // Terracota andino cálido
      badgeBg: Color(0xFFFFEDD5),
      badgeText: Color(0xFF9A3412),
      emoji: '🏔️',
      nombreHabitat: 'Zona Sierra',
    );
  }

  // 3. ZONA SELVA TROPICAL & AMAZONÍA
  if (h.contains('selva') ||
      h.contains('amaz') ||
      h.contains('bosque') ||
      h.contains('mono') ||
      h.contains('otorongo')) {
    return const HabitatThemeData(
      background: Color(0xFFF2FAF4),
      cardBackground: Colors.white,
      gradientStart: Color(0xFFBBF7D0),
      gradientEnd: Color(0xFFDCFCE7),
      accent: Color(0xFF15803D), // Verde esmeralda selva
      badgeBg: Color(0xFFDCFCE7),
      badgeText: Color(0xFF166534),
      emoji: '🌴',
      nombreHabitat: 'Zona Selva',
    );
  }

  // 4. ZONA INTERNACIONAL & SABANA
  if (h.contains('internacional') ||
      h.contains('sabana') ||
      h.contains('africa') ||
      h.contains('leon') ||
      h.contains('jirafa')) {
    return const HabitatThemeData(
      background: Color(0xFFFDF8F3),
      cardBackground: Colors.white,
      gradientStart: Color(0xFFFED7AA),
      gradientEnd: Color(0xFFFEF3C7),
      accent: Color(0xFFDC2626), // Terracota / Ámbar sabana
      badgeBg: Color(0xFFFEE2E2),
      badgeText: Color(0xFF991B1B),
      emoji: '🦁',
      nombreHabitat: 'Zona Internacional',
    );
  }

  // 5. GRANJA INTERACTIVA
  if (h.contains('granja') || h.contains('carmelo')) {
    return const HabitatThemeData(
      background: Color(0xFFFAF5FF),
      cardBackground: Colors.white,
      gradientStart: Color(0xFFE9D5FF),
      gradientEnd: Color(0xFFF3E8FF),
      accent: Color(0xFF7E22CE), // Lavanda / Morado campestre
      badgeBg: Color(0xFFF3E8FF),
      badgeText: Color(0xFF6B21A8),
      emoji: '🚜',
      nombreHabitat: 'Granja Interactiva',
    );
  }

  // Fallback con el color de zona definido en el marcador
  final Color acentoFinal = colorZona ?? const Color(0xFF0E6568);
  return HabitatThemeData(
    background: const Color(0xFFF8FAFC),
    cardBackground: Colors.white,
    gradientStart: acentoFinal.withValues(alpha: 0.2),
    gradientEnd: const Color(0xFFF1F5F9),
    accent: acentoFinal,
    badgeBg: acentoFinal.withValues(alpha: 0.12),
    badgeText: acentoFinal,
    emoji: '🐾',
    nombreHabitat: habitat.isNotEmpty ? habitat : 'Zona Safari',
  );
}

/// Pantalla controladora del detalle del animal.
/// Responsiva: delega a [DetalleAnimalMovil] en celulares (< 720px)
/// y a [DetalleAnimalTablet] en pantallas grandes (>= 720px).
class PantallaDetalleAnimal extends StatefulWidget {
  final MarcadorMapa animal;
  const PantallaDetalleAnimal({super.key, required this.animal});

  @override
  State<PantallaDetalleAnimal> createState() => _PantallaDetalleAnimalState();
}

class _PantallaDetalleAnimalState extends State<PantallaDetalleAnimal>
    with TickerProviderStateMixin {
  bool _isPlayingAudio = false;
  late AnimationController _audioWaveController;

  // Controlador del sello grande animado
  late AnimationController _stampController;
  late Animation<double> _stampScaleAnimation;
  late Animation<double> _stampOpacityAnimation;
  bool _showBigCelebrationStamp = false;

  @override
  void initState() {
    super.initState();
    _audioWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _stampController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _stampScaleAnimation = Tween<double>(begin: 2.8, end: 1.0).animate(
      CurvedAnimation(parent: _stampController, curve: Curves.elasticOut),
    );
    _stampOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stampController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    AudioGuiaService.instance.addListener(_onAudioGuiaChanged);
  }

  @override
  void dispose() {
    AudioGuiaService.instance.removeListener(_onAudioGuiaChanged);
    AudioGuiaService.instance.detener();
    _audioWaveController.dispose();
    _stampController.dispose();
    super.dispose();
  }

  void _onAudioGuiaChanged() {
    if (!mounted) return;
    final isPlaying = AudioGuiaService.instance.isPlaying;
    setState(() {
      _isPlayingAudio = isPlaying;
      if (isPlaying) {
        _audioWaveController.repeat(reverse: true);
      } else {
        _audioWaveController.stop();
      }
    });
  }

  void _toggleAudioguia(DatosAnimal datos) {
    SoundService.instance.playButtonTap();
    AudioGuiaService.instance.toggleHablar(
      datos.getNarracion(widget.animal.nombre),
    );
  }

  Future<void> _marcarVisitado() async {
    SoundService.instance.playButtonTap();
    final messenger = ScaffoldMessenger.of(context);
    final nuevoEstado = await AnimalService.instance.toggleVisitado(
      widget.animal.id,
    );
    if (!mounted) return;

    if (nuevoEstado) {
      // Activar animación de sello grande de pasaporte
      setState(() {
        _showBigCelebrationStamp = true;
      });
      _stampController.forward(from: 0.0);

      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) {
          setState(() {
            _showBigCelebrationStamp = false;
          });
        }
      });
    } else {
      setState(() {});
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: nuevoEstado
            ? const Color(0xFF15803D)
            : Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            Icon(
              nuevoEstado
                  ? Icons.check_circle_rounded
                  : Icons.info_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                nuevoEstado
                    ? '¡${widget.animal.nombre.tr} ${'sellado_en_pasaporte'.tr}'
                    : '${widget.animal.nombre.tr} ${'desmarcado_pasaporte'.tr}',
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final datos = AnimalService.instance.obtenerDatos(widget.animal.nombre);
    final esVisitado = AnimalService.instance.esVisitado(widget.animal.id);
    final theme = getHabitatTheme(
      widget.animal.habitat,
      widget.animal.colorZona,
    );

    return Stack(
      children: [
        // RENDERIZADO RESPONSIVO: MÓVIL (< 720px) vs TABLET/PANTALLAS GRANDES (>= 720px)
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 720) {
              return DetalleAnimalTablet(
                animal: widget.animal,
                datos: datos,
                theme: theme,
                esVisitado: esVisitado,
                isPlayingAudio: _isPlayingAudio,
                audioWaveController: _audioWaveController,
                onToggleAudioguia: () => _toggleAudioguia(datos),
                onToggleVisitado: _marcarVisitado,
                onBack: () => Navigator.pop(context),
              );
            } else {
              return DetalleAnimalMovil(
                animal: widget.animal,
                datos: datos,
                theme: theme,
                esVisitado: esVisitado,
                isPlayingAudio: _isPlayingAudio,
                audioWaveController: _audioWaveController,
                onToggleAudioguia: () => _toggleAudioguia(datos),
                onToggleVisitado: _marcarVisitado,
                onBack: () => Navigator.pop(context),
              );
            }
          },
        ),

        // OVERLAY DEL SELLO GRANDE ANIMADO CELEBRATORIO AL MARCAR
        if (_showBigCelebrationStamp)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _stampController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: -0.22,
                        child: Transform.scale(
                          scale: _stampScaleAnimation.value,
                          child: Opacity(
                            opacity: _stampOpacityAnimation.value.clamp(
                              0.0,
                              1.0,
                            ),
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFC62828),
                          width: 4.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFC62828)
                                .withValues(alpha: 0.7),
                            width: 2.0,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 26,
                                  color: Color(0xFFC62828),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '¡EXPLORADO!',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.5,
                                    color: const Color(0xFFC62828),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.star_rounded,
                                  size: 26,
                                  color: Color(0xFFC62828),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'PASAPORTE OFICIAL SAFARI 🐾',
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: const Color(0xFFC62828),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${theme.emoji} ${theme.nombreHabitat.toUpperCase()}',
                              style: GoogleFonts.urbanist(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFC62828)
                                    .withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
