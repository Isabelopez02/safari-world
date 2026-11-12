import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

import '../utils/datos_rutas.dart';
import '../utils/servicio_rutas_svg.dart';
import '../widgets/barra_busqueda_hibrida_mapa.dart';
import '../widgets/barra_filtros_mapa.dart';
import '../widgets/barra_inferior_mapa.dart';
import '../widgets/capa_trazos_mapa.dart';
import '../widgets/marcador_animado.dart';
import '../widgets/modal_animales_por_visitar.dart';
import '../widgets/modal_capas_mapa.dart';
import '../widgets/tutorial_overlay.dart';
import '../../pantalla_principal/widgets/modal_tiendas_cercanas.dart';

class PantallaMapa extends StatefulWidget {
  final bool abrirExploracionesAlCargar;
  final String? animalIdInicial;
  final bool esTabEmbedido;
  final String? habitatInicial;
  final int? claveNavegacion;
  final bool modoFacil;
  final VoidCallback? onVolverMenuFacil;

  const PantallaMapa({
    super.key,
    this.abrirExploracionesAlCargar = false,
    this.animalIdInicial,
    this.esTabEmbedido = false,
    this.habitatInicial,
    this.claveNavegacion,
    this.modoFacil = false,
    this.onVolverMenuFacil,
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
  ChipUrgenciaMapa _chipUrgencia = ChipUrgenciaMapa.ninguno;
  String? _habitatFiltro;
  bool _mostrarZonasCalma = true;

  // Navegación secuencial de servicios (ej. Baños 1 de 4 con flechas)
  int _indiceServicioActual = 0;
  List<MarcadorMapa> _serviciosFiltrados = [];

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
      if (widget.habitatInicial != null) {
        _enfocarYTrazarDestino(widget.habitatInicial!);
      } else if (widget.animalIdInicial != null) {
        final matches = marcadores.where((m) => m.id == widget.animalIdInicial);
        if (matches.isNotEmpty) {
          _mostrarInfoMarcador(matches.first);
        }
      } else if (widget.abrirExploracionesAlCargar) {
        _mostrarAnimalesPorVisitar(context);
      } else if (!widget.modoFacil) {
        _checkTutorial();
      }
    });
  }

  @override
  void didUpdateWidget(PantallaMapa oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.claveNavegacion != oldWidget.claveNavegacion ||
            widget.habitatInicial != oldWidget.habitatInicial) &&
        widget.habitatInicial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _enfocarYTrazarDestino(widget.habitatInicial!);
        }
      });
    }
  }

  /// Traza y enfoca automáticamente un destino (escenario, animal o hábitat)
  void _enfocarYTrazarDestino(String destino) {
    final destLower = destino.toLowerCase();

    // 0. Puntos de encuentro y auxilio (desde ¿Te perdiste?)
    if (destLower.contains('encuentro') ||
        destLower.contains('ayuda') ||
        destLower.contains('perdiste') ||
        destLower.contains('auxilio')) {
      final puntosAyuda = accesos.where((a) => a.tipoServicio == 'ayuda').toList();
      if (puntosAyuda.isNotEmpty) {
        setState(() {
          _serviciosFiltrados = List.from(puntosAyuda);
          _indiceServicioActual = 0;
          _habitatFiltro = null;
          _chipUrgencia = ChipUrgenciaMapa.ninguno;
          _filtroServicio = FiltroServicioMapa.todos;
        });
        _mostrarInfoMarcador(puntosAyuda.first, sincronizarCarrusel: false);
        setState(() {
          _isNavigating = true;
        });
        _routeProgressController.forward(from: 0);
        return;
      }
    }

    // 1. Buscar si coincide directamente con el ID de un animal / marcador (ej. 'C05', 'S03', 'I02', 'C08')
    final porId = marcadores.where(
      (m) => m.id.toLowerCase() == destino.trim().toLowerCase(),
    );
    if (porId.isNotEmpty) {
      final marcador = porId.first;
      setState(() {
        _habitatFiltro = marcador.habitat;
      });
      _mostrarInfoMarcador(marcador);
      setState(() {
        _isNavigating = true;
      });
      _routeProgressController.forward(from: 0);
      return;
    }

    // 1.1 Buscar en accesos y paradas clave
    final porAcceso = accesos.where(
      (a) => a.id.toLowerCase() == destino.trim().toLowerCase(),
    );
    if (porAcceso.isNotEmpty) {
      final marcador = porAcceso.first;
      _mostrarInfoMarcador(marcador);
      setState(() {
        _isNavigating = true;
      });
      _routeProgressController.forward(from: 0);
      return;
    }

    // 2. Buscar si coincide con escenarios de shows
    String? markerIdEscenario;
    if (destLower.contains('acuatico') ||
        destLower.contains('acuático') ||
        destLower.contains('lobo') ||
        destLower.contains('foca') ||
        destLower == 'show_marino') {
      markerIdEscenario = 'C05';
    } else if (destLower.contains('rapaces') ||
        destLower.contains('condor') ||
        destLower.contains('cóndor') ||
        destLower.contains('aguila') ||
        destLower == 'show_aves') {
      markerIdEscenario = 'S03';
    } else if (destLower.contains('pinguin') ||
        destLower.contains('pingüin') ||
        destLower.contains('humboldt') ||
        destLower == 'show_pinguinos') {
      markerIdEscenario = 'C08';
    } else if (destLower.contains('leon') ||
        destLower.contains('león') ||
        destLower.contains('sabana') ||
        destLower == 'show_felinos') {
      markerIdEscenario = 'I02';
    }

    if (markerIdEscenario != null) {
      final porEscenario = marcadores.where((m) => m.id == markerIdEscenario);
      if (porEscenario.isNotEmpty) {
        final marcador = porEscenario.first;
        setState(() {
          _habitatFiltro = marcador.habitat;
        });
        _mostrarInfoMarcador(marcador);
        setState(() {
          _isNavigating = true;
        });
        _routeProgressController.forward(from: 0);
        return;
      }
    }

    // 3. Normalizar hábitats (soporta nombres cortos y nombres oficiales)
    String habitatNormalizado = destino;
    if (destLower.contains('costa')) {
      habitatNormalizado = 'Zona Costa';
    } else if (destLower.contains('sierra') || destLower.contains('ande')) {
      habitatNormalizado = 'Zona Sierra';
    } else if (destLower.contains('internacional') ||
        destLower.contains('sabana') ||
        destLower.contains('africa')) {
      habitatNormalizado = 'Zona Internacional';
    } else if (destLower.contains('selva') || destLower.contains('amaz')) {
      habitatNormalizado = 'Zona Selva';
    } else if (destLower.contains('granja')) {
      habitatNormalizado = 'Granja Interactiva';
    }

    setState(() {
      _habitatFiltro = habitatNormalizado;
    });

    final enHabitat = marcadores.where((m) => m.habitat == habitatNormalizado).toList();
    if (enHabitat.isNotEmpty) {
      final favoritos = enHabitat.where((m) => m.categoria == 'Favoritos').toList();
      final destinoMarcador = favoritos.isNotEmpty ? favoritos.first : enHabitat.first;
      _mostrarInfoMarcador(destinoMarcador);
      setState(() {
        _isNavigating = true;
      });
      _routeProgressController.forward(from: 0);
    }
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
    if (_habitatFiltro != null &&
        marcador.tipoServicio == null &&
        !marcador.esBanio &&
        !marcador.esZonaCalma) {
      if (marcador.habitat != _habitatFiltro) return false;
    }

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
        objetivo = _encontrarBanioMasCercano() ?? (banios.isNotEmpty ? banios.first : null);
        _serviciosFiltrados = List.from(banios);
        final idx = _serviciosFiltrados.indexWhere((b) => b.id == objetivo?.id);
        _indiceServicioActual = idx >= 0 ? idx : 0;
      } else if (nuevoFiltro == FiltroServicioMapa.calma) {
        _serviciosFiltrados = List.from(zonasCalma);
        _indiceServicioActual = 0;
        if (zonasCalma.isNotEmpty) {
          objetivo = zonasCalma.first;
        }
      } else {
        _serviciosFiltrados = [];
        final matches =
            accesos.where((a) => _isMarkerMatchingFilter(a)).toList();
        if (matches.isNotEmpty) {
          objetivo = matches.first;
        }
      }

      if (objetivo != null) {
        _mostrarInfoMarcador(objetivo, sincronizarCarrusel: false);
      }
    } else {
      setState(() {
        _serviciosFiltrados = [];
        _marcadorSeleccionado = null;
        _isNavigating = false;
        _rutaActual = [];
        _rutaSvgActual = null;
      });
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

  void _mostrarInfoMarcador(MarcadorMapa marcador, {bool sincronizarCarrusel = true}) {
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
      // Previsualizar marcador sin bloquearlo de inmediato en navegación
      _isNavigating = false;
      _rutaActual = nuevaRuta;
      _rutaSvgActual = rutaSvg;

      if (sincronizarCarrusel) {
        if (marcador.esBanio) {
          _serviciosFiltrados = List.from(banios);
          final idx = _serviciosFiltrados.indexWhere((b) => b.id == marcador.id);
          _indiceServicioActual = idx >= 0 ? idx : 0;
          _chipUrgencia = ChipUrgenciaMapa.banios;
          _filtroServicio = FiltroServicioMapa.banio;
        } else if (marcador.esZonaCalma) {
          _serviciosFiltrados = List.from(zonasCalma);
          final idx = _serviciosFiltrados.indexWhere((z) => z.id == marcador.id);
          _indiceServicioActual = idx >= 0 ? idx : 0;
          _filtroServicio = FiltroServicioMapa.calma;
        } else {
          _serviciosFiltrados = [];
        }
      }
    });
    _centrarEnPunto(marcador.x, marcador.y);
    _routeProgressController.forward(from: 0);
  }

  void _anteriorServicio() {
    if (_serviciosFiltrados.isEmpty) return;
    SoundService.instance.playButtonTap();
    HapticFeedback.selectionClick();
    final nuevoIndice =
        (_indiceServicioActual - 1 + _serviciosFiltrados.length) %
            _serviciosFiltrados.length;
    setState(() {
      _indiceServicioActual = nuevoIndice;
    });
    _mostrarInfoMarcador(_serviciosFiltrados[nuevoIndice],
        sincronizarCarrusel: false);
  }

  void _siguienteServicio() {
    if (_serviciosFiltrados.isEmpty) return;
    SoundService.instance.playButtonTap();
    HapticFeedback.selectionClick();
    final nuevoIndice =
        (_indiceServicioActual + 1) % _serviciosFiltrados.length;
    setState(() {
      _indiceServicioActual = nuevoIndice;
    });
    _mostrarInfoMarcador(_serviciosFiltrados[nuevoIndice],
        sincronizarCarrusel: false);
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
        return _getRect(_keyFab);
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

  void _abrirModalCapas() {
    ModalCapasMapa.mostrar(
      context,
      habitatSeleccionado: _habitatFiltro,
      mostrarZonasCalma: _mostrarZonasCalma,
      onToggleZonasCalma: (val) {
        setState(() {
          _mostrarZonasCalma = val;
          if (!val && _marcadorSeleccionado?.esZonaCalma == true) {
            _marcadorSeleccionado = null;
            _rutaActual = [];
            _rutaSvgActual = null;
            _isNavigating = false;
          }
        });
        AccesibilidadService.instance.setMostrarZonasCalma(val);
      },
      onHabitatCambiado: (nuevoHabitat) {
        setState(() {
          _habitatFiltro = nuevoHabitat;
          _marcadorSeleccionado = null;
          if (nuevoHabitat != null) {
            final enZona = marcadores.where((m) => m.habitat == nuevoHabitat).toList();
            if (enZona.isNotEmpty) {
              _centrarEnPunto(enZona.first.x, enZona.first.y);
            }
          }
        });
      },
      onServicioSeleccionado: (servicio) {
        setState(() {
          if (servicio == 'banio') {
            _chipUrgencia = ChipUrgenciaMapa.banios;
            _filtroServicio = FiltroServicioMapa.banio;
            _serviciosFiltrados = List.from(banios);
            _indiceServicioActual = 0;
            if (banios.isNotEmpty) {
              _mostrarInfoMarcador(banios.first, sincronizarCarrusel: false);
            }
          } else if (servicio == 'estacionamiento') {
            _chipUrgencia = ChipUrgenciaMapa.salidaParking;
            _filtroServicio = FiltroServicioMapa.estacionamiento;
            _serviciosFiltrados = [];
            if (accesos.isNotEmpty) {
              _mostrarInfoMarcador(accesos.first, sincronizarCarrusel: false);
            }
          } else if (servicio == 'calma') {
            _filtroServicio = FiltroServicioMapa.calma;
            _serviciosFiltrados = List.from(zonasCalma);
            _indiceServicioActual = 0;
            if (zonasCalma.isNotEmpty) {
              _mostrarInfoMarcador(zonasCalma.first, sincronizarCarrusel: false);
            }
          } else if (servicio == 'snacks' || servicio == 'tiendas') {
            ModalTiendasCercanas.mostrar(context, onAbrirEnMapa: () {});
          }
        });
      },
    );
  }

  Widget _buildBotonFlotanteCircular({
    Key? key,
    required IconData icono,
    required String tooltip,
    required Color colorIcono,
    required VoidCallback onPressed,
  }) {
    final a11y = AccesibilidadService.instance;
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: a11y.modoAltoContraste
                ? const Color(0xFF0F172A)
                : Colors.white.withValues(alpha: 0.94),
            shape: BoxShape.circle,
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
          child: IconButton(
            key: key,
            icon: Icon(icono),
            color: colorIcono,
            iconSize: 24,
            tooltip: tooltip,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  Widget _buildBarraFiltrosModoFacil() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onVolverMenuFacil != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    SoundService.instance.playButtonTap();
                    widget.onVolverMenuFacil!();
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
                      activo: _chipUrgencia == ChipUrgenciaMapa.banios,
                      onTap: () {
                        SoundService.instance.playButtonTap();
                        HapticFeedback.selectionClick();
                        setState(() => _chipUrgencia = ChipUrgenciaMapa.banios);
                        _onFiltroCambiado(FiltroServicioMapa.banio);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildBotonFiltroFacilItem(
                      titulo: 'filtro_salida'.tr,
                      icono: Icons.exit_to_app_rounded,
                      color: const Color(0xFF2E7D32),
                      activo: _chipUrgencia == ChipUrgenciaMapa.salidaParking,
                      onTap: () {
                        SoundService.instance.playButtonTap();
                        HapticFeedback.selectionClick();
                        setState(() => _chipUrgencia = ChipUrgenciaMapa.salidaParking);
                        _onFiltroCambiado(FiltroServicioMapa.estacionamiento);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildBotonFiltroFacilItem(
                      titulo: 'filtro_calma'.tr,
                      icono: Icons.park_rounded,
                      color: const Color(0xFF6D4C41),
                      activo: _filtroServicio == FiltroServicioMapa.calma,
                      onTap: () {
                        SoundService.instance.playButtonTap();
                        HapticFeedback.selectionClick();
                        setState(() => _chipUrgencia = ChipUrgenciaMapa.ninguno);
                        _onFiltroCambiado(FiltroServicioMapa.calma);
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

                    if (_mostrarZonasCalma)
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
                    if (_marcadorSeleccionado != null &&
                        (!_marcadorSeleccionado!.esZonaCalma || _mostrarZonasCalma))
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

          // BARRA SUPERIOR HÍBRIDA O MODO FÁCIL
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: widget.modoFacil
                ? _buildBarraFiltrosModoFacil()
                : Center(
                    heightFactor: 1.0,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: BarraBusquedaHibridaMapa(
                        chipActivo: _chipUrgencia,
                        onChipSeleccionado: (chip) {
                          setState(() => _chipUrgencia = chip);
                          switch (chip) {
                            case ChipUrgenciaMapa.banios:
                              _onFiltroCambiado(FiltroServicioMapa.banio);
                              break;
                            case ChipUrgenciaMapa.salidaParking:
                              _onFiltroCambiado(FiltroServicioMapa.estacionamiento);
                              break;
                            case ChipUrgenciaMapa.animales:
                              setState(() => _habitatFiltro = null);
                              _onFiltroCambiado(FiltroServicioMapa.todos);
                              break;
                            case ChipUrgenciaMapa.snacks:
                              ModalTiendasCercanas.mostrar(
                                context,
                                onAbrirEnMapa: () {},
                              );
                              break;
                            case ChipUrgenciaMapa.ninguno:
                              _onFiltroCambiado(FiltroServicioMapa.todos);
                              break;
                          }
                        },
                        onAbrirCapas: _abrirModalCapas,
                      ),
                    ),
                  ),
          ),

          // BOTONES FLOTANTES AL LADO INFERIOR DERECHO (UBICACIÓN ARRIBA Y CAPAS DEBAJO)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            right: 16,
            bottom: (_marcadorSeleccionado != null ? 190.0 : 105.0) +
                MediaQuery.of(context).padding.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. BOTÓN MI UBICACIÓN
                _buildBotonFlotanteCircular(
                  key: _keyFab,
                  icono: Icons.my_location_rounded,
                  tooltip: 'Mi ubicación',
                  colorIcono: a11y.modoAltoContraste
                      ? const Color(0xFFFDE047)
                      : AppColors.verdeAzulado,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _onMyLocationPressed();
                  },
                ),
                if (!widget.modoFacil) ...[
                  const SizedBox(height: 10),
                  // 2. BOTÓN CAPAS DEL MAPA (DEBAJO DE LA UBICACIÓN)
                  _buildBotonFlotanteCircular(
                    icono: Icons.layers_rounded,
                    tooltip: 'Capas y Filtros',
                    colorIcono: AppColors.verdePrincipal,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      SoundService.instance.playButtonTap();
                      _abrirModalCapas();
                    },
                  ),
                ],
              ],
            ),
          ),

          // COMPONENTE BARRA INFERIOR REUTILIZABLE (Cápsula Flotante)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              heightFactor: 1.0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: BarraInferiorMapa(
                  keyAnimales: _keyAnimales,
                  marcadorSeleccionado: _marcadorSeleccionado,
                  isNavigating: _isNavigating,
                  marcadores: marcadores,
                  bottomBarPulseController: _bottomBarPulseController,
                  onTapExploraciones: () => _mostrarAnimalesPorVisitar(context),
                  onCerrarSeleccion: () => setState(() {
                    _marcadorSeleccionado = null;
                    _serviciosFiltrados = [];
                    _chipUrgencia = ChipUrgenciaMapa.ninguno;
                    _filtroServicio = FiltroServicioMapa.todos;
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
                      _serviciosFiltrados = [];
                      _chipUrgencia = ChipUrgenciaMapa.ninguno;
                      _filtroServicio = FiltroServicioMapa.todos;
                      _rutaActual = [];
                      _rutaSvgActual = null;
                    });
                  },
                  indiceServicio: _serviciosFiltrados.isNotEmpty ? _indiceServicioActual : null,
                  totalServicios: _serviciosFiltrados.isNotEmpty ? _serviciosFiltrados.length : null,
                  onServicioAnterior: _anteriorServicio,
                  onServicioSiguiente: _siguienteServicio,
                ),
              ),
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
