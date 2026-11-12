import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/audioguia_service.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/services/notification_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_mapa.dart';

/// Subpantallas del Modo Fácil
enum SubVistaModoFacil {
  menuPrincipal,
  escanearQrAnimal,
  showsFacil,
  mapaFacil,
  ayudaFacil,
}

/// Modelo de datos para animales en el Modo Fácil
class AnimalQrFacil {
  final String id;
  final String marcadorId;
  final String nombre;
  final String zona;
  final String imagen;
  final String historiaVoz;
  final String dieta;

  const AnimalQrFacil({
    required this.id,
    required this.marcadorId,
    required this.nombre,
    required this.zona,
    required this.imagen,
    required this.historiaVoz,
    required this.dieta,
  });
}

/// Pantalla especial diseñada para Adultos Mayores y Personas con baja destreza digital.
/// - Escáner de código QR físico con cámara real para TODOS los animales del zoológico
/// - Mapa interactivo idéntico al modo normal pero con 3 filtros gigantes accesibles (Baño, Salida, Zona Tranquila)
/// - Shows de cartelera grande con animación y efecto de guardado
/// - Botón '← Volver al Menú' sticky (fijo en la parte superior) claramente diferenciado de 'Salir del Modo Fácil'
class PantallaModoFacil extends StatefulWidget {
  final VoidCallback onSalirModoFacil;

  const PantallaModoFacil({
    super.key,
    required this.onSalirModoFacil,
  });

  @override
  State<PantallaModoFacil> createState() => _PantallaModoFacilState();
}

class _PantallaModoFacilState extends State<PantallaModoFacil> {
  SubVistaModoFacil _vistaActual = SubVistaModoFacil.menuPrincipal;

  // Controlador de cámara para escaneo QR
  MobileScannerController? _scannerController;
  bool _linternaEncendida = false;

  // Registro de horarios de shows guardados (showTitulo -> horario)
  final Map<String, String> _showHorariosSeleccionados = {};

