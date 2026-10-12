import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/emergency_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

import '../utils/datos_rutas.dart';
import '../widgets/barra_inferior_mapa.dart';
import '../widgets/marcador_animado.dart';
import '../widgets/ruta_painter.dart';
import '../widgets/tutorial_overlay.dart';

class PantallaMapa extends StatefulWidget {
  final bool abrirExploracionesAlCargar;
  const PantallaMapa({super.key, this.abrirExploracionesAlCargar = false});

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
      if (widget.abrirExploracionesAlCargar) {
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
      setState(() => _tutorialStep = 1);
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
      ..translate(tx, ty)
      ..scale(scale);
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
      ..translate(dx, dy)
      ..scale(scale);

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
      ..translate(dx, dy)
      ..scale(zoomScale);

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
    setState(() {
      _marcadorSeleccionado = marcador;
      // Si el usuario toca un baño, iniciar de inmediato la navegación activa hacia él
      _isNavigating = marcador.esBanio;
      _rutaActual = nuevaRuta;
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ListenableBuilder(
          listenable: AnimalService.instance,
          builder: (context, _) {
            final visitados = AnimalService.instance.totalVisitados;
            final total = AnimalService.instance.totalAnimales;
            final pct = AnimalService.instance.porcentajeVisitados;

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.verdeAzulado,
                            AppColors.verdeAzulado.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.verdeAzulado.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.explore,
                                  color: AppColors.verdeAzulado,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '¡Aventura en curso!',
                                      style: GoogleFonts.urbanist(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Has visitado $visitados de $total animales (${(pct * 100).toInt()}%)',
                                      style: GoogleFonts.urbanist(
                                        fontSize: 14,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.25,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: DefaultTabController(
                      length: 6,
                      child: Column(
                        children: [
                          TabBar(
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            labelColor: AppColors.verdePrincipal,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: AppColors.verdeAzulado,
                            indicatorWeight: 3,
                            labelStyle: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                            unselectedLabelStyle: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            tabs: const [
                              Tab(text: '🌿 Todos'),
                              Tab(text: '🦁 Sabana'),
                              Tab(text: '🌴 Selva'),
                              Tab(text: '🐬 Acuático'),
                              Tab(text: '🚜 Granja'),
                              Tab(text: '🏔️ Montaña'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildGridCategorias('Todos'),
                                _buildGridCategorias('Sabana Africana'),
                                _buildGridCategorias('Selva Tropical'),
                                _buildGridCategorias('Mundo Acuático'),
                                _buildGridCategorias('La Granja'),
                                _buildGridCategorias('Bosque & Montaña'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGridCategorias(String habitat) {
    final items = AnimalService.instance.obtenerPorHabitat(habitat);
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_off_rounded, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No hay animales en este hábitat aún.',
              style: GoogleFonts.urbanist(
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final marcador = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
            _mostrarInfoMarcador(marcador);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // FONDO: imagen o gradiente de respaldo
                marcador.imagen != null
                    ? Image.asset(
                        marcador.imagen!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.verdePrincipal,
                                AppColors.verdeAzulado,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              marcador.icono,
                              size: 56,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: marcador.visitado
                                ? [
                                    AppColors.verdePrincipal.withValues(
                                      alpha: 0.7,
                                    ),
                                    AppColors.verdeAzulado.withValues(
                                      alpha: 0.5,
                                    ),
                                  ]
                                : [
                                    AppColors.verdePrincipal,
                                    AppColors.verdeAzulado,
                                  ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            marcador.icono,
                            size: 56,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ),

                // GRADIENTE INFERIOR para texto
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          marcador.nombre,
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          marcador.visitado ? '✓ Visitado' : 'Por visitar',
                          style: GoogleFonts.urbanist(
                            fontSize: 11,
                            color: marcador.visitado
                                ? const Color(0xFF81C784)
                                : Colors.white60,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // BADGE HÁBITAT
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      marcador.habitat.split(' ').first,
                      style: GoogleFonts.urbanist(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // BADGE VISITADO INTERACTIVO
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      SoundService.instance.playButtonTap();
                      await AnimalService.instance.toggleVisitado(marcador.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: marcador.visitado
                            ? const Color(0xFF2E7D32)
                            : Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 1.2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            marcador.visitado
                                ? Icons.check_rounded
                                : Icons.add_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            marcador.visitado ? 'Visto' : 'Marcar',
                            style: GoogleFonts.urbanist(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // SHIMMER DE BRILLO SUAVE
                IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _bottomBarPulseController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: const Alignment(-2.0, -1.0),
                            end: const Alignment(2.0, 1.0),
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.22),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: [
                              (_bottomBarPulseController.value - 0.2).clamp(
                                0.0,
                                1.0,
                              ),
                              _bottomBarPulseController.value.clamp(0.0, 1.0),
                              (_bottomBarPulseController.value + 0.2).clamp(
                                0.0,
                                1.0,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                              progress: _routeProgressController.value,
                            ),
                          );
                        },
                      ),
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
                    ],
                  ],
                ),
              ),
            ),
          ),

          // BOTONES SUPERIORES (Regresar y Guía)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                      ),
                      label: Text(
                        'Regresar',
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.verdePrincipal,
                        elevation: 4,
                        shadowColor: Colors.black26,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      key: _keyComoFunciona,
                      onPressed: () => setState(() => _tutorialStep = 1),
                      icon: const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 18,
                      ),
                      label: Text(
                        'Guía',
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        foregroundColor: AppColors.verdeAzulado,
                        side: const BorderSide(
                          color: AppColors.verdeAzulado,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // CHIP DE FILTRO (Baños)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 66, left: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _dirigirAlBanioMasCercano,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _mostrarBanios
                              ? Colors.blue.shade600
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: _mostrarBanios
                                ? Colors.blue.shade600
                                : Colors.grey.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wc_rounded,
                              size: 16,
                              color: _mostrarBanios
                                  ? Colors.white
                                  : Colors.blue.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Baños',
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _mostrarBanios
                                    ? Colors.white
                                    : Colors.blue.shade600,
                              ),
                            ),
                            if (_mostrarBanios) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // FABS: Soporte, Búsqueda y Mi Ubicación
          Positioned(
            right: 16,
            bottom: 140,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  key: _keyHelp,
                  heroTag: 'help_btn',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFD32F2F),
                  onPressed: () {
                    EmergencyService.instance.mostrarModalEmergencia(context);
                  },
                  child: const Icon(Icons.phone_in_talk_rounded),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.small(
                  key: _keySearch,
                  heroTag: 'search_btn',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.verdePrincipal,
                  onPressed: () {},
                  child: const Icon(Icons.search_rounded),
                ),
                const SizedBox(height: 24),
                FloatingActionButton(
                  key: _keyFab,
                  heroTag: 'location_btn',
                  backgroundColor: AppColors.verdeAzulado,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  onPressed: _onMyLocationPressed,
                  child: const Icon(Icons.my_location_rounded, size: 24),
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
