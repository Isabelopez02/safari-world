import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

import '../widgets/marcador_animado.dart';

class PantallaDetalleAnimal extends StatelessWidget {
  final MarcadorMapa animal;

  const PantallaDetalleAnimal({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verdeAzulado,
      body: Stack(
        children: [
          // Fondo decorativo tipo Pokedex (mitad superior)
          Positioned(
            top: -50,
            right: -50,
            child: Icon(
              animal.icono,
              size: 250,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),

          // Botón de regresar
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Título del animal
          Positioned(
            top: 100,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  animal.nombre,
                  style: GoogleFonts.urbanist(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '#${animal.id}',
                  style: GoogleFonts.urbanist(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Categoría (badge)
          Positioned(
            top: 150,
            left: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                animal.categoria,
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // Imagen principal del animal (Centro arriba)
          Positioned(
            top: 180,
            left: 0,
            right: 0,
            child: Hero(
              tag: 'animal_icon_${animal.id}',
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    animal.icono,
                    size: 100,
                    color: AppColors.verdeAzulado,
                  ),
                ),
              ),
            ),
          ),

          // Hoja inferior blanca (Bottom Sheet Pokedex)
          Positioned(
            top: 360, // Empieza debajo de la mitad de la imagen
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats / Info rápida
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(
                          'Estado',
                          animal.visitado ? 'Visitado' : 'Pendiente',
                          animal.visitado ? Colors.green : Colors.grey,
                        ),
                        _buildStat(
                          'Dieta',
                          'Omnívoro',
                          AppColors.verdePrincipal,
                        ),
                        _buildStat('Peligro', 'Bajo', Colors.orange),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Descripción
                    Text(
                      'Acerca de ${animal.nombre}',
                      style: GoogleFonts.urbanist(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Este magnífico animal es conocido por su increíble adaptación a diferentes entornos. En nuestro zoológico, los cuidadores se aseguran de que tenga una dieta balanceada y espacio suficiente para jugar. ¡No olvides tomarle muchas fotos (sin flash)!',
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.grey[700],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Curiosidades
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.fondoApp,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb,
                            color: Colors.amber,
                            size: 30,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¿Sabías que?',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Duermen un promedio de 12 horas al día y les encanta tomar siestas bajo la sombra.',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String title, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
