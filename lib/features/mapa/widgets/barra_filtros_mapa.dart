import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Tipos de filtro rápido disponibles en el mapa interactivo
enum FiltroServicioMapa {
  todos,
  calma,
  banio,
  estacionamiento,
  boleteria,
  salida,
  juegos,
}

class _OpcionFiltro {
  final FiltroServicioMapa tipo;
  final String etiqueta;
  final IconData icono;
  final Color colorActivo;
  final String? badge;

  const _OpcionFiltro({
    required this.tipo,
    required this.etiqueta,
    required this.icono,
    required this.colorActivo,
    this.badge,
  });
}

/// Barra horizontal de filtros rápidos de servicios esenciales con efecto cristal
class BarraFiltrosMapa extends StatelessWidget {
  final FiltroServicioMapa filtroSeleccionado;
  final ValueChanged<FiltroServicioMapa> onFiltroCambiado;
  final bool altoContraste;

  const BarraFiltrosMapa({
    super.key,
    required this.filtroSeleccionado,
    required this.onFiltroCambiado,
    this.altoContraste = false,
  });

  static const List<_OpcionFiltro> _opciones = [
    _OpcionFiltro(
      tipo: FiltroServicioMapa.todos,
      etiqueta: 'Todos',
      icono: Icons.eco_rounded,
      colorActivo: AppColors.verdeAzulado,
    ),
    _OpcionFiltro(
      tipo: FiltroServicioMapa.calma,
      etiqueta: 'Zonas de Calma',
      icono: Icons.spa_rounded,
      colorActivo: Color(0xFF2E7D32),
      badge: '4',
    ),
    _OpcionFiltro(
      tipo: FiltroServicioMapa.banio,
      etiqueta: 'Baños',
      icono: Icons.wc_rounded,
      colorActivo: AppColors.verdeAzulado,
      badge: '4',
    ),
    _OpcionFiltro(
      tipo: FiltroServicioMapa.estacionamiento,
      etiqueta: 'Estacionamiento',
      icono: Icons.local_parking_rounded,
      colorActivo: Color(0xFF546E7A),
    ),
    _OpcionFiltro(
      tipo: FiltroServicioMapa.boleteria,
      etiqueta: 'Boletería / Entrada',
      icono: Icons.confirmation_number_rounded,
      colorActivo: Color(0xFFD97706),
    ),
    _OpcionFiltro(
      tipo: FiltroServicioMapa.salida,
      etiqueta: 'Salida',
      icono: Icons.logout_rounded,
      colorActivo: Color(0xFFC62828),
    ),
    _OpcionFiltro(
      tipo: FiltroServicioMapa.juegos,
      etiqueta: 'Juegos',
      icono: Icons.attractions_rounded,
      colorActivo: Color(0xFFD97706),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _opciones.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final opcion = _opciones[index];
          final bool isSelected = filtroSeleccionado == opcion.tipo;

          return ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  SoundService.instance.playButtonTap();
                  onFiltroCambiado(opcion.tipo);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (altoContraste ? const Color(0xFFFDE047) : opcion.colorActivo)
                        : (altoContraste
                            ? const Color(0xFF0F172A)
                            : Colors.white.withValues(alpha: 0.88)),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? (altoContraste ? Colors.white : opcion.colorActivo)
                          : (altoContraste
                              ? const Color(0xFF475569)
                              : const Color(0xFFCBD5E1)),
                      width: isSelected ? 2.0 : (altoContraste ? 1.5 : 1.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? opcion.colorActivo.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.10),
                        blurRadius: isSelected ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        opcion.icono,
                        size: 16,
                        color: isSelected
                            ? (altoContraste ? Colors.black : Colors.white)
                            : (altoContraste ? Colors.white : const Color(0xFF334155)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        opcion.etiqueta,
                        style: GoogleFonts.urbanist(
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.w900 : FontWeight.w700,
                          color: isSelected
                              ? (altoContraste ? Colors.black : Colors.white)
                              : (altoContraste ? Colors.white : const Color(0xFF1E293B)),
                        ),
                      ),
                      if (opcion.badge != null) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : opcion.colorActivo.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            opcion.badge!,
                            style: GoogleFonts.urbanist(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? Colors.white
                                  : opcion.colorActivo,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
