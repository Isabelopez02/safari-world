import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Diálogo de diseño safari para solicitar permiso de notificaciones al ingresar
class DialogoPermisoNotificaciones extends StatelessWidget {
  static const String prefKeySolicitadas = 'notificaciones_solicitadas';
  static const String prefKeyHabilitadas = 'notificaciones_habilitadas';

  const DialogoPermisoNotificaciones({super.key});

  /// Verifica en SharedPreferences y muestra el modal si aún no ha sido solicitado.
  static Future<void> verificarYMostrar(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final yaSolicitado = prefs.getBool(prefKeySolicitadas) ?? false;

    if (!yaSolicitado && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const DialogoPermisoNotificaciones(),
      );
    }
  }

  Future<void> _guardarRespuesta(BuildContext context, bool aceptado) async {
    SoundService.instance.playButtonTap();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKeySolicitadas, true);
    await prefs.setBool(prefKeyHabilitadas, aceptado);

    if (context.mounted) {
      Navigator.of(context).pop();
      if (aceptado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.verdePrincipal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '¡Notificaciones activadas! Te avisaremos de shows y eventos.',
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ILUSTRACIÓN / ÍCONO HERO SUPERIOR
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.verdeAzulado.withValues(alpha: 0.12),
                    ),
                  ),
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.verdeAzulado,
                          AppColors.verdePrincipal,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // TÍTULO PRINCIPAL
            Text(
              '¡Activa tus Alertas Safari!',
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),

            // SUBTÍTULO
            Text(
              'Para que disfrutes al máximo tu visita, permítenos acompañarte con información en tiempo real:',
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),

            // BENEFICIOS
            _buildBeneficioItem(
              icon: Icons.theater_comedy_rounded,
              color: const Color(0xFF0284C7),
              titulo: 'Alertas de Shows en Vivo',
              descripcion: 'Avisos 15 min antes del Show Acuático y charlas.',
            ),
            const SizedBox(height: 12),
            _buildBeneficioItem(
              icon: Icons.explore_rounded,
              color: const Color(0xFF16A34A),
              titulo: 'Descubre Animales Cercanos',
              descripcion:
                  'Te avisamos cuando estés cerca de especies por visitar.',
            ),
            const SizedBox(height: 12),
            _buildBeneficioItem(
              icon: Icons.shield_outlined,
              color: const Color(0xFFE11D48),
              titulo: 'Avisos y Seguridad',
              descripcion: 'Puntos de encuentro, emergencias y hora de cierre.',
            ),
            const SizedBox(height: 24),

            // BOTÓN PERMITIR
            ElevatedButton(
              onPressed: () => _guardarRespuesta(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verdeAzulado,
                foregroundColor: Colors.white,
                elevation: 4,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Permitir Notificaciones',
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // BOTÓN MÁS TARDE
            TextButton(
              onPressed: () => _guardarRespuesta(context, false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                'Quizás más tarde',
                style: GoogleFonts.urbanist(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeneficioItem({
    required IconData icon,
    required Color color,
    required String titulo,
    required String descripcion,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descripcion,
                  style: GoogleFonts.urbanist(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    height: 1.25,
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
