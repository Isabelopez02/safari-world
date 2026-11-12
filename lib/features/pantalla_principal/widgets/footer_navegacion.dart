import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Barra de navegación inferior (Footer) elegante, sutil y ergonómica.
/// Cuenta con 5 secciones clave:
/// 0: Inicio
/// 1: Mapa
/// 2: Shows
/// 3: Tu Ruta
/// 4: Perfil
class FooterNavegacion extends StatelessWidget {
  final int indiceSeleccionado;
  final ValueChanged<int> onTabSeleccionado;

  const FooterNavegacion({
    super.key,
    required this.indiceSeleccionado,
    required this.onTabSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    final bool esTablet = MediaQuery.of(context).size.width >= 720;

    final navContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            iconoActivo: Icons.home_rounded,
            iconoInactivo: Icons.home_outlined,
            etiqueta: 'Inicio',
          ),
          _buildNavItem(
            index: 1,
            iconoActivo: Icons.map_rounded,
            iconoInactivo: Icons.map_outlined,
            etiqueta: 'Mapa',
          ),
          _buildNavItem(
            index: 2,
            iconoActivo: Icons.theater_comedy_rounded,
            iconoInactivo: Icons.theater_comedy_outlined,
            etiqueta: 'Shows',
          ),
          _buildNavItem(
            index: 3,
            iconoActivo: Icons.alt_route_rounded,
            iconoInactivo: Icons.alt_route_outlined,
            etiqueta: 'Tu Ruta',
          ),
          _buildNavItem(
            index: 4,
            iconoActivo: Icons.person_rounded,
            iconoInactivo: Icons.person_outline_rounded,
            etiqueta: 'Perfil',
          ),
        ],
      ),
    );

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Container(
        margin: EdgeInsets.fromLTRB(
          esTablet ? 32 : 14,
          2,
          esTablet ? 32 : 14,
          esTablet ? 8 : 4,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: esTablet
            ? SizedBox(
                width: double.infinity,
                child: Center(
                  heightFactor: 1.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: navContent,
                  ),
                ),
              )
            : navContent,
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData iconoActivo,
    required IconData iconoInactivo,
    required String etiqueta,
  }) {
    final bool activo = indiceSeleccionado == index;

    return InkWell(
      onTap: () {
        SoundService.instance.playButtonTap();
        onTabSeleccionado(index);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: activo
              ? AppColors.verdePrincipal.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              activo ? iconoActivo : iconoInactivo,
              color: activo ? AppColors.verdePrincipal : AppColors.textoGris,
              size: 23,
            ),
            const SizedBox(height: 3),
            Text(
              etiqueta,
              style: GoogleFonts.urbanist(
                fontSize: 11,
                fontWeight: activo ? FontWeight.w800 : FontWeight.w600,
                color: activo ? AppColors.verdePrincipal : AppColors.textoGris,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
