import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_mapa.dart';
import 'package:zoologico_front/features/mapa/widgets/modal_animales_por_visitar.dart';
import 'package:zoologico_front/features/pantalla_principal/pantalla_perfil.dart';
import 'package:zoologico_front/features/pantalla_principal/pantalla_ruta.dart';
import 'package:zoologico_front/features/pantalla_principal/pantalla_shows.dart';

import 'widgets/acciones_rapidas_grid.dart';
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
  String? _habitatSeleccionadoParaMapa;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DialogoPermisoNotificaciones.verificarYMostrar(context);
    });
  }

  void _abrirModalExploracion(BuildContext context) {
    ModalAnimalesPorVisitar.mostrar(
      context,
      onSeleccionarAnimal: (marcador) {
        setState(() {
          _habitatSeleccionadoParaMapa = marcador.habitat;
          _tabActual = 1; // Cambiar a pestaña Mapa
        });
      },
    );
  }

  void _onTabSeleccionado(int index) {
    setState(() => _tabActual = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Si estamos en cualquier otra pestaña que no sea Inicio, volver a Inicio primero
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
          index: _tabActual,
          children: [
            // PESTAÑA 0: INICIO (SUTIL, ELEGANTE Y DESPEJADA)
            _buildCuerpoPrincipal(context),

            // PESTAÑA 1: MAPA HÍBRIDO INTERACTIVO (FOOTER VISIBLE)
            PantallaMapa(
              esTabEmbedido: true,
              habitatInicial: _habitatSeleccionadoParaMapa,
            ),

            // PESTAÑA 2: CARTELERA DE SHOWS CINEPLANET (FOOTER VISIBLE)
            PantallaShows(
              esTabEmbedido: true,
              onIrAlInicio: () => setState(() => _tabActual = 0),
            ),

            // PESTAÑA 3: TU RUTA - HÁBITATS & EXPEDICIONES (FOOTER VISIBLE)
            PantallaRuta(
              onTrazarRuta: (habitat) {
                setState(() {
                  _habitatSeleccionadoParaMapa = habitat;
                  _tabActual = 1; // Lleva al mapa con la zona seleccionada
                });
              },
            ),

            // PESTAÑA 4: PERFIL DEL EXPLORADOR ESTILO IPHONE (FOOTER VISIBLE)
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

            // 1. ENCABEZADO SUTIL ("TU AVENTURA EMPIEZA AQUÍ")
            EncabezadoSutil(
              nombreParque: 'Parque de las Leyendas',
              onNotificacionesTap: () {
                DialogoPermisoNotificaciones.verificarYMostrar(context);
              },
              onPerfilTap: () => setState(() => _tabActual = 4),
            ),

            const SizedBox(height: 14),

            // 2. BANNER BONITO DESTACADO
            BannerBonito(
              onTap: () => setState(() => _tabActual = 2),
            ),

            const SizedBox(height: 20),

            // 3. PROGRESO CIRCULAR: ANIMALES OBSERVADOS HOY
            ProgresoCircularAnimales(
              onVerDetalle: () => _abrirModalExploracion(context),
            ),

            const SizedBox(height: 22),

            // 4. OPCIONES DE ACCIONES RÁPIDAS (¿QUÉ QUIERES HACER?)
            AccionesRapidasGrid(
              onVerShows: () => setState(() => _tabActual = 2),
              onVerMapa: () => setState(() => _tabActual = 3),
              onBuscarTiendas: () {
                ModalTiendasCercanas.mostrar(
                  context,
                  onAbrirEnMapa: () => setState(() => _tabActual = 1),
                );
              },
              onTePerdiste: () {
                ModalTePerdiste.mostrar(
                  context,
                  onIrAlMapa: () => setState(() => _tabActual = 1),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
