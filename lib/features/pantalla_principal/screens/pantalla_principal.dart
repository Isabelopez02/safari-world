import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_mapa.dart';
import 'package:zoologico_front/core/widgets/modal_animales_por_visitar.dart';
import 'package:zoologico_front/features/modo_facil/pantalla_modo_facil.dart';
import 'package:zoologico_front/features/perfil/pantalla_perfil.dart';
import 'package:zoologico_front/features/rutas/screens/pantalla_ruta.dart';
import 'package:zoologico_front/features/shows/screens/pantalla_shows.dart';

import '../widgets/acciones_rapidas_grid.dart';
import '../widgets/banner_bonito.dart';
import '../widgets/dialogo_permiso_notificaciones.dart';
import '../widgets/encabezado_sutil.dart';
import '../widgets/footer_navegacion.dart';
import '../widgets/modal_te_perdiste.dart';
import 'package:zoologico_front/core/widgets/modal_tiendas_cercanas.dart';
import '../widgets/progreso_circular_animales.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  DateTime? _lastBackPressTime;
  int _tabActual = 0;
  String? _habitatSeleccionadoParaMapa;
  int _contadorNavegacionMapa = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DialogoPermisoNotificaciones.verificarYMostrar(context);
    });
  }

  void _irAlMapaConDestino(String destino) {
    setState(() {
      _habitatSeleccionadoParaMapa = destino;
      _contadorNavegacionMapa++;
      _tabActual = 1;
    });
  }

  void _abrirModalExploracion(BuildContext context) {
    ModalAnimalesPorVisitar.mostrar(
      context,
      onSeleccionarAnimal: (marcador) {
        _irAlMapaConDestino(marcador.id);
      },
    );
  }

  void _onTabSeleccionado(int index) {
    setState(() => _tabActual = index);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AccesibilidadService.instance,
        IdiomaService.instance,
      ]),
      builder: (context, _) {
        final bool modoFacil = AccesibilidadService.instance.modoFacil;
        if (modoFacil) {
          return PantallaModoFacil(
            onSalirModoFacil: () {
              AccesibilidadService.instance.setModoFacil(false);
            },
          );
        }

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
                  claveNavegacion: _contadorNavegacionMapa,
                ),

                // PESTAÑA 2: CARTELERA DE SHOWS CINEPLANET (FOOTER VISIBLE)
                PantallaShows(
                  esTabEmbedido: true,
                  onIrAlInicio: () => setState(() => _tabActual = 0),
                  onVerEnMapa: (destino) => _irAlMapaConDestino(destino),
                ),

                // PESTAÑA 3: TU RUTA - HÁBITATS & EXPEDICIONES (FOOTER VISIBLE)
                PantallaRuta(
                  onTrazarRuta: (destino) => _irAlMapaConDestino(destino),
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
      },
    );
  }

  Widget _buildCuerpoPrincipal(BuildContext context) {
    final bool esTablet = MediaQuery.of(context).size.width >= 720;

    final Widget content = Column(
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

        const SizedBox(height: 10),

        // 1.1 BARRA DE BÚSQUEDA RÁPIDA (ACCESO DIRECTO A LOS 76 PINES)
        _buildBarraBusquedaHome(context),

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
          onVerMapa: () => setState(() => _tabActual = 1),
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
              onIrAlMapaConDestino: (destino) => _irAlMapaConDestino(destino),
            );
          },
        ),

        const SizedBox(height: 24),
      ],
    );

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: esTablet
            ? SizedBox(
                width: double.infinity,
                child: Center(
                  heightFactor: 1.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: content,
                    ),
                  ),
                ),
              )
            : content,
      ),
    );
  }

  Widget _buildBarraBusquedaHome(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: InkWell(
        onTap: () {
          SoundService.instance.playButtonTap();
          _mostrarBuscadorHome(context);
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.verdePrincipal.withValues(alpha: 0.22),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.verdePrincipal, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'buscar_animales'.tr,
                  style: GoogleFonts.urbanist(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.verdePrincipal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune_rounded, color: AppColors.verdePrincipal, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarBuscadorHome(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        String query = '';
        final TextEditingController searchCtrl = TextEditingController();

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final pines = AnimalService.instance.obtenerTodosLosPines();
            final qNorm = AnimalService.normalizarTexto(query);

            List<MarcadorMapa> sugerencias = [];
            if (qNorm.isNotEmpty) {
              sugerencias = pines.where((p) {
                final nomNorm = AnimalService.normalizarTexto(p.nombre);
                final idNorm = AnimalService.normalizarTexto(p.id);
                final habNorm = AnimalService.normalizarTexto(p.habitat);
                return nomNorm.contains(qNorm) ||
                    idNorm == qNorm ||
                    habNorm.contains(qNorm);
              }).toList();
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.78,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Asa superior de arrastre
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Caja de texto con autofocus
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchCtrl,
                            autofocus: true,
                            onChanged: (val) {
                              setModalState(() => query = val);
                            },
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textoOscuro,
                            ),
                            decoration: InputDecoration(
                              hintText: 'buscar_animales'.tr,
                              hintStyle: GoogleFonts.urbanist(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade400,
                              ),
                              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.verdePrincipal),
                              suffixIcon: query.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 20),
                                      onPressed: () {
                                        searchCtrl.clear();
                                        setModalState(() => query = '');
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => Navigator.of(modalContext).pop(),
                          icon: const Icon(Icons.close_rounded, size: 24),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Contenido: Si está vacío muestra búsquedas rápidas, sino lista de resultados
                  Expanded(
                    child: query.isEmpty
                        ? ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              Text(
                                'Búsquedas Frecuentes',
                                style: GoogleFonts.urbanist(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textoOscuro,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildChipBusquedaRapida('🦁 Leones', 'I02', modalContext),
                                  _buildChipBusquedaRapida('🐧 Pingüinos', 'C08', modalContext),
                                  _buildChipBusquedaRapida('🦅 Cóndor', 'S03', modalContext),
                                  _buildChipBusquedaRapida('🦒 Jirafa', 'I12', modalContext),
                                  _buildChipBusquedaRapida('🚻 Baño', 'B01', modalContext),
                                  _buildChipBusquedaRapida('🚪 Salida', 'SAL_01', modalContext),
                                  _buildChipBusquedaRapida('🚑 Tópico Médico', 'AYUDA_02', modalContext),
                                  _buildChipBusquedaRapida('🎠 Zona de Juegos', 'JUE_01', modalContext),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Explorar por Hábitats',
                                style: GoogleFonts.urbanist(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textoOscuro,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildChipHabitat('Zona Costa', modalContext),
                                  _buildChipHabitat('Zona Sierra', modalContext),
                                  _buildChipHabitat('Zona Selva', modalContext),
                                  _buildChipHabitat('Zona Internacional', modalContext),
                                  _buildChipHabitat('Granja Interactiva', modalContext),
                                ],
                              ),
                            ],
                          )
                        : (sugerencias.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                                      const SizedBox(height: 10),
                                      Text(
                                        'No se encontraron lugares con "$query"',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.urbanist(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: sugerencias.length,
                                separatorBuilder: (_, _) => const Divider(height: 1),
                                itemBuilder: (ctx, idx) {
                                  final pin = sugerencias[idx];
                                  final colorPin = pin.colorZona ?? AppColors.verdePrincipal;
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: colorPin.withValues(alpha: 0.15),
                                      child: Icon(pin.icono, color: colorPin, size: 22),
                                    ),
                                    title: Text(
                                      pin.nombre.tr,
                                      style: GoogleFonts.urbanist(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textoOscuro,
                                      ),
                                    ),
                                    subtitle: Text(
                                      pin.habitat.tr,
                                      style: GoogleFonts.urbanist(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppColors.verdePrincipal.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.navigation_rounded, size: 14, color: AppColors.verdePrincipal),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Ver en Mapa',
                                            style: GoogleFonts.urbanist(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.verdePrincipal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      SoundService.instance.playButtonTap();
                                      Navigator.of(modalContext).pop();
                                      _irAlMapaConDestino(pin.id);
                                    },
                                  );
                                },
                              )),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChipBusquedaRapida(String etiqueta, String destinoId, BuildContext modalContext) {
    return ActionChip(
      avatar: const Icon(Icons.location_on_rounded, size: 16, color: AppColors.verdePrincipal),
      label: Text(
        etiqueta,
        style: GoogleFonts.urbanist(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textoOscuro,
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      onPressed: () {
        SoundService.instance.playButtonTap();
        Navigator.of(modalContext).pop();
        _irAlMapaConDestino(destinoId);
      },
    );
  }

  Widget _buildChipHabitat(String habitat, BuildContext modalContext) {
    return ActionChip(
      avatar: const Icon(Icons.eco_rounded, size: 16, color: Color(0xFF0D9488)),
      label: Text(
        habitat,
        style: GoogleFonts.urbanist(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F766E),
        ),
      ),
      backgroundColor: const Color(0xFFCCFBF1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF99F6E4)),
      ),
      onPressed: () {
        SoundService.instance.playButtonTap();
        Navigator.of(modalContext).pop();
        _irAlMapaConDestino(habitat);
      },
    );
  }
}
