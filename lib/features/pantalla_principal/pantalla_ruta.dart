import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Modelo descriptivo de un hábitat / zona para la página de rutas
class HabitatRutaItem {
  final String id;
  final String nombre;
  final String etiqueta;
  final Color colorEtiqueta;
  final String animalesTexto;
  final String duracion;
  final String caracteristicas;
  final String imagen;
  final String habitatFiltro;

  const HabitatRutaItem({
    required this.id,
    required this.nombre,
    required this.etiqueta,
    required this.colorEtiqueta,
    required this.animalesTexto,
    required this.duracion,
    required this.caracteristicas,
    required this.imagen,
    required this.habitatFiltro,
  });
}

/// Página de "Tu Ruta": permite conocer los animales por hábitats
/// y trazar el recorrido hacia cada zona directamente en el mapa.
class PantallaRuta extends StatelessWidget {
  final ValueChanged<String>? onTrazarRuta;

  const PantallaRuta({
    super.key,
    this.onTrazarRuta,
  });

  static const List<HabitatRutaItem> _habitats = [
    HabitatRutaItem(
      id: 'sabana',
      nombre: 'Sabana Africana',
      etiqueta: '🌍 DESTACADA',
      colorEtiqueta: Color(0xFFD97706),
      animalesTexto: 'Leones, Jirafas, Cebras',
      duracion: '30 min',
      caracteristicas: 'Miradores amplios y cafetería',
      imagen: 'assets/images/animales_con_fondo/leon-card.jpg',
      habitatFiltro: 'Zona Internacional',
    ),
    HabitatRutaItem(
      id: 'selva',
      nombre: 'Selva Amazónica',
      etiqueta: '🌴 SELVA',
      colorEtiqueta: Color(0xFF2E7D32),
      animalesTexto: 'Otorongo, Monos, Aves',
      duracion: '25 min',
      caracteristicas: 'Senderos con sombra y descanso',
      imagen: 'assets/images/animales_con_fondo/otorongo.jpg',
      habitatFiltro: 'Zona Selva',
    ),
    HabitatRutaItem(
      id: 'costa',
      nombre: 'Costa Marina',
      etiqueta: '🌊 COSTA',
      colorEtiqueta: Color(0xFF0077B6),
      animalesTexto: 'Pingüinos, Lobos de Mar',
      duracion: '20 min',
      caracteristicas: 'Piscina interactiva y anfiteatro',
      imagen: 'assets/images/animales_con_fondo/pinguino-card.jpg',
      habitatFiltro: 'Zona Costa',
    ),
    HabitatRutaItem(
      id: 'sierra',
      nombre: 'Sierra Andina',
      etiqueta: '⛰️ ANDES',
      colorEtiqueta: Color(0xFF8D6E63),
      animalesTexto: 'Cóndor Andino, Vicuñas',
      duracion: '20 min',
      caracteristicas: 'Mirador panorámico y artesanía',
      imagen: 'assets/images/animales_con_fondo/condor.jpg',
      habitatFiltro: 'Zona Sierra',
    ),
    HabitatRutaItem(
      id: 'granja',
      nombre: 'Granja Familiar',
      etiqueta: '🚜 FAMILIAR',
      colorEtiqueta: Color(0xFF8E24AA),
      animalesTexto: 'Vacas, Ovejas, Alpacas',
      duracion: '15 min',
      caracteristicas: 'Contacto directo y alimento',
      imagen: 'assets/images/animales_con_fondo/vaca-card.jpg',
      habitatFiltro: 'Granja Interactiva',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(
          'Rutas & Hábitats',
          style: GoogleFonts.urbanist(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textoOscuro,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INTRODUCCIÓN EDITORIAL MINIMALISTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONOCE LOS HÁBITATS DEL PARQUE',
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.verdePrincipal.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Selecciona un hábitat para trazar su recorrido en el mapa.',
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

            // CUADRÍCULA MINIMALISTA DE 2 POR FILA (2 POR CARD)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _habitats.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final habitat = _habitats[index];
                return _buildHabitatCard(context, habitat);
              },
            ),

            // Margen inferior para que no quede tapado por el footer persistente
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitatCard(BuildContext context, HabitatRutaItem habitat) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          SoundService.instance.playButtonTap();
          if (onTrazarRuta != null) {
            onTrazarRuta!(habitat.habitatFiltro);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.asset(
                          habitat.imagen,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.nature_people, size: 36, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    // Gradiente suave para legibilidad
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
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
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
                                const Icon(Icons.schedule_rounded, size: 10.5, color: Colors.white),
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
                    // Botón circular minimalista flotante con brújula
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.verdePrincipal,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.explore_rounded,
                          color: Colors.white,
                          size: 17,
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
                        fontWeight: FontWeight.w600,
                        color: AppColors.verdePrincipal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 11.5,
                          color: AppColors.textoGris,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Trazar sendero',
                          style: GoogleFonts.urbanist(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textoGris,
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
