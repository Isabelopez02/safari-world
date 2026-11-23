import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';

import '../data/filtro_servicio_mapa.dart';
import '../utils/datos_rutas.dart';
import '../utils/servicio_rutas_svg.dart';
import '../widgets/barra_busqueda_hibrida_mapa.dart';
import '../widgets/barra_inferior_mapa.dart';
import '../widgets/barra_superior_mapa.dart';
import '../widgets/canvas_mapa_interactivo.dart';
import '../widgets/controles_flotantes_mapa.dart';

import 'package:zoologico_front/core/widgets/modal_animales_por_visitar.dart';

import '../widgets/modal_capas_mapa.dart';
import '../widgets/tutorial_overlay.dart';

import 'package:zoologico_front/core/widgets/modal_tiendas_cercanas.dart';

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
  final List<MarcadorMapa> zonasCalma = AnimalService.instance
      .obtenerZonasCalma();

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
      if (widget.habitatInicial != null) {
        _enfocarYTrazarDestino(widget.habitatInicial!);
      } else if (widget.animalIdInicial != null) {
        _enfocarYTrazarDestino(widget.animalIdInicial!);
      } else {
        _centrarEnUbicacionInicial(false);
      }
      if (widget.abrirExploracionesAlCargar) {
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
        widget.habitatInicial != oldWidget.habitatInicial ||
        widget.animalIdInicial != oldWidget.animalIdInicial)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.habitatInicial != null) {
          _enfocarYTrazarDestino(widget.habitatInicial!);
        } else if (widget.animalIdInicial != null) {
          _enfocarYTrazarDestino(widget.animalIdInicial!);
        }
      });
    }
  }

  /// Traza y enfoca automáticamente un destino (escenario, animal, baño o hábitat)
  void _enfocarYTrazarDestino(String destino) {
    final destLower = destino.toLowerCase().trim();

    // 0. Búsqueda inteligente universal sobre los 76 pines del parque (animales, baños, accesos, calma)
    final pinInteligente = AnimalService.instance.buscarPinInteligente(destino);
    if (pinInteligente != null) {
      setState(() {
        if (pinInteligente.esBanio) {
          _mostrarBanios = true;
          _chipUrgencia = ChipUrgenciaMapa.banios;
          _filtroServicio = FiltroServicioMapa.banio;
          _habitatFiltro = null;
        } else if (pinInteligente.esZonaCalma) {
          _mostrarZonasCalma = true;
          _chipUrgencia = ChipUrgenciaMapa.ninguno;
          _filtroServicio = FiltroServicioMapa.calma;
          _habitatFiltro = null;
        } else if (pinInteligente.tipoServicio == 'ayuda' ||
            pinInteligente.id.startsWith('AYUDA')) {
          _habitatFiltro = null;
          _chipUrgencia = ChipUrgenciaMapa.ninguno;
          _filtroServicio = FiltroServicioMapa.todos;
        } else if (pinInteligente.tipoServicio == 'salida' ||
            pinInteligente.tipoServicio == 'boleteria' ||
            pinInteligente.tipoServicio == 'estacionamiento' ||
            pinInteligente.tipoServicio == 'juegos') {
          _habitatFiltro = null;
          _chipUrgencia = ChipUrgenciaMapa.ninguno;
          _filtroServicio = FiltroServicioMapa.todos;
        } else {
          _habitatFiltro = pinInteligente.habitat;
          _chipUrgencia = ChipUrgenciaMapa.ninguno;
          _filtroServicio = FiltroServicioMapa.todos;
        }
      });
      _mostrarInfoMarcador(pinInteligente);
      setState(() {
        _isNavigating = true;
      });
      _routeProgressController.forward(from: 0);
      return;
    }

    // 0.1 Puntos de encuentro y auxilio (desde ¿Te perdiste?, Tópico Médico o SOS)
    if (destLower.contains('encuentro') ||
        destLower.contains('ayuda') ||
        destLower.contains('perdiste') ||
        destLower.contains('auxilio') ||
        destLower.contains('topico') ||
        destLower.contains('tópico') ||
        destLower == 'ayuda_02' ||
        destLower == 'ayuda_01') {
      final puntosAyuda = accesos.where((a) {
        if (destLower == 'ayuda_02' || destLower == 'ayuda_01') {
          return a.id.toLowerCase() == destLower;
        }
        return a.tipoServicio == 'ayuda' ||
            a.id.toUpperCase().startsWith('AYUDA');
      }).toList();
      if (puntosAyuda.isNotEmpty) {
        final target = puntosAyuda.first;
        setState(() {
          _serviciosFiltrados = List.from(puntosAyuda);
          _indiceServicioActual = 0;
          _habitatFiltro = null;
          _chipUrgencia = ChipUrgenciaMapa.ninguno;
          _filtroServicio = FiltroServicioMapa.todos;
        });
        _mostrarInfoMarcador(target, sincronizarCarrusel: false);
        setState(() {
          _isNavigating = true;
        });
        _routeProgressController.forward(from: 0);
        return;
      }
    }

    // 1. Buscar si coincide directamente con el ID de un animal / marcador (ej. 'C05', 'S03', 'I02', 'C08')
    final porId = marcadores.where((m) => m.id.toLowerCase() == destLower);
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

    // 1.1 Buscar en accesos, salidas y entradas (ej. 'SAL_01', 'ENT_01')
    final porAcceso = accesos.where(
      (a) =>
          a.id.toLowerCase() == destLower ||
          a.nombre.toLowerCase().contains(destLower),
    );
    if (porAcceso.isNotEmpty) {
      final marcador = porAcceso.first;
      setState(() {
        _habitatFiltro = null;
      });
      _mostrarInfoMarcador(marcador);
      setState(() {
        _isNavigating = true;
      });
      _routeProgressController.forward(from: 0);
      return;
    }

    // 1.2 Buscar en baños del zoológico (ej. 'B01', 'B02', 'baño')
    final porBanio = banios.where(
      (b) =>
          b.id.toLowerCase() == destLower ||
          b.nombre.toLowerCase().contains(destLower),
    );
    if (porBanio.isNotEmpty) {
      final marcador = porBanio.first;
      setState(() {
        _mostrarBanios = true;
        _chipUrgencia = ChipUrgenciaMapa.banios;
        _filtroServicio = FiltroServicioMapa.banio;
        _habitatFiltro = null;
      });
      _mostrarInfoMarcador(marcador);
      setState(() {
        _isNavigating = true;
      });
      _routeProgressController.forward(from: 0);
      return;
    }

    // 1.3 Buscar en zonas de calma
    final porCalma = zonasCalma.where(
      (c) =>
          c.id.toLowerCase() == destLower ||
          c.nombre.toLowerCase().contains(destLower),
    );
    if (porCalma.isNotEmpty) {
      final marcador = porCalma.first;
      setState(() {
        _mostrarZonasCalma = true;
        _chipUrgencia = ChipUrgenciaMapa.ninguno;
        _filtroServicio = FiltroServicioMapa.calma;
        _habitatFiltro = null;
      });
      _mostrarInfoMarcador(marcador);
      setState(() {
        _isNavigating = true;
      });
      _routeProgressController.forward(from: 0);
      return;
    }

    // 1.4 Buscar animal por coincidencia de nombre
    final porNombre = marcadores.where(
      (m) =>
          m.nombre.toLowerCase().contains(destLower) ||
          destLower.contains(m.nombre.toLowerCase()),
    );
    if (porNombre.isNotEmpty) {
      final marcador = porNombre.first;
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

    final enHabitat = marcadores
        .where((m) => m.habitat == habitatNormalizado)
        .toList();
    if (enHabitat.isNotEmpty) {
      final favoritos = enHabitat
          .where((m) => m.categoria == 'Favoritos')
          .toList();
      final destinoMarcador = favoritos.isNotEmpty
          ? favoritos.first
          : enHabitat.first;
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
        objetivo =
            _encontrarBanioMasCercano() ??
            (banios.isNotEmpty ? banios.first : null);
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
        final matches = accesos
            .where((a) => _isMarkerMatchingFilter(a))
            .toList();
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
    final double zoomScale = math.max(
      currentScale,
      math.max(minMapScale, 1.35),
    );

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

  void _mostrarInfoMarcador(
    MarcadorMapa marcador, {
    bool sincronizarCarrusel = true,
  }) {
    final origen =
        grafoMapa.nodos[_nodoActual]?.posicion ??
        ServicioRutasSvg.puntoEntradaOficial;
    final nuevaRuta = grafoMapa.encontrarRutaMasCorta(_nodoActual, marcador.id);
    final rutaSvg = ServicioRutasSvg.obtenerRutaHacia(marcador, origen: origen);
    setState(() {
      _marcadorSeleccionado = marcador;
      // En modo fácil la navegación se activa de inmediato para dibujar el sendero
      _isNavigating = widget.modoFacil;
      _rutaActual = nuevaRuta;
      _rutaSvgActual = rutaSvg;

      if (sincronizarCarrusel) {
        if (marcador.esBanio) {
          _serviciosFiltrados = List.from(banios);
          final idx = _serviciosFiltrados.indexWhere(
            (b) => b.id == marcador.id,
          );
          _indiceServicioActual = idx >= 0 ? idx : 0;
          _chipUrgencia = ChipUrgenciaMapa.banios;
          _filtroServicio = FiltroServicioMapa.banio;
        } else if (marcador.esZonaCalma) {
          _serviciosFiltrados = List.from(zonasCalma);
          final idx = _serviciosFiltrados.indexWhere(
            (z) => z.id == marcador.id,
          );
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
    _mostrarInfoMarcador(
      _serviciosFiltrados[nuevoIndice],
      sincronizarCarrusel: false,
    );
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
    _mostrarInfoMarcador(
      _serviciosFiltrados[nuevoIndice],
      sincronizarCarrusel: false,
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
            final enZona = marcadores
                .where((m) => m.habitat == nuevoHabitat)
                .toList();
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
              _mostrarInfoMarcador(
                zonasCalma.first,
                sincronizarCarrusel: false,
              );
            }
          } else if (servicio == 'snacks' || servicio == 'tiendas') {
            ModalTiendasCercanas.mostrar(context, onAbrirEnMapa: () {});
          }
        });
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
    final double currentScale = _transformationController.value
        .getMaxScaleOnAxis();
    final bool mostrarEtiquetasAnimales = currentScale >= 1.25;
    final a11y = AccesibilidadService.instance;

    return Scaffold(
      backgroundColor: a11y.modoAltoContraste
          ? const Color(0xFF020617)
          : Colors.white,
      extendBody: true,
      body: Stack(
        children: [
          // 1. CANVAS INTERACTIVO DEL MAPA (Capas, Pines, Trazos y Radar)
          CanvasMapaInteractivo(
            transformationController: _transformationController,
            minMapScale: minMapScale,
            mapaAncho: mapaAncho,
            mapaAlto: mapaAlto,
            marcadorSeleccionado: _marcadorSeleccionado,
            marcadores: marcadores,
            banios: banios,
            accesos: accesos,
            zonasCalma: zonasCalma,
            mostrarBanios: _mostrarBanios,
            mostrarZonasCalma: _mostrarZonasCalma,
            mostrarEtiquetasAnimales: mostrarEtiquetasAnimales,
            filtroServicio: _filtroServicio,
            habitatFiltro: _habitatFiltro,
            nodoActual: _nodoActual,
            grafoMapa: grafoMapa,
            radarPulseAnimation: _radarPulseAnimation,
            routeProgressAnimation: _routeProgressController,
            rutaSvgActual: _rutaSvgActual,
            rutaActual: _rutaActual,
            isNavigating: _isNavigating,
            onDeseleccionar: () {
              if (_marcadorSeleccionado != null) {
                setState(() {
                  _marcadorSeleccionado = null;
                  _rutaActual = [];
                  _rutaSvgActual = null;
                });
              }
            },
            onSelectMarcador: (marcador) => _mostrarInfoMarcador(marcador),
          ),

          // 2. BARRA SUPERIOR HÍBRIDA / MODO FÁCIL
          BarraSuperiorMapa(
            modoFacil: widget.modoFacil,
            onVolverMenuFacil: widget.onVolverMenuFacil,
            chipActivo: _chipUrgencia,
            filtroServicio: _filtroServicio,
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
                  ModalTiendasCercanas.mostrar(context, onAbrirEnMapa: () {});
                  break;
                case ChipUrgenciaMapa.ninguno:
                  _onFiltroCambiado(FiltroServicioMapa.todos);
                  break;
              }
            },
            onFiltroCambiado: _onFiltroCambiado,
            onAbrirCapas: _abrirModalCapas,
          ),

          // 3. CONTROLES FLOTANTES (Mi Ubicación y Capas con Glassmorphism)
          ControlesFlotantesMapa(
            keyFab: _keyFab,
            hayMarcadorSeleccionado: _marcadorSeleccionado != null,
            modoFacil: widget.modoFacil,
            onMiUbicacionPressed: _onMyLocationPressed,
            onCapasPressed: _abrirModalCapas,
          ),

          // 4. BARRA INFERIOR REUTILIZABLE (Cápsula Flotante)
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
                  indiceServicio: _serviciosFiltrados.isNotEmpty
                      ? _indiceServicioActual
                      : null,
                  totalServicios: _serviciosFiltrados.isNotEmpty
                      ? _serviciosFiltrados.length
                      : null,
                  onServicioAnterior: _anteriorServicio,
                  onServicioSiguiente: _siguienteServicio,
                ),
              ),
            ),
          ),

          // 5. OVERLAY DEL TUTORIAL
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
