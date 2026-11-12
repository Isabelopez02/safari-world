import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/emergency_service.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/services/notification_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/core/widgets/modal_animales_por_visitar.dart';

import 'widgets/modal_insignias_perfil.dart';
import 'widgets/seccion_card_grupo.dart';
import 'widgets/selector_idioma_perfil.dart';
import 'widgets/selector_tamano_letra.dart';

/// Pantalla de Perfil y Ajustes con diseño y ergonomía estilo iOS / iPhone:
/// - Secciones agrupadas con paleta safari unificada (#FBF9F6 y verdes de la app)
/// - Selector de tamaño de letra con vista previa en vivo
/// - Selector de idioma (Español, English, Quechua)
/// - Insignias y medallas en modal
/// - Ajustes de accesibilidad, notificaciones y sonido
class PantallaPerfil extends StatefulWidget {
  final VoidCallback? onVolverAlInicio;

  const PantallaPerfil({
    super.key,
    this.onVolverAlInicio,
  });

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  // Estados de notificaciones estilo iOS
  bool _notificacionesShows = true;
  bool _alertasRuta = true;
  bool _efectosSonoros = true;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: IdiomaService.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFBF9F6),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            automaticallyImplyLeading: false,
            leading: widget.onVolverAlInicio != null
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textoOscuro,
                      size: 20,
                    ),
                    onPressed: () {
                      SoundService.instance.playButtonTap();
                      widget.onVolverAlInicio!();
                    },
                  )
                : null,
            title: Text(
              'perfil_titulo'.tr,
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: AppColors.textoOscuro,
                letterSpacing: -0.5,
              ),
            ),
          ),
          body: Builder(
            builder: (context) {
              final bool esTablet = MediaQuery.of(context).size.width >= 720;
              final Widget content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TARJETA DE USUARIO ESTILO APPLE ID
                  _buildAppleIdCard(),

                  const SizedBox(height: 22),

                  // 2. SECCIÓN IDIOMA GLOBAL
                  SeccionCardGrupo(
                    titulo: 'idioma_titulo'.tr,
                    children: const [
                      SelectorIdiomaPerfil(),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // 3. SECCIÓN VISUALIZACIÓN & DALTONISMO
                  SeccionCardGrupo(
                    titulo: 'tamano_texto'.tr,
                    children: [
                      const SelectorTamanoLetra(),
                      const Divider(height: 1, indent: 56),
                      AnimatedBuilder(
                        animation: AccesibilidadService.instance,
                        builder: (context, _) {
                          final daltonismoActivo =
                              AccesibilidadService.instance.modoDaltonismo;
                          return _buildIosSwitchRow(
                            icono: Icons.visibility_rounded,
                            colorIcono: AppColors.verdeAzulado,
                            titulo: 'modo_daltonismo_tit'.tr,
                            subtitulo: 'modo_daltonismo_sub'.tr,
                            valor: daltonismoActivo,
                            onChanged: (val) {
                              SoundService.instance.playButtonTap();
                              AccesibilidadService.instance.setModoDaltonismo(val);
                            },
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 56),
                      AnimatedBuilder(
                        animation: AccesibilidadService.instance,
                        builder: (context, _) {
                          final modoFacilActivo =
                              AccesibilidadService.instance.modoFacil;
                          return _buildIosSwitchRow(
                            icono: Icons.elderly_rounded,
                            colorIcono: const Color(0xFFC2185B),
                            titulo: 'modo_facil_tit'.tr,
                            subtitulo: 'modo_facil_sub'.tr,
                            valor: modoFacilActivo,
                            onChanged: (val) {
                              SoundService.instance.playButtonTap();
                              AccesibilidadService.instance.setModoFacil(val);
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // 4. SECCIÓN NOTIFICACIONES
                  SeccionCardGrupo(
                    titulo: 'notificaciones_titulo'.tr,
                    children: [
                      _buildIosSwitchRow(
                        icono: Icons.theater_comedy_rounded,
                        colorIcono: AppColors.verdePrincipal,
                        titulo: 'alertas_shows'.tr,
                        subtitulo: 'alertas_shows_sub'.tr,
                        valor: _notificacionesShows,
                        onChanged: (val) {
                          SoundService.instance.playButtonTap();
                          setState(() => _notificacionesShows = val);
                          if (val) {
                            NotificationService.instance.mostrarNotificacion(
                              id: 102,
                              titulo: '🔔 Parque de las Leyendas',
                              cuerpo: 'Las notificaciones han sido activadas',
                            );
                          }
                        },
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildIosSwitchRow(
                        icono: Icons.navigation_rounded,
                        colorIcono: const Color(0xFF2E7D32),
                        titulo: 'Guía de Ruta & Senderos',
                        subtitulo: 'Sugerencias del camino mientras caminas',
                        valor: _alertasRuta,
                        onChanged: (val) {
                          SoundService.instance.playButtonTap();
                          setState(() => _alertasRuta = val);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // 5. SECCIÓN EXPEDICIÓN Y PROGRESO
                  SeccionCardGrupo(
                    titulo: 'EXPEDICIÓN DEL DÍA',
                    children: [
                      AnimatedBuilder(
                        animation: AnimalService.instance,
                        builder: (context, _) {
                          final visitados = AnimalService.instance.totalVisitados;
                          final total = AnimalService.instance.totalAnimales;
                          return _buildIosNavigationRow(
                            icono: Icons.pets_rounded,
                            colorIcono: const Color(0xFF40916C),
                            titulo: 'Animales Observados',
                            valorTrailing: '$visitados de $total vistos',
                            onTap: () {
                              SoundService.instance.playButtonTap();
                              ModalAnimalesPorVisitar.mostrar(
                                context,
                                onSeleccionarAnimal: (_) {},
                              );
                            },
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildIosNavigationRow(
                        icono: Icons.emoji_events_rounded,
                        colorIcono: const Color(0xFFDF9F1D),
                        titulo: 'Insignias y Medallas',
                        valorTrailing: '3 obtenidas',
                        onTap: () {
                          ModalInsigniasPerfil.mostrar(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // 6. SECCIÓN SONIDO Y ASISTENCIA
                  SeccionCardGrupo(
                    titulo: 'PREFERENCIAS DEL PARQUE',
                    children: [
                      _buildIosSwitchRow(
                        icono: Icons.volume_up_rounded,
                        colorIcono: const Color(0xFF8D6E63),
                        titulo: 'Efectos de Sonido',
                        subtitulo: 'Respuesta sonora al interactuar con botones',
                        valor: _efectosSonoros,
                        onChanged: (val) {
                          SoundService.instance.playButtonTap();
                          setState(() => _efectosSonoros = val);
                        },
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildIosNavigationRow(
                        icono: Icons.sos_rounded,
                        colorIcono: AppColors.rojoEmergencia,
                        titulo: 'Emergencias y Primeros Auxilios',
                        valorTrailing: 'Llamar',
                        onTap: () {
                          EmergencyService.instance.mostrarModalEmergencia(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  // BOTÓN RESTABLECER / SALIR
                  Center(
                    child: TextButton(
                      onPressed: () {
                        SoundService.instance.playButtonTap();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.verdePrincipal,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            content: const Text(
                              'Datos de sesión y recorrido sincronizados correctamente',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Cerrar Sesión de Explorador',
                        style: GoogleFonts.urbanist(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFF3B30),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Versión 2.4.0 • Safari Edition\nParque Zoológico de las Leyendas',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 90),
                ],
              );

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: esTablet
                    ? SizedBox(
                        width: double.infinity,
                        child: Center(
                          heightFactor: 1.0,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: content,
                          ),
                        ),
                      )
                    : content,
              );
            },
          ),
        );
      },
    );
  }

  /// Tarjeta de Usuario estilo Apple ID
  Widget _buildAppleIdCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.verdePrincipal.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                size: 34,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explorador Safari',
                  style: GoogleFonts.urbanist(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textoOscuro,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pase General • ID #ZOO-94821',
                  style: GoogleFonts.urbanist(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoGris,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.verdePrincipal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Entrada Activa Hoy',
                    style: GoogleFonts.urbanist(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.verdePrincipal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  /// Fila con Switch nativo Cupertino (iOS style)
  Widget _buildIosSwitchRow({
    required IconData icono,
    required Color colorIcono,
    required String titulo,
    required String subtitulo,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 11.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorIcono,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.urbanist(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textoOscuro,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitulo,
                  style: GoogleFonts.urbanist(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoGris,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: valor,
            activeTrackColor: AppColors.verdePrincipal,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  /// Fila de navegación con chevron (iOS style)
  Widget _buildIosNavigationRow({
    required IconData icono,
    required Color colorIcono,
    required String titulo,
    required String valorTrailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorIcono,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icono, color: Colors.white, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                titulo,
                style: GoogleFonts.urbanist(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textoOscuro,
                ),
              ),
            ),
            Text(
              valorTrailing,
              style: GoogleFonts.urbanist(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
