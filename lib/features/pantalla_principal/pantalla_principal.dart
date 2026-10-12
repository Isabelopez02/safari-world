import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_mapa.dart';
import 'package:zoologico_front/core/services/sound_service.dart';

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  void _navigateToMap(BuildContext context) {
    SoundService.instance.playButtonTap();
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false, // Permite ver la pantalla anterior durante la transición
        transitionDuration: const Duration(milliseconds: 1200),
        reverseTransitionDuration: const Duration(milliseconds: 1200),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PantallaMapa(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Stack(
            children: [
              // 1. La nueva pantalla (PantallaMapa) aparece bruscamente a la mitad de la animación
              // cuando la hoja está en su máximo tamaño cubriendo todo.
              FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Interval(
                      0.49,
                      0.51,
                    ), // Transición rápida a la mitad
                  ),
                ),
                child: child,
              ),

              // 2. Animación de la hoja gigante pasando por encima
              AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  final t = animation.value;
                  final size = MediaQuery.of(context).size;

                  // offset: empieza abajo a la derecha, pasa por el centro, termina arriba a la izquierda
                  final dx = (1 - 2 * t) * size.width;
                  final dy = (1 - 2 * t) * size.height;

                  // factor: 0.0 (inicio) -> 0.5 (mitad) -> 0.0 (fin)
                  final factor = 0.5 - (t - 0.5).abs();

                  // scale: empieza en 1, crece masivamente en el centro para tapar la pantalla, vuelve a 1
                  final scale = 1.0 + (factor * 40.0);

                  // rotación ligera para darle efecto orgánico
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
                              width: 150,
                              height: 150,
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
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco para el rebote inferior
      body: Stack(
        children: [
          // Fondo verde oscuro para cubrir el rebote superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(color: const Color(0xFF1B2E24)),
          ),

          // 1. BACKGROUND JUNGLE IMAGE (Mitad superior)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Imagen original
                Image.asset(
                  'assets/images/pantalla_principal/hero_fondo.png',
                  fit: BoxFit.cover,
                ),
                // Capa oscura encima
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. CONTENIDO DESPLAZABLE SOBRE EL FONDO
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- HEADER CONTENT ---
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 24.0,
                              right: 10.0,
                              top: 20.0,
                              bottom: 20.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 13,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 10),
                                      Text(
                                        'Visita todas nuestras\nzonas con nuestro mapa',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.urbanist(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () =>
                                            _navigateToMap(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.verdeAzulado,
                                          foregroundColor: Colors.white,
                                          elevation: 3,
                                          shadowColor: Colors.black45,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.explore_rounded,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'EMPEZAR A NAVEGAR',
                                              style: GoogleFonts.urbanist(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: Image.asset(
                                    'assets/images/pantalla_principal/investigador.png',
                                    height: 140,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.bottomRight,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.pets,
                                              size: 80,
                                              color: Colors.white,
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // --- CUERPO BLANCO Y TARJETA FLOTANTE ---
                          Expanded(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Fondo blanco principal con borde redondeado superior
                                Container(
                                  margin: const EdgeInsets.only(top: 55),
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 65),
                                      Text(
                                        'Conoce otros de nuestros servicios',
                                        style: GoogleFonts.urbanist(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textoOscuro,
                                        ),
                                      ),
                                      const SizedBox(height: 55),

                                      // TARJETAS 3D (Foca y Castor)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: _buildServiceCard(
                                                title: 'Shows acuáticos',
                                                subtitle: '10am · 1pm · 4pm',
                                                imagePath: 'assets/images/pantalla_principal/foca.png',
                                                accentColor:
                                                    AppColors.verdeAzulado,
                                                onTap: () {},
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildServiceCard(
                                                title: 'Contacto de emergencia',
                                                subtitle: '912321232',
                                                imagePath: 'assets/images/pantalla_principal/emergencia.png',
                                                accentColor: const Color(
                                                  0xFF8B263E,
                                                ),
                                                onTap: () {},
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 40),

                                      // BANNER DEL MAPA
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 28.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Explora nuestro mapa ',
                                                  style: GoogleFonts.urbanist(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppColors.textoOscuro,
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.arrow_forward,
                                                  size: 16,
                                                  color: AppColors.textoOscuro,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            GestureDetector(
                                              onTap: () =>
                                                  _navigateToMap(context),
                                              child: Container(
                                                height: 120,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withAlpha(
                                                            (255 * 0.12)
                                                                .toInt(),
                                                          ),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ],
                                                  image: const DecorationImage(
                                                    image: AssetImage(
                                                      'assets/images/mapa_zoologico.png',
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 40),

                                      const Spacer(), // Empuja el footer a la parte inferior
                                      // FOOTER IMAGE
                                      Image.asset(
                                        'assets/images/pantalla_principal/footer.png',
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ],
                                  ),
                                ),

                                // --- TARJETA FLOTANTE (Carrusel de Animales) ---
                                Positioned(
                                  top: -5,
                                  left: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(
                                            (255 * 0.15).toInt(),
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Expanded(
                                              child: Divider(
                                                indent: 20,
                                                endIndent: 12,
                                                color: Colors.grey,
                                                thickness: 1,
                                              ),
                                            ),
                                            Text(
                                              '¿Qué animales te falta visitar?',
                                              style: GoogleFonts.urbanist(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textoOscuro,
                                              ),
                                            ),
                                            const Expanded(
                                              child: Divider(
                                                indent: 12,
                                                endIndent: 20,
                                                color: Colors.grey,
                                                thickness: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          height: 32,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: 15,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            itemBuilder: (context, index) {
                                              final animals = [
                                                {
                                                  'icon': Icons.pets,
                                                  'color':
                                                      AppColors.verdePrincipal,
                                                },
                                                {
                                                  'icon':
                                                      Icons.water_drop_rounded,
                                                  'color':
                                                      AppColors.verdeAzulado,
                                                },
                                                {
                                                  'icon': Icons.ac_unit_rounded,
                                                  'color': Colors.blue,
                                                },
                                                {
                                                  'icon': Icons
                                                      .flutter_dash_rounded,
                                                  'color': Colors.teal,
                                                },
                                                {
                                                  'icon': Icons
                                                      .cruelty_free_rounded,
                                                  'color': Colors.brown,
                                                },
                                              ];
                                              final item =
                                                  animals[index %
                                                      animals.length];
                                              return GestureDetector(
                                                onTap: () =>
                                                    _navigateToMap(context),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10.0,
                                                      ),
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          (item['color']
                                                                  as Color)
                                                              .withValues(
                                                                alpha: 0.1,
                                                              ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      item['icon'] as IconData,
                                                      color:
                                                          item['color']
                                                              as Color,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TARJETAS 3D CON ANIMAL SOBRESALIENDO Y EFECTO SHIMMER
  // ============================================================
  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        SoundService.instance.playButtonTap();
        onTap();
      },
      child: SizedBox(
        height: 185,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // TARJETA BASE BLANCA
            Container(
              height: 135,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.22),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    // CONTENIDO TEXTO
                    Positioned(
                      bottom: 12,
                      left: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.verdePrincipal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.urbanist(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Ver detalles',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: accentColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 11,
                                  color: accentColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // SHIMMER DE LUZ SUAVE EN LA TARJETA
                    const Positioned.fill(child: _ShimmerSweep()),
                  ],
                ),
              ),
            ),

            // IMAGEN 3D SOBRESALIENDO DE LA MITAD SUPERIOR
            Positioned(
              top: 0,
              child: Image.asset(
                imagePath,
                height: 105,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.pets, size: 40, color: accentColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerSweep extends StatefulWidget {
  const _ShimmerSweep();
  @override
  State<_ShimmerSweep> createState() => _ShimmerSweepState();
}

class _ShimmerSweepState extends State<_ShimmerSweep>
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
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(-2.0, -1.0),
                end: const Alignment(2.0, 1.0),
                colors: [
                  Colors.white.withValues(alpha: 0.0),
                  Colors.white.withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0.0),
                ],
                stops: [
                  (_anim.value - 0.2).clamp(0.0, 1.0),
                  _anim.value.clamp(0.0, 1.0),
                  (_anim.value + 0.2).clamp(0.0, 1.0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
