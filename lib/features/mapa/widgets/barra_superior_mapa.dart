import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Barra superior de navegación y controles del mapa (Regresar, Baños y Guía)
class BarraSuperiorMapa extends StatelessWidget {
  final VoidCallback onRegresar;
  final bool mostrarBanios;
  final VoidCallback onToggleBanios;
  final int tutorialStep;
  final VoidCallback onToggleGuia;
  final GlobalKey keyComoFunciona;

  const BarraSuperiorMapa({
    super.key,
    required this.onRegresar,
    required this.mostrarBanios,
    required this.onToggleBanios,
    required this.tutorialStep,
    required this.onToggleGuia,
    required this.keyComoFunciona,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        child: Row(
          children: [
            // Botón Regresar de alto contraste
            GestureDetector(
              onTap: onRegresar,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.verdeAzulado,
                    width: 1.8,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 14,
                      color: AppColors.verdeAzulado,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Regresar',
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textoOscuro,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Chip Filtro Baños
            GestureDetector(
              onTap: onToggleBanios,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: mostrarBanios
                      ? Colors.blue.shade700
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blue.shade700,
                    width: 1.8,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wc_rounded,
                      size: 15,
                      color: mostrarBanios
                          ? Colors.white
                          : Colors.blue.shade700,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Baños',
                      style: GoogleFonts.urbanist(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: mostrarBanios
                            ? Colors.white
                            : Colors.blue.shade800,
                      ),
                    ),
                    if (mostrarBanios) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.close_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Botón Guía Tutorial (Toggle instantáneo)
            GestureDetector(
              key: keyComoFunciona,
              onTap: () {
                SoundService.instance.playButtonTap();
                onToggleGuia();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: tutorialStep > 0
                      ? const Color(0xFFF59E0B)
                      : AppColors.verdeAzulado,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lightbulb_rounded,
                      size: 16,
                      color: Color(0xFFFFD54F),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      tutorialStep > 0 ? 'Cerrar Guía' : 'Guía',
                      style: GoogleFonts.urbanist(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
