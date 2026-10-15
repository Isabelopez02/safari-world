import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/core/widgets/imagen_animal.dart';

/// Sección carrusel de avatares de animales por descubrir
class AnimalesCarrusel extends StatelessWidget {
  final VoidCallback onExploracionesTap;
  final ValueChanged<MarcadorMapa> onSeleccionarAnimal;

  const AnimalesCarrusel({
    super.key,
    required this.onExploracionesTap,
    required this.onSeleccionarAnimal,
  });

  @override
  Widget build(BuildContext context) {
    final animales = AnimalService.instance.obtenerTodosLosAnimales();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animales del parque',
                      style: GoogleFonts.urbanist(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textoOscuro,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Desliza y descubre las ${animales.length} fichas',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onExploracionesTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.verdeAzulado.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver todos (${animales.length})',
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
          height: 112,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: animales.length,
            itemBuilder: (context, index) =>
                _buildAnimalAvatar(animales[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimalAvatar(MarcadorMapa animal) {
    return GestureDetector(
      onTap: () => onSeleccionarAnimal(animal),
      child: Padding(
        padding: const EdgeInsets.only(right: 14.0),
        child: SizedBox(
          width: 82,
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
                  child: ClipOval(child: ImagenAnimal(animal: animal)),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                animal.nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textoOscuro,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
