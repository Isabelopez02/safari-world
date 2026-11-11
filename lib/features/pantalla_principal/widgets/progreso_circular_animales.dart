import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Widget de progreso circular que indica de forma sutil y gamificada
/// cuántos animales ha observado el visitante durante el día.
class ProgresoCircularAnimales extends StatelessWidget {
  final VoidCallback onVerDetalle;

  const ProgresoCircularAnimales({
    super.key,
    required this.onVerDetalle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AnimalService.instance,
      builder: (context, _) {
        final totalVisitados = AnimalService.instance.totalVisitados;
        final totalAnimales = AnimalService.instance.totalAnimales;
        final progreso = AnimalService.instance.porcentajeVisitados;
        final porcentajeEntero = (progreso * 100).toInt();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: InkWell(
            onTap: () {
              SoundService.instance.playButtonTap();
              onVerDetalle();
            },
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.verdePrincipal.withValues(alpha: 0.1),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // CÍRCULO INDICADOR DE PROGRESO CON NÚMERO CENTRAL
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: progreso > 0 ? progreso : 0.02,
                          strokeWidth: 7,
                          strokeCap: StrokeCap.round,
                          backgroundColor: AppColors.verdePrincipal.withValues(
                            alpha: 0.12,
                          ),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.verdePrincipal,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$totalVisitados',
                            style: GoogleFonts.urbanist(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.verdePrincipal,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'de $totalAnimales',
                            style: GoogleFonts.urbanist(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textoGris,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(width: 18),

                  // TEXTOS EXPLICATIVOS Y MOTIVACIONALES
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.amarilloMostaza.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$porcentajeEntero% COMPLETADO',
                                style: GoogleFonts.urbanist(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFB07800),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Animales observados hoy',
                          style: GoogleFonts.urbanist(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textoOscuro,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          totalVisitados == 0
                              ? '¡Comienza tu expedición por el zoológico!'
                              : totalVisitados < 5
                                  ? '¡Buen progreso! Sigue explorando hábitats.'
                                  : '¡Excelente día de safari! Gran descubrimiento.',
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textoGris,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Ver bitácora de animales',
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.verdePrincipal,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: AppColors.verdePrincipal,
                            ),
                          ],
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
    );
  }
}
