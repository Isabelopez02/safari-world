import 'package:flutter/material.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

class MarcadorMapa {
  final String id;
  final String nombre;
  final double x;
  final double y;
  final IconData icono;
  bool visitado;
  final String categoria;
  final String? imagen;

  MarcadorMapa({
    required this.id,
    required this.nombre,
    required this.x,
    required this.y,
    this.icono = Icons.pets,
    this.visitado = false,
    this.categoria = 'Todos',
    this.imagen,
  });
}

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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(
      begin: 0.9,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (!widget.marcador.visitado || widget.isSelected) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MarcadorAnimado oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((!widget.marcador.visitado || widget.isSelected) &&
        !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (widget.marcador.visitado &&
        !widget.isSelected &&
        _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color markerColor = widget.marcador.visitado
        ? AppColors.verdeClaro
        : (widget.isSelected
              ? AppColors.verdeAzulado
              : AppColors.verdePrincipal);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: SizedBox(
        width: 80,
        height: 80,
        child: Center(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Pulso
                  if (!widget.marcador.visitado || widget.isSelected)
                    Transform.scale(
                      scale: _animation.value,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: markerColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  // Icono base
                  Container(
                    width: widget.isSelected ? 54 : 44,
                    height: widget.isSelected ? 54 : 44,
                    decoration: BoxDecoration(
                      color: widget.marcador.visitado
                          ? AppColors.fondoGrisClaro
                          : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: markerColor,
                        width: widget.isSelected ? 4 : 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: widget.isSelected ? 8 : 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.marcador.icono,
                      color: markerColor,
                      size: widget.isSelected ? 26 : 22,
                    ),
                  ),
                  // Check verde si está visitado
                  if (widget.marcador.visitado)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
