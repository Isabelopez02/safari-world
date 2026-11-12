import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Encabezado sutil, moderno y limpio para la pantalla principal.
/// Destaca el saludo de aventura con tipografía ligera y elegante,
/// sin contrastes agresivos ni saturación visual.
class EncabezadoSutil extends StatelessWidget {
  final String nombreParque;
  final VoidCallback? onNotificacionesTap;
  final VoidCallback? onPerfilTap;

  const EncabezadoSutil({
    super.key,
    this.nombreParque = 'Parque de las Leyendas',
    this.onNotificacionesTap,
    this.onPerfilTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FILA SUPERIOR: CHIP DE ESTADO Y BOTONES DE ACCIÓN RÁPIDA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chip sutil del parque / estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.verdePrincipal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.verdePrincipal.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Abierto hoy • 9:00 AM - 5:30 PM',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.verdePrincipal,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Botón de notificaciones o campana sutil
              InkWell(
                onTap: () {
                  SoundService.instance.playButtonTap();
                  if (onNotificacionesTap != null) {
                    onNotificacionesTap!();
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.textoOscuro,
                        size: 22,
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.amarilloMostaza,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // OVERLINE: "TU AVENTURA EMPIEZA AQUÍ"
          Text(
            'tu_aventura'.tr.toUpperCase(),
            style: GoogleFonts.urbanist(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.2,
              color: AppColors.verdePrincipal.withValues(alpha: 0.75),
            ),
          ),

          const SizedBox(height: 4),

          // TÍTULO PRINCIPAL: "Bienvenido a ..."
          RichText(
            text: TextSpan(
              style: GoogleFonts.urbanist(
                fontSize: 27,
                fontWeight: FontWeight.w900,
                color: AppColors.textoOscuro,
                letterSpacing: -0.5,
                height: 1.15,
              ),
              children: [
                TextSpan(
                  text: '${'parque_nombre'.tr} 🌿',
                  style: GoogleFonts.urbanist(
                    color: AppColors.verdePrincipal,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
