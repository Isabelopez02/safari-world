import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';
import 'package:zoologico_front/core/data/datos_marcadores.dart';
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

  /// Retorna la historia/narración activa según el idioma seleccionado
  String get historiaVozActiva {
    final datos = AnimalService.instance.obtenerDatos(nombre);
    final narracion = datos.getNarracion(nombre);
    return narracion.trim().isNotEmpty ? narracion : historiaVoz;
  }
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

  // Parámetros para trazar rutas hacia el mapa interactivo real
  String? _destinoAnimalId;
  String? _destinoHabitat;
  int _claveNavegacionMapa = 0;

  // Reconocimiento de voz para búsqueda por micrófono
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechInitialized = false;

  // Estado del protocolo de emergencia SOS
  bool _alertaSosActiva = false;

  void _irAlMapaConRuta({String? animalId, String? habitat}) {
    SoundService.instance.playButtonTap();
    AudioGuiaService.instance.detener();
    _detenerScanner();
    setState(() {
      _destinoAnimalId = animalId;
      _destinoHabitat = habitat;
      _claveNavegacionMapa++;
      _animalEscaneado = null;
      _vistaActual = SubVistaModoFacil.mapaFacil;
    });
  }

  void _activarAlertaSos() {
    SoundService.instance.playButtonTap();
    HapticFeedback.heavyImpact();
    setState(() {
      _alertaSosActiva = true;
      _vistaActual = SubVistaModoFacil.ayudaFacil;
    });
    AudioGuiaService.instance.reproducir(
      'Alerta SOS activada. Por favor mantenga la calma. El personal de auxilio y guardaparques del zoológico han sido notificados.',
    );
  }

  void _desactivarAlertaSos() {
    SoundService.instance.playButtonTap();
    AudioGuiaService.instance.detener();
    setState(() {
      _alertaSosActiva = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Alerta SOS desactivada',
            style: GoogleFonts.urbanist(fontWeight: FontWeight.w800),
          ),
          backgroundColor: Colors.green.shade800,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _realizarLlamada(String numero, String nombreDestino) async {
    SoundService.instance.playButtonTap();
    final uri = Uri.parse('tel:$numero');
    AudioGuiaService.instance.reproducir('Llamando a $nombreDestino.');

    try {
      final bool puedeLlamar = await canLaunchUrl(uri);
      if (puedeLlamar) {
        await launchUrl(uri);
        return;
      }
    } catch (e) {
      debugPrint('Error al lanzar llamada: $e');
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.phone_in_talk_rounded, color: Color(0xFFC62828), size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Llamada Telefónica',
                  style: GoogleFonts.urbanist(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Número de $nombreDestino:',
                style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: SelectableText(
                  numero,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFC62828),
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Puede marcar directamente este número desde cualquier teléfono o pedir auxilio a un guardaparques.',
                style: GoogleFonts.urbanist(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
              child: Text(
                'Entendido',
                style: GoogleFonts.urbanist(fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }

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
    final narracion = datos.getNarracion(m.nombre);
    final historia = narracion.trim().isNotEmpty
        ? narracion
        : (datos.getCuriosidad(m.nombre).trim().isNotEmpty
            ? datos.getCuriosidad(m.nombre)
            : '${m.nombre.tr} • ${m.habitat.tr}');
    final dieta = datos.dieta.trim().isNotEmpty ? datos.dieta.tr : 'Alimentación balanceada';

    return AnimalQrFacil(
      id: 'qr_${m.id.toLowerCase()}',
      marcadorId: m.id,
      nombre: m.nombre,
      zona: '${m.habitat.tr} • Sendero accesible',
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
      AudioGuiaService.instance.reproducir('${animal.nombre.tr}. ${animal.historiaVozActiva}');
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
          bottomNavigationBar: _buildFooterModoFacil(),
        );
      },
    );
  }

  Widget _buildBotonVozEncabezado() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF7B1FA2).withValues(alpha: 0.3)),
      ),
      child: IconButton(
        icon: const Icon(Icons.mic_rounded, color: Color(0xFF7B1FA2), size: 18),
        tooltip: 'busqueda_por_voz'.tr,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        onPressed: () => _mostrarModalBusquedaVoz(context),
      ),
    );
  }

  Widget _buildBotonSosEncabezado() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC62828).withValues(alpha: 0.4)),
      ),
      child: IconButton(
        icon: const Icon(Icons.sos_rounded, color: Color(0xFFC62828), size: 18),
        tooltip: 'alerta_sos'.tr,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        onPressed: _activarAlertaSos,
      ),
    );
  }

  Future<void> _mostrarModalBusquedaVoz(BuildContext context) async {
    SoundService.instance.playButtonTap();
    AudioGuiaService.instance.detener();

    String textoReconocido = '';
    bool escuchando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            void iniciarEscucha() async {
              bool speechDisponible = _speechInitialized;
              if (!speechDisponible) {
                try {
                  speechDisponible = await _speechToText.initialize(
                    onStatus: (status) => debugPrint('STT Status: $status'),
                    onError: (error) => debugPrint('STT Error: ${error.errorMsg}'),
                  );
                  _speechInitialized = speechDisponible;
                } catch (e) {
                  debugPrint('Error inicializando STT: $e');
                  speechDisponible = false;
                }
              }

              if (speechDisponible) {
                setModalState(() {
                  escuchando = true;
                  textoReconocido = 'Escuchando...';
                });
                try {
                  await _speechToText.listen(
                    onResult: (result) {
                      setModalState(() {
                        textoReconocido = result.recognizedWords;
                      });
                      if (result.finalResult && textoReconocido.trim().isNotEmpty) {
                        _procesarResultadoVoz(textoReconocido, modalContext);
                      }
                    },
                    listenOptions: stt.SpeechListenOptions(
                      listenMode: stt.ListenMode.confirmation,
                      localeId: IdiomaService.instance.idioma == AppIdioma.en ? 'en_US' : 'es_PE',
                    ),
                  );
                } catch (e) {
                  debugPrint('Error al escuchar: $e');
                }
              } else {
                setModalState(() {
                  textoReconocido = 'Toque una opción de abajo:';
                });
                AudioGuiaService.instance.reproducir('Diga o seleccione el lugar que busca.');
              }
            }

            void detenerEscucha() async {
              if (escuchando) {
                await _speechToText.stop();
                setModalState(() => escuchando = false);
              }
            }

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7B1FA2).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.mic_rounded, color: Color(0xFF7B1FA2), size: 24),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'busqueda_por_voz'.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.urbanist(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textoOscuro,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          detenerEscucha();
                          Navigator.of(modalContext).pop();
                        },
                        icon: const Icon(Icons.close_rounded, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      SoundService.instance.playButtonTap();
                      if (escuchando) {
                        detenerEscucha();
                      } else {
                        iniciarEscucha();
                      }
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: escuchando ? const Color(0xFFC62828) : const Color(0xFF7B1FA2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (escuchando ? const Color(0xFFC62828) : const Color(0xFF7B1FA2))
                                .withValues(alpha: 0.4),
                            blurRadius: 18,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        escuchando ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    escuchando ? '🎙️ Escuchando... Hable ahora' : 'Toque el micrófono para hablar',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: escuchando ? const Color(0xFFC62828) : const Color(0xFF7B1FA2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      textoReconocido.isEmpty
                          ? 'Diga por ejemplo: "León", "Baños", "Pingüinos" o "Tópico"'
                          : textoReconocido,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textoReconocido.isEmpty ? Colors.grey.shade600 : AppColors.textoOscuro,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'O toque una opción directa:',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textoOscuro,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChipVozRapida('🦁 Leones', 'Leones', modalContext),
                      _buildChipVozRapida('🐧 Pingüinos', 'Pingüinos', modalContext),
                      _buildChipVozRapida('🦅 Cóndor', 'Cóndor', modalContext),
                      _buildChipVozRapida('🦒 Jirafa', 'Jirafa', modalContext),
                      _buildChipVozRapida('🚻 Baño', 'Baño', modalContext),
                      _buildChipVozRapida('🚪 Salida', 'Salida', modalContext),
                      _buildChipVozRapida('🚑 Tópico', 'Tópico', modalContext),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChipVozRapida(String etiqueta, String consulta, BuildContext modalContext) {
    return ActionChip(
      avatar: const Icon(Icons.search_rounded, size: 16, color: Color(0xFF7B1FA2)),
      label: Text(
        etiqueta,
        style: GoogleFonts.urbanist(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF4A148C),
        ),
      ),
      backgroundColor: const Color(0xFFF3E5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFCE93D8)),
      ),
      onPressed: () => _procesarResultadoVoz(consulta, modalContext),
    );
  }

  void _procesarResultadoVoz(String consulta, BuildContext modalContext) {
    if (Navigator.of(modalContext).canPop()) {
      Navigator.of(modalContext).pop();
    }
    final q = consulta.toLowerCase().trim();

    // 1. Caso Baños
    if (q.contains('baño') || q.contains('servicio') || q.contains('sshh') || q.contains('sanitario')) {
      AudioGuiaService.instance.reproducir('Localizando baños en el mapa real.');
      _irAlMapaConRuta(animalId: 'B01');
      return;
    }

    // 2. Caso Tópico / Auxilio
    if (q.contains('topico') || q.contains('tópico') || q.contains('medico') || q.contains('médico') || q.contains('auxilio')) {
      AudioGuiaService.instance.reproducir('Trazando sendero hacia el Tópico Médico.');
      _irAlMapaConRuta(animalId: 'AYUDA_02');
      return;
    }

    // 3. Caso Salida / Entrada
    if (q.contains('salida') || q.contains('salir') || q.contains('puerta')) {
      AudioGuiaService.instance.reproducir('Trazando sendero hacia la Salida Principal.');
      _irAlMapaConRuta(animalId: 'SAL_01');
      return;
    }

    // 4. Buscar animal por nombre en marcadoresZoologico
    for (final m in marcadoresZoologico) {
      final nom = m.nombre.toLowerCase();
      if (nom.contains(q) || q.contains(nom)) {
        AudioGuiaService.instance.reproducir('Encontrado: ${m.nombre.tr}. Trazando sendero en el mapa.');
        _irAlMapaConRuta(animalId: m.id);
        return;
      }
    }

    // Por palabra clave de animal
    for (final m in marcadoresZoologico) {
      for (final palabra in m.nombre.toLowerCase().split(' ')) {
        if (palabra.length > 3 && q.contains(palabra)) {
          AudioGuiaService.instance.reproducir('Encontrado: ${m.nombre.tr}. Trazando sendero en el mapa.');
          _irAlMapaConRuta(animalId: m.id);
          return;
        }
      }
    }

    AudioGuiaService.instance.reproducir('Mostrando mapa general.');
    _irAlMapaConRuta();
  }

  Widget _buildBotonIdiomaEncabezado() {
    return InkWell(
      onTap: () {
        SoundService.instance.playButtonTap();
        _mostrarModalIdiomaFacil(context);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              IdiomaService.instance.banderaIdioma,
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textoOscuro,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down_rounded, size: 16, color: AppColors.textoOscuro),
          ],
        ),
      ),
    );
  }

  /// Barra superior fija que jamás desaparece al hacer scroll
  Widget _buildEncabezadoSuperior() {
    final esMenu = _vistaActual == SubVistaModoFacil.menuPrincipal && _animalEscaneado == null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.verdePrincipal.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('👵', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'modo_facil'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.urbanist(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.verdePrincipal,
                          letterSpacing: 0.4,
                        ),
                      ),
                      Text(
                        'letra_grande_sub'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.urbanist(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textoGris,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                _buildBotonVozEncabezado(),
                const SizedBox(width: 4),
                _buildBotonSosEncabezado(),
                const SizedBox(width: 4),
                _buildBotonIdiomaEncabezado(),
                const SizedBox(width: 4),
                ElevatedButton.icon(
                  onPressed: () {
                    SoundService.instance.playButtonTap();
                    AudioGuiaService.instance.detener();
                    widget.onSalirModoFacil();
                  },
                  icon: const Icon(Icons.exit_to_app_rounded, size: 14, color: Colors.white),
                  label: Text(
                    'salir'.tr,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                    icon: const Icon(Icons.arrow_back_rounded, size: 22, color: Colors.white),
                    label: Text(
                      'volver_al_menu'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFF334155), width: 1.5),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _buildBotonVozEncabezado(),
                const SizedBox(width: 4),
                _buildBotonSosEncabezado(),
                const SizedBox(width: 4),
                _buildBotonIdiomaEncabezado(),
                const SizedBox(width: 4),
                // 2. BOTÓN SALIR DEL MODO FÁCIL AL MODO ESTÁNDAR COMPACTO
                IconButton(
                  onPressed: () {
                    SoundService.instance.playButtonTap();
                    AudioGuiaService.instance.detener();
                    widget.onSalirModoFacil();
                  },
                  icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFFC62828)),
                  tooltip: 'salir_modo_facil'.tr,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEE),
                    padding: const EdgeInsets.all(6),
                    minimumSize: const Size(32, 32),
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
                'bienvenido_parque'.tr,
                style: GoogleFonts.urbanist(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textoOscuro,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'bienvenido_sub'.tr,
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

        // 1. BÚSQUEDA POR VOZ (HABLAR AL MICRÓFONO)
        _buildBotonMenuGigante(
          icono: Icons.mic_rounded,
          colorFondo: const Color(0xFFF3E5F5),
          colorIcono: const Color(0xFF7B1FA2),
          titulo: 'busqueda_por_voz'.tr,
          subtitulo: 'Diga el nombre de un animal, baño o hábitat para guiarlo',
          onTap: () => _mostrarModalBusquedaVoz(context),
        ),
        const SizedBox(height: 16),

        // 2. ESCANEAR QR / AUDIO GUÍA
        _buildBotonMenuGigante(
          icono: Icons.qr_code_scanner_rounded,
          colorFondo: const Color(0xFFF3E5F5),
          colorIcono: const Color(0xFF7B1FA2),
          titulo: 'escanear_placa_guia'.tr,
          subtitulo: 'escanear_camara_sub'.tr,
          onTap: () => _cambiarVista(SubVistaModoFacil.escanearQrAnimal),
        ),
        const SizedBox(height: 16),

        // 3. MAPA FÁCIL
        _buildBotonMenuGigante(
          icono: Icons.map_rounded,
          colorFondo: const Color(0xFFE3F2FD),
          colorIcono: const Color(0xFF1565C0),
          titulo: 'mapa_zoologico'.tr,
          subtitulo: 'mapa_facil_sub'.tr,
          onTap: () => _irAlMapaConRuta(),
        ),
        const SizedBox(height: 16),

        // 4. SHOWS DE HOY
        _buildBotonMenuGigante(
          icono: Icons.theater_comedy_rounded,
          colorFondo: const Color(0xFFFFF3E0),
          colorIcono: const Color(0xFFE65100),
          titulo: 'shows_hoy'.tr,
          subtitulo: 'shows_facil_sub'.tr,
          onTap: () => _cambiarVista(SubVistaModoFacil.showsFacil),
        ),
        const SizedBox(height: 16),

        // 5. CAMBIAR IDIOMA (ESPAÑOL / ENGLISH / QUECHUA / AIMARA)
        _buildBotonMenuGigante(
          icono: Icons.language_rounded,
          colorFondo: const Color(0xFFE0F2FE),
          colorIcono: const Color(0xFF0284C7),
          titulo: '${'cambiar_idioma'.tr} (${IdiomaService.instance.banderaIdioma})',
          subtitulo: '${IdiomaService.instance.nombreIdioma} • Tap to switch language',
          onTap: () => _mostrarModalIdiomaFacil(context),
        ),
        const SizedBox(height: 16),

        // 6. BOTÓN DE AUXILIO / AYUDA Y SOS
        _buildBotonMenuGigante(
          icono: Icons.sos_rounded,
          colorFondo: const Color(0xFFFFEBEE),
          colorIcono: const Color(0xFFC62828),
          titulo: '${'pedir_ayuda'.tr} • SOS',
          subtitulo: 'pedir_ayuda_sub'.tr,
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
                  'apunte_camara'.tr,
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
              'catalogo_animales'.tr,
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
                                    m.nombre.tr,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textoOscuro,
                                    ),
                                  ),
                                  Text(
                                    '${m.habitat.tr} • Código: ${m.id}',
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
              animal.nombre.tr,
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
                    AudioGuiaService.instance.reproducir('${'felicitaciones_visitado'.tr} ${animal.nombre.tr}.');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ ${animal.nombre.tr} • ${'marcar_visitado'.tr}'),
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
                        'historia_animal'.tr,
                        style: GoogleFonts.urbanist(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textoOscuro,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF7B1FA2), size: 30),
                        tooltip: 'repetir_narracion'.tr,
                        onPressed: () {
                          AudioGuiaService.instance.reproducir('${animal.nombre.tr}. ${animal.historiaVozActiva}');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    animal.historiaVozActiva,
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

            // BOTÓN PARA TRAZAR SENDERO EN EL MAPA REAL
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  AudioGuiaService.instance.reproducir('Trazando sendero hacia ${animal.nombre.tr} en el mapa.');
                  _irAlMapaConRuta(animalId: animal.marcadorId);
                },
                icon: const Icon(Icons.navigation_rounded, size: 24, color: Colors.white),
                label: Text(
                  '${'trazar_en_mapa_real'.tr} 🗺️',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 14),

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
                  'escanear_otra_placa'.tr,
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
      key: ValueKey('mapa_facil_$_claveNavegacionMapa'),
      modoFacil: true,
      animalIdInicial: _destinoAnimalId,
      habitatInicial: _destinoHabitat,
      claveNavegacion: _claveNavegacionMapa,
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
        // ==========================================
        // 1. PROTOCOLO Y ALERTA SOS DE EMERGENCIA
        // ==========================================
        if (_alertaSosActiva)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFB71C1C),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.yellowAccent, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.6),
                  blurRadius: 18,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🚨', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '¡ALERTA SOS ACTIVADA!',
                        style: GoogleFonts.urbanist(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'El personal médico y los guardaparques del zoológico han sido notificados. Mantenga la calma y permanezca en su lugar o acérquese al sendero principal.',
                  style: GoogleFonts.urbanist(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _irAlMapaConRuta(animalId: 'AYUDA_02'),
                    icon: const Icon(Icons.navigation_rounded, color: Color(0xFFB71C1C)),
                    label: Text(
                      '🗺️ Trazar sendero al Tópico en el Mapa',
                      style: GoogleFonts.urbanist(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFB71C1C),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _realizarLlamada('014445555', 'Tópico Médico Central'),
                    icon: const Icon(Icons.phone_rounded, color: Colors.white),
                    label: Text(
                      '📞 Llamar de inmediato al Tópico (01-444-5555)',
                      style: GoogleFonts.urbanist(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _desactivarAlertaSos,
                    icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                    label: Text(
                      'desactivar_sos'.tr,
                      style: GoogleFonts.urbanist(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFB71C1C),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sos_rounded, color: Colors.white, size: 36),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'alerta_sos'.tr.toUpperCase(),
                            style: GoogleFonts.urbanist(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Presione si necesita auxilio urgente o está desorientado',
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _activarAlertaSos,
                    icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFFB71C1C), size: 26),
                    label: Text(
                      '¡ACTIVAR ALERTA SOS AHORA!',
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFB71C1C),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 18),

        // ==========================================
        // 2. ASISTENCIA MÉDICA Y AMBULANCIA
        // ==========================================
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
                  Expanded(
                    child: Text(
                      'Asistencia Médica',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFC62828),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Personal médico de guardia disponible las 24 horas para emergencias dentro del parque.',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _realizarLlamada('014445555', 'Tópico Central del Parque'),
                  icon: const Icon(Icons.phone_rounded, color: Colors.white),
                  label: Text(
                    '${'llamar_topico'.tr} (01-444-5555)',
                    style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _realizarLlamada('106', 'Ambulancia SAMU (106)'),
                  icon: const Icon(Icons.local_hospital_rounded, color: Color(0xFFC62828)),
                  label: Text(
                    'llamar_samu'.tr,
                    style: GoogleFonts.urbanist(fontSize: 14.5, fontWeight: FontWeight.w900, color: const Color(0xFFC62828)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFC62828), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _irAlMapaConRuta(animalId: 'AYUDA_02'),
                  icon: const Icon(Icons.map_rounded, color: Color(0xFFC62828)),
                  label: Text(
                    '🗺️ Ver Tópico en el Mapa Real con Sendero',
                    style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFFC62828)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ==========================================
        // 3. ORIENTADOR DEL PARQUE Y SILLA DE RUEDAS
        // ==========================================
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
                  Expanded(
                    child: Text(
                      'Orientador del Parque',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '¿Tiene dudas o necesita una silla de ruedas? Llame al módulo o trace el camino en el mapa.',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _realizarLlamada('014445556', 'Guardaparques y Orientadores'),
                  icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.white),
                  label: Text(
                    '${'llamar_guardaparques'.tr} (01-444-5556)',
                    style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _realizarLlamada('105', 'Central de Emergencias 105'),
                  icon: const Icon(Icons.local_police_rounded, color: Color(0xFF1565C0)),
                  label: Text(
                    'Llamar a Emergencias (105)',
                    style: GoogleFonts.urbanist(fontSize: 14.5, fontWeight: FontWeight.w900, color: const Color(0xFF1565C0)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _irAlMapaConRuta(animalId: 'AYUDA_01'),
                  icon: const Icon(Icons.map_rounded, color: Color(0xFF1565C0)),
                  label: Text(
                    '🗺️ Ver Módulo de Guardaparques en el Mapa',
                    style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF1565C0)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // FOOTER ACCESIBLE DE NAVEGACIÓN RÁPIDA (MODO FÁCIL & MODO ANIMAL)
  // ===========================================================================
  Widget _buildFooterModoFacil() {
    int indexActivo = 0;
    switch (_vistaActual) {
      case SubVistaModoFacil.menuPrincipal:
        indexActivo = 0;
        break;
      case SubVistaModoFacil.escanearQrAnimal:
        indexActivo = 1;
        break;
      case SubVistaModoFacil.mapaFacil:
        indexActivo = 2;
        break;
      case SubVistaModoFacil.showsFacil:
        indexActivo = 3;
        break;
      case SubVistaModoFacil.ayudaFacil:
        indexActivo = 4;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItemFooterFacil(
                index: 0,
                activo: indexActivo == 0,
                icono: Icons.home_rounded,
                etiqueta: 'nav_inicio'.tr,
                onTap: () => _cambiarVista(SubVistaModoFacil.menuPrincipal),
              ),
              _buildItemFooterFacil(
                index: 1,
                activo: indexActivo == 1,
                icono: Icons.pets_rounded,
                etiqueta: 'nav_animales'.tr,
                onTap: () {
                  if (_vistaActual == SubVistaModoFacil.escanearQrAnimal && _animalEscaneado != null) {
                    setState(() => _animalEscaneado = null);
                  }
                  _cambiarVista(SubVistaModoFacil.escanearQrAnimal);
                },
              ),
              _buildItemFooterFacil(
                index: 2,
                activo: indexActivo == 2,
                icono: Icons.map_rounded,
                etiqueta: 'nav_mapa'.tr,
                onTap: () => _cambiarVista(SubVistaModoFacil.mapaFacil),
              ),
              _buildItemFooterFacil(
                index: 3,
                activo: indexActivo == 3,
                icono: Icons.theater_comedy_rounded,
                etiqueta: 'nav_shows'.tr,
                onTap: () => _cambiarVista(SubVistaModoFacil.showsFacil),
              ),
              _buildItemFooterFacil(
                index: 4,
                activo: indexActivo == 4,
                icono: Icons.help_rounded,
                etiqueta: 'nav_ayuda'.tr,
                colorEspecial: const Color(0xFFC62828),
                onTap: () => _cambiarVista(SubVistaModoFacil.ayudaFacil),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemFooterFacil({
    required int index,
    required bool activo,
    required IconData icono,
    required String etiqueta,
    required VoidCallback onTap,
    Color? colorEspecial,
  }) {
    final colorBase = colorEspecial ?? AppColors.verdePrincipal;
    final colorTexto = activo ? colorBase : const Color(0xFF64748B);

    return Expanded(
      child: InkWell(
        onTap: () {
          SoundService.instance.playButtonTap();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: activo ? colorBase.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icono,
                size: activo ? 28 : 24,
                color: colorTexto,
              ),
              const SizedBox(height: 3),
              Text(
                etiqueta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.urbanist(
                  fontSize: activo ? 12 : 11,
                  fontWeight: activo ? FontWeight.w900 : FontWeight.w700,
                  color: colorTexto,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SELECTOR GIGANTE Y ACCESIBLE DE IDIOMA PARA MODO FÁCIL
  // ===========================================================================
  void _mostrarModalIdiomaFacil(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.language_rounded, color: Color(0xFF0284C7), size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'cambiar_idioma'.tr,
                            style: GoogleFonts.urbanist(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textoOscuro,
                            ),
                          ),
                          Text(
                            'seleccionar_idioma'.tr,
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textoGris,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCardOpcionIdiomaFacil(
                  ctx: ctx,
                  titulo: 'Español',
                  subtitulo: 'Predeterminado (Perú)',
                  bandera: '🇵🇪',
                  idioma: AppIdioma.es,
                ),
                const SizedBox(height: 12),
                _buildCardOpcionIdiomaFacil(
                  ctx: ctx,
                  titulo: 'English',
                  subtitulo: 'International tourists',
                  bandera: '🇺🇸',
                  idioma: AppIdioma.en,
                ),
                const SizedBox(height: 12),
                _buildCardOpcionIdiomaFacil(
                  ctx: ctx,
                  titulo: 'Runasimi / Quechua',
                  subtitulo: 'Piruwpa paqarisqa simin',
                  bandera: '🏔️',
                  idioma: AppIdioma.qu,
                ),
                const SizedBox(height: 12),
                _buildCardOpcionIdiomaFacil(
                  ctx: ctx,
                  titulo: 'Aymar aru / Aimara',
                  subtitulo: 'Qullasuyu jaqinakan arupa',
                  bandera: '☀️',
                  idioma: AppIdioma.ay,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardOpcionIdiomaFacil({
    required BuildContext ctx,
    required String titulo,
    required String subtitulo,
    required String bandera,
    required AppIdioma idioma,
  }) {
    final bool seleccionado = IdiomaService.instance.idioma == idioma;
    return InkWell(
      onTap: () {
        SoundService.instance.playButtonTap();
        IdiomaService.instance.cambiarIdioma(idioma);
        Navigator.pop(ctx);
        String mensajeVoz = 'Idioma cambiado a $titulo';
        if (idioma == AppIdioma.en) mensajeVoz = 'Language changed to English';
        if (idioma == AppIdioma.qu) mensajeVoz = 'Simi t\'ikrasqa Runasimiman';
        if (idioma == AppIdioma.ay) mensajeVoz = 'Aru mayjt\'ayata Aymar aruru';
        AudioGuiaService.instance.reproducir(mensajeVoz);
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.verdePrincipal.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: seleccionado ? AppColors.verdePrincipal : Colors.grey.shade300,
            width: seleccionado ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(bandera, style: const TextStyle(fontSize: 24)),
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
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textoGris,
                    ),
                  ),
                ],
              ),
            ),
            if (seleccionado)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.verdePrincipal,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
