import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/emergency_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

import '../utils/datos_rutas.dart';
import '../utils/servicio_rutas_svg.dart';
import '../widgets/barra_inferior_mapa.dart';
import '../widgets/barra_superior_mapa.dart';
import '../widgets/marcador_animado.dart';
import '../widgets/modal_animales_por_visitar.dart';
import '../widgets/ruta_painter.dart';
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

  // Marcadores cargados desde AnimalService
  final List<MarcadorMapa> marcadores = AnimalService.instance
      .obtenerTodosLosAnimales();
  final List<MarcadorMapa> banios = AnimalService.instance.obtenerBanios();

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

  void _centrarEnPunto(double x, double y) {
    final size = MediaQuery.of(context).size;
    final double minMapScale = math.max(
      size.width / mapaAncho,
      size.height / mapaAlto,
    );
    final double currentScale = _transformationController.value
        .getMaxScaleOnAxis();
    final double zoomScale = math.max(currentScale, math.max(minMapScale, 1.4));

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
    final nuevaRuta = grafoMapa.encontrarRutaMasCorta(_nodoActual, marcador.id);
    final rutaSvg = ServicioRutasSvg.obtenerRutaHacia(marcador);
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

  void _dirigirAlBanioMasCercano() {
    SoundService.instance.playButtonTap();

    // 1. Mostrar los paraderos de baños en el mapa si estaban ocultos
    setState(() {
      _mostrarBanios = true;
    });

    // 2. Si ya estábamos navegando a un baño y se vuelve a presionar, toggle off
    if (_marcadorSeleccionado != null &&
        _marcadorSeleccionado!.esBanio &&
        _isNavigating) {
      setState(() {
        _marcadorSeleccionado = null;
        _isNavigating = false;
        _rutaActual = [];
        _rutaSvgActual = null;
        _mostrarBanios = false;
      });
      return;
    }

    // 3. Buscar el baño más cercano calculando la ruta más corta
    MarcadorMapa? mejorBanio;
    List<Offset> mejorRuta = [];
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
          mejorRuta = ruta;
        }
      }
    }

    final destino = mejorBanio ?? banios.first;
    final rutaFinal = mejorRuta.isNotEmpty
        ? mejorRuta
        : grafoMapa.encontrarRutaMasCorta(_nodoActual, destino.id);

    // 4. Activar navegación directa hacia el paradero del baño
    setState(() {
      _marcadorSeleccionado = destino;
      _isNavigating = true;
      _rutaActual = rutaFinal;
      _rutaSvgActual = ServicioRutasSvg.obtenerRutaHacia(destino);
    });

    _centrarEnPunto(destino.x, destino.y);
    _routeProgressController.forward(from: 0);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const Icon(Icons.wc_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Dirigiéndote al paradero de ${destino.nombre} (#${destino.id})',
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double minMapScale = math.max(
      screenSize.width / mapaAncho,
      screenSize.height / mapaAlto,
    );

    return Scaffold(
      backgroundColor: Colors.white,
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
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/mapa_zoologico.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _routeProgressController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: RutaPainter(
                              _rutaActual,
                              _isNavigating,
                              rutaSvg: _rutaSvgActual,
                              progress: _routeProgressController.value,
                            ),
                          );
                        },
                      ),
                    ),
                    // MARCADOR GUÍA ANIMADO QUE VIAJA POR LA CURVA SVG
                    if (_rutaSvgActual != null)
                      AnimatedBuilder(
                        animation: _routeProgressController,
                        builder: (context, child) {
                          if (_routeProgressController.value <= 0.0) {
                            return const SizedBox.shrink();
                          }
                          final metrics = _rutaSvgActual!.computeMetrics().toList();
                          if (metrics.isEmpty) return const SizedBox.shrink();

                          final totalLength = metrics.fold(0.0, (acc, m) => acc + m.length);
                          final targetDist = _routeProgressController.value * totalLength;

                          Offset puntoGuia = Offset.zero;
                          double distAcumulada = 0.0;
                          for (final metric in metrics) {
                            if (targetDist <= distAcumulada + metric.length) {
                              final localDist = targetDist - distAcumulada;
                              puntoGuia = metric.getTangentForOffset(localDist)?.position ?? Offset.zero;
                              break;
                            }
                            distAcumulada += metric.length;
                          }
                          if (puntoGuia == Offset.zero && metrics.isNotEmpty) {
                            puntoGuia = metrics.last.getTangentForOffset(metrics.last.length)?.position ?? Offset.zero;
                          }

                          return Positioned(
                            left: puntoGuia.dx - 18,
                            top: puntoGuia.dy - 34,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _isNavigating
                                    ? const Color(0xFF0E6568)
                                    : const Color(0xFFE65100),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.navigation_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          );
                        },
                      ),
                    // PARADEROS DE ANIMALES
                    ...marcadores.map((marcador) {
                      return Positioned(
                        left: marcador.x - 52,
                        top: marcador.y - 40,
                        child: MarcadorAnimado(
                          marcador: marcador,
                          isSelected: _marcadorSeleccionado?.id == marcador.id,
                          onTap: () => _mostrarInfoMarcador(marcador),
                        ),
                      );
                    }),
                    // PARADEROS DE BAÑOS (si el filtro está activo)
                    if (_mostrarBanios)
                      ...banios.map((banio) {
                        return Positioned(
                          left: banio.x - 38,
                          top: banio.y - 32,
                          child: MarcadorAnimado(
                            marcador: banio,
                            isSelected: _marcadorSeleccionado?.id == banio.id,
                            onTap: () => _mostrarInfoMarcador(banio),
                          ),
                        );
                      }),
                    // ONDA DE RADAR EXPANSIVA EN LA UBICACIÓN DEL USUARIO
                    if (grafoMapa.nodos.containsKey(_nodoActual)) ...[
                      Positioned(
                        left: grafoMapa.nodos[_nodoActual]!.posicion.dx - 60,
                        top: grafoMapa.nodos[_nodoActual]!.posicion.dy - 60,
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
                      Positioned(
                        left: grafoMapa.nodos[_nodoActual]!.posicion.dx - 12,
                        top: grafoMapa.nodos[_nodoActual]!.posicion.dy - 12,
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
                      // BADGE DESTACADO: TÚ ESTÁS AQUÍ
                      Positioned(
                        left: grafoMapa.nodos[_nodoActual]!.posicion.dx - 65,
                        top: grafoMapa.nodos[_nodoActual]!.posicion.dy - 46,
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
                    ],
                  ],
                ),
              ),
            ),
          ),

          // SOMBRA AMBIENTAL SUPERIOR PARA CONTRASTE DEL MAPA
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // BARRA SUPERIOR MODULAR (Regresar, Baños y Guía)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BarraSuperiorMapa(
              onRegresar: () => Navigator.pop(context),
              mostrarBanios: _mostrarBanios,
              onToggleBanios: _dirigirAlBanioMasCercano,
              tutorialStep: _tutorialStep,
              onToggleGuia: () {
                setState(() {
                  _tutorialStep = (_tutorialStep > 0 ? 0 : 1);
                });
              },
              keyComoFunciona: _keyComoFunciona,
            ),
          ),

          // BOTONES FLOTANTES CIRCULARES PERFECTOS (SOS, Búsqueda, Mi Ubicación)
          // Con padding inferior dinámico para que no los tape la barra del celular
          Positioned(
            right: 16,
            bottom: 140 + MediaQuery.of(context).padding.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón Emergencia SOS
                _buildCircularActionButton(
                  key: _keyHelp,
                  color: const Color(0xFFD32F2F),
                  iconColor: Colors.white,
                  icon: Icons.phone_in_talk_rounded,
                  size: 46,
                  iconSize: 20,
                  onPressed: () {
                    EmergencyService.instance.mostrarModalEmergencia(context);
                  },
                ),
                const SizedBox(height: 12),

                // Botón Búsqueda y Exploraciones
                _buildCircularActionButton(
                  key: _keySearch,
                  color: Colors.white,
                  iconColor: AppColors.verdeAzulado,
                  icon: Icons.search_rounded,
                  size: 46,
                  iconSize: 22,
                  onPressed: () => _mostrarAnimalesPorVisitar(context),
                ),
                const SizedBox(height: 16),

                // Botón Mi Ubicación Radar
                _buildCircularActionButton(
                  key: _keyFab,
                  color: AppColors.verdeAzulado,
                  iconColor: Colors.white,
                  icon: Icons.my_location_rounded,
                  size: 54,
                  iconSize: 26,
                  onPressed: _onMyLocationPressed,
                ),
              ],
            ),
          ),

          // COMPONENTE BARRA INFERIOR REUTILIZABLE
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

  Widget _buildCircularActionButton({
    Key? key,
    required Color color,
    required Color iconColor,
    required IconData icon,
    required double size,
    required double iconSize,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      key: key,
      onTap: () {
        SoundService.instance.playButtonTap();
        onPressed();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}
