import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/models/datos_animal.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/audioguia_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

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

HabitatThemeData getHabitatTheme(String habitat) {
  final h = habitat.toLowerCase();
  if (h.contains('sabana')) {
    return const HabitatThemeData(
      background: Color(0xFFFDFBF7),
      cardBackground: Color(0xFFFFFBEB),
      gradientStart: Color(0xFFFEF3C7),
      gradientEnd: Color(0xFFFFFBEB),
      accent: Color(0xFFD97706),
      badgeBg: Color(0xFFFDE68A),
      badgeText: Color(0xFF92400E),
      emoji: '🦁',
      nombreHabitat: 'Sabana Africana',
    );
  } else if (h.contains('selva')) {
    return const HabitatThemeData(
      background: Color(0xFFF7FBF8),
      cardBackground: Color(0xFFF0FDF4),
      gradientStart: Color(0xFFDCFCE7),
      gradientEnd: Color(0xFFF0FDF4),
      accent: Color(0xFF16A34A),
      badgeBg: Color(0xFFBBF7D0),
      badgeText: Color(0xFF166534),
      emoji: '🌴',
      nombreHabitat: 'Selva Tropical',
    );
  } else if (h.contains('acua') || h.contains('mar') || h.contains('foca') || h.contains('pinguino') || h.contains('delfin')) {
    return const HabitatThemeData(
      background: Color(0xFFF6FAFC),
      cardBackground: Color(0xFFF0F9FF),
      gradientStart: Color(0xFFE0F2FE),
      gradientEnd: Color(0xFFF0F9FF),
      accent: Color(0xFF0284C7),
      badgeBg: Color(0xFFBAE6FD),
      badgeText: Color(0xFF075985),
      emoji: '🐬',
      nombreHabitat: 'Mundo Acuático',
    );
  } else if (h.contains('granja')) {
    return const HabitatThemeData(
      background: Color(0xFFFCFDF6),
      cardBackground: Color(0xFFFEFCE8),
      gradientStart: Color(0xFFF7FEE7),
      gradientEnd: Color(0xFFFEFCE8),
      accent: Color(0xFF65A30D),
      badgeBg: Color(0xFFECFCCB),
      badgeText: Color(0xFF3F6212),
      emoji: '🚜',
      nombreHabitat: 'La Granja',
    );
  } else {
    // Bosque & Montaña / Por defecto
    return const HabitatThemeData(
      background: Color(0xFFF8FAFC),
      cardBackground: Color(0xFFF1F5F9),
      gradientStart: Color(0xFFE2E8F0),
      gradientEnd: Color(0xFFF1F5F9),
      accent: Color(0xFF475569),
      badgeBg: Color(0xFFCBD5E1),
      badgeText: Color(0xFF1E293B),
      emoji: '🏔️',
      nombreHabitat: 'Bosque & Montaña',
    );
  }
}

