import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

import '../data/filtro_servicio_mapa.dart';
import '../utils/pathfinding.dart';
import 'capa_trazos_mapa.dart';
import 'marcador_animado.dart';

/// Canvas interactivo del mapa que renderiza el fondo, las capas de marcadores,
/// los trazos vectoriales animados y el radar de ubicación del usuario.
class CanvasMapaInteractivo extends StatelessWidget {
  final TransformationController transformationController;
  final double minMapScale;
  final double maxMapScale;
  final double mapaAncho;
  final double mapaAlto;

  final MarcadorMapa? marcadorSeleccionado;
  final List<MarcadorMapa> marcadores;
  final List<MarcadorMapa> banios;
  final List<MarcadorMapa> accesos;
  final List<MarcadorMapa> zonasCalma;

  final bool mostrarBanios;
  final bool mostrarZonasCalma;
  final bool mostrarEtiquetasAnimales;

  final FiltroServicioMapa filtroServicio;
  final String? habitatFiltro;

  final String nodoActual;
  final GrafoZoolologico grafoMapa;
  final Animation<double> radarPulseAnimation;
  final Animation<double> routeProgressAnimation;
  final Path? rutaSvgActual;
  final List<Offset> rutaActual;
  final bool isNavigating;

  final VoidCallback onDeseleccionar;
  final ValueChanged<MarcadorMapa> onSelectMarcador;

  const CanvasMapaInteractivo({
    super.key,
    required this.transformationController,
    required this.minMapScale,
    this.maxMapScale = 5.0,
    required this.mapaAncho,
    required this.mapaAlto,
    required this.marcadorSeleccionado,
    required this.marcadores,
    required this.banios,
    required this.accesos,
    required this.zonasCalma,
    required this.mostrarBanios,
    required this.mostrarZonasCalma,
    required this.mostrarEtiquetasAnimales,
    required this.filtroServicio,
    this.habitatFiltro,
    required this.nodoActual,
    required this.grafoMapa,
    required this.radarPulseAnimation,
    required this.routeProgressAnimation,
    this.rutaSvgActual,
    required this.rutaActual,
    required this.isNavigating,
    required this.onDeseleccionar,
    required this.onSelectMarcador,
  });

  bool _isMarkerMatchingFilter(MarcadorMapa marcador) {
    if (habitatFiltro != null &&
        marcador.tipoServicio == null &&
        !marcador.esBanio &&
        !marcador.esZonaCalma) {
      if (marcador.habitat != habitatFiltro) return false;
    }

    switch (filtroServicio) {
      case FiltroServicioMapa.todos:
        return true;
      case FiltroServicioMapa.calma:
        return marcador.esZonaCalma || marcador.tipoServicio == 'calma';
      case FiltroServicioMapa.banio:
        return marcador.esBanio || marcador.tipoServicio == 'banio';
      case FiltroServicioMapa.estacionamiento:
        return marcador.tipoServicio == 'estacionamiento';
      case FiltroServicioMapa.boleteria:
        return marcador.tipoServicio == 'boleteria';
      case FiltroServicioMapa.salida:
        return marcador.tipoServicio == 'salida';
      case FiltroServicioMapa.juegos:
        return marcador.tipoServicio == 'juegos';
    }
  }

