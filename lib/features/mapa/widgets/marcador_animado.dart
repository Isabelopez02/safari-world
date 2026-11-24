import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

export 'package:zoologico_front/core/models/marcador_mapa.dart';

class MarcadorAnimado extends StatefulWidget {
  final MarcadorMapa marcador;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isDimmed;
  final bool isHighlighted;
  final bool mostrarEtiqueta;

  const MarcadorAnimado({
    super.key,
    required this.marcador,
    required this.onTap,
    this.isSelected = false,
    this.isDimmed = false,
    this.isHighlighted = false,
    this.mostrarEtiqueta = true,
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
    if (!widget.isDimmed && (!widget.marcador.visitado || widget.isSelected)) {
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
    if (!widget.isDimmed &&
        (!widget.marcador.visitado || widget.isSelected) &&
        !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if ((widget.isDimmed ||
            (widget.marcador.visitado && !widget.isSelected)) &&
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
    return ListenableBuilder(
      listenable: AccesibilidadService.instance,
      builder: (context, _) {
        final Widget pinWidget = widget.marcador.esZonaCalma
            ? _buildCalmZonePin()
            : (widget.marcador.esBanio
                  ? _buildBathroomPin()
                  : (widget.marcador.tipoServicio != null
                        ? _buildAccessPin()
                        : _buildAnimalParadero()));

        // Si el filtro no coincide con este marcador o hay una ruta activa, se atenúa en segundo plano
        if (widget.isDimmed) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 260),
            opacity: 0.16,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: pinWidget,
            ),
          );
        }

        // Marcador activo o enfocado: opacidad total y colores vívidos
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 260),
          opacity: 1.0,
          child: pinWidget,
        );
      },
    );
  }

  Widget _buildAnimalParadero() {
    final a11y = AccesibilidadService.instance;
    final bool a11yActivo = a11y.accesibilidadVisualActiva;

    final sound = SoundService.instance.getSoundReaction(
      widget.marcador.nombre,
    );
    final Color colorZonaBase =
        widget.marcador.colorZona ?? AppColors.verdePrincipal;
    final Color colorZona = a11y.getColorZona(
      habitat: widget.marcador.habitat,
      colorPorDefecto: colorZonaBase,
    );
    final IconData iconoZona = a11y.getIconoZona(widget.marcador.habitat);
    final String codigoZona = a11y.getCodigoZona(widget.marcador.habitat);

    final borderColor = widget.isSelected
        ? (a11yActivo ? const Color(0xFFFDE047) : const Color(0xFFFF9800))
        : (widget.marcador.visitado
              ? (a11yActivo ? const Color(0xFF4ADE80) : const Color(0xFF2E7D32))
              : colorZona);

    // Diámetro más compacto para que no sature el mapa ni tape zonas contiguas
    final double pinSize = widget.isSelected
        ? 38.0
        : (a11yActivo ? 30.0 : 28.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: SizedBox(
        width: a11yActivo ? 76 : 70,
        height: 78,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // ONOMATOPEYA FLOTANTE
            if (_showBubble)
              Positioned(
                top: -24,
                child: AnimatedBuilder(
                  animation: _bubbleController,
                  builder: (_, _) => SlideTransition(
                    position: _bubbleSlide,
                    child: FadeTransition(
                      opacity: _bubbleFade,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.verdePrincipal,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(color: Colors.black45, blurRadius: 5),
                          ],
                        ),
                        child: Text(
                          sound,
                          style: GoogleFonts.urbanist(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // CONTENIDO DEL PARADERO (AVATAR CIRCULAR COMPACTO + ETIQUETA PEGADA A LA IMAGEN)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (_, _) => Transform.scale(
                        scale: _bounceAnimation.value,
                        child: _buildAvatarWithPulse(pinSize, borderColor),
                      ),
                    ),
                    // BADGE GEOMÉTRICO DE DALTONISMO EN LA ESQUINA DEL AVATAR
                    if (a11yActivo && !widget.isDimmed)
                      Positioned(
                        top: -3,
                        left: -3,
                        child: Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: colorZona, width: 1.6),
                            boxShadow: const [
                              BoxShadow(color: Colors.black54, blurRadius: 3),
                            ],
                          ),
                          child: Icon(iconoZona, size: 11, color: colorZona),
                        ),
                      ),
                  ],
                ),
                // Letras solo visibles si NO está atenuado y mostrarEtiqueta está activo o si el marcador está seleccionado/enfocado
                if (!widget.isDimmed &&
                    (widget.mostrarEtiqueta ||
                        widget.isSelected ||
                        widget.isHighlighted))
                  Transform.translate(
                    offset: const Offset(0, -2.5),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: a11yActivo ? 74 : 66,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        color: a11yActivo
                            ? Colors
                                  .black // Negro puro para alto contraste WCAG AAA
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                        border: Border.all(
                          color: widget.isSelected
                              ? (a11yActivo
                                    ? const Color(0xFFFDE047)
                                    : const Color(0xFFFFB74D))
                              : (a11yActivo ? colorZona : colorZona),
                          width: a11yActivo ? 1.6 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (a11yActivo) ...[
                            Text(
                              codigoZona.split(' ').first,
                              style: TextStyle(
                                fontSize: 6.8,
                                fontWeight: FontWeight.bold,
                                color: colorZona,
                              ),
                            ),
                            const SizedBox(width: 2),
                          ] else ...[
                            Text(
                              widget.marcador.visitado ? '✓ ' : '🐾 ',
                              style: TextStyle(
                                fontSize: 6.5,
                                color: widget.marcador.visitado
                                    ? const Color(0xFF81C784)
                                    : const Color(0xFFFFD54F),
                              ),
                            ),
                          ],
                          Flexible(
                            child: Text(
                              widget.marcador.nombre,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.urbanist(
                                fontSize: 8.0,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.1,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
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
            // Halo de pulso (solo activo para destino o pines activos no atenuados)
            if (!widget.isDimmed &&
                (!widget.marcador.visitado || widget.isSelected))
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: size + 10,
                  height: size + 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: borderColor.withValues(alpha: 0.25),
                  ),
                ),
              ),

            // AVATAR CIRCULAR CON FOTO Y BORDE DE ALTO CONTRASTE
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: borderColor,
                  width: widget.isSelected ? 2.4 : 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 5,
                    offset: const Offset(0, 1.5),
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
                            size: size * 0.52,
                            color: borderColor,
                          ),
                        ),
                      )
                    : Container(
                        color: borderColor.withValues(alpha: 0.15),
                        child: Icon(
                          widget.marcador.icono,
                          size: size * 0.52,
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
                  padding: const EdgeInsets.all(1.2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black38, blurRadius: 2.5),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF2E7D32),
                    size: 10,
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
        ? const Color(0xFFFF9800)
        : Colors.blue.shade600;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: SizedBox(
        width: 54,
        height: 64,
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
                    if (widget.isSelected)
                      Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 38,
                          height: 38,
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
                          width: widget.isSelected ? 32 : 24,
                          height: widget.isSelected ? 32 : 24,
                          decoration: BoxDecoration(
                            color: pinColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: widget.isSelected ? 2.2 : 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.isSelected
                                    ? pinColor.withValues(alpha: 0.45)
                                    : Colors.black38,
                                blurRadius: widget.isSelected ? 6 : 3,
                                offset: const Offset(0, 1.5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.wc_rounded,
                            color: Colors.white,
                            size: widget.isSelected ? 16 : 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (!widget.isDimmed &&
                (widget.mostrarEtiqueta ||
                    widget.isSelected ||
                    widget.isHighlighted))
              Transform.translate(
                offset: const Offset(0, -2),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white, width: 1.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '🚻 Baños',
                    style: GoogleFonts.urbanist(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalmZonePin() {
    final a11y = AccesibilidadService.instance;
    final bool a11yActivo = a11y.accesibilidadVisualActiva;
    const Color pinColor = Color(0xFF10B981); // Verde esmeralda relajante

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: SizedBox(
        width: 74,
        height: 74,
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
                    // Halo relajante expansivo
                    Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: pinColor.withValues(alpha: 0.28),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (_, _) => Transform.scale(
                        scale: _bounceAnimation.value,
                        child: Container(
                          width: widget.isSelected ? 32 : 26,
                          height: widget.isSelected ? 32 : 26,
                          decoration: BoxDecoration(
                            color: a11yActivo
                                ? const Color(0xFF047857)
                                : pinColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: widget.isSelected ? 2.5 : 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: pinColor.withValues(alpha: 0.45),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.marcador.icono,
                            color: Colors.white,
                            size: widget.isSelected ? 17 : 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (!widget.isDimmed &&
                (widget.mostrarEtiqueta ||
                    widget.isSelected ||
                    widget.isHighlighted))
              Transform.translate(
                offset: const Offset(0, -2),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 72),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: a11yActivo ? Colors.black : const Color(0xFF065F46),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: a11yActivo
                          ? const Color(0xFF4ADE80)
                          : Colors.white,
                      width: a11yActivo ? 1.5 : 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🌿 ', style: TextStyle(fontSize: 7.0)),
                      Flexible(
                        child: Text(
                          'Zona Calma',
                          style: GoogleFonts.urbanist(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessPin() {
    final a11y = AccesibilidadService.instance;
    final bool a11yActivo = a11y.accesibilidadVisualActiva;

    // Colores semánticos y de alto contraste por tipo de servicio
    final Color pinColor;
    final String labelCorta;
    final String simbolo;

    switch (widget.marcador.tipoServicio) {
      case 'boleteria':
        pinColor = a11yActivo
            ? const Color(0xFFF59E0B)
            : const Color(0xFFD97706);
        labelCorta = 'Boletería';
        simbolo = '🎟️';
        break;
      case 'salida':
        pinColor = a11yActivo
            ? const Color(0xFFF43F5E)
            : const Color(0xFFE11D48);
        labelCorta = 'Salida';
        simbolo = '🚪';
        break;
      case 'estacionamiento':
        pinColor = a11yActivo
            ? const Color(0xFF38BDF8)
            : const Color(0xFF2563EB);
        labelCorta = 'Cochera';
        simbolo = '🅿️';
        break;
      case 'juegos':
        pinColor = a11yActivo
            ? const Color(0xFFC084FC)
            : const Color(0xFF9333EA);
        labelCorta = 'Juegos';
        simbolo = '🎠';
        break;
      default:
        pinColor = widget.marcador.colorZona ?? AppColors.verdeAzulado;
        labelCorta = widget.marcador.nombre.split(' ').first;
        simbolo = '📍';
    }

    final Color borderColor = widget.isSelected
        ? (a11yActivo ? const Color(0xFFFDE047) : const Color(0xFFFF9800))
        : Colors.white;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: SizedBox(
        width: 66,
        height: 68,
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
                    if (widget.isSelected)
                      Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pinColor.withValues(alpha: 0.28),
                          ),
                        ),
                      ),
                    AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (_, _) => Transform.scale(
                        scale: _bounceAnimation.value,
                        child: Container(
                          width: widget.isSelected ? 32 : 25,
                          height: widget.isSelected ? 32 : 25,
                          decoration: BoxDecoration(
                            color: pinColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: borderColor,
                              width: widget.isSelected ? 2.4 : 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.isSelected
                                    ? pinColor.withValues(alpha: 0.45)
                                    : Colors.black45,
                                blurRadius: widget.isSelected ? 6 : 3.5,
                                offset: const Offset(0, 1.5),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.marcador.icono,
                            color: Colors.white,
                            size: widget.isSelected ? 16 : 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (!widget.isDimmed &&
                (widget.mostrarEtiqueta ||
                    widget.isSelected ||
                    widget.isHighlighted))
              Transform.translate(
                offset: const Offset(0, -2),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 68),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: a11yActivo
                        ? const Color(0xFF0F172A)
                        : Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: a11yActivo ? pinColor : Colors.white60,
                      width: a11yActivo ? 1.4 : 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$simbolo ', style: const TextStyle(fontSize: 7.0)),
                      Flexible(
                        child: Text(
                          labelCorta,
                          style: GoogleFonts.urbanist(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
