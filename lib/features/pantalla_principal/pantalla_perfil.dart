import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/mapa/widgets/modal_accesibilidad_mapa.dart';

/// Pantalla de perfil del explorador del zoológico,
/// con estadísticas de recorrido, medallas obtenidas y configuración.
class PantallaPerfil extends StatelessWidget {
  final VoidCallback? onVolverAlInicio;

  const PantallaPerfil({
    super.key,
    this.onVolverAlInicio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: onVolverAlInicio != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textoOscuro, size: 20),
                onPressed: () {
                  SoundService.instance.playButtonTap();
                  onVolverAlInicio!();
                },
              )
            : null,
        title: Text(
          'Mi Perfil de Explorador',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppColors.textoOscuro,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          children: [
            // TARJETA DE USUARIO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor:
                        AppColors.verdePrincipal.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 42,
                      color: AppColors.verdePrincipal,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visitante Aventurero',
                          style: GoogleFonts.urbanist(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textoOscuro,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Entrada General • Boleto Familiar',
                          style: GoogleFonts.urbanist(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textoGris,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.verdePrincipal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '🌟 Nivel: Guardián Junior',
                            style: GoogleFonts.urbanist(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.verdePrincipal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ESTADÍSTICAS EN TIEMPO REAL
            AnimatedBuilder(
              animation: AnimalService.instance,
              builder: (context, _) {
                final visitados = AnimalService.instance.totalVisitados;
                final total = AnimalService.instance.totalAnimales;
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        titulo: 'Avistamientos',
                        valor: '$visitados / $total',
                        icono: Icons.visibility_rounded,
                        color: AppColors.verdePrincipal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        titulo: 'Shows Vistos',
                        valor: '1 Show',
                        icono: Icons.theater_comedy_rounded,
                        color: const Color(0xFF0077B6),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // INSIGNIAS / LOGROS
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Insignias Desbloqueadas',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textoOscuro,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBadge(
                  emoji: '🦁',
                  titulo: 'Rey León',
                  subtitulo: 'Zona Sabana',
                  desbloqueada: true,
                ),
                _buildBadge(
                  emoji: '🐬',
                  titulo: 'Acrobacias',
                  subtitulo: 'Show Marino',
                  desbloqueada: true,
                ),
                _buildBadge(
                  emoji: '🦜',
                  titulo: 'Aviario Real',
                  subtitulo: 'Aves Selva',
                  desbloqueada: false,
                ),
                _buildBadge(
                  emoji: '🚜',
                  titulo: 'Granjero',
                  subtitulo: 'Granja Zoo',
                  desbloqueada: true,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // PREFERENCIAS Y ACCESIBILIDAD
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ajustes de Visita',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textoOscuro,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.verdePrincipal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.accessibility_new_rounded,
                        color: AppColors.verdePrincipal,
                      ),
                    ),
                    title: Text(
                      'Modo de Accesibilidad',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    ),
                    subtitle: Text(
                      'Alto contraste, rampas y asistencia auditiva',
                      style: GoogleFonts.urbanist(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      SoundService.instance.playButtonTap();
                      ModalAccesibilidadMapa.mostrar(context);
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDF9F1D).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.volume_up_rounded,
                        color: Color(0xFFDF9F1D),
                      ),
                    ),
                    title: Text(
                      'Efectos Sonoros',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    ),
                    subtitle: Text(
                      'Sonidos de botones y avisos del parque',
                      style: GoogleFonts.urbanist(fontSize: 12),
                    ),
                    trailing: Switch(
                      value: true,
                      activeTrackColor: AppColors.verdePrincipal.withValues(alpha: 0.5),
                      activeThumbColor: AppColors.verdePrincipal,
                      onChanged: (val) {
                        SoundService.instance.playButtonTap();
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            valor,
            style: GoogleFonts.urbanist(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.textoOscuro,
            ),
          ),
          Text(
            titulo,
            style: GoogleFonts.urbanist(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textoGris,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String emoji,
    required String titulo,
    required String subtitulo,
    required bool desbloqueada,
  }) {
    return Opacity(
      opacity: desbloqueada ? 1.0 : 0.4,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: desbloqueada ? Colors.white : Colors.grey.shade200,
              shape: BoxShape.circle,
              boxShadow: desbloqueada
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            titulo,
            style: GoogleFonts.urbanist(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textoOscuro,
            ),
          ),
          Text(
            subtitulo,
            style: GoogleFonts.urbanist(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textoGris,
            ),
          ),
        ],
      ),
    );
  }
}
