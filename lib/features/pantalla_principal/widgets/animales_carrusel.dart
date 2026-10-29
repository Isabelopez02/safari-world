import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Datos de animales destacados para el carrusel de inicio
class AnimalCarruselItem {
  final String id;
  final String nombre;
  final String imagen;

  const AnimalCarruselItem({
    required this.id,
    required this.nombre,
    required this.imagen,
  });
}

/// Sección carrusel de avatares de animales por descubrir con navegación directa
class AnimalesCarrusel extends StatelessWidget {
  final VoidCallback onExploracionesTap;
  final ValueChanged<String>? onSeleccionarAnimal;

  const AnimalesCarrusel({
    super.key,
    required this.onExploracionesTap,
    this.onSeleccionarAnimal,
  });

  static const List<AnimalCarruselItem> animalesDestacados = [
    AnimalCarruselItem(
      id: 'I02',
      nombre: 'Leones',
      imagen: 'assets/images/animales_con_fondo/leon-card.jpg',
    ),
    AnimalCarruselItem(
      id: 'C08',
      nombre: 'Pingüinos',
      imagen: 'assets/images/animales_con_fondo/pinguino-card.jpg',
    ),
    AnimalCarruselItem(
      id: 'I12',
      nombre: 'Jirafa',
      imagen: 'assets/images/animales_con_fondo/jirafa.jpg',
    ),
    AnimalCarruselItem(
      id: 'C05',
      nombre: 'Lobos de Mar',
      imagen: 'assets/images/animales_con_fondo/foca-card.jpg',
    ),
    AnimalCarruselItem(
      id: 'I08',
      nombre: 'Oso de Anteojos',
      imagen: 'assets/images/animales_con_fondo/osoPanda-card.jpg',
    ),
    AnimalCarruselItem(
      id: 'C06',
      nombre: 'Cocodrilo',
      imagen: 'assets/images/animales_con_fondo/cocodrilo-card.jpg',
    ),
    AnimalCarruselItem(
      id: 'I07',
      nombre: 'Tigre',
      imagen: 'assets/images/animales_con_fondo/tigre-card.jpg',
    ),
    AnimalCarruselItem(
      id: 'G01',
      nombre: 'Vacas',
      imagen: 'assets/images/animales_con_fondo/vaca-card.jpg',
    ),
  ];

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿A quién deseas visitar hoy?',
                      style: GoogleFonts.urbanist(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textoOscuro,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Toca un animal para ir directo a su paradero',
                      style: GoogleFonts.urbanist(
                        fontSize: 12.5,
                        color: const Color(0xFF4A5568), // Gris oscuro de alto contraste WCAG
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Botón con tamaño táctil ergonómico (>= 44dp)
              GestureDetector(
                onTap: () {
                  SoundService.instance.playButtonTap();
                  onExploracionesTap();
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.verdeAzulado.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.verdeAzulado.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver todos',
                        style: GoogleFonts.urbanist(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.verdeAzulado,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColors.verdeAzulado,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Carrusel horizontal con pista visual (cut-off) para incentivar scroll
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: animalesDestacados.length,
            itemBuilder: (context, index) {
              final animal = animalesDestacados[index];
              return _buildAnimalAvatar(animal);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnimalAvatar(AnimalCarruselItem animal) {
    return GestureDetector(
      onTap: () {
        SoundService.instance.playAnimalTap(animal.nombre);
        if (onSeleccionarAnimal != null) {
          onSeleccionarAnimal!(animal.id);
        } else {
          onExploracionesTap();
        }
      },
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
                    color: AppColors.verdeAzulado.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    animal.imagen,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.pets, color: AppColors.verdeAzulado),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              constraints: const BoxConstraints(maxWidth: 68),
              child: Text(
                animal.nombre,
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textoOscuro,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
