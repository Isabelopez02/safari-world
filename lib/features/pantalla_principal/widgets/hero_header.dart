import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Encabezado Safari Aventura: sin saturación de badges, con tipografía gruesa
/// y legible, e íconos intuitivos para evitar fatiga visual.
class HeroHeader extends StatelessWidget {
  final VoidCallback onNavegarTap;

  const HeroHeader({
    super.key,
    required this.onNavegarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CHIP ÚNICO Y LIMPIO DE BIENVENIDA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.nature_people_rounded,
                  size: 16,
                  color: Color(0xFF81C784),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Parque Natural & Safari Zoo',
                    style: GoogleFonts.urbanist(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. FILA PRINCIPAL: TÍTULO, SUBTÍTULO LEGIBLE Y PERSONAJE
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Bienvenido a tu\nAventura Salvaje!',
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: -0.3,
                        shadows: const [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Letras con mayor grosor y tamaño para máxima legibilidad en móviles
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Descubre hábitats, escucha animales y navega con GPS.',
                        style: GoogleFonts.urbanist(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // PERSONAJE EXPLORADOR AMIGABLE
              Expanded(
                flex: 9,
                child: SizedBox(
                  height: 140,
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Container(
                        width: 115,
                        height: 115,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      Image.asset(
                        'assets/images/pantalla_principal/investigador.png',
                        height: 135,
                        fit: BoxFit.contain,
                        alignment: Alignment.centerRight,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.pets_rounded,
                              size: 60,
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // BOTÓN PRINCIPAL DESTACADO CON ÍCONO (ANCHO COMPLETO Y TOTALMENTE RESPONSIVE)
          GestureDetector(
            onTap: () {
              SoundService.instance.playButtonTap();
              onNavegarTap();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.verdeAzulado,
                    AppColors.verdePrincipal,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.45),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.verdeAzulado.withValues(
                      alpha: 0.45,
                    ),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.explore_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Explorar Mapa Interactivo',
                      style: GoogleFonts.urbanist(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3. SOLO 3 DESTACADOS VISUALES CON ÍCONOS (SIN SATURACIÓN DE BADGES)
          Row(
            children: [
              _buildFeatureIconPill(
                icon: Icons.pets_rounded,
                label: '20 Animales',
                color: const Color(0xFFFFD54F),
              ),
              const SizedBox(width: 8),
              _buildFeatureIconPill(
                icon: Icons.near_me_rounded,
                label: 'Rutas GPS',
                color: const Color(0xFF81D4FA),
              ),
              const SizedBox(width: 8),
              _buildFeatureIconPill(
                icon: Icons.water_drop_rounded,
                label: 'Shows en Vivo',
                color: const Color(0xFFA5D6A7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIconPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.urbanist(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
