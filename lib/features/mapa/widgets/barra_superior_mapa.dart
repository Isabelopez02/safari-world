import 'package:flutter/material.dart';

import '../data/filtro_servicio_mapa.dart';
import 'barra_busqueda_hibrida_mapa.dart';
import 'barra_filtros_modo_facil.dart';

/// Barra superior del mapa interactivo con degradado de contraste y soporte para modo normal y modo fácil
class BarraSuperiorMapa extends StatelessWidget {
  final bool modoFacil;
  final VoidCallback? onVolverMenuFacil;
  final ChipUrgenciaMapa chipActivo;
  final FiltroServicioMapa filtroServicio;
  final ValueChanged<ChipUrgenciaMapa> onChipSeleccionado;
  final ValueChanged<FiltroServicioMapa> onFiltroCambiado;
  final VoidCallback onAbrirCapas;

  const BarraSuperiorMapa({
    super.key,
    required this.modoFacil,
    this.onVolverMenuFacil,
    required this.chipActivo,
    required this.filtroServicio,
    required this.onChipSeleccionado,
    required this.onFiltroCambiado,
    required this.onAbrirCapas,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sombra ambiental superior para contraste del mapa y filtros
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 160,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.black.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Barra superior híbrida o modo fácil
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: modoFacil
              ? BarraFiltrosModoFacil(
                  onVolverMenuFacil: onVolverMenuFacil,
                  chipUrgencia: chipActivo,
                  filtroServicio: filtroServicio,
                  onChipUrgenciaCambiado: onChipSeleccionado,
                  onFiltroCambiado: onFiltroCambiado,
                )
              : Center(
                  heightFactor: 1.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: BarraBusquedaHibridaMapa(
                      chipActivo: chipActivo,
                      onChipSeleccionado: onChipSeleccionado,
                      onAbrirCapas: onAbrirCapas,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
