import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import '../data/show_models.dart';

/// Pestañas superiores para alternar entre Horarios, Reglas y Escenarios
class PestanasSeccionShows extends StatelessWidget {
  final SeccionShows seccionActiva;
  final ValueChanged<SeccionShows> onCambiarSeccion;

  const PestanasSeccionShows({
    super.key,
    required this.seccionActiva,
    required this.onCambiarSeccion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: _buildItemCardSeccion(
              seccion: SeccionShows.horarios,
              icono: Icons.calendar_month_rounded,
              titulo: 'horarios_funciones'.tr,
              seleccionado: seccionActiva == SeccionShows.horarios,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildItemCardSeccion(
              seccion: SeccionShows.reglas,
              icono: Icons.verified_user_rounded,
              titulo: 'reglas_shows'.tr,
              seleccionado: seccionActiva == SeccionShows.reglas,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildItemCardSeccion(
              seccion: SeccionShows.escenarios,
              icono: Icons.stadium_rounded,
              titulo: 'escenarios_shows'.tr,
              seleccionado: seccionActiva == SeccionShows.escenarios,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCardSeccion({
    required SeccionShows seccion,
    required IconData icono,
    required String titulo,
    required bool seleccionado,
  }) {
    return InkWell(
      onTap: () {
        SoundService.instance.playButtonTap();
        onCambiarSeccion(seccion);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.verdePrincipal : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: seleccionado
                ? AppColors.verdePrincipal
                : Colors.black.withValues(alpha: 0.06),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: seleccionado
                  ? AppColors.verdePrincipal.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: seleccionado ? 10 : 6,
              offset: Offset(0, seleccionado ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              size: 20,
              color: seleccionado ? Colors.white : AppColors.verdePrincipal,
            ),
            const SizedBox(height: 5),
            Text(
              titulo,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.urbanist(
                fontSize: 11,
                fontWeight: seleccionado ? FontWeight.w900 : FontWeight.w700,
                color: seleccionado ? Colors.white : AppColors.textoOscuro,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
