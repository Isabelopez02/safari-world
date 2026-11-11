import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_mapa.dart';
import 'package:zoologico_front/features/mapa/widgets/modal_animales_por_visitar.dart';
import 'package:zoologico_front/features/pantalla_principal/pantalla_detalle_show_acuatico.dart';
import 'package:zoologico_front/features/pantalla_principal/pantalla_perfil.dart';
import 'package:zoologico_front/features/pantalla_principal/pantalla_shows.dart';

import 'widgets/acciones_rapidas_grid.dart';
import 'widgets/animales_carrusel.dart';
import 'widgets/banner_bonito.dart';
import 'widgets/dialogo_permiso_notificaciones.dart';
import 'widgets/encabezado_sutil.dart';
import 'widgets/footer_navegacion.dart';
import 'widgets/modal_te_perdiste.dart';
import 'widgets/modal_tiendas_cercanas.dart';
import 'widgets/progreso_circular_animales.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  DateTime? _lastBackPressTime;
  int _tabActual = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DialogoPermisoNotificaciones.verificarYMostrar(context);
    });
  }

  void _navigateToMapExploraciones(BuildContext context) {
    SoundService.instance.playButtonTap();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const PantallaMapa(abrirExploracionesAlCargar: true),
      ),
    );
  }

  void _navigateToMapConAnimal(BuildContext context, String animalId) {
    SoundService.instance.playButtonTap();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaMapa(animalIdInicial: animalId),
      ),
    );
  }

  void _navigateToShowAcuatico(BuildContext context) {
    SoundService.instance.playButtonTap();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PantallaDetalleShowAcuatico(),
      ),
    );
  }

  void _navigateToShows(BuildContext context) {
    SoundService.instance.playButtonTap();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PantallaShows(),
      ),
    );
  }

  void _navigateToMap(BuildContext context) {
    SoundService.instance.playButtonTap();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PantallaMapa(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _abrirModalExploracion(BuildContext context) {
    ModalAnimalesPorVisitar.mostrar(
      context,
      onSeleccionarAnimal: (marcador) {
        _navigateToMapConAnimal(context, marcador.id);
      },
    );
  }

  void _onTabSeleccionado(int index) {
    if (index == 0) {
      setState(() => _tabActual = 0);
    } else if (index == 1) {
      _navigateToMap(context);
    } else if (index == 2) {
      _navigateToShows(context);
    } else if (index == 3) {
      _navigateToMapExploraciones(context);
    } else if (index == 4) {
      setState(() => _tabActual = 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Si estamos en perfil, volver a Inicio antes de salir
        if (_tabActual != 0) {
          setState(() => _tabActual = 0);
          return;
        }

        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.verdePrincipal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Row(
                children: [
                  const Text('🌿', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Presiona atrás de nuevo para salir del Zoológico',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF9F6),
        body: IndexedStack(
          index: _tabActual == 4 ? 1 : 0,
          children: [
            // PESTAÑA 0: PANTALLA PRINCIPAL SUTIL Y REESTRUCTURADA
            _buildCuerpoPrincipal(context),

            // PESTAÑA 4: PERFIL DEL EXPLORADOR
            PantallaPerfil(
              onVolverAlInicio: () => setState(() => _tabActual = 0),
            ),
          ],
        ),
        bottomNavigationBar: FooterNavegacion(
          indiceSeleccionado: _tabActual,
          onTabSeleccionado: _onTabSeleccionado,
        ),
      ),
    );
  }

  Widget _buildCuerpoPrincipal(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            // 1. ENCABEZADO SUTIL
            EncabezadoSutil(
              nombreParque: 'Parque de las Leyendas',
              onNotificacionesTap: () {
                DialogoPermisoNotificaciones.verificarYMostrar(context);
              },
            ),

            const SizedBox(height: 14),

            // 2. BANNER BONITO DESTACADO
            BannerBonito(
              onTap: () => _navigateToShowAcuatico(context),
            ),

            const SizedBox(height: 20),

            // 3. PROGRESO CIRCULAR: ANIMALES OBSERVADOS HOY
            ProgresoCircularAnimales(
              onVerDetalle: () => _abrirModalExploracion(context),
            ),

            const SizedBox(height: 22),

            // 4. OPCIONES DE ACCIONES RÁPIDAS (¿QUÉ QUIERES HACER?)
            AccionesRapidasGrid(
              onVerShows: () => _navigateToShows(context),
              onVerMapa: () => _navigateToMap(context),
              onBuscarTiendas: () {
                ModalTiendasCercanas.mostrar(
                  context,
                  onAbrirEnMapa: () => _navigateToMap(context),
                );
              },
              onTePerdiste: () {
                ModalTePerdiste.mostrar(
                  context,
                  onIrAlMapa: () => _navigateToMap(context),
                );
              },
            ),

            const SizedBox(height: 26),

            // 5. CARRUSEL DE ANIMALES POR DESCUBRIR
            AnimalesCarrusel(
              onExploracionesTap: () => _navigateToMapExploraciones(context),
              onSeleccionarAnimal: (animalId) =>
                  _navigateToMapConAnimal(context, animalId),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
