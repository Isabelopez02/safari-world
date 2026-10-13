import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/models/datos_animal.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Pantalla minimalista de detalle y ficha de campo de cada animal.
/// Diseño compacto, intuitivo y safari explorer que no ocupa espacio excesivo.
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
            backgroundColor: AppColors.verdeAzulado,
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
                    'Reproduciendo audioguía de ${widget.animal.nombre} 🎧',
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
      } else {
        _audioWaveController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final datos = AnimalService.instance.obtenerDatos(widget.animal.nombre);
    final esVisitado = AnimalService.instance.esVisitado(widget.animal.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        child: Column(
          children: [
            // BARRA SUPERIOR MINIMALISTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      SoundService.instance.playButtonTap();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
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
                        size: 17,
                      ),
                    ),
                  ),
                  Text(
                    'Ficha de Explorador 🐾',
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textoOscuro,
                    ),
                  ),
                  // BOTÓN AUDIOGUÍA MINIMALISTA
                  GestureDetector(
                    onTap: () => _toggleAudioguia(datos),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _isPlayingAudio
                            ? const Color(0xFFFF9800)
                            : AppColors.verdeAzulado.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isPlayingAudio
                              ? const Color(0xFFFF9800)
                              : AppColors.verdeAzulado.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isPlayingAudio
                                ? Icons.pause_circle_filled_rounded
                                : Icons.headphones_rounded,
                            color: _isPlayingAudio
                                ? Colors.white
                                : AppColors.verdeAzulado,
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _isPlayingAudio ? 'Pausar' : 'Audioguía',
                            style: GoogleFonts.urbanist(
                              color: _isPlayingAudio
                                  ? Colors.white
                                  : AppColors.verdeAzulado,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // CONTENIDO SCROLLEABLE COMPACTO
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),

                    // TARJETA DE PRESENTACIÓN COMPACTA DEL ANIMAL
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Foto circular compacta (100x100 dp)
                          Hero(
                            tag: 'animal_icon_${widget.animal.id}',
                            child: Container(
                              width: 95,
                              height: 95,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.verdeAzulado,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.verdeAzulado
                                        .withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: widget.animal.imagen != null
                                    ? Image.asset(
                                        widget.animal.imagen!,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        widget.animal.icono,
                                        size: 46,
                                        color: AppColors.verdeAzulado,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Datos principales a la derecha
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.verdeAzulado
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Zona #${widget.animal.id}',
                                        style: GoogleFonts.urbanist(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.verdeAzulado,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: esVisitado
                                            ? const Color(0xFFE8F5E9)
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        esVisitado
                                            ? '✓ Visitado'
                                            : 'Por visitar',
                                        style: GoogleFonts.urbanist(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: esVisitado
                                              ? const Color(0xFF2E7D32)
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.animal.nombre,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textoOscuro,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  datos.nombreCientifico,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.verdePrincipal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  datos.habitat,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // REPRODUCTOR AUDIOGUÍA EXPANDIBLE MINIMALISTA
                    if (_isPlayingAudio) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFB74D),
                            width: 1.2,
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
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Narración Guía Zoo Oficial',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFE65100),
                                  ),
                                ),
                                const Spacer(),
                                AnimatedBuilder(
                                  animation: _audioWaveController,
                                  builder: (context, child) {
                                    return Row(
                                      children: List.generate(4, (i) {
                                        final h = 5.0 +
                                            (11.0 *
                                                ((_audioWaveController.value +
                                                        (i * 0.25)) %
                                                    1.0));
                                        return Container(
                                          margin:
                                              const EdgeInsets.only(left: 3),
                                          width: 3,
                                          height: h,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE65100),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        );
                                      }),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              datos.narracionAudioguia,
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                color: Colors.brown.shade800,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // CHIPS DE ESTADO EN FILA MINIMALISTA
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chipInfo(
                          icon: Icons.restaurant_rounded,
                          label: datos.dieta,
                          color: AppColors.verdePrincipal,
                        ),
                        _chipInfo(
                          icon: Icons.terrain_rounded,
                          label: datos.habitat.split(' ').first,
                          color: AppColors.verdeAzulado,
                        ),
                        _chipInfo(
                          icon: Icons.shield_rounded,
                          label: datos.estadoConservacion,
                          color: const Color(0xFFE65100),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // HORARIOS Y ALIMENTACIÓN (2 COLUMNAS COMPACTAS)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule_rounded,
                                      size: 15,
                                      color: AppColors.verdePrincipal,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Horarios',
                                      style: GoogleFonts.urbanist(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textoOscuro,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${datos.horaApertura} - ${datos.horaCierre}',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.verdePrincipal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.restaurant_menu_rounded,
                                      size: 15,
                                      color: AppColors.verdeAzulado,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Dieta diaria',
                                      style: GoogleFonts.urbanist(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textoOscuro,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  datos.alimentos.take(2).join(', '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.verdeAzulado,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // COMPORTAMIENTO COMPACTO
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.psychology_rounded,
                                size: 16,
                                color: AppColors.verdePrincipal,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Comportamiento en hábitat',
                                style: GoogleFonts.urbanist(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textoOscuro,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            datos.comportamiento,
                            style: GoogleFonts.urbanist(
                              fontSize: 12.5,
                              color: Colors.grey[700],
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // CURIOSIDAD COMPACTA "¿SABÍAS QUE? 💡"
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.verdePrincipal
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¿Sabías que?',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.verdePrincipal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  datos.curiosidad,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    color: Colors.grey[800],
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // BOTÓN DE ACCIÓN INFERIOR: MARCAR COMO VISITADO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    SoundService.instance.playButtonTap();
                    final messenger = ScaffoldMessenger.of(context);
                    final nuevoEstado = await AnimalService.instance
                        .toggleVisitado(widget.animal.id);
                    if (!mounted) return;
                    setState(() {});
                    messenger.hideCurrentSnackBar();
                    messenger.showSnackBar(
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
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                nuevoEstado
                                    ? '¡${widget.animal.nombre} marcado como visitado! 🎉'
                                    : '${widget.animal.nombre} desmarcado de visitas',
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
                  },
                  icon: Icon(
                    esVisitado
                        ? Icons.check_circle_rounded
                        : Icons.bookmark_add_rounded,
                    size: 18,
                  ),
                  label: Text(
                    esVisitado
                        ? 'Visitado ✓ (Toca para desmarcar)'
                        : 'Marcar en mi pasaporte de visitas 🐾',
                    style: GoogleFonts.urbanist(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: esVisitado
                        ? const Color(0xFF2E7D32)
                        : AppColors.verdeAzulado,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipInfo({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
