import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

enum ChipUrgenciaMapa {
  ninguno,
  banios,
  animales,
  snacks,
  salidaParking,
}

/// Barra superior híbrida del mapa estilo Google Maps / Disney Parks:
/// - Selector de capas compacto
/// - 4 chips de urgencia y servicios vitales (Baños, Animales, Snacks, Salida/Parking)
class BarraBusquedaHibridaMapa extends StatelessWidget {
  final ChipUrgenciaMapa chipActivo;
  final ValueChanged<ChipUrgenciaMapa> onChipSeleccionado;
  final VoidCallback onAbrirCapas;

  const BarraBusquedaHibridaMapa({
    super.key,
    required this.chipActivo,
    required this.onChipSeleccionado,
    required this.onAbrirCapas,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 14.0, left: 16.0, right: 16.0, bottom: 8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // BOTÓN CAPAS / FILTROS (🎛️)
              _buildCircleActionButton(
                icono: Icons.layers_rounded,
                colorFondo: Colors.white.withValues(alpha: 0.94),
                colorIcono: AppColors.verdePrincipal,
                onTap: onAbrirCapas,
              ),
              const SizedBox(width: 8),
              _buildQuickPill(
                tipo: ChipUrgenciaMapa.banios,
                icono: Icons.wc_rounded,
                etiqueta: 'Baños',
                colorTema: AppColors.verdeAzulado,
              ),
              const SizedBox(width: 8),
              _buildQuickPill(
                tipo: ChipUrgenciaMapa.animales,
                icono: Icons.pets_rounded,
                etiqueta: 'Animales',
                colorTema: AppColors.verdePrincipal,
              ),
              const SizedBox(width: 8),
              _buildQuickPill(
                tipo: ChipUrgenciaMapa.snacks,
                icono: Icons.storefront_rounded,
                etiqueta: 'Snacks & Café',
                colorTema: AppColors.amarilloMostaza,
              ),
              const SizedBox(width: 8),
              _buildQuickPill(
                tipo: ChipUrgenciaMapa.salidaParking,
                icono: Icons.local_parking_rounded,
                etiqueta: 'Salida & Parking',
                colorTema: const Color(0xFF546E7A),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icono,
    required Color colorFondo,
    required Color colorIcono,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            SoundService.instance.playButtonTap();
            onTap();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colorFondo,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icono, color: colorIcono, size: 21),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPill({
    required ChipUrgenciaMapa tipo,
    required IconData icono,
    required String etiqueta,
    required Color colorTema,
  }) {
    final bool activo = chipActivo == tipo;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            SoundService.instance.playButtonTap();
            onChipSeleccionado(activo ? ChipUrgenciaMapa.ninguno : tipo);
          },
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: activo
                  ? colorTema
                  : Colors.white.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: activo
                    ? colorTema
                    : Colors.black.withValues(alpha: 0.08),
                width: activo ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: activo
                      ? colorTema.withValues(alpha: 0.28)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icono,
                  size: 15,
                  color: activo ? Colors.white : colorTema,
                ),
                const SizedBox(width: 5),
                Text(
                  etiqueta,
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: activo ? Colors.white : AppColors.textoOscuro,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
