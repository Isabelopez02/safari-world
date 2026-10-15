import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/audioguia_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_mapa.dart';

/// Detalle de la exhibición educativa de lobos marinos de Huachipa.
/// Diseño minimalista, elegante y humano inspirado en guías de aventura natural,
/// con paleta safari, tipografía Urbanist, horarios limpios y audioguía con voz real.
class PantallaDetalleShowAcuatico extends StatefulWidget {
  const PantallaDetalleShowAcuatico({super.key});

  @override
  State<PantallaDetalleShowAcuatico> createState() =>
      _PantallaDetalleShowAcuaticoState();
}

class _PantallaDetalleShowAcuaticoState
    extends State<PantallaDetalleShowAcuatico> {
  int _horarioSeleccionado = 0;
  bool _recordatorioGuardado = false;

  static const String _narracionShow =
      'Conoce a Nayra, Sol y Luna en la exhibición educativa de lobos marinos de Huachipa. '
      'El parque comparte sus historias de rescate y rehabilitación y explica la importancia de proteger '
      'los ecosistemas marinos. La actividad se realiza en el anfiteatro y tiene aforo limitado.';

  final List<Map<String, dynamic>> _horarios = [
    {
      'hora': '12:00 m.',
      'tipo': 'Sábados, domingos y feriados',
      'icono': Icons.wb_sunny_outlined,
    },
    {
      'hora': '3:00 p. m.',
      'tipo': 'Sábados, domingos y feriados',
      'icono': Icons.wb_twilight_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    AudioGuiaService.instance.addListener(_onAudioStateChanged);
  }

  @override
  void dispose() {
    AudioGuiaService.instance.removeListener(_onAudioStateChanged);
    AudioGuiaService.instance.detener();
    super.dispose();
  }

  void _onAudioStateChanged() {
    if (mounted) setState(() {});
  }

  void _toggleAudioShow() {
    SoundService.instance.playButtonTap();
    AudioGuiaService.instance.toggleHablar(_narracionShow);
  }

  void _toggleRecordatorio() {
    SoundService.instance.playButtonTap();
    setState(() => _recordatorioGuardado = !_recordatorioGuardado);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.verdePrincipal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Icon(
              _recordatorioGuardado
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _recordatorioGuardado
                    ? 'Recordatorio fijado para la función de las ${_horarios[_horarioSeleccionado]['hora']}'
                    : 'Recordatorio cancelado',
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = AudioGuiaService.instance.isPlaying;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: Stack(
        children: [
          // CONTENIDO SCROLLEABLE
          Positioned.fill(
            bottom: 85 + MediaQuery.of(context).padding.bottom,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HERO BANNER FOTOGRÁFICO
                  _buildHeroHeader(context),

                  // 2. CUERPO PRINCIPAL CON CONTENIDO MINIMALISTA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),

                        // Título y Badge de Ubicación
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Exhibición de lobos marinos',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textoOscuro,
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: AppColors.verdePrincipal,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Anfiteatro · Sede Huachipa',
                                          style: GoogleFonts.urbanist(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey.shade700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Badge sutil de estado
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFA5D6A7),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                'En Vivo',
                                style: GoogleFonts.urbanist(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Descripción breve y elegante
                        Text(
                          'Descripción',
                          style: GoogleFonts.urbanist(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textoOscuro,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Conoce a Nayra, Sol y Luna, y aprende sobre su rescate, rehabilitación y conservación.',
                          style: GoogleFonts.urbanist(
                            fontSize: 13.5,
                            color: Colors.grey.shade700,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // 3. DETALLES DEL SHOW (GRILLA 2x2 ESTILO CAMP DETAILS)
                        Text(
                          'Detalles del Show',
                          style: GoogleFonts.urbanist(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textoOscuro,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildGridDetalles(),

                        const SizedBox(height: 24),

                        // 4. HORARIOS DE FUNCIONES (SELECTOR MINIMALISTA)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Horarios Disponibles',
                              style: GoogleFonts.urbanist(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textoOscuro,
                              ),
                            ),
                            Text(
                              'Elige tu turno',
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildSelectorHorarios(),

                        const SizedBox(height: 22),

                        // 5. TARJETA DE AUDIOGUÍA CON VOZ REAL
                        _buildAudioguiaCard(isPlaying),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BARRA INFERIOR FIJA CON BOTÓN PRINCIPAL (ESTILO REFERENCIA)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  // HEADER ELEGANTE Y TIERNO CON LA FOCA TRANSPARENTE (SIN FONDO ARTIFICIAL)
  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD), Color(0xFFF0F9FF)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // Círculos y burbujas decorativas suaves en el fondo
          Positioned(
            right: -25,
            top: -20,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
              ),
            ),
          ),

          // Contenido principal
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Barra superior de navegación en el header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          SoundService.instance.playButtonTap();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textoOscuro,
                            size: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🐬', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 5),
                            Text(
                              'Anfiteatro de Huachipa',
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // FOCA 3D TRANSPARENTE TIERNA (REUTILIZADA DE LA TARJETA)
                SizedBox(
                  height: 195,
                  child: Center(
                    child: Image.asset(
                      'assets/images/pantalla_principal/foca.png',
                      height: 195,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.pets,
                        size: 70,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // GRILLA 2x2 ESTILO CAMP DETAILS
  Widget _buildGridDetalles() {
    final detalles = [
      {
        'label': 'DURACIÓN',
        'valor': '35 Minutos',
        'icono': Icons.schedule_rounded,
        'bg': const Color(0xFFFFF3E0),
        'color': const Color(0xFFD97706),
      },
      {
        'label': 'ESPECIES',
        'valor': 'Lobos marinos',
        'icono': Icons.pets_rounded,
        'bg': const Color(0xFFE0F2FE),
        'color': const Color(0xFF0284C7),
      },
      {
        'label': 'UBICACIÓN',
        'valor': 'Anfiteatro Marino',
        'icono': Icons.water_drop_rounded,
        'bg': const Color(0xFFE0F2F1),
        'color': const Color(0xFF00897B),
      },
      {
        'label': 'ACCESO',
        'valor': 'Pase General',
        'icono': Icons.confirmation_number_outlined,
        'bg': const Color(0xFFE8F5E9),
        'color': const Color(0xFF2E7D32),
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: detalles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.3,
      ),
      itemBuilder: (context, index) {
        final d = detalles[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: d['bg'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  d['icono'] as IconData,
                  color: d['color'] as Color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      d['label'] as String,
                      style: GoogleFonts.urbanist(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      d['valor'] as String,
                      style: GoogleFonts.urbanist(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textoOscuro,
                      ),
                      overflow: TextOverflow.ellipsis,
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

  // SELECTOR DE HORARIOS MINIMALISTA
  Widget _buildSelectorHorarios() {
    return Row(
      children: List.generate(_horarios.length, (index) {
        final item = _horarios[index];
        final bool isSelected = _horarioSeleccionado == index;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              SoundService.instance.playButtonTap();
              setState(() => _horarioSeleccionado = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 4,
                right: index == _horarios.length - 1 ? 0 : 4,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.verdePrincipal
                      : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.verdePrincipal.withValues(alpha: 0.15)
                        : Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    item['icono'] as IconData,
                    size: 20,
                    color: isSelected
                        ? AppColors.verdePrincipal
                        : Colors.grey.shade500,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['hora'] as String,
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? AppColors.verdePrincipal
                          : AppColors.textoOscuro,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['tipo'] as String,
                    style: GoogleFonts.urbanist(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.verdePrincipal.withValues(alpha: 0.8)
                          : Colors.grey.shade500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // TARJETA DE AUDIOGUÍA CON VOZ REAL
  Widget _buildAudioguiaCard(bool isPlaying) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPlaying ? AppColors.verdePrincipal : Colors.grey.shade200,
          width: isPlaying ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isPlaying
                  ? AppColors.verdePrincipal
                  : const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.volume_up_rounded : Icons.headphones_rounded,
              color: isPlaying ? Colors.white : AppColors.verdePrincipal,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audioguía del Show',
                  style: GoogleFonts.urbanist(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textoOscuro,
                  ),
                ),
                Text(
                  isPlaying
                      ? 'Narrando en voz alta por el altavoz 🎧'
                      : 'Escucha la historia con voz de biólogos',
                  style: GoogleFonts.urbanist(
                    fontSize: 11.5,
                    color: isPlaying
                        ? AppColors.verdePrincipal
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _toggleAudioShow,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isPlaying
                    ? const Color(0xFFD32F2F)
                    : AppColors.verdePrincipal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isPlaying ? 'Pausar' : 'Escuchar',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BARRA INFERIOR FIJA CON BOTÓN PRINCIPAL Y RECORDATORIO
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // BOTÓN PRINCIPAL ANCHO SAFARI
          Expanded(
            child: GestureDetector(
              onTap: () {
                SoundService.instance.playButtonTap();
                AudioGuiaService.instance.detener();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaMapa(
                      animalIdInicial:
                          'A09', // Dirige al marcador de lobos marinos
                    ),
                  ),
                );
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.verdePrincipal,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.verdePrincipal.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.near_me_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ir a los lobos marinos en el mapa',
                      style: GoogleFonts.urbanist(
                        fontSize: 14.5,
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

          const SizedBox(width: 10),

          // BOTÓN SECUNDARIO DE RECORDATORIO (IGUAL AL ICONO CALENDARIO DE LA FOTO)
          GestureDetector(
            onTap: _toggleRecordatorio,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _recordatorioGuardado
                    ? const Color(0xFFE8F5E9)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _recordatorioGuardado
                      ? AppColors.verdePrincipal
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Icon(
                _recordatorioGuardado
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                color: _recordatorioGuardado
                    ? AppColors.verdePrincipal
                    : Colors.grey.shade700,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
