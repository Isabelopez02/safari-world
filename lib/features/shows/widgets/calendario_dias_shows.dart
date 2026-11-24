import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

import '../utils/shows_date_utils.dart';

/// Selector horizontal de días tipo cartelera Cineplanet (Hoy, Mañana, Días del mes)
class CalendarioDiasShows extends StatelessWidget {
  final List<DateTime> diasCalendario;
  final int diaSeleccionadoIndex;
  final ValueChanged<int> onSeleccionarDia;

  const CalendarioDiasShows({
    super.key,
    required this.diasCalendario,
    required this.diaSeleccionadoIndex,
    required this.onSeleccionarDia,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: diasCalendario.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final fecha = diasCalendario[index];
          final bool seleccionado = diaSeleccionadoIndex == index;
          final String diaSemana = ShowsDateUtils.obtenerNombreDia(
            fecha,
            index,
          );
          final String numeroDia = fecha.day.toString();

          return InkWell(
            onTap: () {
              SoundService.instance.playButtonTap();
              onSeleccionarDia(index);
            },
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 68,
              decoration: BoxDecoration(
                color: seleccionado ? AppColors.verdePrincipal : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: seleccionado
                      ? AppColors.verdePrincipal
                      : Colors.black.withValues(alpha: 0.07),
                  width: seleccionado ? 1.6 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: seleccionado
                        ? AppColors.verdePrincipal.withValues(alpha: 0.28)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: seleccionado ? 12 : 6,
                    offset: Offset(0, seleccionado ? 5 : 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    diaSemana.toUpperCase(),
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: seleccionado
                          ? Colors.white.withValues(alpha: 0.9)
                          : AppColors.textoGris,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    numeroDia,
                    style: GoogleFonts.urbanist(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      color: seleccionado
                          ? Colors.white
                          : AppColors.textoOscuro,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
