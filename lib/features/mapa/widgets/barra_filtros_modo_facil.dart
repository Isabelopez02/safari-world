import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';

import '../data/filtro_servicio_mapa.dart';
import 'barra_busqueda_hibrida_mapa.dart';

/// Barra accesible de filtros grandes para personas con discapacidad motriz o cognitiva (Modo Fácil)
class BarraFiltrosModoFacil extends StatelessWidget {
  final VoidCallback? onVolverMenuFacil;
  final ChipUrgenciaMapa chipUrgencia;
  final FiltroServicioMapa filtroServicio;
  final ValueChanged<ChipUrgenciaMapa> onChipUrgenciaCambiado;
  final ValueChanged<FiltroServicioMapa> onFiltroCambiado;

  const BarraFiltrosModoFacil({
    super.key,
    this.onVolverMenuFacil,
    required this.chipUrgencia,
    required this.filtroServicio,
    required this.onChipUrgenciaCambiado,
    required this.onFiltroCambiado,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onVolverMenuFacil != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    SoundService.instance.playButtonTap();
                    onVolverMenuFacil!();
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 24, color: Colors.white),
                  label: Text(
                    'volver_al_menu'.tr,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.white, width: 1.5),
                    ),
                    elevation: 6,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            // 3 Filtros accesibles y grandes
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildBotonFiltroFacilItem(
                      titulo: 'filtro_banios'.tr,
                      icono: Icons.wc_rounded,
                      color: const Color(0xFF0288D1),
                      activo: chipUrgencia == ChipUrgenciaMapa.banios,
                      onTap: () {
                        SoundService.instance.playButtonTap();
                        HapticFeedback.selectionClick();
                        onChipUrgenciaCambiado(ChipUrgenciaMapa.banios);
                        onFiltroCambiado(FiltroServicioMapa.banio);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildBotonFiltroFacilItem(
                      titulo: 'filtro_salida'.tr,
                      icono: Icons.exit_to_app_rounded,
                      color: const Color(0xFF2E7D32),
                      activo: chipUrgencia == ChipUrgenciaMapa.salidaParking,
                      onTap: () {
                        SoundService.instance.playButtonTap();
                        HapticFeedback.selectionClick();
                        onChipUrgenciaCambiado(ChipUrgenciaMapa.salidaParking);
                        onFiltroCambiado(FiltroServicioMapa.estacionamiento);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildBotonFiltroFacilItem(
                      titulo: 'filtro_calma'.tr,
                      icono: Icons.park_rounded,
                      color: const Color(0xFF6D4C41),
                      activo: filtroServicio == FiltroServicioMapa.calma,
                      onTap: () {
                        SoundService.instance.playButtonTap();
                        HapticFeedback.selectionClick();
                        onChipUrgenciaCambiado(ChipUrgenciaMapa.ninguno);
                        onFiltroCambiado(FiltroServicioMapa.calma);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonFiltroFacilItem({
    required String titulo,
    required IconData icono,
    required Color color,
    required bool activo,
    required VoidCallback onTap,
  }) {
    return Material(
      color: activo ? color : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, color: activo ? Colors.white : color, size: 26),
              const SizedBox(height: 4),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: activo ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
