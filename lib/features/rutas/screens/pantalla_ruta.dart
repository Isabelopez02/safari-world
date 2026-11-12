import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import '../data/datos_habitats_rutas.dart';
import '../widgets/tarjeta_habitat_ruta.dart';

/// Página de "Tu Ruta": permite conocer los animales por hábitats
/// y trazar el recorrido hacia cada zona directamente en el mapa.
class PantallaRuta extends StatelessWidget {
  final ValueChanged<String>? onTrazarRuta;

  const PantallaRuta({
    super.key,
    this.onTrazarRuta,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AnimalService.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFBF9F6),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            automaticallyImplyLeading: false,
            title: Text(
              'rutas_habitats'.tr,
              style: GoogleFonts.urbanist(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textoOscuro,
                letterSpacing: -0.4,
              ),
            ),
          ),
          body: Builder(
            builder: (context) {
              final double screenWidth = MediaQuery.of(context).size.width;
              final bool esTablet = screenWidth >= 720;
              final int columnas = esTablet ? (screenWidth >= 1000 ? 4 : 3) : 2;
              final double childAspect = esTablet ? 0.78 : 0.72;

              final Widget content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Introducción editorial
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'conoce_habitats'.tr,
                          style: GoogleFonts.urbanist(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppColors.verdePrincipal.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'conoce_habitats_sub'.tr,
                          style: GoogleFonts.urbanist(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textoGris,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cuadrícula adaptable de hábitats
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listaHabitatsRuta.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnas,
                      crossAxisSpacing: esTablet ? 16 : 12,
                      mainAxisSpacing: esTablet ? 16 : 14,
                      childAspectRatio: childAspect,
                    ),
                    itemBuilder: (context, index) {
                      final habitat = listaHabitatsRuta[index];
                      return TarjetaHabitatRuta(
                        habitat: habitat,
                        onTrazarRuta: onTrazarRuta,
                      );
                    },
                  ),

                  const SizedBox(height: 90),
                ],
              );

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: esTablet ? 24.0 : 16.0,
                  vertical: 4.0,
                ),
                child: esTablet
                    ? SizedBox(
                        width: double.infinity,
                        child: Center(
                          heightFactor: 1.0,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1040),
                            child: content,
                          ),
                        ),
                      )
                    : content,
              );
            },
          ),
        );
      },
    );
  }
}