/// Pantalla minimalista de detalle y ficha de campo de cada animal.
/// Personalizada por hábitat con sello grande animado de pasaporte explorador.
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
      CurvedAnimation(parent: _stampController, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
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
    AudioGuiaService.instance.toggleHablar(datos.narracionAudioguia);
  }

  Future<void> _marcarVisitado(bool esVisitadoActual) async {
    SoundService.instance.playButtonTap();
    final messenger = ScaffoldMessenger.of(context);
    final nuevoEstado = await AnimalService.instance.toggleVisitado(widget.animal.id);
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
        backgroundColor: nuevoEstado ? const Color(0xFF2E7D32) : Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            Icon(
              nuevoEstado ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                nuevoEstado
                    ? '¡${widget.animal.nombre} sellado en tu pasaporte! 🎉'
                    : '${widget.animal.nombre} desmarcado de visitas',
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
    final theme = getHabitatTheme(widget.animal.habitat);

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          // FONDO AMBIENTAL SEGÚN EL HÁBITAT
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.gradientStart.withValues(alpha: 0.5),
                    theme.background,
                  ],
                ),
              ),
            ),
          ),

          // CONTENIDO PRINCIPAL
          SafeArea(
            child: Column(
              children: [
                // BARRA SUPERIOR MINIMALISTA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          SoundService.instance.playButtonTap();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textoOscuro,
                            size: 17,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${theme.emoji} Ficha de Explorador',
                            style: GoogleFonts.urbanist(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textoOscuro,
                            ),
                          ),
                        ],
                      ),
                      // BOTÓN AUDIOGUÍA MINIMALISTA
                      GestureDetector(
                        onTap: () => _toggleAudioguia(datos),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _isPlayingAudio
                                ? const Color(0xFFFF9800)
                                : theme.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isPlayingAudio
                                  ? const Color(0xFFFF9800)
                                  : theme.accent.withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isPlayingAudio
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.headphones_rounded,
                                color: _isPlayingAudio
                                    ? Colors.white
                                    : theme.accent,
                                size: 15,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _isPlayingAudio ? 'Pausar' : 'Audioguía',
                                style: GoogleFonts.urbanist(
                                  color: _isPlayingAudio
                                      ? Colors.white
                                      : theme.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // CONTENIDO SCROLLEABLE
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),

                        // TARJETA DE PRESENTACIÓN DEL ANIMAL CON SU HÁBITAT Y SELLO
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: theme.accent.withValues(alpha: 0.25),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.accent.withValues(alpha: 0.10),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Foto circular del animal con borde del hábitat
                                  Hero(
                                    tag: 'animal_icon_${widget.animal.id}',
                                    child: Container(
                                      width: 95,
                                      height: 95,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: theme.accent,
                                          width: 3.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.accent.withValues(alpha: 0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: widget.animal.imagen != null
                                            ? Image.asset(
                                                widget.animal.imagen!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  color: theme.accent,
                                                  child: Icon(
                                                    widget.animal.icono,
                                                    size: 46,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                color: theme.accent,
                                                child: Icon(
                                                  widget.animal.icono,
                                                  size: 46,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Datos principales a la derecha
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Badge hábitat temático
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: theme.badgeBg,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${theme.emoji} ${theme.nombreHabitat}',
                                                style: GoogleFonts.urbanist(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                  color: theme.badgeText,
                                                ),
                                              ),
                                            ),
                                            // Chip zona
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '#${widget.animal.id}',
                                                style: GoogleFonts.urbanist(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          widget.animal.nombre,
                                          style: GoogleFonts.urbanist(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textoOscuro,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        Text(
                                          datos.nombreCientifico,
                                          style: GoogleFonts.urbanist(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: theme.accent,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          datos.habitat,
                                          style: GoogleFonts.urbanist(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // SELLO DE PASAPORTE EXPLORADOR EN LA TARJETA (CUANDO ESTÁ VISITADO)
                            if (esVisitado)
                              Positioned(
                                top: -8,
                                right: 10,
                                child: Transform.rotate(
                                  angle: -0.16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC62828).withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFC62828),
                                        width: 2.2,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: const Color(0xFFC62828).withValues(alpha: 0.6),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 13,
                                            color: Color(0xFFC62828),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            'EXPLORADO 🐾',
                                            style: GoogleFonts.urbanist(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.0,
                                              color: const Color(0xFFC62828),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // REPRODUCTOR AUDIOGUÍA EXPANDIBLE MINIMALISTA
                        if (_isPlayingAudio) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFFB74D),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.graphic_eq_rounded,
                                      color: Color(0xFFE65100),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Narración Guía Zoo Oficial',
                                      style: GoogleFonts.urbanist(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFFE65100),
                                      ),
                                    ),
                                    const Spacer(),
                                    AnimatedBuilder(
                                      animation: _audioWaveController,
                                      builder: (context, child) {
                                        return Row(
                                          children: List.generate(4, (i) {
                                            final h = 5.0 +
                                                (11.0 *
                                                    ((_audioWaveController.value +
                                                            (i * 0.25)) %
                                                        1.0));
                                            return Container(
                                              margin: const EdgeInsets.only(left: 3),
                                              width: 3,
                                              height: h,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE65100),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            );
                                          }),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  datos.narracionAudioguia,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    color: Colors.brown.shade800,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),

                        // CHIPS DE ESTADO EN FILA MINIMALISTA
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _chipInfo(
                              icon: Icons.restaurant_rounded,
                              label: datos.dieta,
                              color: theme.accent,
                            ),
                            _chipInfo(
                              icon: Icons.terrain_rounded,
                              label: theme.nombreHabitat,
                              color: theme.accent,
                            ),
                            _chipInfo(
                              icon: Icons.shield_rounded,
                              label: datos.estadoConservacion,
                              color: const Color(0xFFE65100),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // HORARIOS Y ALIMENTACIÓN (2 COLUMNAS COMPACTAS)
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.schedule_rounded,
                                          size: 15,
                                          color: theme.accent,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Horarios',
                                          style: GoogleFonts.urbanist(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textoOscuro,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${datos.horaApertura} - ${datos.horaCierre}',
                                      style: GoogleFonts.urbanist(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: theme.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.restaurant_menu_rounded,
                                          size: 15,
                                          color: theme.accent,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Dieta diaria',
                                          style: GoogleFonts.urbanist(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textoOscuro,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      datos.alimentos.take(2).join(', '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.urbanist(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: theme.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // COMPORTAMIENTO COMPACTO
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.psychology_rounded,
                                    size: 16,
                                    color: theme.accent,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Comportamiento en hábitat',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textoOscuro,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                datos.comportamiento,
                                style: GoogleFonts.urbanist(
                                  fontSize: 12.5,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // CURIOSIDAD COMPACTA "¿SABÍAS QUE? 💡" CON FONDO DEL HÁBITAT
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.gradientStart.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.accent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('💡', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '¿Sabías que?',
                                      style: GoogleFonts.urbanist(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: theme.accent,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      datos.curiosidad,
                                      style: GoogleFonts.urbanist(
                                        fontSize: 12,
                                        color: Colors.grey[800],
                                        height: 1.35,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // BOTÓN DE ACCIÓN INFERIOR: MARCAR EN MI PASAPORTE DE VISITAS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _marcarVisitado(esVisitado),
                      icon: Icon(
                        esVisitado ? Icons.check_circle_rounded : Icons.bookmark_add_rounded,
                        size: 18,
                      ),
                      label: Text(
                        esVisitado
                            ? 'Animal Explorado ✓ (Toca para desmarcar)'
                            : 'Marcar en mi pasaporte de visitas 🐾',
                        style: GoogleFonts.urbanist(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: esVisitado ? const Color(0xFF2E7D32) : theme.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // OVERLAY DEL SELLO GRANDE ANIMADO CELEBRATORIO AL MARCAR
          if (_showBigCelebrationStamp)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.28),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _stampController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: -0.22,
                          child: Transform.scale(
                            scale: _stampScaleAnimation.value,
                            child: Opacity(
                              opacity: _stampOpacityAnimation.value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFC62828), width: 4.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFC62828).withValues(alpha: 0.7),
                              width: 2.0,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, size: 26, color: Color(0xFFC62828)),
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
                                  const Icon(Icons.star_rounded, size: 26, color: Color(0xFFC62828)),
                                ],
                              ),
                              const SizedBox(width: 6),
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
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFC62828).withValues(alpha: 0.85),
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
      ),
    );
  }

  Widget _chipInfo({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
