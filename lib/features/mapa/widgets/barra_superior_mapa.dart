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
  final bool compacto;

  const BarraSuperiorMapa({
    super.key,
    required this.onRegresar,
    required this.mostrarBanios,
    required this.onToggleBanios,
    required this.tutorialStep,
    required this.onToggleGuia,
    required this.keyComoFunciona,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    void toggleGuia() {
      SoundService.instance.playButtonTap();
      onToggleGuia();
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compacto ? 8 : 14,
          vertical: compacto ? 6 : 10,
        ),
        child: Row(
          children: [
            // Botón Regresar de alto contraste
            Semantics(
              label: 'Regresar',
              button: true,
              onTap: onRegresar,
              child: GestureDetector(
                onTap: onRegresar,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compacto ? 10 : 14,
                    vertical: compacto ? 8 : 9,
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
                      if (!compacto) ...[
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
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Chip Filtro Baños
            Semantics(
              label: mostrarBanios ? 'Ocultar baños' : 'Mostrar baños',
              button: true,
              onTap: onToggleBanios,
              child: GestureDetector(
                onTap: onToggleBanios,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compacto ? 9 : 12,
                    vertical: compacto ? 8 : 9,
                  ),
                  decoration: BoxDecoration(
                    color: mostrarBanios ? Colors.blue.shade700 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade700, width: 1.8),
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
                      if (!compacto) ...[
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
                      ],
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
            ),

            SizedBox(width: compacto ? 5 : 8),

            // Botón Guía Tutorial (Toggle instantáneo)
            Semantics(
              key: keyComoFunciona,
              label: tutorialStep > 0 ? 'Cerrar guía' : 'Abrir guía',
              button: true,
              onTap: toggleGuia,
              child: GestureDetector(
                onTap: toggleGuia,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compacto ? 9 : 14,
                    vertical: compacto ? 8 : 9,
                  ),
                  decoration: BoxDecoration(
                    color: tutorialStep > 0
                        ? const Color(0xFFF59E0B)
                        : AppColors.verdeAzulado,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 1.5),
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
                      if (!compacto) ...[
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
