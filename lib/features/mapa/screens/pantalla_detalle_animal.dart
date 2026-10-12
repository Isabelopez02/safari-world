import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/models/datos_animal.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

class PantallaDetalleAnimal extends StatefulWidget {
  final MarcadorMapa animal;
  const PantallaDetalleAnimal({super.key, required this.animal});

  @override
  State<PantallaDetalleAnimal> createState() => _PantallaDetalleAnimalState();
}

class _PantallaDetalleAnimalState extends State<PantallaDetalleAnimal>
    with SingleTickerProviderStateMixin {
  bool _isPlayingAudio = false;
  late AnimationController _audioWaveController;

  @override
  void initState() {
    super.initState();
    _audioWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _audioWaveController.dispose();
    super.dispose();
  }

  void _toggleAudioguia(DatosAnimal datos) {
    SoundService.instance.playButtonTap();
    setState(() {
      _isPlayingAudio = !_isPlayingAudio;
      if (_isPlayingAudio) {
        _audioWaveController.repeat(reverse: true);
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
                const Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Reproduciendo audioguÃ­a de ${widget.animal.nombre}',
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        _audioWaveController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final datos = AnimalService.instance.obtenerDatos(widget.animal.nombre);
    final esVisitado = AnimalService.instance.esVisitado(widget.animal.id);
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. FONDO HERO SUPERIOR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenH * 0.46,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/pantalla_principal/hero_fondo.png',
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.65),
                        Colors.black.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. BARRA SUPERIOR (BOTÃ“N REGRESAR + BOTÃ“N AUDIOGUÃA)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // BotÃ³n Regresar
                    GestureDetector(
                      onTap: () {
                        SoundService.instance.playButtonTap();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),

                    // BOTÃ“N AUDIOGUÃA INTERACTIVA
                    GestureDetector(
                      onTap: () => _toggleAudioguia(datos),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _isPlayingAudio
                              ? const Color(0xFFFF9800)
                              : Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _isPlayingAudio
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            if (_isPlayingAudio)
                              BoxShadow(
                                color: const Color(0xFFFF9800)
                                    .withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isPlayingAudio
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isPlayingAudio
                                  ? 'Pausar audio'
                                  : 'Escuchar audioguÃ­a',
                              style: GoogleFonts.urbanist(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. IMAGEN DEL ANIMAL PROTAGONISTA: ENCIMA Y MÃS GRANDE (215x215 dp)
          Positioned(
            top: 75,
            left: 0,
            right: 0,
            child: Center(
              child: Hero(
                tag: 'animal_icon_${widget.animal.id}',
                child: Container(
                  width: 215,
                  height: 215,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.verdeAzulado,
                      width: 4.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: AppColors.verdeAzulado.withValues(alpha: 0.25),
                        blurRadius: 16,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: widget.animal.imagen != null
                        ? Image.asset(widget.animal.imagen!, fit: BoxFit.cover)
                        : Icon(
                            widget.animal.icono,
                            size: 110,
                            color: AppColors.verdeAzulado,
                          ),
                  ),
                ),
              ),
            ),
          ),

          // 4. TARJETA BLANCA DE CONTENIDO INFERIOR SCROLLEABLE
          Positioned(
            top: screenH * 0.38,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 18,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: 26,
                  left: 24,
                  right: 24,
                  bottom: 36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar tipo Apple
                    Center(
                      child: Container(
                        width: 40,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // TÃTULO Y CÃ“DIGO DEL ANIMAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.animal.nombre,
                                style: GoogleFonts.urbanist(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textoOscuro,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                datos.nombreCientifico,
                                style: GoogleFonts.urbanist(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.verdePrincipal,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.verdeAzulado.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Zona #${widget.animal.id}',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.verdeAzulado,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // REPRODUCTOR DE AUDIOGUÃA EXPANDIBLE
                    if (_isPlayingAudio)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFFB74D),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.graphic_eq_rounded,
                                  color: Color(0xFFE65100),
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Voz oficial del GuÃ­a Zoo',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFE65100),
                                  ),
                                ),
                                const Spacer(),
                                AnimatedBuilder(
                                  animation: _audioWaveController,
                                  builder: (context, child) {
                                    return Row(
                                      children: List.generate(4, (index) {
                                        final h =
                                            6.0 +
                                            (14.0 *
                                                ((_audioWaveController.value +
                                                        (index * 0.25)) %
                                                    1.0));
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            left: 3,
                                          ),
                                          width: 3.5,
                                          height: h,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE65100),
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        );
                                      }),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              datos.narracionAudioguia,
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                color: Colors.brown.shade800,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // BADGES DE ESTADO (DIETA, HÃBITAT, CONSERVACIÃ“N)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(
                          icon: Icons.restaurant_rounded,
                          label: datos.dieta,
                          color: AppColors.verdePrincipal,
                        ),
                        _buildBadge(
                          icon: Icons.terrain_rounded,
                          label: datos.habitat,
                          color: AppColors.verdeAzulado,
                        ),
                        _buildBadge(
                          icon: Icons.shield_rounded,
                          label: datos.estadoConservacion,
                          color: const Color(0xFFE65100),
                        ),
                        _buildBadge(
                          icon: esVisitado
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          label: esVisitado ? '✓ Visitado' : 'Por visitar',
                          color: esVisitado
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade600,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // BOTÓN INTERACTIVO DE REGISTRO DE VISITA
                    _buildTarjetaRegistroVisita(esVisitado),

                    const SizedBox(height: 24),

                    // HORARIO DE ACTIVIDAD Y VISITAS
                    _sectionTitle(
                      'Horario de visita & comidas',
                      Icons.schedule_rounded,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.verdeAzulado.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.verdeAzulado.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _scheduleItem(
                            'Apertura',
                            datos.horaApertura,
                            Icons.wb_sunny_rounded,
                            Colors.orange,
                          ),
                          Container(
                            height: 38,
                            width: 1,
                            color: Colors.grey.withValues(alpha: 0.25),
                          ),
                          _scheduleItem(
                            'Cierre',
                            datos.horaCierre,
                            Icons.nights_stay_rounded,
                            AppColors.verdeAzulado,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ALIMENTACIÃ“N DETALLADA
                    _sectionTitle(
                      'Â¿QuÃ© come?',
                      Icons.restaurant_menu_rounded,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: datos.alimentos.map((a) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.22),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            a,
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textoOscuro,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 26),

                    // COMPORTAMIENTO Y HÃBITOS
                    _sectionTitle(
                      'Comportamiento y vida social',
                      Icons.psychology_rounded,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      datos.comportamiento,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // CURIOSIDAD FASCINANTE "Â¿SABÃAS QUE?"
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8F5),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.verdePrincipal.withValues(
                            alpha: 0.18,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ðŸ’¡', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Â¿SabÃ­as que?',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.verdePrincipal,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  datos.curiosidad,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 13.5,
                                    color: Colors.grey[800],
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.verdePrincipal),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.urbanist(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: AppColors.textoOscuro,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleItem(String label, String time, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.urbanist(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: AppColors.textoOscuro,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTarjetaRegistroVisita(bool esVisitado) {
    return GestureDetector(
      onTap: () async {
        SoundService.instance.playButtonTap();
        final nuevoEstado = await AnimalService.instance.toggleVisitado(
          widget.animal.id,
        );
        setState(() {});

        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: nuevoEstado
                ? const Color(0xFF2E7D32)
                : Colors.grey.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Row(
              children: [
                Icon(
                  nuevoEstado
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    nuevoEstado
                        ? '¡Genial! Has marcado a ${widget.animal.nombre} como visitado 🎉'
                        : '${widget.animal.nombre} desmarcado de visitados',
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: esVisitado ? const Color(0xFFE8F5E9) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: esVisitado
                ? const Color(0xFF4CAF50).withValues(alpha: 0.6)
                : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: esVisitado
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: esVisitado
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: Icon(
                esVisitado ? Icons.check_rounded : Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    esVisitado
                        ? '¡Animal Registrado como Visitado!'
                        : '¿Ya visitaste a este animal?',
                    style: GoogleFonts.urbanist(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: esVisitado
                          ? const Color(0xFF1B5E20)
                          : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    esVisitado
                        ? 'Toca aquí para desmarcarlo de tus exploraciones'
                        : 'Toca para registrar tu visita y sumar a tu progreso',
                    style: GoogleFonts.urbanist(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: esVisitado
                          ? const Color(0xFF2E7D32)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              esVisitado
                  ? Icons.task_alt_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: esVisitado
                  ? const Color(0xFF2E7D32)
                  : Colors.grey.shade400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
