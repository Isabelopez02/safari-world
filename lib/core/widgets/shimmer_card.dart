import 'package:flutter/material.dart';

/// Shimmer sweep widget: efecto de brillo animado estilo videojuego.
class ShimmerSweep extends StatefulWidget {
  const ShimmerSweep({super.key});

  @override
  State<ShimmerSweep> createState() => _ShimmerSweepState();
}

class _ShimmerSweepState extends State<ShimmerSweep>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _anim = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: const Alignment(-1.5, -1),
            end: const Alignment(1.5, 1),
            colors: [
              Colors.transparent,
              Colors.white.withValues(alpha: 0.22),
              Colors.transparent,
            ],
            stops: [
              (_anim.value - 0.25).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 0.25).clamp(0.0, 1.0),
            ],
          ).createShader(bounds),
          child: Container(color: Colors.white),
        );
      },
    );
  }
}
