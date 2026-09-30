import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🎨 PALETA EXTRAÍDA DE LA IMAGEN
class AppColors {
  static const fondo       = Color(0xFFFDF6EC);
  static const verde       = Color(0xFF5C8D3E);
  static const verdeOscuro = Color(0xFF4A7C2F);
  static const verdeClaro  = Color(0xFFE8F0DD);
  static const amarillo    = Color(0xFFD4E157);
  static const textoOsc   = Color(0xFF3E2F1C);
  static const textoGris  = Color(0xFF8B7D6B);
  static const cardBlanco = Colors.white;
}

class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key});

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  // Estado para saber qué filtro está seleccionado
  String _filtroSeleccionado = 'ANIMALES';
  final TransformationController _transformationController = TransformationController();

  void _zoomIn() {
    _zoom(1.5);
  }

  void _zoomOut() {
    _zoom(1 / 1.5);
  }

  void _zoom(double factor) {
    final matrix = _transformationController.value.clone();
    
    // Zoom enfocado al centro aproximado del mapa
    final size = MediaQuery.of(context).size;
    final focalPoint = Offset(size.width / 2, size.height / 3);

    final currentScale = matrix.getMaxScaleOnAxis();
    final newScale = (currentScale * factor).clamp(0.1, 5.0);
    final ratio = newScale / currentScale;

    matrix.translate(focalPoint.dx, focalPoint.dy);
    matrix.scale(ratio, ratio);
    matrix.translate(-focalPoint.dx, -focalPoint.dy);

    _transformationController.value = matrix;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Widget _buildCategoryCard(String title, IconData icon) {
    final bool isSelected = _filtroSeleccionado == title;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _filtroSeleccionado = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 90,
        margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4), 
        decoration: BoxDecoration(
          color: isSelected ? AppColors.verdeClaro : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.verde : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected 
            ? [BoxShadow(color: AppColors.verde.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
            : [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.verdeOscuro : AppColors.textoGris,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10, 
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600, 
                color: isSelected ? AppColors.verdeOscuro : Colors.black87
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      extendBody: true, // Mantiene la posibilidad de que el footer flote sobre el fondo
      body: Column(
        children: [
          // 1. SECCIÓN DEL MAPA INTERACTIVO (Arriba)
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.1,
                    maxScale: 5.0,
                    // EdgeInsets.zero evita que la imagen pueda salirse de los bordes y desaparecer
                    boundaryMargin: EdgeInsets.zero, 
                    constrained: false,
                    child: Image.asset(
                      'assets/images/mapa_zoologico.png',
                    ),
                  ),
                ),

                // BARRA SUPERIOR FLOTANTE
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                              ]
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.black),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                                ]
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // BOTONES DE ZOOM (+ / -) A LA DERECHA
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.black87),
                          onPressed: _zoomIn,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.remove, color: Colors.black87),
                          onPressed: _zoomOut,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. SECCIÓN DE TARJETAS DE FILTRO (Abajo, no superpuesto al mapa)
          Container(
            color: AppColors.fondo, // Fondo propio para la sección
            padding: const EdgeInsets.only(top: 16, bottom: 85), // bottom: 85 para evitar que el footer lo tape
            child: SizedBox(
              height: 105,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildCategoryCard('ANIMALES', Icons.pets),
                  _buildCategoryCard('SERVICIOS', Icons.restaurant_menu),
                  _buildCategoryCard('BAÑOS', Icons.wc),
                  _buildCategoryCard('TIENDAS', Icons.storefront), 
                  _buildCategoryCard('CLÍNICAS', Icons.local_hospital), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
