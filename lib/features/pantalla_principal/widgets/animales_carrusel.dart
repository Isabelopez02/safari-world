import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Sección carrusel de avatares de animales por descubrir
class AnimalesCarrusel extends StatelessWidget {
  final VoidCallback onExploracionesTap;

  const AnimalesCarrusel({
    super.key,
    required this.onExploracionesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                onTap: onExploracionesTap,
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
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildAnimalAvatar(
                'León',
                'assets/images/animales_con_fondo/leon-card.jpg',
              ),
              _buildAnimalAvatar(
                'Pingüino',
                'assets/images/animales_con_fondo/pinguino-card.jpg',
              ),
              _buildAnimalAvatar(
                'Jirafa',
                'assets/images/animales_con_fondo/jirada-card.jpg',
              ),
              _buildAnimalAvatar(
                'Foca',
                'assets/images/animales_con_fondo/foca-card.jpg',
              ),
              _buildAnimalAvatar(
                'Panda',
                'assets/images/animales_con_fondo/osoPanda-card.jpg',
              ),
              _buildAnimalAvatar(
                'Cocodrilo',
                'assets/images/animales_con_fondo/cocodrilo-card.jpg',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimalAvatar(String nombre, String imagePath) {
    return GestureDetector(
      onTap: onExploracionesTap,
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
}
