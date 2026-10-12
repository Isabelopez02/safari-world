import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

export 'package:zoologico_front/core/models/marcador_mapa.dart';

class MarcadorAnimado extends StatefulWidget {
  final MarcadorMapa marcador;
  final VoidCallback onTap;
  final bool isSelected;

  const MarcadorAnimado({
    super.key,
    required this.marcador,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<MarcadorAnimado> createState() => _MarcadorAnimadoState();
}

class _MarcadorAnimadoState extends State<MarcadorAnimado>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  late AnimationController _bubbleController;
  late Animation<double> _bubbleFade;
  late Animation<Offset> _bubbleSlide;

  bool _showBubble = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (!widget.marcador.visitado || widget.isSelected) {
      _pulseController.repeat(reverse: true);
    }

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _bubbleFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _bubbleController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    _bubbleSlide = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.8))
        .animate(
          CurvedAnimation(
            parent: _bubbleController,
            curve: Curves.easeOutCubic,
          ),
        );
    _bubbleController.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _showBubble = false);
      }
    });
  }

  @override
  void didUpdateWidget(MarcadorAnimado old) {
    super.didUpdateWidget(old);
    if ((!widget.marcador.visitado || widget.isSelected) &&
        !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.marcador.visitado &&
        !widget.isSelected &&
        _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
    if (widget.isSelected && !old.isSelected) {
      _triggerFeedback();
    }
  }

  void _triggerFeedback() {
    _bounceController.forward(from: 0).then((_) => _bounceController.reverse());
    setState(() => _showBubble = true);
    _bubbleController.forward(from: 0);
  }

  void _handleTap() {
    if (widget.marcador.esBanio) {
      SoundService.instance.playButtonTap();
    } else {
      SoundService.instance.playAnimalTap(widget.marcador.nombre);
    }
    _triggerFeedback();
    widget.onTap();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.marcador.esBanio) return _buildBathroomPin();
    return _buildAnimalParadero();
  }

  Widget _buildAnimalParadero() {
    final sound = SoundService.instance.getSoundReaction(
      widget.marcador.nombre,
    );
    final borderColor = widget.isSelected
        ? const Color(0xFFFF9800) // Naranja dorado brillante al seleccionar
        : (widget.marcador.visitado
              ? const Color(0xFF2E7D32)
              : AppColors.verdePrincipal);

    final double pinSize = widget.isSelected ? 72.0 : 58.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: SizedBox(
        width: 104,
        height: 125,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // ONOMATOPEYA FLOTANTE
            if (_showBubble)
              Positioned(
                top: -28,
                child: AnimatedBuilder(
                  animation: _bubbleController,
                  builder: (_, _) => SlideTransition(
                    position: _bubbleSlide,
                    child: FadeTransition(
                      opacity: _bubbleFade,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.verdePrincipal,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 6),
                          ],
                        ),
                        child: Text(
                          sound,
                          style: GoogleFonts.urbanist(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // CONTENIDO DEL PARADERO (AVATAR GRANDE + NOMBRE)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (_, _) => Transform.scale(
                    scale: _bounceAnimation.value,
                    child: _buildAvatarWithPulse(pinSize, borderColor),
                  ),
                ),
                const SizedBox(height: 3),
                // Etiqueta con nombre del animal
                Container(
                  constraints: const BoxConstraints(maxWidth: 90),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.marcador.nombre,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.urbanist(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: borderColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWithPulse(double size, Color borderColor) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, _) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Halo de pulso
            if (!widget.marcador.visitado || widget.isSelected)
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: size + 16,
                  height: size + 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: borderColor.withValues(alpha: 0.18),
                  ),
                ),
              ),

            // AVATAR CIRCULAR CON FOTO GRANDE
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: borderColor,
                  width: widget.isSelected ? 3.5 : 2.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: widget.marcador.imagen != null
                    ? Image.asset(
                        widget.marcador.imagen!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: borderColor.withValues(alpha: 0.15),
                          child: Icon(
                            widget.marcador.icono,
                            size: size * 0.5,
                            color: borderColor,
                          ),
                        ),
                      )
                    : Container(
                        color: borderColor.withValues(alpha: 0.15),
                        child: Icon(
                          widget.marcador.icono,
                          size: size * 0.5,
                          color: borderColor,
                        ),
                      ),
              ),
            ),

            // BADGE VISITADO (CHECK VERDE)
            if (widget.marcador.visitado)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF2E7D32),
                    size: 16,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBathroomPin() {
    final Color pinColor = widget.isSelected
        ? const Color(0xFFFF9800) // Naranja dorado brillante al seleccionar
        : Colors.blue.shade600;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: SizedBox(
        width: 76,
        height: 96,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, _) {
                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Halo expansivo de selecciÃ³n
                    if (widget.isSelected)
                      Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pinColor.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                    AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (_, _) => Transform.scale(
                        scale: _bounceAnimation.value,
                        child: Container(
                          width: widget.isSelected ? 50 : 44,
                          height: widget.isSelected ? 50 : 44,
                          decoration: BoxDecoration(
                            color: pinColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: widget.isSelected ? 3.0 : 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.isSelected
                                    ? pinColor.withValues(alpha: 0.45)
                                    : Colors.black26,
                                blurRadius: widget.isSelected ? 10 : 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.wc_rounded,
                            color: Colors.white,
                            size: widget.isSelected ? 26 : 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? const Color(0xFFFFF3E0)
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: widget.isSelected
                      ? const Color(0xFFFFB74D)
                      : Colors.blue.shade200,
                  width: 1,
                ),
              ),
              child: Text(
                'BaÃ±o',
                style: GoogleFonts.urbanist(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: widget.isSelected
                      ? const Color(0xFFE65100)
                      : Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
