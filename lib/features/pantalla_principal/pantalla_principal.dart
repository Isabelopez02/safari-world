import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_mapa.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_detalle_animal.dart';
import 'package:zoologico_front/features/mapa/widgets/modal_animales_por_visitar.dart';

import 'widgets/animales_carrusel.dart';
import 'widgets/banner_mapa.dart';
import 'widgets/emergencia_card.dart';
import 'widgets/hero_header.dart';
import 'widgets/show_acuatico_card.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  DateTime? _lastBackPressTime;

  void _mostrarCatalogo(BuildContext context) {
    SoundService.instance.playButtonTap();
    ModalAnimalesPorVisitar.mostrar(
      context,
      onSeleccionarAnimal: _abrirFichaAnimal,
    );
  }

  void _abrirFichaAnimal(MarcadorMapa animal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaDetalleAnimal(animal: animal),
      ),
    );
  }

  void _navigateToMap(BuildContext context) {
    SoundService.instance.playButtonTap();
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 1000),
        reverseTransitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PantallaMapa(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Stack(
            children: [
              FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.48, 0.52),
                  ),
                ),
                child: child,
              ),
              AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  final t = animation.value;
                  final size = MediaQuery.of(context).size;
                  final dx = (1 - 2 * t) * size.width;
                  final dy = (1 - 2 * t) * size.height;
                  final factor = 0.5 - (t - 0.5).abs();
                  final scale = 1.0 + (factor * 35.0);
                  final rotation = t * 3.14159;

                  return IgnorePointer(
                    child: Transform.translate(
                      offset: Offset(dx, dy),
                      child: Transform.scale(
                        scale: scale,
                        child: Transform.rotate(
                          angle: rotation,
                          child: Center(
                            child: Image.asset(
                              'assets/images/planta_1.png',
                              width: 140,
                              height: 140,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.verdePrincipal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Row(
                children: [
                  const Text('🌿', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Presiona atrás de nuevo para salir del Zoológico',
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
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // FONDO HERO SAFARI ADAPTABLE
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 380,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/pantalla_principal/hero_fondo.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          Colors.black.withValues(alpha: 0.25),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // CONTENIDO SCROLLEABLE
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    // ENCABEZADO SAFARI AVENTURA
                    HeroHeader(onNavegarTap: () => _navigateToMap(context)),

                    const SizedBox(height: 20),

                    // CUERPO PRINCIPAL (TARJETA BLANCA SAFARI ORGÁNICA)
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, -6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 22),

                          // --- 1. SECCIÓN: ANIMALES POR DESCUBRIR (AVATARES FOTOGRÁFICOS) ---
                          AnimalesCarrusel(
                            onExploracionesTap: () => _mostrarCatalogo(context),
                            onSeleccionarAnimal: _abrirFichaAnimal,
                          ),

                          const SizedBox(height: 32),

                          // --- 2. SECCIÓN: SERVICIOS Y EXPERIENCIAS (CARDS 3D POP-OUT) ---
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Experiencias y servicios',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textoOscuro,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.verdePrincipal.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified_rounded,
                                        size: 13,
                                        color: AppColors.verdePrincipal,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Zoo Guide',
                                        style: GoogleFonts.urbanist(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.verdePrincipal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // TARJETAS 3D POP-OUT VERTICALES (FONDOS TEMÁTICOS MARINO Y MÉDICO)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              children: [
                                ShowAcuaticoCard(),
                                SizedBox(height: 22),
                                EmergenciaCard(),
                              ],
                            ),
                          ),

                          const SizedBox(height: 34),

                          // --- 3. SECCIÓN: BANNER DEL MAPA INTERACTIVO ---
                          BannerMapa(onTap: () => _navigateToMap(context)),

                          const SizedBox(height: 30),

                          // FOOTER BOTÁNICO
                          Image.asset(
                            'assets/images/pantalla_principal/footer.png',
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ],
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
