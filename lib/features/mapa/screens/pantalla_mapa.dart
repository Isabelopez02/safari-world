import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/emergency_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

import '../utils/datos_rutas.dart';
import '../utils/servicio_rutas_svg.dart';
import '../widgets/barra_filtros_mapa.dart';
import '../widgets/barra_inferior_mapa.dart';
import '../widgets/barra_superior_mapa.dart';
import '../widgets/capa_trazos_mapa.dart';
import '../widgets/marcador_animado.dart';
import '../widgets/modal_accesibilidad_mapa.dart';
import '../widgets/modal_animales_por_visitar.dart';
import '../widgets/tutorial_overlay.dart';

class PantallaMapa extends StatefulWidget {
  final bool abrirExploracionesAlCargar;
  final String? animalIdInicial;
  const PantallaMapa({
    super.key,
    this.abrirExploracionesAlCargar = false,
    this.animalIdInicial,
  });

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa>
    with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late AnimationController _cameraAnimationController;
  late AnimationController _routeProgressController;
  late AnimationController _bottomBarPulseController;
  late AnimationController _radarPulseController;
  late Animation<double> _radarPulseAnimation;

  Animation<Matrix4>? _cameraAnimation;

  final GlobalKey _keyAnimales = GlobalKey();
  final GlobalKey _keySearch = GlobalKey();
  final GlobalKey _keyHelp = GlobalKey();
  final GlobalKey _keyComoFunciona = GlobalKey();
  final GlobalKey _keyFab = GlobalKey();

  int _tutorialStep = 0;
  final int _totalTutorialSteps = 5;

  final double mapaAncho = 1920;
  final double mapaAlto = 1080;

  List<Offset> _rutaActual = [];
  Path? _rutaSvgActual;
  MarcadorMapa? _marcadorSeleccionado;
  final String _nodoActual = 'entrada';
  bool _isNavigating = false;
  bool _mostrarBanios = false;
  FiltroServicioMapa _filtroServicio = FiltroServicioMapa.todos;

  // Marcadores cargados desde AnimalService
  final List<MarcadorMapa> marcadores = AnimalService.instance
      .obtenerTodosLosAnimales();
  final List<MarcadorMapa> banios = AnimalService.instance.obtenerBanios();
  final List<MarcadorMapa> accesos = AnimalService.instance.obtenerAccesos();
  final List<MarcadorMapa> zonasCalma = AnimalService.instance.obtenerZonasCalma();

