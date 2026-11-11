import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Bloque de 4 acciones rápidas tipo tarjeta sutil:
/// 1. Ver shows
/// 2. Ver mapa
/// 3. Buscar tiendas cercanas
/// 4. ¿Te perdiste?
class AccionesRapidasGrid extends StatelessWidget {
  final VoidCallback onVerShows;
  final VoidCallback onVerMapa;
  final VoidCallback onBuscarTiendas;
  final VoidCallback onTePerdiste;

  const AccionesRapidasGrid({
    super.key,
    required this.onVerShows,
    required this.onVerMapa,
    required this.onBuscarTiendas,
    required this.onTePerdiste,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Qué quieres hacer hoy?',
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textoOscuro,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),

          // FILA 1: SHOWS Y MAPA
          Row(
            children: [
              Expanded(
                child: _buildTarjetaAccion(
                  icono: Icons.theater_comedy_rounded,
                  colorFondoIcono: const Color(0xFF0077B6),
                  titulo: 'Ver shows',
                  subtitulo: 'Horarios y eventos',
                  onTap: onVerShows,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTarjetaAccion(
                  icono: Icons.alt_route_rounded,
                  colorFondoIcono: AppColors.verdePrincipal,
                  titulo: 'Ruta del día',
                  subtitulo: 'Senderos y paradas',
                  onTap: onVerMapa,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // FILA 2: TIENDAS Y ¿TE PERDISTE?
          Row(
            children: [
              Expanded(
                child: _buildTarjetaAccion(
                  icono: Icons.storefront_rounded,
                  colorFondoIcono: const Color(0xFFD97706),
                  titulo: 'Tiendas cercanas',
                  subtitulo: 'Snacks y recuerdos',
                  onTap: onBuscarTiendas,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTarjetaAccion(
                  icono: Icons.explore_rounded,
                  colorFondoIcono: const Color(0xFFE65100),
                  titulo: '¿Te perdiste?',
                  subtitulo: 'Orientación y ayuda',
                  onTap: onTePerdiste,
                  destacado: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaAccion({
    required IconData icono,
    required Color colorFondoIcono,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
    bool destacado = false,
  }) {
    return InkWell(
      onTap: () {
        SoundService.instance.playButtonTap();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: destacado
                ? colorFondoIcono.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.06),
            width: destacado ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: colorFondoIcono.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icono, color: colorFondoIcono, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: GoogleFonts.urbanist(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textoOscuro,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitulo,
              style: GoogleFonts.urbanist(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textoGris,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
