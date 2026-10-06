import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _PantallaMapaState extends State<PantallaMapa> {
  final TransformationController _transformationController =
      TransformationController();

  final GlobalKey _keyAnimales = GlobalKey();
  final GlobalKey _keySearch = GlobalKey();
  final GlobalKey _keyHelp = GlobalKey();
  final GlobalKey _keyComoFunciona = GlobalKey();

  int _tutorialStep = 0;

  final double mapaAncho = 1920;
  final double mapaAlto = 1080;

  List<Offset> _rutaActual = [];
  MarcadorMapa? _marcadorSeleccionado;
  String _nodoActual = 'entrada';
  bool _isNavigating = false;

  final List<MarcadorMapa> marcadores = [
    MarcadorMapa(
      id: 'A01',
      nombre: 'Chimpancé',
      x: 346.0,
      y: 287.0,
      icono: Icons.pets,
    ),
    MarcadorMapa(
      id: 'A02',
      nombre: 'Mono',
      x: 438.0,
      y: 305.0,
      icono: Icons.pets,
    ),
    MarcadorMapa(
      id: 'A03',
      nombre: 'Cebra',
      x: 570.0,
      y: 214.0,
      icono: Icons.pets,
    ),
    MarcadorMapa(
      id: 'A04',
      nombre: 'Camello',
      x: 634.0,
      y: 273.0,
      icono: Icons.pets,
    ),
    MarcadorMapa(
      id: 'A05',
      nombre: 'Jirafa',
      x: 709.0,
      y: 277.0,
      icono: Icons.pets,
    ),
    MarcadorMapa(
      id: 'A06',
      nombre: 'Oso 1',
      x: 904.0,
      y: 308.0,
      icono: Icons.pets,
    ),
    MarcadorMapa(
      id: 'A07',
      nombre: 'Oso 2',
      x: 1026.0,
      y: 292.0,
      icono: Icons.pets,
    ),
    MarcadorMapa(
      id: 'A08',
      nombre: 'Delfín',
      x: 1170.0,
      y: 233.0,
      icono: Icons.water_drop,
    ),
    MarcadorMapa(
      id: 'A09',
      nombre: 'Foca',
      x: 1279.0,
      y: 277.0,
      icono: Icons.water_drop,
    ),
    MarcadorMapa(
      id: 'A10',
      nombre: 'León',
      x: 1451.0,
      y: 414.0,
      icono: Icons.pets,
    ),
    MarcadorMapa(
      id: 'A11',
      nombre: 'Tigre',
      x: 1378.0,
      y: 474.0,
      icono: Icons.pets,
    ),
    MarcadorMapa(
      id: 'A12',
      nombre: 'Leopardo',
      x: 1518.0,
      y: 494.0,
      icono: Icons.pets,
    ),
    MarcadorMapa(
      id: 'A13',
      nombre: 'Elefante',
      x: 1123.0,
      y: 539.0,
      icono: Icons.pets,
    ),
    MarcadorMapa(
      id: 'A14',
      nombre: 'Pingüino',
      x: 1270.0,
      y: 647.0,
      icono: Icons.ac_unit,
    ),
    MarcadorMapa(
      id: 'A15',
      nombre: 'Nutria',
      x: 1369.0,
      y: 603.0,
      icono: Icons.water_drop,
    ),
    MarcadorMapa(
      id: 'A16',
      nombre: 'Pelícano',
      x: 1466.0,
      y: 638.0,
      icono: Icons.flutter_dash,
    ),
    MarcadorMapa(
      id: 'A17',
      nombre: 'Cocodrilo',
      x: 664.0,
      y: 554.0,
      icono: Icons.pets,
    ),
    MarcadorMapa(
      id: 'A18',
      nombre: 'Vaca',
      x: 273.0,
      y: 638.0,
      icono: Icons.cruelty_free,
    ),
    MarcadorMapa(
      id: 'A19',
      nombre: 'Oveja',
      x: 377.0,
      y: 650.0,
      icono: Icons.cruelty_free,
    ),
    MarcadorMapa(
      id: 'A20',
      nombre: 'Cerdo',
      x: 458.0,
      y: 635.0,
      icono: Icons.cruelty_free,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final scale = size.height / mapaAlto;
      final matrix = Matrix4.identity()
        ..scale(scale)
        ..translate(-(mapaAncho * scale - size.width) / 2 / scale, 0.0);
      _transformationController.value = matrix;
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _mostrarInfoMarcador(MarcadorMapa marcador) {
    final nuevaRuta = grafoMapa.encontrarRutaMasCorta(_nodoActual, marcador.id);
    setState(() {
      _marcadorSeleccionado = marcador;
      _isNavigating = false;
      _rutaActual = nuevaRuta;
    });
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
      default:
        return Rect.zero;
    }
  }

  String _getTextForStep(int step) {
    switch (step) {
      case 1:
        return 'Observa los animales que\nya visitaste o te faltan\nvisitar';
      case 2:
        return 'Busca un animal o\nservicio en especifico';
      case 3:
        return 'Llama a\nemergencia';
      case 4:
        return 'Vuelve a mirar este\ntutorial';
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7F4),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/pantalla_principal/investigador.png',
                        height: 60,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.pets, size: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '¿Qué animal te falta visitar?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.verdeAzulado,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: marcadores.length,
                  itemBuilder: (context, index) {
                    final marcador = marcadores[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _mostrarInfoMarcador(marcador);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.verdeAzulado,
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                marcador.icono,
                                color: AppColors.verdeAzulado,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            marcador.nombre,
                            style: GoogleFonts.urbanist(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textoOscuro,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarraInferior() {
    if (_marcadorSeleccionado == null) {
      return GestureDetector(
        onTap: () => _mostrarAnimalesPorVisitar(context),
        child: Container(
          height: 100,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
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
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      key: _keyAnimales,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Animales por visitar',
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.verdeAzulado,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 2,
                          width: 80,
                          color: AppColors.verdeAzulado.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(
                        marcadores.length > 4 ? 4 : marcadores.length,
                        (index) {
                          final marcador = marcadores[index];
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.verdeAzulado,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                marcador.icono,
                                color: AppColors.verdeAzulado,
                                size: 18,
                              ),
                            ),
                          );
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
    } else if (!_isNavigating) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.verdeAzulado.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _marcadorSeleccionado!.icono,
                    color: AppColors.verdeAzulado,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _marcadorSeleccionado!.nombre,
                        style: GoogleFonts.urbanist(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Vista previa de ruta',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _marcadorSeleccionado = null;
                      _rutaActual = [];
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Navegar a la pantalla de información del animal
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.verdeAzulado,
                      side: const BorderSide(color: AppColors.verdeAzulado),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Ver información',
                      style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isNavigating = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdeAzulado,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions_walk,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ir allí',
                          style: GoogleFonts.urbanist(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.navigation,
                        color: Colors.blueAccent,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '150 m',
                        style: GoogleFonts.urbanist(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Llegarás en 2 min a ${_marcadorSeleccionado!.nombre}',
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isNavigating = false;
                  _marcadorSeleccionado = null;
                  _rutaActual = [];
                });
              },
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: Text(
                'Cancelar',
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.1,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(500),
              constrained: false,
              child: SizedBox(
                width: mapaAncho,
                height: mapaAlto,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTapUp: (details) {
                          final x = details.localPosition.dx.round();
                          final y = details.localPosition.dy.round();
                          print('📍 COORDENADA MAPA: x: $x, y: $y');
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Copiado: x: $x, y: $y'),
                              backgroundColor: Colors.black87,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/mapa_zoologico.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: RutaPainter(_rutaActual, _isNavigating),
                      ),
                    ),
                    ...marcadores.map((marcador) {
                      return Positioned(
                        left: marcador.x - 40,
                        top: marcador.y - 40,
                        child: MarcadorAnimado(
                          marcador: marcador,
                          onTap: () => _mostrarInfoMarcador(marcador),
                        ),
                      );
                    }).toList(),
                    if (grafoMapa.nodos.containsKey(_nodoActual))
                      Positioned(
                        left: grafoMapa.nodos[_nodoActual]!.posicion.dx - 12,
                        top: grafoMapa.nodos[_nodoActual]!.posicion.dy - 12,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
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
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Regresar',
                              style: GoogleFonts.urbanist(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _tutorialStep = 1;
                          });
                        },
                        child: Container(
                          key: _keyComoFunciona,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '¿Como funciona el mapa?',
                            style: GoogleFonts.urbanist(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  key: _keyHelp,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.help_outline, color: Colors.black87),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  key: _keySearch,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.black87),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBarraInferior(),
          ),
          if (_tutorialStep > 0)
            TutorialOverlay(
              step: _tutorialStep,
              targetRect: _getRectForStep(_tutorialStep),
              text: _getTextForStep(_tutorialStep),
              onNext: () {
                setState(() {
                  if (_tutorialStep < 4) {
                    _tutorialStep++;
                  } else {
                    _tutorialStep = 0;
                  }
                });
              },
            ),
        ],
      ),
    );
  }
}
