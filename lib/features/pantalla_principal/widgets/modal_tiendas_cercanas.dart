import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

class TiendaItem {
  final String nombre;
  final String tipo;
  final String distancia;
  final String horario;
  final IconData icono;
  final Color color;

  const TiendaItem({
    required this.nombre,
    required this.tipo,
    required this.distancia,
    required this.horario,
    required this.icono,
    required this.color,
  });
}

/// Modal que lista tiendas de souvenirs, cafeterías y puntos de descanso cercanos.
class ModalTiendasCercanas extends StatelessWidget {
  final VoidCallback onAbrirEnMapa;

  const ModalTiendasCercanas({
    super.key,
    required this.onAbrirEnMapa,
  });

  static const List<TiendaItem> _tiendas = [
    TiendaItem(
      nombre: 'Souvenir Safari Store',
      tipo: 'Regalos, peluches y recuerdos',
      distancia: 'A 80 metros • Entrada Principal',
      horario: '9:30 AM - 5:30 PM',
      icono: Icons.storefront_rounded,
      color: Color(0xFF2E7D32),
    ),
    TiendaItem(
      nombre: 'Cafetería El Mirador',
      tipo: 'Café, sándwiches y bebidas frías',
      distancia: 'A 150 metros • Frente a Zona Sabana',
      horario: '10:00 AM - 5:00 PM',
      icono: Icons.coffee_rounded,
      color: Color(0xFF8D6E63),
    ),
    TiendaItem(
      nombre: 'Heladería & Snacks Los Monos',
      tipo: 'Helados artesanales y aperitivos',
      distancia: 'A 220 metros • Zona Selva',
      horario: '10:30 AM - 5:00 PM',
      icono: Icons.icecream_rounded,
      color: Color(0xFFE57373),
    ),
    TiendaItem(
      nombre: 'Bazar Artesanal Andino',
      tipo: 'Tejidos, artesanías típicas y gorros',
      distancia: 'A 310 metros • Zona Sierra',
      horario: '10:00 AM - 5:00 PM',
      icono: Icons.shopping_bag_rounded,
      color: Color(0xFFDF9F1D),
    ),
  ];

  static void mostrar(BuildContext context, {required VoidCallback onAbrirEnMapa}) {
    SoundService.instance.playButtonTap();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalTiendasCercanas(onAbrirEnMapa: onAbrirEnMapa),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de agarre
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // TÍTULO Y DESCRIPCIÓN
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.amarilloMostaza.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.amarilloMostaza,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tiendas y Snacks Cercanos',
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textoOscuro,
                    ),
                  ),
                  Text(
                    'Encuentra recuerdos, comida fresca e hidratación',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textoGris,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // LISTADO DE TIENDAS
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: _tiendas.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final tienda = _tiendas[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFBFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: tienda.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(tienda.icono, color: tienda.color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tienda.nombre,
                              style: GoogleFonts.urbanist(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textoOscuro,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tienda.tipo,
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textoGris,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 13,
                                  color: tienda.color,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    tienda.distancia,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: tienda.color,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // BOTÓN VER TODAS EN EL MAPA
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onAbrirEnMapa();
              },
              icon: const Icon(Icons.map_rounded, size: 18, color: Colors.white),
              label: Text(
                'Ver puntos de servicio en el mapa',
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verdePrincipal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
