import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/models/datos_animal.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'pantalla_detalle_animal.dart';

/// Layout optimizado para pantallas grandes (Tablets, iPad, Desktop y Plegables >= 720px)
/// Distribución en dos columnas con panel visual/interactivo a la izquierda
/// y panel educativo detallado a la derecha.
class DetalleAnimalTablet extends StatelessWidget {
  final MarcadorMapa animal;
  final DatosAnimal datos;
  final HabitatThemeData theme;
  final bool esVisitado;
  final bool isPlayingAudio;
  final AnimationController audioWaveController;
  final VoidCallback onToggleAudioguia;
  final VoidCallback onToggleVisitado;
  final VoidCallback onBack;

  const DetalleAnimalTablet({
    super.key,
    required this.animal,
    required this.datos,
    required this.theme,
    required this.esVisitado,
    required this.isPlayingAudio,
    required this.audioWaveController,
    required this.onToggleAudioguia,
    required this.onToggleVisitado,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AccesibilidadService.instance,
      builder: (context, _) {
        final a11y = AccesibilidadService.instance;
        final bool oscuro = a11y.modoAltoContraste;
        final Color fondoPantalla =
            oscuro ? const Color(0xFF020617) : theme.background;

        return Scaffold(
          backgroundColor: fondoPantalla,
          body: SafeArea(
            child: Column(
              children: [
                // BARRA SUPERIOR DE NAVEGACIÓN TABLET
                _buildBarraSuperior(),

                // CUERPO EN DOS COLUMNAS RESPONSIVAS
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // COLUMNA IZQUIERDA: FOTO GRANDE, IDENTIDAD Y PASAPORTE (45%)
                        Expanded(
                          flex: 5,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // FOTO HERO GRANDE CON MARCO TEMÁTICO
                                _buildHeroPhoto(),

                                const SizedBox(height: 16),

                                // TARJETA DE REPRODUCTOR DE AUDIOGUÍA
                                _buildPanelAudioguia(),

                                const SizedBox(height: 16),

                                // TARJETA DEL PASAPORTE EXPLORADOR
                                _buildTarjetaPasaporte(),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 24),

                        // COLUMNA DERECHA: DASHBOARD EDUCATIVO SCROLLEABLE (55%)
                        Expanded(
                          flex: 6,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // CHIPS DE ESTADO Y CONSERVACIÓN
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _buildChip(
                                      icon: Icons.terrain_rounded,
                                      label: '${theme.emoji} ${theme.nombreHabitat}',
                                      color: oscuro ? const Color(0xFFFDE047) : theme.accent,
                                    ),
                                    _buildChip(
                                      icon: Icons.restaurant_rounded,
                                      label: datos.dieta,
                                      color: oscuro ? const Color(0xFFFDE047) : theme.accent,
                                    ),
                                    _buildChip(
                                      icon: Icons.shield_rounded,
                                      label: datos.estadoConservacion,
                                      color: oscuro ? const Color(0xFFFB923C) : const Color(0xFFE65100),
                                      esAlerta: true,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // HORARIOS Y ALIMENTACIÓN
                                _buildTarjetaHorariosYDieta(),

                                const SizedBox(height: 16),

                                // COMPORTAMIENTO EN EL HÁBITAT
                                _buildTarjetaComportamiento(),

                                const SizedBox(height: 16),

                                // ¿SABÍAS QUE? (CURIOSIDAD CIENTÍFICA)
                                _buildTarjetaCuriosidad(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarraSuperior() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: AppColors.textoOscuro,
                  ),
                ),
                onPressed: onBack,
              ),
              const SizedBox(width: 8),
              Text(
                'Ficha de Explorador · ${theme.nombreHabitat}',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textoOscuro,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'Parada #${animal.id}',
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: theme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPhoto() {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: theme.accent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.accent.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (animal.imagen != null)
              Image.asset(
                animal.imagen!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallbackPhoto(),
              )
            else
              _buildFallbackPhoto(),

            // DEGRADADO SUTIL
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black12,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // TÍTULO Y NOMBRE CIENTÍFICO DENTRO DEL BANNER
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.nombre,
                    style: GoogleFonts.urbanist(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    datos.nombreCientifico,
                    style: GoogleFonts.urbanist(
                      fontSize: 14.5,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackPhoto() {
    return Center(
      child: Icon(
        animal.icono,
        size: 90,
        color: Colors.white.withValues(alpha: 0.85),
      ),
    );
  }

  Widget _buildPanelAudioguia() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPlayingAudio ? const Color(0xFFFFF8E1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPlayingAudio
              ? const Color(0xFFFFB74D)
              : Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPlayingAudio
                      ? const Color(0xFFFF9800)
                      : theme.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlayingAudio
                      ? Icons.graphic_eq_rounded
                      : Icons.headphones_rounded,
                  color: isPlayingAudio ? Colors.white : theme.accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audioguía del Explorador',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textoOscuro,
                      ),
                    ),
                    Text(
                      isPlayingAudio ? 'Reproduciendo narración en vivo' : 'Narración guiada por expertos',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: onToggleAudioguia,
                icon: Icon(
                  isPlayingAudio
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_arrow_rounded,
                  size: 18,
                ),
                label: Text(isPlayingAudio ? 'Pausar' : 'Escuchar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPlayingAudio
                      ? const Color(0xFFE65100)
                      : theme.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          if (isPlayingAudio) ...[
            const SizedBox(height: 12),
            Text(
              datos.narracionAudioguia,
              style: GoogleFonts.urbanist(
                fontSize: 12.5,
                color: Colors.brown.shade800,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTarjetaPasaporte() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: esVisitado ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: esVisitado ? const Color(0xFF86EFAC) : Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                esVisitado
                    ? Icons.check_circle_rounded
                    : Icons.menu_book_rounded,
                color: esVisitado ? const Color(0xFF15803D) : theme.accent,
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      esVisitado ? '¡Animal Descubierto!' : 'Pasaporte de Visitas',
                      style: GoogleFonts.urbanist(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: esVisitado
                            ? const Color(0xFF15803D)
                            : AppColors.textoOscuro,
                      ),
                    ),
                    Text(
                      esVisitado
                          ? 'Sello oficial registrado en tu álbum safari'
                          : 'Registra tu visita al observar a esta especie',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
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
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onToggleVisitado,
              icon: Icon(
                esVisitado ? Icons.undo_rounded : Icons.verified_rounded,
                size: 18,
              ),
              label: Text(
                esVisitado
                    ? 'Desmarcar de mi pasaporte'
                    : 'Marcar en mi pasaporte 🐾',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: esVisitado
                    ? Colors.grey.shade700
                    : (theme.accent),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
    bool esAlerta = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: esAlerta ? const Color(0xFFFFF3E0) : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: esAlerta ? const Color(0xFFFFB74D) : color.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaHorariosYDieta() {
    final a11y = AccesibilidadService.instance;
    final bool oscuro = a11y.modoAltoContraste;
    final Color fondoTarjeta = oscuro ? const Color(0xFF0F172A) : Colors.white;
    final Color bordeTarjeta = oscuro ? Colors.white12 : Colors.grey.shade200;
    final Color textoTitulo = oscuro ? Colors.white : AppColors.textoOscuro;
    final Color textoSecundario = oscuro ? const Color(0xFF94A3B8) : Colors.grey[600]!;
    final Color accentColor = oscuro ? const Color(0xFFFDE047) : theme.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: fondoTarjeta,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bordeTarjeta),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.schedule_rounded, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Horarios de observación',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textoSecundario,
                    ),
                  ),
                  Text(
                    '${datos.horaApertura} - ${datos.horaCierre}',
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: textoTitulo,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              thickness: 0.8,
              color: oscuro ? Colors.white12 : Colors.grey.shade200,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.restaurant_menu_rounded, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dieta y alimentos suministrados',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textoSecundario,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      datos.alimentos.join(', '),
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textoTitulo,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaComportamiento() {
    final a11y = AccesibilidadService.instance;
    final bool oscuro = a11y.modoAltoContraste;
    final Color fondoTarjeta = oscuro ? const Color(0xFF0F172A) : Colors.white;
    final Color bordeTarjeta = oscuro ? Colors.white12 : Colors.grey.shade200;
    final Color textoTitulo = oscuro ? Colors.white : AppColors.textoOscuro;
    final Color textoSecundario = oscuro ? const Color(0xFF94A3B8) : Colors.grey.shade800;
    final Color accentColor = oscuro ? const Color(0xFFFDE047) : theme.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: fondoTarjeta,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bordeTarjeta),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_rounded, size: 20, color: accentColor),
              const SizedBox(width: 8),
              Text(
                'Comportamiento en el hábitat',
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: textoTitulo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            datos.comportamiento,
            style: GoogleFonts.urbanist(
              fontSize: 13.5,
              color: textoSecundario,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaCuriosidad() {
    final a11y = AccesibilidadService.instance;
    final bool oscuro = a11y.modoAltoContraste;
    final Color fondoCuriosidad = oscuro
        ? const Color(0xFF1E293B)
        : theme.gradientStart.withValues(alpha: 0.35);
    final Color bordeColor = oscuro
        ? const Color(0xFFFDE047).withValues(alpha: 0.5)
        : theme.accent.withValues(alpha: 0.35);
    final Color accentColor = oscuro ? const Color(0xFFFDE047) : theme.accent;
    final Color textoBody = oscuro ? const Color(0xFFCBD5E1) : Colors.grey.shade900;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: fondoCuriosidad,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: bordeColor,
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Sabías que?',
                  style: GoogleFonts.urbanist(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  datos.curiosidad,
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    color: textoBody,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
