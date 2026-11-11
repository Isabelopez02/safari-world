import 'package:flutter/material.dart';
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
      nombre: 'Sabana Africana & Internacional',
      etiqueta: '🌍 ZONA DESTACADA',
      colorEtiqueta: Color(0xFFD97706),
      animalesTexto: 'Leones, Jirafas, Cebras, Rinocerontes y Felinos',
      duracion: '30 min de recorrido',
      caracteristicas: 'Terreno plano • Miradores amplios • Cafetería cercana',
      imagen: 'assets/images/animales_con_fondo/leon-card.jpg',
      habitatFiltro: 'Zona Internacional',
    ),
    HabitatRutaItem(
      id: 'selva',
      nombre: 'Selva Amazónica & Bosque Tropical',
      etiqueta: '🌴 BIODIVERSIDAD',
      colorEtiqueta: Color(0xFF2E7D32),
      animalesTexto: 'Otorongo, Anaconda, Monos, Guacamayos y Tapires',
      duracion: '25 min de recorrido',
      caracteristicas: 'Senderos con sombra • Vegetación densa • Zonas de descanso',
      imagen: 'assets/images/animales_con_fondo/otorongo.jpg',
      habitatFiltro: 'Zona Selva',
    ),
    HabitatRutaItem(
      id: 'costa',
      nombre: 'Costa Marina & Pingüinos',
      etiqueta: '🌊 FAUNA COSTERA',
      colorEtiqueta: Color(0xFF0077B6),
      animalesTexto: 'Lobos de Mar, Pingüinos de Humboldt, Focas y Aves guaneras',
      duracion: '20 min de recorrido',
      caracteristicas: 'Piscina interactiva • Anfiteatro Acuático • Brisa marina',
      imagen: 'assets/images/animales_con_fondo/pinguino-card.jpg',
      habitatFiltro: 'Zona Costa',
    ),
    HabitatRutaItem(
      id: 'sierra',
      nombre: 'Sierra Andina & Alturas',
      etiqueta: '⛰️ ANDES PERUANOS',
      colorEtiqueta: Color(0xFF8D6E63),
      animalesTexto: 'Cóndor Andino, Vicuñas, Alpacas y Zorro Andino',
      duracion: '20 min de recorrido',
      caracteristicas: 'Mirador panorámico • Clima fresco • Bazar artesanal',
      imagen: 'assets/images/animales_con_fondo/condor.jpg',
      habitatFiltro: 'Zona Sierra',
    ),
    HabitatRutaItem(
      id: 'granja',
      nombre: 'Granja Interactiva Familiar',
      etiqueta: '🚜 IDEAL NIÑOS',
      colorEtiqueta: Color(0xFF8E24AA),
      animalesTexto: 'Vacas Holstein, Ovejas, Alpacas bebé y Aves de corral',
      duracion: '15 min de recorrido',
      caracteristicas: 'Contacto directo • Alimento permitido • Área techada',
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INTRODUCCIÓN EDITORIAL
            Text(
              'CONOCE LOS HÁBITATS DEL PARQUE',
              style: GoogleFonts.urbanist(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.verdePrincipal.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Elige qué animales deseas visitar hoy y traza el sendero en el mapa.',
              style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textoGris,
                height: 1.25,
              ),
            ),

            const SizedBox(height: 18),

            // LISTA DE TARJETAS DE HÁBITATS
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _habitats.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final habitat = _habitats[index];
                return _buildHabitatCard(context, habitat);
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitatCard(BuildContext context, HabitatRutaItem habitat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEN PANORÁMICA DE LA ZONA
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                child: AspectRatio(
                  aspectRatio: 16 / 7.5,
                  child: Image.asset(
                    habitat.imagen,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.nature_people, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              // Gradiente sutil
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                ),
              ),
              // Badge de Zona
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: habitat.colorEtiqueta,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    habitat.etiqueta,
                    style: GoogleFonts.urbanist(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              // Duración
              Positioned(
                bottom: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_walk_rounded, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        habitat.duracion,
                        style: GoogleFonts.urbanist(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // INFORMACIÓN EDITORIAL Y BOTÓN DE ACCIÓN
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habitat.nombre,
                  style: GoogleFonts.urbanist(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textoOscuro,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🐾 ', style: TextStyle(fontSize: 13)),
                    Expanded(
                      child: Text(
                        habitat.animalesTexto,
                        style: GoogleFonts.urbanist(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.verdePrincipal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 13, color: AppColors.textoGris),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        habitat.caracteristicas,
                        style: GoogleFonts.urbanist(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textoGris,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // BOTÓN TRAZAR RUTA EN EL MAPA
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      SoundService.instance.playButtonTap();
                      if (onTrazarRuta != null) {
                        onTrazarRuta!(habitat.habitatFiltro);
                      }
                    },
                    icon: const Icon(Icons.explore_rounded, size: 17, color: Colors.white),
                    label: Text(
                      'Trazar ruta hacia esta zona',
                      style: GoogleFonts.urbanist(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdePrincipal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
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
