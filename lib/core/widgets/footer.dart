import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

// 🎨 PALETA OUTDOOR (respeta la que ya usas)
class AppColors {
  static const fondo       = Color(0xFFFDF6EC);
  static const verde       = Color(0xFF5C8D3E);
  static const verdeOscuro = Color(0xFF4A7C2F);
  static const textoGris   = Color(0xFF8B7D6B);
  static const barraOscura = Color(0xFF1E1E1E);
}

class FooterZoologico extends StatefulWidget {
  final int indiceActual;
  final ValueChanged<int> alCambiarTab;

  const FooterZoologico({
    super.key,
    required this.indiceActual,
    required this.alCambiarTab,
  });

  @override
  State<FooterZoologico> createState() => _FooterZoologicoState();
}

class _FooterZoologicoState extends State<FooterZoologico>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animacion;
  late int _indiceAnterior;
  late int _indiceActualInterno;

  // 🔹 Lista de items (usa IconData de HugeIcons directamente)
  final List<_NavItemZoologico> _items = const [
    _NavItemZoologico(
      icono: HugeIcons.strokeRoundedHome01,
      label: 'Inicio',
    ),
    _NavItemZoologico(
      icono: HugeIcons.strokeRoundedFire,
      label: 'Fuego',
    ),
    _NavItemZoologico(
      icono: HugeIcons.strokeRoundedSettings01,
      label: 'Ajustes',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _indiceActualInterno = widget.indiceActual;
    _indiceAnterior = widget.indiceActual;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      value: 1.0,
    );
    _animacion = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant FooterZoologico oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.indiceActual != widget.indiceActual) {
      _indiceAnterior = _indiceActualInterno;
      _indiceActualInterno = widget.indiceActual;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SizedBox(
        height: 78,
        child: AnimatedBuilder(
          animation: _animacion,
          builder: (context, _) {
            final t = _animacion.value;
            final posicion =
                _indiceAnterior + (_indiceActualInterno - _indiceAnterior) * t;

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final itemWidth = width / _items.length;
                final centroX = itemWidth * posicion + itemWidth / 2;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) {
                    final x = details.localPosition.dx;
                    final index =
                        (x / itemWidth).floor().clamp(0, _items.length - 1);
                    if (index != widget.indiceActual) {
                      HapticFeedback.selectionClick();
                      widget.alCambiarTab(index);
                    }
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 🔸 Barra oscura con muesca curva
                      CustomPaint(
                        size: Size(width, 78),
                        painter: _NotchPainter(
                          centroX: centroX,
                          colorBarra: AppColors.barraOscura,
                          radioNotch: 32,
                        ),
                      ),

                      // 🔸 Íconos inactivos (los visibles)
                      Positioned.fill(
                        child: Row(
                          children: List.generate(_items.length, (i) {
                            final activo = i == widget.indiceActual;
                            return Expanded(
                              child: Center(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 180),
                                  opacity: activo ? 0 : 1,
                                  child: HugeIcon(
                                    icon: _items[i].icono,
                                    color: Colors.white.withOpacity(0.6),
                                    size: 24,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // 🔸 Círculo elevado (sigue al tab activo)
                      Positioned(
                        top: -4,
                        left: centroX - 32,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.verde,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.barraOscura,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: HugeIcon(
                                  icon: _items[_indiceActualInterno].icono,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NavItemZoologico {
  final dynamic icono;
  final String label;
  const _NavItemZoologico({required this.icono, required this.label});
}

// ============================================================
// 🎨 PAINTER DE LA MUESCA CURVA
// ============================================================
class _NotchPainter extends CustomPainter {
  final double centroX;
  final Color colorBarra;
  final double radioNotch;

  _NotchPainter({
    required this.centroX,
    required this.colorBarra,
    required this.radioNotch,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorBarra
      ..style = PaintingStyle.fill;

    final path = Path();
    const radioEsquina = 28.0;
    final y = 12.0;

    path.moveTo(radioEsquina, y);
    path.lineTo(centroX - radioNotch - 20, y);

    path.cubicTo(
      centroX - radioNotch - 5, y,
      centroX - radioNotch, y + 20,
      centroX - radioNotch, y + 28,
    );

    path.arcToPoint(
      Offset(centroX + radioNotch, y + 28),
      radius: Radius.circular(radioNotch + 6),
      clockwise: false,
    );

    path.cubicTo(
      centroX + radioNotch, y + 20,
      centroX + radioNotch + 5, y,
      centroX + radioNotch + 20, y,
    );

    path.lineTo(size.width - radioEsquina, y);
    path.quadraticBezierTo(size.width, y, size.width, y + radioEsquina);
    path.lineTo(size.width, size.height - radioEsquina);
    path.quadraticBezierTo(
        size.width, size.height, size.width - radioEsquina, size.height);
    path.lineTo(radioEsquina, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radioEsquina);
    path.lineTo(0, y + radioEsquina);
    path.quadraticBezierTo(0, y, radioEsquina, y);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NotchPainter old) =>
      old.centroX != centroX || old.colorBarra != colorBarra;
}