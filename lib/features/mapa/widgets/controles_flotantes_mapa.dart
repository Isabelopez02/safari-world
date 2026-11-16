import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Controles flotantes circulares en la esquina inferior derecha del mapa
/// (Botón Mi Ubicación y Botón Capas del Mapa con efecto glassmorphism)
class ControlesFlotantesMapa extends StatelessWidget {
  final Key? keyFab;
  final bool hayMarcadorSeleccionado;
  final bool modoFacil;
  final VoidCallback onMiUbicacionPressed;
  final VoidCallback onCapasPressed;

  const ControlesFlotantesMapa({
    super.key,
    this.keyFab,
    required this.hayMarcadorSeleccionado,
    required this.modoFacil,
    required this.onMiUbicacionPressed,
    required this.onCapasPressed,
  });

  Widget _buildBotonFlotanteCircular({
    Key? key,
    required BuildContext context,
    required IconData icono,
    required String tooltip,
    required Color colorIcono,
    required VoidCallback onPressed,
  }) {
    final a11y = AccesibilidadService.instance;
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: a11y.modoAltoContraste
                ? const Color(0xFF0F172A)
                : Colors.white.withValues(alpha: 0.94),
            shape: BoxShape.circle,
            border: Border.all(
              color: a11y.modoAltoContraste
                  ? const Color(0xFFFDE047)
                  : const Color(0xFFCBD5E1),
              width: a11y.modoAltoContraste ? 2.0 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: a11y.modoAltoContraste
                    ? const Color(0xFFFDE047).withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            key: key,
            icon: Icon(icono),
            color: colorIcono,
            iconSize: 24,
            tooltip: tooltip,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a11y = AccesibilidadService.instance;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      right: 16,
      bottom: (hayMarcadorSeleccionado ? 190.0 : 105.0) +
          MediaQuery.of(context).padding.bottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. BOTÓN MI UBICACIÓN
          _buildBotonFlotanteCircular(
            key: keyFab,
            context: context,
            icono: Icons.my_location_rounded,
            tooltip: 'Mi ubicación',
            colorIcono: a11y.modoAltoContraste
                ? const Color(0xFFFDE047)
                : AppColors.verdeAzulado,
            onPressed: () {
              HapticFeedback.lightImpact();
              onMiUbicacionPressed();
            },
          ),
          if (!modoFacil) ...[
            const SizedBox(height: 10),
            // 2. BOTÓN CAPAS DEL MAPA (DEBAJO DE LA UBICACIÓN)
            _buildBotonFlotanteCircular(
              context: context,
              icono: Icons.layers_rounded,
              tooltip: 'Capas y Filtros',
              colorIcono: AppColors.verdePrincipal,
              onPressed: () {
                HapticFeedback.lightImpact();
                SoundService.instance.playButtonTap();
                onCapasPressed();
              },
            ),
          ],
        ],
      ),
    );
  }
}
