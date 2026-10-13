import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/emergency_service.dart';

import 'shimmer_sweep.dart';

/// Tarjeta 3D Pop-Out para Emergencia y Ayuda
class EmergenciaCard extends StatelessWidget {
  const EmergenciaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        EmergencyService.instance.mostrarModalEmergencia(context);
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
                          GestureDetector(
                            onTap: () {
                              EmergencyService.instance.mostrarModalEmergencia(
                                context,
                              );
                            },
                            child: Container(
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