  @override
  void initState() {
    super.initState();
    _cameraAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _routeProgressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _bottomBarPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _radarPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _radarPulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _radarPulseController, curve: Curves.easeOut),
    );

    _cameraAnimationController.addListener(() {
      if (_cameraAnimation != null) {
        _transformationController.value = _cameraAnimation!.value;
      }
    });

    AnimalService.instance.addListener(_onAnimalServiceChanged);
    AccesibilidadService.instance.addListener(_onAccesibilidadChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centrarEnUbicacionInicial(false);
      if (widget.animalIdInicial != null) {
        final matches = marcadores.where((m) => m.id == widget.animalIdInicial);
        if (matches.isNotEmpty) {
          _mostrarInfoMarcador(matches.first);
        }
      } else if (widget.abrirExploracionesAlCargar) {
        _mostrarAnimalesPorVisitar(context);
      } else {
        _checkTutorial();
      }
    });
  }

  void _onAnimalServiceChanged() {
    if (mounted) setState(() {});
  }

  void _onAccesibilidadChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeen = prefs.getBool('has_seen_map_tutorial') ?? false;
    if (!hasSeen) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          setState(() => _tutorialStep = 1);
        }
      });
    }
  }

  Future<void> _finishTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_map_tutorial', true);
    setState(() => _tutorialStep = 0);
  }

  @override
  void dispose() {
    AnimalService.instance.removeListener(_onAnimalServiceChanged);
    AccesibilidadService.instance.removeListener(_onAccesibilidadChanged);
    _transformationController.dispose();
    _cameraAnimationController.dispose();
    _routeProgressController.dispose();
    _bottomBarPulseController.dispose();
    _radarPulseController.dispose();
    super.dispose();
  }

  Matrix4 _clampearMatriz(Matrix4 matrix, Size viewportSize) {
    final scale = matrix.getMaxScaleOnAxis();
    final translation = matrix.getTranslation();

    final scaledWidth = mapaAncho * scale;
    final scaledHeight = mapaAlto * scale;

    double tx = translation.x;
    double ty = translation.y;

    if (scaledWidth >= viewportSize.width) {
      tx = tx.clamp(viewportSize.width - scaledWidth, 0.0);
    } else {
      tx = (viewportSize.width - scaledWidth) / 2;
    }

    if (scaledHeight >= viewportSize.height) {
      ty = ty.clamp(viewportSize.height - scaledHeight, 0.0);
    } else {
      ty = (viewportSize.height - scaledHeight) / 2;
    }

    return Matrix4.identity()
      ..translateByVector3(vmath.Vector3(tx, ty, 0.0))
      ..scaleByVector3(vmath.Vector3(scale, scale, 1.0));
  }

  void _centrarEnUbicacionInicial([bool animate = true]) {
    final nodo = grafoMapa.nodos[_nodoActual];
    if (nodo != null) {
      _centrarEnPunto(nodo.posicion.dx, nodo.posicion.dy);
    } else {
      final size = MediaQuery.of(context).size;
      final double scale = math.max(
        size.width / mapaAncho,
        size.height / mapaAlto,
      );
      final dx = (size.width - mapaAncho * scale) / 2;
      final dy = (size.height - mapaAlto * scale) / 2;
      final targetMatrix = Matrix4.identity()
        ..translateByVector3(vmath.Vector3(dx, dy, 0.0))
        ..scaleByVector3(vmath.Vector3(scale, scale, 1.0));

      _limitarYCentrar(targetMatrix, animate);
    }
  }

  bool _isMarkerMatchingFilter(MarcadorMapa marcador) {
    switch (_filtroServicio) {
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

  void _onFiltroCambiado(FiltroServicioMapa nuevoFiltro) {
    setState(() {
      _filtroServicio = nuevoFiltro;
      if (nuevoFiltro == FiltroServicioMapa.banio) {
        _mostrarBanios = true;
      }
    });

    if (nuevoFiltro != FiltroServicioMapa.todos) {
      MarcadorMapa? objetivo;
      if (nuevoFiltro == FiltroServicioMapa.banio) {
        objetivo = _encontrarBanioMasCercano();
      } else if (nuevoFiltro == FiltroServicioMapa.calma) {
        if (zonasCalma.isNotEmpty) {
          objetivo = zonasCalma.first;
        }
      } else {
        final matches =
            accesos.where((a) => _isMarkerMatchingFilter(a)).toList();
        if (matches.isNotEmpty) {
          objetivo = matches.first;
        }
      }

      if (objetivo != null) {
        _centrarEnPunto(objetivo.x, objetivo.y);
      }
    } else {
      _onMyLocationPressed();
    }
  }

  MarcadorMapa? _encontrarBanioMasCercano() {
    MarcadorMapa? mejorBanio;
    double menorDistancia = double.infinity;

    for (final banio in banios) {
      final ruta = grafoMapa.encontrarRutaMasCorta(_nodoActual, banio.id);
      if (ruta.isNotEmpty) {
        double dist = 0;
        for (int i = 0; i < ruta.length - 1; i++) {
          dist += (ruta[i] - ruta[i + 1]).distance;
        }
        if (dist < menorDistancia) {
          menorDistancia = dist;
          mejorBanio = banio;
        }
      }
    }
    return mejorBanio ?? (banios.isNotEmpty ? banios.first : null);
  }

  void _centrarEnPunto(double x, double y) {
    final size = MediaQuery.of(context).size;
    final double minMapScale = math.max(
      size.width / mapaAncho,
      size.height / mapaAlto,
    );
    final double currentScale = _transformationController.value
        .getMaxScaleOnAxis();
    final double zoomScale = math.max(currentScale, math.max(minMapScale, 1.35));

    final double dx = (size.width / 2) - (x * zoomScale);
    final double dy = (size.height / 2) - (y * zoomScale);

    final targetMatrix = Matrix4.identity()
      ..translateByVector3(vmath.Vector3(dx, dy, 0.0))
      ..scaleByVector3(vmath.Vector3(zoomScale, zoomScale, 1.0));

    _limitarYCentrar(targetMatrix, true);
  }

  void _limitarYCentrar(Matrix4 target, bool animate) {
    final size = MediaQuery.of(context).size;
    final clamped = _clampearMatriz(target, size);
    if (animate) {
      _cameraAnimation =
          Matrix4Tween(
            begin: _transformationController.value,
            end: clamped,
          ).animate(
            CurvedAnimation(
              parent: _cameraAnimationController,
              curve: Curves.easeInOut,
            ),
          );
      _cameraAnimationController.forward(from: 0);
    } else {
      _transformationController.value = clamped;
    }
  }

  void _onMyLocationPressed() {
    SoundService.instance.playRadarPulse();
    final nodo = grafoMapa.nodos[_nodoActual];
    if (nodo != null) {
      _centrarEnPunto(nodo.posicion.dx, nodo.posicion.dy);
    }
  }

  void _mostrarInfoMarcador(MarcadorMapa marcador) {
    final origen =
        grafoMapa.nodos[_nodoActual]?.posicion ??
        ServicioRutasSvg.puntoEntradaOficial;
    final nuevaRuta = grafoMapa.encontrarRutaMasCorta(_nodoActual, marcador.id);
    final rutaSvg = ServicioRutasSvg.obtenerRutaHacia(
      marcador,
      origen: origen,
    );
    setState(() {
      _marcadorSeleccionado = marcador;
      // Si el usuario toca un baño, iniciar de inmediato la navegación activa hacia él
      _isNavigating = marcador.esBanio;
      _rutaActual = nuevaRuta;
      _rutaSvgActual = rutaSvg;
    });
    _centrarEnPunto(marcador.x, marcador.y);
    _routeProgressController.forward(from: 0);
  }

  Rect _getRect(GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final size = renderObject.size;
      final offset = renderObject.localToGlobal(Offset.zero);
      return offset & size;
    }
    return Rect.zero;
  }

  Rect _getRectForStep(int step) {
    switch (step) {
      case 1:
        return _getRect(_keyAnimales);
      case 2:
        return _getRect(_keySearch);
      case 3:
        return _getRect(_keyHelp);
      case 4:
        return _getRect(_keyComoFunciona);
      case 5:
        return _getRect(_keyFab);
      default:
        return Rect.zero;
    }
  }

  String _getTextForStep(int step) {
    switch (step) {
      case 1:
        return 'Toca aquí para ver tu progreso\ny los animales que te faltan.';
      case 2:
        return 'Busca un animal o\nservicio en especifico';
      case 3:
        return 'Llama a\nemergencia si lo necesitas';
      case 4:
        return 'Vuelve a mirar este\ntutorial en cualquier momento';
      case 5:
        return 'Usa este botón para volver a tu\nubicación actual rápidamente.';
      default:
        return '';
    }
  }

  void _mostrarAnimalesPorVisitar(BuildContext context) {
    ModalAnimalesPorVisitar.mostrar(
      context,
      onSeleccionarAnimal: _mostrarInfoMarcador,
    );
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
            (_filtroServicio != FiltroServicioMapa.todos && !matches));

    final bool isHighlighted = isSelected ||
        (!haySeleccionActiva &&
            _filtroServicio != FiltroServicioMapa.todos &&
            matches);

    final bool mostrarEtiqueta = isSelected ||
        (!haySeleccionActiva && mostrarEtiquetaDefecto);

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
        onTap: () => _mostrarInfoMarcador(marcador),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double minMapScale = math.max(
      screenSize.width / mapaAncho,
      screenSize.height / mapaAlto,
    );
    final double currentScale =
        _transformationController.value.getMaxScaleOnAxis();
    final bool mostrarEtiquetasAnimales = currentScale >= 1.25;
    final a11y = AccesibilidadService.instance;

    return Scaffold(
      backgroundColor: a11y.modoAltoContraste ? const Color(0xFF020617) : Colors.white,
      extendBody: true,
      body: Stack(
        children: [
          // MAPA INTERACTIVO
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: minMapScale,
              maxScale: 5.0,
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
                                0.38, 0,    0,    0, -15,
                                0,    0.38, 0,    0, -15,
                                0,    0,    0.38, 0, -15,
                                0,    0,    0,    1, 0,
                              ])
                            : const ColorFilter.matrix(<double>[
                                1, 0, 0, 0, 0,
                                0, 1, 0, 0, 0,
                                0, 0, 1, 0, 0,
                                0, 0, 0, 1, 0,
                              ]),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (_marcadorSeleccionado != null) {
                              setState(() {
                                _marcadorSeleccionado = null;
                                _rutaActual = [];
                                _rutaSvgActual = null;
                              });
                            }
                          },
                          child: Image.asset(
                            'assets/images/mapa_zoologico.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),

                    // CAPA 2: PINES SECUNDARIOS / NO SELECCIONADOS
                    // (Se ubican por debajo del trazo de ruta para no tapar el recorrido)
                    ...marcadores
                        .where((m) => m.id != _marcadorSeleccionado?.id)
                        .map((marcador) => _buildMarcadorPosicionado(
                              marcador: marcador,
                              isSelected: false,
                              haySeleccionActiva: _marcadorSeleccionado != null,
                              mostrarEtiquetaDefecto: mostrarEtiquetasAnimales,
                            )),

                    if (_mostrarBanios ||
                        _filtroServicio == FiltroServicioMapa.banio)
                      ...banios
                          .where((b) => b.id != _marcadorSeleccionado?.id)
                          .map((banio) => _buildMarcadorPosicionado(
                                marcador: banio,
                                isSelected: false,
                                haySeleccionActiva: _marcadorSeleccionado != null,
                                mostrarEtiquetaDefecto: true,
                              )),

                    ...accesos
                        .where((a) => a.id != _marcadorSeleccionado?.id)
                        .map((acceso) => _buildMarcadorPosicionado(
                              marcador: acceso,
                              isSelected: false,
                              haySeleccionActiva: _marcadorSeleccionado != null,
                              mostrarEtiquetaDefecto: true,
                            )),

                    if (a11y.mostrarZonasCalma ||
                        _filtroServicio == FiltroServicioMapa.calma)
                      ...zonasCalma
                          .where((c) => c.id != _marcadorSeleccionado?.id)
                          .map((calma) => _buildMarcadorPosicionado(
                                marcador: calma,
                                isSelected: false,
                                haySeleccionActiva: _marcadorSeleccionado != null,
                                mostrarEtiquetaDefecto: true,
                              )),

                    // CAPA 3: MODULAR DE TRAZOS Y RUTAS VECTORIALES SVG (POR ENCIMA DE LOS PINES ATENUADOS)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _routeProgressController,
                          builder: (context, child) {
                            return CapaTrazosMapa(
                              progreso: _routeProgressController.value,
                              rutaSvg: _rutaSvgActual,
                              rutaCoordenadas: _rutaActual,
                              estaNavegando: _isNavigating,
                            );
                          },
                        ),
                      ),
                    ),

                    // CAPA 4: ONDA DE RADAR EXPANSIVA EN LA UBICACIÓN DEL USUARIO (DECORATIVA: NO BLOQUEA CLICS)
                    if (grafoMapa.nodos.containsKey(_nodoActual)) ...[
                      Positioned(
                        left: grafoMapa.nodos[_nodoActual]!.posicion.dx - 60,
                        top: grafoMapa.nodos[_nodoActual]!.posicion.dy - 60,
                        child: IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _radarPulseAnimation,
                            builder: (context, child) {
                              final val = _radarPulseAnimation.value;
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
                        left: grafoMapa.nodos[_nodoActual]!.posicion.dx - 12,
                        top: grafoMapa.nodos[_nodoActual]!.posicion.dy - 12,
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
                        left: grafoMapa.nodos[_nodoActual]!.posicion.dx - 65,
                        top: grafoMapa.nodos[_nodoActual]!.posicion.dy - 46,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.8,
                              ),
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

                    // CAPA 5: DESTINO SELECCIONADO (EN LA CÚSPIDE: POR ENCIMA DEL TRAZO Y DE LOS DEMÁS PINES)
                    if (_marcadorSeleccionado != null)
                      _buildMarcadorPosicionado(
                        marcador: _marcadorSeleccionado!,
                        isSelected: true,
                        haySeleccionActiva: true,
                        mostrarEtiquetaDefecto: true,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // SOMBRA AMBIENTAL SUPERIOR PARA CONTRASTE DEL MAPA Y FILTROS
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

          // BARRA SUPERIOR MODULAR (Regresar, Baños y Guía) + BARRA DE FILTROS RÁPIDOS
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BarraSuperiorMapa(
                  onRegresar: () => Navigator.pop(context),
                  onSOS: () => EmergencyService.instance.mostrarModalEmergencia(context),
                  keyHelp: _keyHelp,
                  tutorialStep: _tutorialStep,
                  altoContraste: a11y.modoAltoContraste,
                  onToggleGuia: () {
                    setState(() {
                      _tutorialStep = (_tutorialStep > 0 ? 0 : 1);
                    });
                  },
                  keyComoFunciona: _keyComoFunciona,
                  onAccesibilidad: () {
                    ModalAccesibilidadMapa.mostrar(
                      context,
                      onSeleccionarZonaCalma: (zona) {
                        setState(() {
                          _filtroServicio = FiltroServicioMapa.calma;
                        });
                        _centrarEnPunto(zona.x, zona.y);
                        _mostrarInfoMarcador(zona);
                      },
                    );
                  },
                ),
                BarraFiltrosMapa(
                  filtroSeleccionado: _filtroServicio,
                  onFiltroCambiado: _onFiltroCambiado,
                  altoContraste: a11y.modoAltoContraste,
                ),
              ],
            ),
          ),

          // ISLA FLOTANTE DE CONTROL DERECHO (Buscar + Mi Ubicación con Cristal)
          // Se eleva dinámicamente si hay un animal seleccionado para no ser invadida por la tarjeta
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            right: 16,
            bottom: (_marcadorSeleccionado != null ? 190.0 : 105.0) +
                MediaQuery.of(context).padding.bottom,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: a11y.modoAltoContraste
                        ? const Color(0xFF0F172A)
                        : Colors.white.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(22),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: _keySearch,
                        icon: const Icon(Icons.search_rounded),
                        color: a11y.modoAltoContraste
                            ? const Color(0xFFFDE047)
                            : AppColors.verdeAzulado,
                        iconSize: 22,
                        tooltip: 'Buscar en el parque',
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _mostrarAnimalesPorVisitar(context);
                        },
                      ),
                      Container(
                        width: 22,
                        height: 1,
                        color: a11y.modoAltoContraste
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                      IconButton(
                        key: _keyFab,
                        icon: const Icon(Icons.my_location_rounded),
                        color: a11y.modoAltoContraste
                            ? const Color(0xFFFDE047)
                            : AppColors.verdeAzulado,
                        iconSize: 22,
                        tooltip: 'Mi ubicación',
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _onMyLocationPressed();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // COMPONENTE BARRA INFERIOR REUTILIZABLE (Cápsula Flotante)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BarraInferiorMapa(
              keyAnimales: _keyAnimales,
              marcadorSeleccionado: _marcadorSeleccionado,
              isNavigating: _isNavigating,
              marcadores: marcadores,
              bottomBarPulseController: _bottomBarPulseController,
              onTapExploraciones: () => _mostrarAnimalesPorVisitar(context),
              onCerrarSeleccion: () => setState(() {
                _marcadorSeleccionado = null;
                _rutaActual = [];
                _rutaSvgActual = null;
              }),
              onIniciarNavegacion: () {
                setState(() => _isNavigating = true);
                _routeProgressController.forward(from: 0);
              },
              onCancelarNavegacion: () {
                setState(() {
                  _isNavigating = false;
                  _marcadorSeleccionado = null;
                  _rutaActual = [];
                  _rutaSvgActual = null;
                });
              },
            ),
          ),

          // OVERLAY DEL TUTORIAL
          if (_tutorialStep > 0)
            TutorialOverlay(
              step: _tutorialStep,
              totalSteps: _totalTutorialSteps,
              targetRect: _getRectForStep(_tutorialStep),
              text: _getTextForStep(_tutorialStep),
              onNext: () {
                if (_tutorialStep < _totalTutorialSteps) {
                  setState(() => _tutorialStep++);
                } else {
                  _finishTutorial();
                }
              },
              onPrev: () => setState(() => _tutorialStep--),
              onSkip: _finishTutorial,
            ),
        ],
      ),
    );
  }
}
