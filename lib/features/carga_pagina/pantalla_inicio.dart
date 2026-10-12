import 'package:flutter/material.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/onboarding/screens/pantalla_onboarding.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  // Estado para controlar la animación
  bool _fase2 = false;

  @override
  void initState() {
    super.initState();

    // Después de 1.5 segundos, iniciamos la transición a Fase 2
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _fase2 = true;
        });
      }
    });

    // Después de 4.5 segundos, navegamos al Onboarding
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const PantallaOnboarding(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeInOut,
        // Cambio de color de fondo: de verde a blanco puro en fase 2
        color: _fase2 ? Colors.white : AppColors.verdeClaro,
        child: Stack(
          children: [
            // ==========================================
            // HOJAS QUE DESAPARECEN EN LA FASE 2
            // ==========================================
            _buildLeaf(
              stays: false,
              image: 'assets/images/planta_1.png',
              top: _fase2 ? -200 : size.height * 0.1,
              left: _fase2 ? -200 : size.width * 0.05,
              angle: 0.1,
              size: 200,
            ),
            _buildLeaf(
              stays: false,
              image: 'assets/images/planta_2.png',
              top: _fase2 ? size.height + 200 : size.height * 0.5,
              left: _fase2 ? size.width + 200 : size.width * 0.4,
              angle: -0.1,
              size: 250,
            ),
            _buildLeaf(
              stays: false,
              image: 'assets/images/planta_1.png',
              top: _fase2 ? -200 : size.height * 0.4,
              left: _fase2 ? size.width + 200 : size.width * 0.6,
              angle: 0.3,
              size: 220,
            ),
            _buildLeaf(
              stays: false,
              image: 'assets/images/planta_2.png',
              top: _fase2 ? size.height + 200 : size.height * 0.8,
              left: _fase2 ? -200 : -20,
              angle: 0.5,
              size: 240,
            ),

            // ==========================================
            // LAS 3 HOJAS PRINCIPALES QUE SE QUEDAN (Como Imagen 2)
            // ==========================================

            // Hoja 1: Esquina superior derecha
            _buildLeaf(
              stays: true,
              image: 'assets/images/planta_1.png',
              top: _fase2 ? -60 : size.height * 0.1,
              left: _fase2 ? size.width - 150 : size.width * 0.5,
              angle: _fase2 ? 0.3 : 0.8,
              size: 280,
            ),
            // Hoja 2: Borde inferior derecho
            _buildLeaf(
              stays: true,
              image: 'assets/images/planta_2.png',
              top: _fase2 ? size.height - 200 : size.height * 0.7,
              left: _fase2 ? size.width - 160 : size.width * 0.4,
              angle: _fase2 ? 0.0 : -0.5,
              size: 300,
            ),
            // Hoja 3: Borde central izquierdo
            _buildLeaf(
              stays: true,
              image: 'assets/images/planta_1.png',
              top: _fase2 ? size.height * 0.45 : size.height * 0.3,
              left: _fase2 ? -180 : size.width * 0.1,
              angle: _fase2 ? 1.4 : 0.2,
              size: 280,
            ),

            // ==========================================
            // LOGO CENTRAL (Aparece en Fase 2)
            // ==========================================
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeIn,
                opacity: _fase2 ? 1.0 : 0.0,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutBack,
                  scale: _fase2 ? 1.0 : 0.3,
                  child: Image.asset(
                    'assets/images/logo_zoologico.png',
                    width: 200,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función constructora para las hojas animadas
  Widget _buildLeaf({
    required bool stays,
    required String image,
    required double top,
    required double left,
    required double angle,
    required double size,
  }) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeInOutCubic,
      top: top,
      left: left,
      child: AnimatedOpacity(
        duration: stays
            ? const Duration(milliseconds: 1800)
            : const Duration(milliseconds: 1000),
        // Si no se queda, la opacidad baja a 0 en la fase 2
        opacity: stays ? 1.0 : (_fase2 ? 0.0 : 1.0),
        child: AnimatedRotation(
          turns: angle,
          duration: const Duration(milliseconds: 1800),
          curve: Curves.easeInOut,
          child: SizedBox(
            width: size,
            height: size,
            child: Image.asset(image, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
