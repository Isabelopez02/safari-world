import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Selector segmentado de tamaño de letra (Normal | Medio | Grande) con vista previa en vivo
class SelectorTamanoLetra extends StatelessWidget {
  const SelectorTamanoLetra({super.key});

  String _obtenerNombreTamano(TamanoTexto tamano) {
    switch (tamano) {
      case TamanoTexto.pequeno:
        return 'letra_pequeno'.tr;
      case TamanoTexto.mediano:
        return 'letra_mediano'.tr;
      case TamanoTexto.grande:
        return 'letra_grande'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AccesibilidadService.instance,
      builder: (context, _) {
        final tamanoActual = AccesibilidadService.instance.tamanoTexto;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.verdePrincipal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.format_size_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tamaño de Letra de la App',
                          style: GoogleFonts.urbanist(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textoOscuro,
                          ),
                        ),
                        Text(
                          'Ajusta la legibilidad para toda la aplicación',
                          style: GoogleFonts.urbanist(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textoGris,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SELECTOR SEGMENTADO ESTILO IPHONE (NORMAL | MEDIO | GRANDE)
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<TamanoTexto>(
                  groupValue: tamanoActual,
                  backgroundColor: const Color(0xFFE5E5EA), // Gris Cupertino
                  thumbColor: Colors.white,
                  children: {
                    TamanoTexto.pequeno: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'A',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Normal',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TamanoTexto.mediano: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'A',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Medio',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TamanoTexto.grande: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'A',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Grande',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  },
                  onValueChanged: (TamanoTexto? nuevoTamano) {
                    if (nuevoTamano != null && nuevoTamano != tamanoActual) {
                      SoundService.instance.playButtonTap();
                      AccesibilidadService.instance.setTamanoTexto(nuevoTamano);

                      final messenger = ScaffoldMessenger.of(context);
                      messenger.hideCurrentSnackBar();
                      messenger.showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          backgroundColor: const Color(0xFF1E293B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          content: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.format_size_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'alerta_letra_cambiada'.tr,
                                      style: GoogleFonts.urbanist(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${'tamano_actual'.tr}: ${_obtenerNombreTamano(nuevoTamano)}',
                                      style: GoogleFonts.urbanist(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 14),

              // CAJA DE VISTA PREVIA DEL TAMAÑO DE TEXTO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9FB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'VISTA PREVIA EN VIVO:',
                          style: GoogleFonts.urbanist(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.verdePrincipal.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tamanoActual == TamanoTexto.pequeno
                                ? 'Escala 1.0x (Estándar)'
                                : tamanoActual == TamanoTexto.mediano
                                ? 'Escala 1.15x (+15%)'
                                : 'Escala 1.30x (+30%)',
                            style: GoogleFonts.urbanist(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.verdePrincipal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '«¡Bienvenido al zoológico! Explora los animales, consulta los shows y disfruta de tu expedición.»',
                      style: GoogleFonts.urbanist(
                        fontSize:
                            13.0 *
                            AccesibilidadService
                                .instance
                                .multiplicadorEscalaTexto,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textoOscuro,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
