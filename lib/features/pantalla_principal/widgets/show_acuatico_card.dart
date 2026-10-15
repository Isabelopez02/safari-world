import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/features/pantalla_principal/pantalla_detalle_show_acuatico.dart';

import 'shimmer_sweep.dart';

/// Tarjeta 3D Pop-Out para el Show Acuático
class ShowAcuaticoCard extends StatelessWidget {
  const ShowAcuaticoCard({super.key});

  @override
  Widget build(BuildContext context) {
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
        height: 215,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // 1. BASE DE LA TARJETA CON FONDO MARINO ELEGANTE
            Container(
              height: 185,
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
                                Flexible(
                                  child: Text(
                                    'EXHIBICIÓN · 2 HORARIOS',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.4,
                                    ),
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
                                'Lobos marinos · Huachipa\nSáb., dom. y feriados\n12:00 m. y 3:00 p. m.',
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
                    const Positioned.fill(child: ShimmerSweep()),
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
}
