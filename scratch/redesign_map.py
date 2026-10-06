import re

# This script will rewrite pantalla_mapa.dart with the new UX/UI
dart_code = """
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

import '../utils/pathfinding.dart';
import '../utils/datos_rutas.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/marcador_animado.dart';
import '../widgets/ruta_painter.dart';

class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key});

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> with TickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late AnimationController _cameraAnimationController;
  late AnimationController _routeProgressController;
  late AnimationController _bottomBarPulseController;
  
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
  String _nodoActual = 'entrada';
  bool _isNavigating = false;
  bool _isBottomSheetOpen = false;

  final List<MarcadorMapa> marcadores = [
    MarcadorMapa(id: 'A01', nombre: 'Chimpancé', x: 346.0, y: 287.0, icono: Icons.pets, categoria: 'Favoritos', visitado: true),
    MarcadorMapa(id: 'A02', nombre: 'Mono', x: 438.0, y: 305.0, icono: Icons.pets, categoria: 'Cerca de ti'),
    MarcadorMapa(id: 'A03', nombre: 'Cebra', x: 570.0, y: 214.0, icono: Icons.pets, categoria: 'Todos'),
    MarcadorMapa(id: 'A04', nombre: 'Camello', x: 634.0, y: 273.0, icono: Icons.pets, categoria: 'Todos'),
    MarcadorMapa(id: 'A05', nombre: 'Jirafa', x: 709.0, y: 277.0, icono: Icons.pets, categoria: 'Favoritos'),
    MarcadorMapa(id: 'A06', nombre: 'Oso Pardo', x: 904.0, y: 308.0, icono: Icons.pets, categoria: 'Cerca de ti', visitado: true),
    MarcadorMapa(id: 'A07', nombre: 'Oso Frontino', x: 1026.0, y: 292.0, icono: Icons.pets, categoria: 'Todos'),
    MarcadorMapa(id: 'A08', nombre: 'Delfín', x: 1170.0, y: 233.0, icono: Icons.water_drop, categoria: 'Favoritos'),
    MarcadorMapa(id: 'A09', nombre: 'Foca', x: 1279.0, y: 277.0, icono: Icons.water_drop, categoria: 'Todos'),
    MarcadorMapa(id: 'A10', nombre: 'León', x: 1451.0, y: 414.0, icono: Icons.pets, categoria: 'Favoritos'),
    MarcadorMapa(id: 'A11', nombre: 'Tigre', x: 1378.0, y: 474.0, icono: Icons.pets, categoria: 'Todos', visitado: true),
    MarcadorMapa(id: 'A12', nombre: 'Leopardo', x: 1518.0, y: 494.0, icono: Icons.pets, categoria: 'Todos'),
    MarcadorMapa(id: 'A13', nombre: 'Elefante', x: 1123.0, y: 539.0, icono: Icons.pets, categoria: 'Favoritos'),
    MarcadorMapa(id: 'A14', nombre: 'Pingüino', x: 1270.0, y: 647.0, icono: Icons.ac_unit, categoria: 'Todos'),
    MarcadorMapa(id: 'A15', nombre: 'Nutria', x: 1369.0, y: 603.0, icono: Icons.water_drop, categoria: 'Cerca de ti'),
    MarcadorMapa(id: 'A16', nombre: 'Pelícano', x: 1466.0, y: 638.0, icono: Icons.flutter_dash, categoria: 'Todos'),
    MarcadorMapa(id: 'A17', nombre: 'Cocodrilo', x: 664.0, y: 554.0, icono: Icons.pets, categoria: 'Cerca de ti'),
    MarcadorMapa(id: 'A18', nombre: 'Vaca', x: 273.0, y: 638.0, icono: Icons.cruelty_free, categoria: 'Todos'),
    MarcadorMapa(id: 'A19', nombre: 'Oveja', x: 377.0, y: 650.0, icono: Icons.cruelty_free, categoria: 'Todos', visitado: true),
    MarcadorMapa(id: 'A20', nombre: 'Cerdo', x: 458.0, y: 635.0, icono: Icons.cruelty_free, categoria: 'Todos'),
  ];

  @override
  void initState() {
    super.initState();
    _cameraAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _routeProgressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _bottomBarPulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    
    _cameraAnimationController.addListener(() {
      if (_cameraAnimation != null) {
        _transformationController.value = _cameraAnimation!.value;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centrarEnUbicacionInicial(false);
      _checkTutorial();
    });
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
    _transformationController.dispose();
    _cameraAnimationController.dispose();
    _routeProgressController.dispose();
    _bottomBarPulseController.dispose();
    super.dispose();
  }

  void _centrarEnUbicacionInicial([bool animate = true]) {
    final size = MediaQuery.of(context).size;
    final scale = size.height / mapaAlto;
    final targetMatrix = Matrix4.identity()
      ..scale(scale)
      ..translate(-(mapaAncho * scale - size.width) / 2 / scale, 0.0);
    
    _limitarYCentrar(targetMatrix, animate);
  }

  void _centrarEnPunto(double x, double y) {
    final size = MediaQuery.of(context).size;
    final double currentScale = _transformationController.value.getMaxScaleOnAxis();
    final double zoomScale = currentScale < 1.5 ? 1.5 : currentScale;
    
    final targetMatrix = Matrix4.identity()
      ..translate(size.width / 2, size.height / 2)
      ..scale(zoomScale)
      ..translate(-x, -y);
      
    _limitarYCentrar(targetMatrix, true);
  }

  void _limitarYCentrar(Matrix4 target, bool animate) {
    if (animate) {
      _cameraAnimation = Matrix4Tween(
        begin: _transformationController.value,
        end: target,
      ).animate(CurvedAnimation(parent: _cameraAnimationController, curve: Curves.easeInOut));
      _cameraAnimationController.forward(from: 0);
    } else {
      _transformationController.value = target;
    }
  }

  void _mostrarInfoMarcador(MarcadorMapa marcador) {
    final nuevaRuta = grafoMapa.encontrarRutaMasCorta(_nodoActual, marcador.id);
    setState(() {
      _marcadorSeleccionado = marcador;
      _isNavigating = false;
      _rutaActual = nuevaRuta;
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
      case 1: return _getRect(_keyAnimales);
      case 2: return _getRect(_keySearch);
      case 3: return _getRect(_keyHelp);
      case 4: return _getRect(_keyComoFunciona);
      case 5: return _getRect(_keyFab);
      default: return Rect.zero;
    }
  }

  String _getTextForStep(int step) {
    switch (step) {
      case 1: return 'Toca aquí para ver tu progreso\ny los animales que te faltan.';
      case 2: return 'Busca un animal o\\nservicio en especifico';
      case 3: return 'Llama a\\nemergencia si lo necesitas';
      case 4: return 'Vuelve a mirar este\\ntutorial en cualquier momento';
      case 5: return 'Usa este botón para volver a tu\\nubicación actual rápidamente.';
      default: return '';
    }
  }

  void _mostrarAnimalesPorVisitar(BuildContext context) {
    setState(() => _isBottomSheetOpen = true);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFFFDF6EC), // Fondo crema cálido
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 50, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDF9F1D), Color(0xFFFDE1A9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: const Color(0xFFDF9F1D).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.explore, color: Color(0xFFDF9F1D), size: 36),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('¡Aventura en curso!', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                            Text('Has visitado ${marcadores.where((m) => m.visitado).length} de ${marcadores.length} animales', style: GoogleFonts.urbanist(fontSize: 14, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: AppColors.verdePrincipal,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppColors.amarilloMostaza,
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(text: 'Todos'),
                          Tab(text: 'Cerca de ti'),
                          Tab(text: 'Favoritos'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildGridCategorias('Todos'),
                            _buildGridCategorias('Cerca de ti'),
                            _buildGridCategorias('Favoritos'),
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
    ).whenComplete(() {
      setState(() => _isBottomSheetOpen = false);
    });
  }

  Widget _buildGridCategorias(String categoria) {
    final items = categoria == 'Todos' ? marcadores : marcadores.where((m) => m.categoria == categoria).toList();
    if (items.isEmpty) {
      return Center(child: Text('No hay animales aquí aún.', style: GoogleFonts.urbanist(color: Colors.grey)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final marcador = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
            _mostrarInfoMarcador(marcador);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: marcador.visitado ? AppColors.verdeClaro.withValues(alpha: 0.3) : Colors.transparent),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: marcador.visitado ? AppColors.fondoGrisClaro : AppColors.fondoApp,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(marcador.icono, color: marcador.visitado ? AppColors.verdeClaro : AppColors.amarilloMostaza, size: 40),
                    ),
                    if (marcador.visitado)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 12),
                      )
                  ],
                ),
                const SizedBox(height: 12),
                Text(marcador.nombre, style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
                Text(marcador.visitado ? 'Visitado' : 'Por visitar', style: GoogleFonts.urbanist(fontSize: 12, color: marcador.visitado ? Colors.green : Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarraInferior() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        key: _keyAnimales,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
        ),
        child: _marcadorSeleccionado == null 
            ? _buildBarraExploracion()
            : (!_isNavigating ? _buildBarraVistaPrevia() : _buildBarraNavegando()),
      ),
    );
  }

  Widget _buildBarraExploracion() {
    int visitados = marcadores.where((m) => m.visitado).length;
    return GestureDetector(
      onTap: () => _mostrarAnimalesPorVisitar(context),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _bottomBarPulseController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -2 * _bottomBarPulseController.value),
                child: Icon(Icons.keyboard_arrow_up_rounded, color: AppColors.amarilloMostaza, size: 28),
              );
            },
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tus Exploraciones', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.verdePrincipal)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.amarilloMostaza.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                        child: Text('$visitados/${marcadores.length} descubiertos', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.amarilloMostaza)),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: List.generate(
                  marcadores.length > 3 ? 3 : marcadores.length,
                  (index) {
                    final m = marcadores[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: m.visitado ? AppColors.verdeClaro : AppColors.fondoApp,
                          shape: BoxShape.circle,
                          border: Border.all(color: m.visitado ? Colors.transparent : Colors.grey.withValues(alpha: 0.3)),
                        ),
                        child: Icon(m.icono, color: m.visitado ? Colors.white : Colors.grey, size: 18),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBarraVistaPrevia() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: AppColors.amarilloMostaza.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
              child: Icon(_marcadorSeleccionado!.icono, color: AppColors.amarilloMostaza, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_marcadorSeleccionado!.nombre, style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.verdePrincipal)),
                  Text(_marcadorSeleccionado!.categoria, style: GoogleFonts.urbanist(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.black54, size: 20),
              ),
              onPressed: () => setState(() { _marcadorSeleccionado = null; _rutaActual = []; }),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.verdePrincipal,
                  side: const BorderSide(color: AppColors.verdePrincipal, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Ver Info', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () { setState(() => _isNavigating = true); _routeProgressController.forward(from: 0); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amarilloMostaza,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.directions_walk, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Explorar', style: GoogleFonts.urbanist(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarraNavegando() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.verdePrincipal.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.navigation, color: AppColors.verdePrincipal, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('En camino a ${_marcadorSeleccionado!.nombre}', style: GoogleFonts.urbanist(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('150 metros • 2 min', style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.verdePrincipal)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () { setState(() { _isNavigating = false; _marcadorSeleccionado = null; _rutaActual = []; }); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE6E6),
                  foregroundColor: const Color(0xFFD93B3B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: Text('Detener Navegación', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoApp,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.1,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(1000),
              constrained: false,
              child: SizedBox(
                width: mapaAncho,
                height: mapaAlto,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTapUp: (details) {
                          // Solo para debug:
                          // final x = details.localPosition.dx.round();
                          // final y = details.localPosition.dy.round();
                          // print('x: $x, y: $y');
                        },
                        child: Image.asset('assets/images/mapa_zoologico.png', fit: BoxFit.fill),
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _routeProgressController,
                        builder: (context, child) {
                          return CustomPaint(painter: RutaPainter(_rutaActual, _isNavigating, progress: _routeProgressController.value));
                        },
                      ),
                    ),
                    ...marcadores.map((marcador) {
                      return Positioned(
                        left: marcador.x - 40,
                        top: marcador.y - 40,
                        child: MarcadorAnimado(
                          marcador: marcador,
                          isSelected: _marcadorSeleccionado?.id == marcador.id,
                          onTap: () => _mostrarInfoMarcador(marcador),
                        ),
                      );
                    }),
                    if (grafoMapa.nodos.containsKey(_nodoActual))
                      Positioned(
                        left: grafoMapa.nodos[_nodoActual]!.posicion.dx - 12,
                        top: grafoMapa.nodos[_nodoActual]!.posicion.dy - 12,
                        child: Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // TOP BUTTONS
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Navigation Button (Regresar)
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                      label: Text('Regresar', style: GoogleFonts.urbanist(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.verdePrincipal,
                        elevation: 4,
                        shadowColor: Colors.black26,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    // Help Button (Como funciona)
                    OutlinedButton.icon(
                      key: _keyComoFunciona,
                      onPressed: () => setState(() => _tutorialStep = 1),
                      icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
                      label: Text('Guía', style: GoogleFonts.urbanist(fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.8),
                        foregroundColor: AppColors.amarilloMostaza,
                        side: const BorderSide(color: AppColors.amarilloMostaza, width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // FAB Mi Ubicacion & Help tools
          Positioned(
            right: 16,
            bottom: 140, // Above bottom bar
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  key: _keyHelp,
                  heroTag: 'help_btn',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.verdePrincipal,
                  onPressed: () {},
                  child: const Icon(Icons.support_agent_rounded),
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
                  backgroundColor: AppColors.verdePrincipal,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    final nodo = grafoMapa.nodos[_nodoActual];
                    if (nodo != null) _centrarEnPunto(nodo.posicion.dx, nodo.posicion.dy);
                  },
                  child: const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
          ),
          
          // BOTTOM BAR
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBarraInferior(),
          ),
          
          // TUTORIAL
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
"""

with open(r'c:\Users\USUARIO\Desktop\Universidad\flutter\zoologico_front\zoologico_front\lib\features\mapa\screens\pantalla_mapa.dart', 'w', encoding='utf-8') as f:
    f.write(dart_code)

print("Rediseño completado.")
