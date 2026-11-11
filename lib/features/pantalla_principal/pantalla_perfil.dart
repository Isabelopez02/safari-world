import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/emergency_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/mapa/widgets/modal_animales_por_visitar.dart';

/// Pantalla de Perfil y Ajustes con diseño y ergonomía estilo iOS / iPhone:
/// - Secciones agrupadas con paleta safari unificada (#FBF9F6 y verdes de la app)
/// - Selector de tamaño de letra (Normal, Medio, Grande) con vista previa en vivo
/// - Botón activador para Modo Daltonismo con switch nativo
/// - Alertas de shows y rutas
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
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6), // Paleta safari unificada con el resto de la app
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
          'Perfil y Ajustes',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: AppColors.textoOscuro,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. TARJETA DE USUARIO ESTILO APPLE ID
            // ==========================================
            _buildAppleIdCard(),

            const SizedBox(height: 22),

            // ==========================================
            // 2. SECCIÓN VISUALIZACIÓN & DALTONISMO
            // ==========================================
            _buildSectionHeader('VISUALIZACIÓN Y DALTONISMO'),
            _buildCardGroup(
              children: [
                _buildSelectorTamanoTexto(),
                const Divider(height: 1, indent: 56),
                AnimatedBuilder(
                  animation: AccesibilidadService.instance,
                  builder: (context, _) {
                    final daltonismoActivo =
                        AccesibilidadService.instance.modoDaltonismo;
                    return _buildIosSwitchRow(
                      icono: Icons.visibility_rounded,
                      colorIcono: AppColors.verdeAzulado,
                      titulo: 'Modo Daltonismo',
                      subtitulo:
                          'Paleta de alto contraste adaptada para visión de color',
                      valor: daltonismoActivo,
                      onChanged: (val) {
                        SoundService.instance.playButtonTap();
                        AccesibilidadService.instance.setModoDaltonismo(val);
                      },
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ==========================================
            // 3. SECCIÓN NOTIFICACIONES
            // ==========================================
            _buildSectionHeader('NOTIFICACIONES'),
            _buildCardGroup(
              children: [
                _buildIosSwitchRow(
                  icono: Icons.theater_comedy_rounded,
                  colorIcono: AppColors.verdePrincipal,
                  titulo: 'Alertas de Shows',
                  subtitulo: 'Aviso 15 min antes de cada función',
                  valor: _notificacionesShows,
                  onChanged: (val) {
                    SoundService.instance.playButtonTap();
                    setState(() => _notificacionesShows = val);
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

            // ==========================================
            // 4. SECCIÓN EXPEDICIÓN Y PROGRESO
            // ==========================================
            _buildSectionHeader('EXPEDICIÓN DEL DÍA'),
            _buildCardGroup(
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
                    SoundService.instance.playButtonTap();
                    _mostrarModalInsignias(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ==========================================
            // 5. SECCIÓN SONIDO Y ASISTENCIA
            // ==========================================
            _buildSectionHeader('PREFERENCIAS DEL PARQUE'),
            _buildCardGroup(
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
        ),
      ),
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
          // Avatar Circular iOS con iniciales/icono
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

  /// Encabezado en mayúsculas sutiles estilo iOS
  Widget _buildSectionHeader(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, bottom: 8.0),
      child: Text(
        titulo,
        style: GoogleFonts.urbanist(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: AppColors.verdePrincipal.withValues(alpha: 0.75),
        ),
      ),
    );
  }

  /// Contenedor redondeado blanco para agrupar celdas estilo iOS
  Widget _buildCardGroup({required List<Widget> children}) {
    return Container(
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
      child: Column(
        children: children,
      ),
    );
  }

  /// Selector de tamaño de letra estilo Cupertino con 3 opciones: Pequeño, Mediano, Grande
  Widget _buildSelectorTamanoTexto() {
    return AnimatedBuilder(
      animation: AccesibilidadService.instance,
      builder: (context, _) {
        final tamanoActual = AccesibilidadService.instance.tamanoTexto;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.verdePrincipal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.format_size_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tamaño de Letra de la App',
                          style: GoogleFonts.urbanist(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textoOscuro,
                          ),
                        ),
                        Text(
                          'Ajusta la legibilidad para toda la aplicación',
                          style: GoogleFonts.urbanist(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textoGris,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SELECTOR SEGMENTADO ESTILO IPHONE (NORMAL | MEDIO | GRANDE)
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<TamanoTexto>(
                  groupValue: tamanoActual,
                  backgroundColor: const Color(0xFFE5E5EA), // Gris Cupertino
                  thumbColor: Colors.white,
                  children: {
                    TamanoTexto.pequeno: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'A',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Normal',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TamanoTexto.mediano: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'A',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Medio',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TamanoTexto.grande: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'A',
                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Grande',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  },
                  onValueChanged: (TamanoTexto? nuevoTamano) {
                    if (nuevoTamano != null) {
                      SoundService.instance.playButtonTap();
                      AccesibilidadService.instance.setTamanoTexto(nuevoTamano);
                    }
                  },
                ),
              ),

              const SizedBox(height: 14),

              // CAJA DE VISTA PREVIA DEL TAMAÑO DE TEXTO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9FB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'VISTA PREVIA EN VIVO:',
                          style: GoogleFonts.urbanist(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.verdePrincipal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tamanoActual == TamanoTexto.pequeno
                                ? 'Escala 1.0x (Estándar)'
                                : tamanoActual == TamanoTexto.mediano
                                    ? 'Escala 1.15x (+15%)'
                                    : 'Escala 1.30x (+30%)',
                            style: GoogleFonts.urbanist(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.verdePrincipal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '«¡Bienvenido al zoológico! Explora los animales, consulta los shows y disfruta de tu expedición.»',
                      style: GoogleFonts.urbanist(
                        fontSize: 13.0 *
                            AccesibilidadService
                                .instance.multiplicadorEscalaTexto,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textoOscuro,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
            activeTrackColor: AppColors.verdePrincipal, // Verde armonizado con la app
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

  void _mostrarModalInsignias(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Tus Insignias Safari',
                style: GoogleFonts.urbanist(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textoOscuro,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text('🦁 Rey León', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('🐬 Acróbata', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('🚜 Granjero', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
