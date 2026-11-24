import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/models/datos_animal.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/pantalla_principal/widgets/footer_navegacion.dart';

import 'pantalla_detalle_animal.dart';

/// Layout optimizado para pantallas de teléfonos móviles (< 720px)
/// Experiencia inmersiva vertical con Hero Image panorámica, tipografía editorial
/// y chips sin truncamiento de texto.
class DetalleAnimalMovil extends StatelessWidget {
  final MarcadorMapa animal;
  final DatosAnimal datos;
  final HabitatThemeData theme;
  final bool esVisitado;
  final bool isPlayingAudio;
  final AnimationController audioWaveController;
  final VoidCallback onToggleAudioguia;
  final VoidCallback onToggleVisitado;
  final VoidCallback onBack;

  const DetalleAnimalMovil({
    super.key,
    required this.animal,
    required this.datos,
    required this.theme,
    required this.esVisitado,
    required this.isPlayingAudio,
    required this.audioWaveController,
    required this.onToggleAudioguia,
    required this.onToggleVisitado,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AccesibilidadService.instance,
        IdiomaService.instance,
      ]),
      builder: (context, _) {
        final a11y = AccesibilidadService.instance;
        final bool oscuro = a11y.modoAltoContraste;

        // En modo alto contraste: fondo oscuro profundo, texto blanco, tarjetas dark
        final Color fondoPantalla = oscuro
            ? const Color(0xFF020617)
            : theme.background;
        final Color textoTitulo = oscuro ? Colors.white : AppColors.textoOscuro;
        final Color accentColor = oscuro
            ? const Color(0xFFFDE047)
            : theme.accent;

        return Scaffold(
          backgroundColor: fondoPantalla,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. CABECERA HERO PANORÁMICA EXPANDIBLE
              SliverAppBar(
                expandedHeight: 260.0,
                pinned: true,
                elevation: 0,
                backgroundColor: theme.accent,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: onBack,
                    ),
                  ),
                ),
                actions: [
                  // BOTÓN AUDIOGUÍA FLOTANTE
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 12,
                      top: 8,
                      bottom: 8,
                    ),
                    child: GestureDetector(
                      onTap: onToggleAudioguia,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isPlayingAudio
                              ? const Color(0xFFFF9800)
                              : Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isPlayingAudio
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.6),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPlayingAudio
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.headphones_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isPlayingAudio ? 'pausar'.tr : 'audioguia'.tr,
                              style: GoogleFonts.urbanist(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // FOTO PRINCIPAL DEL ANIMAL
                      Hero(
                        tag: 'animal_image_${animal.id}',
                        child: animal.imagen != null
                            ? Image.asset(
                                animal.imagen!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildFallbackImage(),
                              )
                            : _buildFallbackImage(),
                      ),

                      // DEGRADADO OSCURO INFERIOR PARA CONTRASTE
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.25),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.65),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),

                      // BADGE HÁBITAT SOBRE LA FOTO
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: theme.accent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    theme.emoji,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    theme.nombreHabitat.tr,
                                    style: GoogleFonts.urbanist(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '#${animal.id}',
                                style: GoogleFonts.urbanist(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. CUERPO DE INFORMACIÓN EDITORIAL
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TÍTULO Y NOMBRE CIENTÍFICO CON SELLO SI ESTÁ VISITADO
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  animal.nombre.tr,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w900,
                                    color: textoTitulo,
                                    height: 1.15,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  datos.nombreCientifico,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 13.5,
                                    fontStyle: FontStyle.italic,
                                    color: accentColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (esVisitado)
                            Transform.rotate(
                              angle: -0.14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC62828)
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFC62828),
                                    width: 1.8,
                                  ),
                                ),
                                child: Text(
                                  'visitado_sello'.tr,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFC62828),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // CHIPS DE ESTADO EN WRAP (DIETA, HÁBITAT, CONSERVACIÓN)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChip(
                            icon: Icons.restaurant_rounded,
                            label: datos.dieta.tr,
                            color: accentColor,
                          ),
                          _buildChip(
                            icon: Icons.shield_rounded,
                            label: datos.estadoConservacion.tr,
                            color: oscuro
                                ? const Color(0xFFFB923C)
                                : const Color(0xFFE65100),
                            esAlerta: true,
                          ),
                        ],
                      ),

                      // REPRODUCTOR AUDIOGUÍA EXPANDIBLE
                      if (isPlayingAudio) ...[
                        const SizedBox(height: 16),
                        _buildReproductorAudioguia(),
                      ],

                      const SizedBox(height: 16),

                      // HORARIOS Y ALIMENTACIÓN (SIN TRUNCAMIENTO DE TEXTO)
                      _buildTarjetaHorariosYDieta(),

                      const SizedBox(height: 14),

                      // COMPORTAMIENTO EN EL HÁBITAT
                      _buildTarjetaComportamiento(),

                      const SizedBox(height: 14),

                      // ¿SABÍAS QUE? (CURIOSIDAD DEL EXPLORADOR)
                      _buildTarjetaCuriosidad(),

                      const SizedBox(height: 18),

                      // PASAPORTE DE VISITAS
                      _buildBotonPasaporte(),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: FooterNavegacion(
            indiceSeleccionado: 1,
            onTabSeleccionado: (index) {
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Widget _buildBotonPasaporte() {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onToggleVisitado,
        icon: Icon(
          esVisitado ? Icons.check_circle_rounded : Icons.bookmark_add_rounded,
          size: 20,
          color: Colors.white,
        ),
        label: Text(
          esVisitado ? 'explorado_pasaporte'.tr : 'marcar_pasaporte'.tr,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: esVisitado ? const Color(0xFF15803D) : theme.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          shadowColor: (esVisitado ? const Color(0xFF15803D) : theme.accent)
              .withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: theme.accent,
      alignment: Alignment.center,
      child: Icon(
        animal.icono,
        size: 72,
        color: Colors.white.withValues(alpha: 0.85),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
    bool esAlerta = false,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: esAlerta
            ? const Color(0xFFFFF3E0)
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esAlerta
              ? const Color(0xFFFFB74D)
              : color.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReproductorAudioguia() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.graphic_eq_rounded,
                color: Color(0xFFE65100),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'narracion_audioguia'.tr,
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFE65100),
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: audioWaveController,
                builder: (context, child) {
                  return Row(
                    children: List.generate(4, (i) {
                      final h =
                          5.0 +
                          (12.0 *
                              ((audioWaveController.value + (i * 0.25)) % 1.0));
                      return Container(
                        margin: const EdgeInsets.only(left: 3),
                        width: 3,
                        height: h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE65100),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            datos.getNarracion(animal.nombre),
            style: GoogleFonts.urbanist(
              fontSize: 12.5,
              color: Colors.brown.shade800,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaHorariosYDieta() {
    final a11y = AccesibilidadService.instance;
    final bool oscuro = a11y.modoAltoContraste;
    final Color fondoTarjeta = oscuro ? const Color(0xFF0F172A) : Colors.white;
    final Color bordeTarjeta = oscuro ? Colors.white12 : Colors.grey.shade200;
    final Color textoTitulo = oscuro ? Colors.white : AppColors.textoOscuro;
    final Color textoSecundario = oscuro
        ? const Color(0xFF94A3B8)
        : Colors.grey.shade600;
    final Color accentColor = oscuro ? const Color(0xFFFDE047) : theme.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fondoTarjeta,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bordeTarjeta),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FILA HORARIOS
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'horarios_visualizacion'.tr,
                      style: GoogleFonts.urbanist(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: textoSecundario,
                      ),
                    ),
                    Text(
                      '${datos.horaApertura} - ${datos.horaCierre}',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: textoTitulo,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              thickness: 0.8,
              color: oscuro ? Colors.white12 : Colors.grey.shade200,
            ),
          ),

          // FILA DIETA (TEXTO COMPLETO SIN RECORTES)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  size: 16,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'alimentacion_dieta_diaria'.tr,
                      style: GoogleFonts.urbanist(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: textoSecundario,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      datos.alimentos.map((a) => a.tr).join(', '),
                      style: GoogleFonts.urbanist(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: textoTitulo,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaComportamiento() {
    final a11y = AccesibilidadService.instance;
    final bool oscuro = a11y.modoAltoContraste;
    final Color fondoTarjeta = oscuro ? const Color(0xFF0F172A) : Colors.white;
    final Color bordeTarjeta = oscuro ? Colors.white12 : Colors.grey.shade200;
    final Color textoTitulo = oscuro ? Colors.white : AppColors.textoOscuro;
    final Color textoSecundario = oscuro
        ? const Color(0xFF94A3B8)
        : Colors.grey.shade800;
    final Color accentColor = oscuro ? const Color(0xFFFDE047) : theme.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fondoTarjeta,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bordeTarjeta),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_rounded, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'comportamiento_habitat'.tr,
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: textoTitulo,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            datos.getComportamiento(animal.nombre),
            style: GoogleFonts.urbanist(
              fontSize: 13,
              color: textoSecundario,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaCuriosidad() {
    final a11y = AccesibilidadService.instance;
    final bool oscuro = a11y.modoAltoContraste;
    final Color fondoCuriosidad = oscuro
        ? const Color(0xFF1E293B)
        : theme.gradientStart.withValues(alpha: 0.35);
    final Color bordeColor = oscuro
        ? const Color(0xFFFDE047).withValues(alpha: 0.5)
        : theme.accent.withValues(alpha: 0.35);
    final Color accentColor = oscuro ? const Color(0xFFFDE047) : theme.accent;
    final Color textoBody = oscuro
        ? const Color(0xFFCBD5E1)
        : Colors.grey.shade900;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fondoCuriosidad,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bordeColor, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'sabias_que'.tr,
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  datos.getCuriosidad(animal.nombre),
                  style: GoogleFonts.urbanist(
                    fontSize: 12.5,
                    color: textoBody,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
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
