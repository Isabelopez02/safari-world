import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_mapa.dart';

import 'pantalla_detalle_show_acuatico.dart';

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  void _navigateToMapExploraciones(BuildContext context) {
    SoundService.instance.playButtonTap();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const PantallaMapa(abrirExploracionesAlCargar: true),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // FONDO HERO CON GRADIENTE TIPO APPLE/SAFARI
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.46,
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
                        Colors.black.withValues(alpha: 0.6),
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

                  // TOP HERO (Título + Botón Apple + Pingüino Explorador)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 13,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  '🌲 Parque Natural & Safari',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Explora nuestras\nzonas interactivas',
                                style: GoogleFonts.urbanist(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  height: 1.15,
                                  letterSpacing: -0.5,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black38,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Botón de estilo iOS / Apple
                              GestureDetector(
                                onTap: () => _navigateToMap(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.verdeAzulado,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.verdeAzulado
                                            .withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.explore_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Empezar a navegar',
                                        style: GoogleFonts.urbanist(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Image.asset(
                            'assets/images/pantalla_principal/investigador.png',
                            height: 145,
                            fit: BoxFit.contain,
                            alignment: Alignment.centerRight,
                            errorBuilder: (context, error, stackTrace) =>
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

                  const SizedBox(height: 24),

                  // CUERPO PRINCIPAL (TARJETA BLANCA TIPO APPLE SHEET)
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Handle bar tipo iOS
                        Center(
                          child: Container(
                            width: 38,
                            height: 4.5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // --- 1. SECCIÓN: ANIMALES POR DESCUBRIR (AVATARES FOTOGRÁFICOS) ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '¿A quién deseas visitar hoy?',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textoOscuro,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  Text(
                                    'Toca un animal para ver su ubicación',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () =>
                                    _navigateToMapExploraciones(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.verdeAzulado.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Tus exploraciones',
                                        style: GoogleFonts.urbanist(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.verdeAzulado,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 10,
                                        color: AppColors.verdeAzulado,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Carrusel horizontal de avatares fotográficos de animales
                        SizedBox(
                          height: 92,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              _buildAnimalAvatar(
                                context,
                                'León',
                                'assets/images/animales_con_fondo/leon-card.jpg',
                              ),
                              _buildAnimalAvatar(
                                context,
                                'Pingüino',
                                'assets/images/animales_con_fondo/pinguino-card.jpg',
                              ),
                              _buildAnimalAvatar(
                                context,
                                'Gorila',
                                'assets/images/animales_con_fondo/gorila-card.jpg',
                              ),
                              _buildAnimalAvatar(
                                context,
                                'Jirafa',
                                'assets/images/animales_con_fondo/jirada-card.jpg',
                              ),
                              _buildAnimalAvatar(
                                context,
                                'Foca',
                                'assets/images/animales_con_fondo/foca-card.jpg',
                              ),
                              _buildAnimalAvatar(
                                context,
                                'Panda',
                                'assets/images/animales_con_fondo/osoPanda-card.jpg',
                              ),
                              _buildAnimalAvatar(
                                context,
                                'Cocodrilo',
                                'assets/images/animales_con_fondo/cocodrilo-card.jpg',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // --- 2. SECCIÓN: SERVICIOS Y EXPERIENCIAS (CARDS 3D POP-OUT) ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.verdePrincipal.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Zoo Guide',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.verdePrincipal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // TARJETAS 3D POP-OUT VERTICALES (UNA DEBAJO DE LA OTRA CON FONDOS TEMÁTICOS)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              _buildShowAcuaticoCard(context),
                              const SizedBox(height: 22),
                              _buildEmergenciaCard(context),
                            ],
                          ),
                        ),

                        const SizedBox(height: 34),

                        // --- 3. SECCIÓN: BANNER DEL MAPA INTERACTIVO ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Mapa satelital del parque',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textoOscuro,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => _navigateToMap(context),
                                child: Container(
                                  height: 155,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.12,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.asset(
                                          'assets/images/mapa_zoologico.png',
                                          fit: BoxFit.cover,
                                        ),
                                        // Gradiente para legibilidad
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withValues(
                                                  alpha: 0.75,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 14,
                                          left: 16,
                                          right: 16,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '20 Zonas y Paraderos',
                                                    style: GoogleFonts.urbanist(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Rutas con GPS inteligente y Dijkstra',
                                                    style: GoogleFonts.urbanist(
                                                      fontSize: 12,
                                                      color: Colors.white70,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.near_me_rounded,
                                                  size: 18,
                                                  color: AppColors.verdeAzulado,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

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
    );
  }

  // ============================================================
  // AVATAR CIRCULAR DE ANIMAL (ESTILO HISTORIAS APPLE / INSTAGRAM)
  // ============================================================
  Widget _buildAnimalAvatar(
    BuildContext context,
    String nombre,
    String imagePath,
  ) {
    return GestureDetector(
      onTap: () => _navigateToMapExploraciones(context),
      child: Padding(
        padding: const EdgeInsets.only(right: 14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.verdeAzulado, AppColors.verdePrincipal],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.verdeAzulado.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.pets, color: AppColors.verdeAzulado),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              nombre,
              style: GoogleFonts.urbanist(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textoOscuro,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TARJETA VERTICAL 3D: SHOWS ACUÁTICOS (FONDO TEMÁTICO MARINO)
  // ============================================================
  Widget _buildShowAcuaticoCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundService.instance.playButtonTap();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PantallaDetalleShowAcuatico(),
          ),
        );
      },
      child: SizedBox(
        height: 185,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // 1. BASE DE LA TARJETA CON FONDO MARINO ELEGANTE
            Container(
              height: 155,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F3E4D),
                    Color(0xFF145366),
                    Color(0xFF1B6B80),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: const Color(0xFF26A69A).withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F3E4D).withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Stack(
                  children: [
                    // Círculos de luz ambiental acuática
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF26A69A)
                              .withValues(alpha: 0.12),
                        ),
                      ),
                    ),

                    // CONTENIDO TEXTO A LA IZQUIERDA
                    Positioned(
                      left: 18,
                      top: 16,
                      bottom: 16,
                      right: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // BADGE EN VIVO
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF26A69A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.water_drop_rounded,
                                  size: 11,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'EN VIVO · 3 FUNCIONES',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // TÍTULO Y SUBTÍTULO
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Shows Acuáticos',
                                style: GoogleFonts.urbanist(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Focas y lobos marinos\n10:00 AM · 1:00 PM · 4:00 PM',
                                style: GoogleFonts.urbanist(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),

                          // BOTÓN VER DETALLES
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Ver detalles',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F3E4D),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13,
                                  color: Color(0xFF0F3E4D),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // SHIMMER SUAVE
                    const Positioned.fill(child: _ShimmerSweep()),
                  ],
                ),
              ),
            ),

            // 2. ANIMAL 3D SOBRESALIENDO (FOCA POP-OUT)
            Positioned(
              right: 8,
              top: 0,
              bottom: 6,
              child: Image.asset(
                'assets/images/pantalla_principal/foca.png',
                height: 175,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.pets, size: 70, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TARJETA VERTICAL 3D: EMERGENCIA Y AYUDA (FONDO CÁLIDO PROTECTOR)
  // ============================================================
  Widget _buildEmergenciaCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundService.instance.playButtonTap();
      },
      child: SizedBox(
        height: 170,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // 1. BASE DE LA TARJETA CON FONDO DE ASISTENCIA MÉDICA
            Container(
              height: 145,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF8B1E1E),
                    Color(0xFFA82525),
                    Color(0xFFC53030),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: Colors.red.shade300.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B1E1E).withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Stack(
                  children: [
                    // Círculos de luz ambiental
                    Positioned(
                      right: -15,
                      top: -15,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),

                    // CONTENIDO TEXTO A LA IZQUIERDA
                    Positioned(
                      left: 18,
                      top: 14,
                      bottom: 14,
                      right: 135,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // BADGE ASISTENCIA 24/7
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.health_and_safety_rounded,
                                  size: 11,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'ASISTENCIA 24/7',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // TÍTULO Y SUBTÍTULO
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Emergencia & Ayuda',
                                style: GoogleFonts.urbanist(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Llama directo: 912 321 232\nAtención médica y rescate',
                                style: GoogleFonts.urbanist(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),

                          // BOTÓN LLAMAR SOS
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.phone_in_talk_rounded,
                                  size: 12,
                                  color: Color(0xFF8B1E1E),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Contactar SOS',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF8B1E1E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // SHIMMER SUAVE
                    const Positioned.fill(child: _ShimmerSweep()),
                  ],
                ),
              ),
            ),

            // 2. ILUSTRACIÓN 3D SOBRESALIENDO (EMERGENCIA POP-OUT)
            Positioned(
              right: 12,
              top: 2,
              bottom: 8,
              child: Image.asset(
                'assets/images/pantalla_principal/emergencia.png',
                height: 155,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.health_and_safety,
                  size: 70,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Shimmer sweep widget — reflejo de luz suave sin tapar contenido
// =====================================================================
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
                  Colors.white.withValues(alpha: 0.2),
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