  Widget _buildMarcadorPosicionado({
    required MarcadorMapa marcador,
    required bool isSelected,
    required bool haySeleccionActiva,
    required bool mostrarEtiquetaDefecto,
  }) {
    final bool matches = _isMarkerMatchingFilter(marcador);

    // Si hay un marcador/recorrido seleccionado:
    // - El seleccionado nunca se atenúa y siempre muestra su etiqueta
    // - Los demás marcadores se atenúan (isDimmed = true) y ocultan su texto para no tapar la ruta
    final bool isDimmed = isSelected
        ? false
        : (haySeleccionActiva ||
              (filtroServicio != FiltroServicioMapa.todos && !matches));

    final bool isHighlighted =
        isSelected ||
        (!haySeleccionActiva &&
            filtroServicio != FiltroServicioMapa.todos &&
            matches);

    final bool mostrarEtiqueta =
        isSelected || (!haySeleccionActiva && mostrarEtiquetaDefecto);

    final double leftOffset;
    final double topOffset;
    if (marcador.esZonaCalma) {
      leftOffset = marcador.x - 37;
      topOffset = marcador.y - 14;
    } else if (marcador.esBanio) {
      leftOffset = marcador.x - 27;
      topOffset = marcador.y - 12;
    } else {
      leftOffset = marcador.x - 35;
      topOffset = marcador.y - 14;
    }

    return Positioned(
      key: ValueKey('marcador_${marcador.id}'),
      left: leftOffset,
      top: topOffset,
      child: MarcadorAnimado(
        marcador: marcador,
        isSelected: isSelected,
        isDimmed: isDimmed,
        isHighlighted: isHighlighted,
        mostrarEtiqueta: mostrarEtiqueta,
        onTap: () => onSelectMarcador(marcador),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a11y = AccesibilidadService.instance;

    return Positioned.fill(
      child: InteractiveViewer(
        transformationController: transformationController,
        minScale: minMapScale,
        maxScale: maxMapScale,
        boundaryMargin: EdgeInsets.zero,
        constrained: false,
        child: SizedBox(
          width: mapaAncho,
          height: mapaAlto,
          child: Stack(
            children: [
              // CAPA 1: MAPA BASE
              Positioned.fill(
                child: ColorFiltered(
                  colorFilter: a11y.modoAltoContraste
                      ? const ColorFilter.matrix(<double>[
                          0.38,
                          0,
                          0,
                          0,
                          -15,
                          0,
                          0.38,
                          0,
                          0,
                          -15,
                          0,
                          0,
                          0.38,
                          0,
                          -15,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ])
                      : const ColorFilter.matrix(<double>[
                          1,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onDeseleccionar,
                    child: Image.asset(
                      'assets/images/mapa_zoologico.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),

              // CAPA 2: PINES SECUNDARIOS / NO SELECCIONADOS
              ...marcadores
                  .where((m) => m.id != marcadorSeleccionado?.id)
                  .map(
                    (marcador) => _buildMarcadorPosicionado(
                      marcador: marcador,
                      isSelected: false,
                      haySeleccionActiva: marcadorSeleccionado != null,
                      mostrarEtiquetaDefecto: mostrarEtiquetasAnimales,
                    ),
                  ),

              if (mostrarBanios || filtroServicio == FiltroServicioMapa.banio)
                ...banios
                    .where((b) => b.id != marcadorSeleccionado?.id)
                    .map(
                      (banio) => _buildMarcadorPosicionado(
                        marcador: banio,
                        isSelected: false,
                        haySeleccionActiva: marcadorSeleccionado != null,
                        mostrarEtiquetaDefecto: true,
                      ),
                    ),

              ...accesos
                  .where((a) => a.id != marcadorSeleccionado?.id)
                  .map(
                    (acceso) => _buildMarcadorPosicionado(
                      marcador: acceso,
                      isSelected: false,
                      haySeleccionActiva: marcadorSeleccionado != null,
                      mostrarEtiquetaDefecto: true,
                    ),
                  ),

              if (mostrarZonasCalma)
                ...zonasCalma
                    .where((c) => c.id != marcadorSeleccionado?.id)
                    .map(
                      (calma) => _buildMarcadorPosicionado(
                        marcador: calma,
                        isSelected: false,
                        haySeleccionActiva: marcadorSeleccionado != null,
                        mostrarEtiquetaDefecto: true,
                      ),
                    ),

              // CAPA 3: MODULAR DE TRAZOS Y RUTAS VECTORIALES SVG
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: routeProgressAnimation,
                    builder: (context, child) {
                      return CapaTrazosMapa(
                        progreso: routeProgressAnimation.value,
                        rutaSvg: rutaSvgActual,
                        rutaCoordenadas: rutaActual,
                        estaNavegando: isNavigating,
                      );
                    },
                  ),
                ),
              ),

              // CAPA 4: ONDA DE RADAR EXPANSIVA EN LA UBICACIÓN DEL USUARIO
              if (grafoMapa.nodos.containsKey(nodoActual)) ...[
                Positioned(
                  left: grafoMapa.nodos[nodoActual]!.posicion.dx - 60,
                  top: grafoMapa.nodos[nodoActual]!.posicion.dy - 60,
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: radarPulseAnimation,
                      builder: (context, child) {
                        final val = radarPulseAnimation.value;
                        return Container(
                          width: 120,
                          height: 120,
                          alignment: Alignment.center,
                          child: Container(
                            width: 24 + (96 * val),
                            height: 24 + (96 * val),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.verdeAzulado.withValues(
                                alpha: (1.0 - val) * 0.35,
                              ),
                              border: Border.all(
                                color: AppColors.verdeAzulado.withValues(
                                  alpha: (1.0 - val) * 0.8,
                                ),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: grafoMapa.nodos[nodoActual]!.posicion.dx - 12,
                  top: grafoMapa.nodos[nodoActual]!.posicion.dy - 12,
                  child: IgnorePointer(
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.verdeAzulado,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // BADGE DESTACADO: TÚ ESTÁS AQUÍ
                Positioned(
                  left: grafoMapa.nodos[nodoActual]!.posicion.dx - 65,
                  top: grafoMapa.nodos[nodoActual]!.posicion.dy - 46,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 1.8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tú estás aquí',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // CAPA 5: DESTINO SELECCIONADO (EN LA CÚSPIDE)
              if (marcadorSeleccionado != null &&
                  (!marcadorSeleccionado!.esZonaCalma || mostrarZonasCalma))
                _buildMarcadorPosicionado(
                  marcador: marcadorSeleccionado!,
                  isSelected: true,
                  haySeleccionActiva: true,
                  mostrarEtiquetaDefecto: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