  // Animal actualmente escaneado o seleccionado
  AnimalQrFacil? _animalEscaneado;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    AudioGuiaService.instance.detener();
    super.dispose();
  }

  void _iniciarScanner() {
    _scannerController ??= MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  void _detenerScanner() {
    _scannerController?.dispose();
    _scannerController = null;
  }

  void _cambiarVista(SubVistaModoFacil nuevaVista) {
    SoundService.instance.playButtonTap();
    AudioGuiaService.instance.detener();

    if (nuevaVista == SubVistaModoFacil.escanearQrAnimal) {
      _iniciarScanner();
    } else {
      _detenerScanner();
    }

    setState(() {
      _vistaActual = nuevaVista;
      if (nuevaVista != SubVistaModoFacil.escanearQrAnimal) {
        _animalEscaneado = null;
      }
    });
  }

  /// Convierte un MarcadorMapa del zoológico a una ficha fácil y accesible
  AnimalQrFacil _convertirMarcadorAFacil(MarcadorMapa m) {
    final datos = AnimalService.instance.obtenerDatos(m.nombre);
    final historia = datos.narracionAudioguia.trim().isNotEmpty
        ? datos.narracionAudioguia
        : (datos.curiosidad.trim().isNotEmpty
            ? datos.curiosidad
            : '${m.nombre} vive en la zona ${m.habitat}. Es una de las especies más representativas del Parque de las Leyendas.');
    final dieta = datos.dieta.trim().isNotEmpty ? datos.dieta : 'Alimentación balanceada y supervisada';

    return AnimalQrFacil(
      id: 'qr_${m.id.toLowerCase()}',
      marcadorId: m.id,
      nombre: m.nombre,
      zona: '${m.habitat} • Sendero accesible',
      imagen: m.imagen ?? 'assets/images/animales_con_fondo/leon-card.jpg',
      dieta: dieta,
      historiaVoz: historia,
    );
  }

  /// Busca cualquier animal del catálogo del zoológico a partir del código QR escaneado
  AnimalQrFacil? _buscarAnimalPorQr(String raw) {
    final clean = raw.trim().toLowerCase();
    final todos = AnimalService.instance.obtenerTodosLosAnimales();

    // 1. Por ID directo (ej. 'i02', 'g01', 's01', 'c02', etc.)
    for (final m in todos) {
      if (m.id.toLowerCase() == clean || 'qr_${m.id.toLowerCase()}' == clean) {
        return _convertirMarcadorAFacil(m);
      }
    }

    // 2. Por coincidencia en el nombre
    for (final m in todos) {
      final nom = m.nombre.toLowerCase();
      if (clean == nom || clean.contains(nom) || nom.contains(clean)) {
        return _convertirMarcadorAFacil(m);
      }
    }

    // 3. Si el código QR es una URL (ej. https://zoologico.pe/animal/I02)
    for (final m in todos) {
      if (clean.contains(m.id.toLowerCase())) {
        return _convertirMarcadorAFacil(m);
      }
    }

    // 4. Por palabras clave principales
    for (final m in todos) {
      for (final palabra in m.nombre.toLowerCase().split(' ')) {
        if (palabra.length > 3 && clean.contains(palabra)) {
          return _convertirMarcadorAFacil(m);
        }
      }
    }

    // Si no coincide exactamente, toma el primer animal del parque como respaldo seguro
    if (todos.isNotEmpty) {
      return _convertirMarcadorAFacil(todos.first);
    }
    return null;
  }

  void _onQrDetectado(String raw) {
    final animal = _buscarAnimalPorQr(raw);
    if (animal != null && mounted) {
      SoundService.instance.playAnimalTap(animal.nombre);
      HapticFeedback.heavyImpact();
      _detenerScanner();

      setState(() {
        _animalEscaneado = animal;
      });

      // Narración por voz inmediata y clara
      AudioGuiaService.instance.reproducir('Ha llegado a ${animal.nombre}. ${animal.historiaVoz}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: IdiomaService.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFBF9F6),
          body: SafeArea(
            child: Column(
              children: [
                // BARRA SUPERIOR PEGADA (STICKY) CON 'VOLVER AL MENÚ' Y 'SALIR' COMPLETAMENTE DIFERENCIADOS
                _buildEncabezadoSuperior(),

                // CONTENIDO DE LA VISTA SELECCIONADA
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _buildCuerpoSegunVista(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Barra superior fija que jamás desaparece al hacer scroll
  Widget _buildEncabezadoSuperior() {
    final esMenu = _vistaActual == SubVistaModoFacil.menuPrincipal && _animalEscaneado == null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: esMenu
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.verdePrincipal.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('👵', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MODO FÁCIL',
                          style: GoogleFonts.urbanist(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.verdePrincipal,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Letra grande y lectura guiada',
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textoGris,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    SoundService.instance.playButtonTap();
                    AudioGuiaService.instance.detener();
                    widget.onSalirModoFacil();
                  },
                  icon: const Icon(Icons.exit_to_app_rounded, size: 18, color: Colors.white),
                  label: Text(
                    'Salir',
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                // 1. BOTÓN GIGANTE VOLVER AL MENÚ (NUNCA SE CONFUNDE)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      SoundService.instance.playButtonTap();
                      AudioGuiaService.instance.detener();
                      setState(() {
                        _animalEscaneado = null;
                        _vistaActual = SubVistaModoFacil.menuPrincipal;
                      });
                    },
                    icon: const Icon(Icons.arrow_back_rounded, size: 26, color: Colors.white),
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
                        side: const BorderSide(color: Color(0xFF334155), width: 1.5),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 2. BOTÓN SALIR DEL MODO FÁCIL AL MODO ESTÁNDAR (EN ROJO Y DIFERENCIADO)
                OutlinedButton.icon(
                  onPressed: () {
                    SoundService.instance.playButtonTap();
                    AudioGuiaService.instance.detener();
                    widget.onSalirModoFacil();
                  },
                  icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFC62828)),
                  label: Text(
                    'salir_modo_facil'.tr,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.urbanist(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFC62828),
                      height: 1.1,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEE),
                    side: const BorderSide(color: Color(0xFFEF9A9A), width: 1.4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCuerpoSegunVista() {
    switch (_vistaActual) {
      case SubVistaModoFacil.menuPrincipal:
        return _buildMenuPrincipal();
      case SubVistaModoFacil.escanearQrAnimal:
        return _buildVistaEscanearQrAnimal();
      case SubVistaModoFacil.showsFacil:
        return _buildVistaShowsFacil();
      case SubVistaModoFacil.mapaFacil:
        return _buildVistaMapaFacil();
      case SubVistaModoFacil.ayudaFacil:
        return _buildVistaAyudaFacil();
    }
  }

  // ===========================================================================
  // 1. MENÚ PRINCIPAL
  // ===========================================================================
  Widget _buildMenuPrincipal() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
      children: [
        // TARJETA DE BIENVENIDA
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.verdePrincipal.withValues(alpha: 0.25), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Bienvenido al Parque! 🦁',
                style: GoogleFonts.urbanist(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textoOscuro,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Toque cualquiera de los botones grandes de abajo para usar el parque de forma fácil y sin complicaciones.',
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textoGris,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 1. ESCANEAR QR / AUDIO GUÍA
        _buildBotonMenuGigante(
          icono: Icons.qr_code_scanner_rounded,
          colorFondo: const Color(0xFFF3E5F5),
          colorIcono: const Color(0xFF7B1FA2),
          titulo: 'escanear_placa_guia'.tr,
          subtitulo: 'Abra la cámara y apunte al letrero de cualquier animal para escuchar su historia',
          onTap: () => _cambiarVista(SubVistaModoFacil.escanearQrAnimal),
        ),
        const SizedBox(height: 16),

        // 2. MAPA FÁCIL
        _buildBotonMenuGigante(
          icono: Icons.map_rounded,
          colorFondo: const Color(0xFFE3F2FD),
          colorIcono: const Color(0xFF1565C0),
          titulo: 'mapa_zoologico'.tr,
          subtitulo: 'Mapa interactivo con botones gigantes para Baños, Salida y Zona Tranquila',
          onTap: () => _cambiarVista(SubVistaModoFacil.mapaFacil),
        ),
        const SizedBox(height: 16),

        // 3. SHOWS DE HOY
        _buildBotonMenuGigante(
          icono: Icons.theater_comedy_rounded,
          colorFondo: const Color(0xFFFFF3E0),
          colorIcono: const Color(0xFFE65100),
          titulo: 'shows_hoy'.tr,
          subtitulo: 'Cartelera grande con guardado en 1 toque y efecto de confirmación',
          onTap: () => _cambiarVista(SubVistaModoFacil.showsFacil),
        ),
        const SizedBox(height: 16),

        // 4. BOTÓN DE AUXILIO / AYUDA
        _buildBotonMenuGigante(
          icono: Icons.help_outline_rounded,
          colorFondo: const Color(0xFFFFEBEE),
          colorIcono: const Color(0xFFC62828),
          titulo: 'pedir_ayuda'.tr,
          subtitulo: 'Contactar a un orientador o asistencia médica del parque',
          onTap: () => _cambiarVista(SubVistaModoFacil.ayudaFacil),
        ),
      ],
    );
  }

  Widget _buildBotonMenuGigante({
    required IconData icono,
    required Color colorFondo,
    required Color colorIcono,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        SoundService.instance.playButtonTap();
        onTap();
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colorIcono.withValues(alpha: 0.35), width: 1.8),
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
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: colorFondo,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icono, color: colorIcono, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textoOscuro,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textoGris,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: colorIcono, size: 20),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. VISTA ESCANEAR QR REAL CON CÁMARA + TODOS LOS ANIMALES
  // ===========================================================================
  Widget _buildVistaEscanearQrAnimal() {
    if (_animalEscaneado != null) {
      return _buildFichaAnimalEscaneado(_animalEscaneado!);
    }

    _iniciarScanner();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
      children: [
        // INSTRUCCIÓN PRINCIPAL
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF7B1FA2).withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.center_focus_strong_rounded, color: Color(0xFF7B1FA2), size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Apunte la cámara a la placa QR o letrero físico de cualquier animal del parque.',
                  style: GoogleFonts.urbanist(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A148C),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // VISOR DE CÁMARA REAL (MOBILE SCANNER)
        Container(
          height: 330,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF7B1FA2), width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                if (_scannerController != null)
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: (BarcodeCapture capture) {
                      final raw = capture.barcodes.firstOrNull?.rawValue;
                      if (raw != null && raw.isNotEmpty) {
                        _onQrDetectado(raw);
                      }
                    },
                    errorBuilder: (context, error) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.videocam_off_rounded, color: Colors.white70, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'Cámara en espera o no disponible.\nPuede seleccionar cualquier animal con los botones de abajo.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.urbanist(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                // MARCO DE ENFOQUE VISUAL CON LÍNEA
                Center(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.greenAccent, width: 3.5),
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 2,
                            width: 200,
                            color: Colors.greenAccent.withValues(alpha: 0.75),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Text(
                            'Enfoque aquí el QR',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.urbanist(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // BOTONES FLOTANTES DE LA CÁMARA (LINTERNA Y CAMBIO)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: Icon(
                            _linternaEncendida ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                            color: _linternaEncendida ? Colors.amber : Colors.white,
                          ),
                          onPressed: () {
                            _scannerController?.toggleTorch();
                            setState(() => _linternaEncendida = !_linternaEncendida);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.flip_camera_android_rounded, color: Colors.white),
                          onPressed: () => _scannerController?.switchCamera(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // BOTÓN PARA EXPLORAR LA LISTA COMPLETA DE TODOS LOS ANIMALES DEL ZOOLÓGICO
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _mostrarModalCatalogoCompleto(context),
            icon: const Icon(Icons.format_list_bulleted_rounded, size: 24, color: Colors.white),
            label: Text(
              '🐾 Elegir de la Lista Completa de Animales',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B1FA2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'O pruebe directamente con estas placas frecuentes:',
          style: GoogleFonts.urbanist(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppColors.textoOscuro,
          ),
        ),
        const SizedBox(height: 10),

        // ACCESOS DIRECTOS A PLACAS DE ANIMALES POPULARES
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildChipPlacaRapida('🦁 León (I02)', 'I02'),
            _buildChipPlacaRapida('🐬 Lobo de Mar (C02)', 'C02'),
            _buildChipPlacaRapida('🐧 Pingüino (C03)', 'C03'),
            _buildChipPlacaRapida('🦅 Cóndor (S01)', 'S01'),
            _buildChipPlacaRapida('🦒 Jirafa (I04)', 'I04'),
            _buildChipPlacaRapida('🐅 Tigre (I03)', 'I03'),
          ],
        ),
      ],
    );
  }

  Widget _buildChipPlacaRapida(String etiqueta, String idAnimal) {
    return ElevatedButton.icon(
      onPressed: () => _onQrDetectado(idAnimal),
      icon: const Icon(Icons.qr_code_2_rounded, size: 20, color: Colors.white),
      label: Text(
        etiqueta,
        style: GoogleFonts.urbanist(
          fontSize: 14.5,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A148C),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  /// Muestra una lista modal de TODOS los animales del zoológico para elegir en 1 toque
  void _mostrarModalCatalogoCompleto(BuildContext context) {
    final todos = AnimalService.instance.obtenerTodosLosAnimales();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Todos los Animales del Parque (${todos.length})',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textoOscuro,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 26),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: todos.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final m = todos[i];
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _onQrDetectado(m.id);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                m.imagen ?? 'assets/images/animales_con_fondo/leon-card.jpg',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.pets, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.nombre,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textoOscuro,
                                    ),
                                  ),
                                  Text(
                                    '${m.habitat} • Código: ${m.id}',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textoGris,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.volume_up_rounded, color: Color(0xFF7B1FA2), size: 28),
                          ],
                        ),
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

  /// Ficha accesible del animal escaneado con auto-audio y botón 'Marcar Visitado'
  Widget _buildFichaAnimalEscaneado(AnimalQrFacil animal) {
    return ListenableBuilder(
      listenable: AnimalService.instance,
      builder: (context, _) {
        final visitado = AnimalService.instance.esVisitado(animal.marcadorId);

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
          children: [
            // FOTO DEL ANIMAL
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                animal.imagen,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  height: 220,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.pets, size: 64, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // TÍTULO Y HÁBITAT
            Text(
              animal.nombre,
              style: GoogleFonts.urbanist(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.textoOscuro,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.verdePrincipal, size: 20),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    animal.zona,
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.verdePrincipal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // BOTÓN PRINCIPAL: MARCAR COMO VISITADO DIRECTO
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  SoundService.instance.playButtonTap();
                  HapticFeedback.mediumImpact();
                  AnimalService.instance.marcarVisitado(animal.marcadorId, !visitado);

                  if (!visitado) {
                    AudioGuiaService.instance.reproducir('¡Felicitaciones! Ha marcado a ${animal.nombre} como visitado.');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ ¡${animal.nombre} marcado como visitado!'),
                        backgroundColor: Colors.green.shade800,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: Icon(
                  visitado ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                  size: 28,
                  color: Colors.white,
                ),
                label: Text(
                  visitado ? 'visitado_listo'.tr : 'marcar_visitado'.tr,
                  style: GoogleFonts.urbanist(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: visitado ? const Color(0xFF2E7D32) : const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // HISTORIA CON AUDIO Y BOTÓN DE VOZ
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '🎙️ Historia del Animal',
                        style: GoogleFonts.urbanist(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textoOscuro,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF7B1FA2), size: 30),
                        tooltip: 'Repetir narración',
                        onPressed: () {
                          AudioGuiaService.instance.reproducir('${animal.nombre}. ${animal.historiaVoz}');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    animal.historiaVoz,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textoOscuro,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.restaurant_rounded, color: Colors.orange, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            animal.dieta,
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // BOTÓN PARA ESCANEAR OTRA PLACA
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  SoundService.instance.playButtonTap();
                  AudioGuiaService.instance.detener();
                  _iniciarScanner();
                  setState(() => _animalEscaneado = null);
                },
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 24, color: Color(0xFF7B1FA2)),
                label: Text(
                  '📷 Escanear otra placa QR',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF7B1FA2),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF7B1FA2), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 3. VISTA MAPA INTERACTIVO CON FILTROS GRANDES (BAÑOS, SALIDA, ZONA TRANQUILA)
  // ===========================================================================
  Widget _buildVistaMapaFacil() {
    return PantallaMapa(
      modoFacil: true,
      onVolverMenuFacil: () => _cambiarVista(SubVistaModoFacil.menuPrincipal),
    );
  }

  // ===========================================================================
  // 4. VISTA SHOWS FÁCIL CON EFECTO DE GUARDADO
  // ===========================================================================
  Widget _buildVistaShowsFacil() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
      children: [
        _buildTarjetaShowFacil(
          titulo: 'Show de Lobos Marinos',
          lugar: 'Anfiteatro Acuático • Zona Costa (Rampa plana)',
          imagen: 'assets/images/animales_con_fondo/foca-card.jpg',
          duracion: '35 min de espectáculo',
          horarios: ['10:00 AM', '01:00 PM', '04:00 PM'],
        ),
        const SizedBox(height: 18),

        _buildTarjetaShowFacil(
          titulo: 'Vuelo de Cóndores y Águilas',
          lugar: 'Mirador Andino • Zona Sierra (Senderos con sombra)',
          imagen: 'assets/images/animales_con_fondo/aguila.jpg',
          duracion: '25 min de vuelo libre',
          horarios: ['11:30 AM', '03:30 PM'],
        ),
        const SizedBox(height: 18),

        _buildTarjetaShowFacil(
          titulo: 'Alimentación de Pingüinos',
          lugar: 'Piscina Humboldt • Zona Costa',
          imagen: 'assets/images/animales_con_fondo/pinguino-card.jpg',
          duracion: '20 min con cuidadores',
          horarios: ['12:00 PM', '02:30 PM'],
        ),
      ],
    );
  }

  Widget _buildTarjetaShowFacil({
    required String titulo,
    required String lugar,
    required String imagen,
    required String duracion,
    required List<String> horarios,
  }) {
    final horarioSeleccionado = _showHorariosSeleccionados[titulo];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: horarioSeleccionado != null ? const Color(0xFF2E7D32) : Colors.black12,
          width: horarioSeleccionado != null ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: horarioSeleccionado != null
                ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              imagen,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.urbanist(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textoOscuro,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: AppColors.verdePrincipal),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        lugar,
                        style: GoogleFonts.urbanist(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textoGris,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: AppColors.textoGris),
                    const SizedBox(width: 4),
                    Text(
                      duracion,
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textoGris,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Toque un horario para reservar y guardar su asiento:',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textoOscuro,
                  ),
                ),
                const SizedBox(height: 10),

                // FILA DE HORARIOS CON EFECTO VISUAL DE GUARDADO
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: horarios.map((h) {
                    final estaGuardado = horarioSeleccionado == h;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: estaGuardado
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withValues(alpha: 0.45),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          SoundService.instance.playButtonTap();
                          HapticFeedback.heavyImpact();

                          setState(() {
                            _showHorariosSeleccionados[titulo] = h;
                          });

                          // Disparar notificación del sistema
                          NotificationService.instance.mostrarNotificacion(
                            id: h.hashCode,
                            titulo: '🎟️ Parque de las Leyendas (Modo Fácil)',
                            cuerpo: 'Te registraste a un show a las $h',
                          );

                          // Confirmación por voz
                          AudioGuiaService.instance.reproducir('Asiento guardado para $titulo a las $h. Le avisaremos con tiempo.');
                        },
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            estaGuardado ? Icons.check_circle_rounded : Icons.access_time_rounded,
                            key: ValueKey(estaGuardado),
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        label: Text(
                          estaGuardado ? '$h ✓ Guardado' : h,
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: estaGuardado ? const Color(0xFF1B5E20) : AppColors.verdePrincipal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: estaGuardado ? const Color(0xFF69F0AE) : Colors.transparent,
                              width: estaGuardado ? 2.5 : 0,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // EFECTO ANIMADO INFERIOR: CARTEL DE HORARIO GUARDADO
                if (horarioSeleccionado != null) ...[
                  const SizedBox(height: 14),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.task_alt_rounded, color: Color(0xFF2E7D32), size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '🎉 ¡Asiento confirmado a las $horarioSeleccionado! Le notificaremos antes de comenzar.',
                            style: GoogleFonts.urbanist(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1B5E20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. VISTA AYUDA FÁCIL
  // ===========================================================================
  Widget _buildVistaAyudaFacil() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade300, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.health_and_safety_rounded, color: Color(0xFFC62828), size: 30),
                  const SizedBox(width: 10),
                  Text(
                    'Asistencia Médica',
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFC62828),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Si usted o un familiar no se siente bien, el tópico médico tiene personal listo para atenderlo.',
                style: GoogleFonts.urbanist(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    SoundService.instance.playButtonTap();
                    AudioGuiaService.instance.reproducir('Llamando al tópico médico del parque. Por favor mantenga la calma.');
                  },
                  icon: const Icon(Icons.phone_rounded, color: Colors.white),
                  label: Text(
                    'Llamar al Tópico Central',
                    style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade300, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.support_agent_rounded, color: Color(0xFF1565C0), size: 30),
                  const SizedBox(width: 10),
                  Text(
                    'Orientador del Parque',
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '¿Tiene dudas o necesita una silla de ruedas? Un orientador acudirá a su ubicación.',
                style: GoogleFonts.urbanist(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    SoundService.instance.playButtonTap();
                    AudioGuiaService.instance.reproducir('Un orientador del zoológico ha sido notificado y se acercará a ayudarlo.');
                  },
                  icon: const Icon(Icons.accessibility_new_rounded, color: Colors.white),
                  label: Text(
                    'Solicitar Asistencia / Silla de Ruedas',
                    style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
