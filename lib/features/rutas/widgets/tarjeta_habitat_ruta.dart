import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

import '../data/habitat_ruta_item.dart';
import 'modal_animales_habitat.dart';

/// Tarjeta visual que presenta un hábitat / zona del parque zoológico
class TarjetaHabitatRuta extends StatelessWidget {
  final HabitatRutaItem habitat;
  final ValueChanged<String>? onTrazarRuta;

  const TarjetaHabitatRuta({
    super.key,
    required this.habitat,
    this.onTrazarRuta,
  });

  @override
  Widget build(BuildContext context) {
    final animalesZona = AnimalService.instance.obtenerPorHabitat(
      habitat.habitatFiltro,
    );
    final totalZona = animalesZona.length;
    final exploradosZona = animalesZona.where((a) => a.visitado).length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          SoundService.instance.playButtonTap();
          ModalAnimalesHabitat.mostrar(
            context,
            habitat: habitat,
            onTrazarRuta: onTrazarRuta,
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: habitat.colorFondo,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: habitat.colorBorde, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: habitat.colorAcento.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. FOTO PRINCIPAL VERTICAL CON BADGES SUTILES
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(19),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.asset(
                          habitat.imagen,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.nature_people,
                                  size: 36,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ),
                    // Gradiente suave para legibilidad
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(19),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.28),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.45),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Badge sutil de duración / tiempo
                    Positioned(
                      top: 8,
                      left: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  size: 10.5,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 3.5),
                                Text(
                                  habitat.duracion,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Badge de exploración en vivo "visitados/total"
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (exploradosZona == totalZona && totalZona > 0)
                                  ? const Color(0xFF15803D)
                                        .withValues(alpha: 0.85)
                                  : Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 0.9,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  exploradosZona == totalZona && totalZona > 0
                                      ? Icons.check_circle_rounded
                                      : Icons.pets_rounded,
                                  size: 11,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$exploradosZona/$totalZona',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. TEXTOS MINIMALISTAS AL PIE
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habitat.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.urbanist(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textoOscuro,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      habitat.animalesTexto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.urbanist(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: habitat.colorAcento,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 11.5,
                                color: habitat.colorAcento.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  'Ver animales ($totalZona)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: habitat.colorAcento,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            SoundService.instance.playButtonTap();
                            onTrazarRuta?.call(habitat.habitatFiltro);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: habitat.colorAcento.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: habitat.colorAcento.withValues(
                                  alpha: 0.3,
                                ),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.near_me_rounded,
                                  size: 10,
                                  color: habitat.colorAcento,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Trazar',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: habitat.colorAcento,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
  }
}
