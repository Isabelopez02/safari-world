import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/emergency_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Modal sutil y tranquilizador de orientación y auxilio para visitantes desorientados.
class ModalTePerdiste extends StatelessWidget {
  final VoidCallback onIrAlMapa;

  const ModalTePerdiste({
    super.key,
    required this.onIrAlMapa,
  });

  static void mostrar(BuildContext context, {required VoidCallback onIrAlMapa}) {
    SoundService.instance.playButtonTap();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalTePerdiste(onIrAlMapa: onIrAlMapa),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de agarre
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // CABECERA AMIGABLE
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: Color(0xFFE65100),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Te perdiste? Tranquilo/a',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Estamos aquí para ayudarte a retomar el camino',
                      style: GoogleFonts.urbanist(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textoGris,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // OPCIÓN 1: ABRIR EL MAPA
          _buildOpcionCard(
            context: context,
            icono: Icons.map_outlined,
            colorIcono: AppColors.verdePrincipal,
            titulo: 'Abrir mapa interactivo',
            subtitulo: 'Consulta los senderos, zonas y animales alrededor',
            onTap: () {
              Navigator.pop(context);
              onIrAlMapa();
            },
          ),

          const SizedBox(height: 12),

          // OPCIÓN 2: PUNTOS DE ENCUENTRO Y GUÍAS
          _buildOpcionCard(
            context: context,
            icono: Icons.signpost_rounded,
            colorIcono: const Color(0xFF0288D1),
            titulo: 'Puntos de encuentro y guías',
            subtitulo: 'Hay módulos de guardaparques en cada entrada y plaza principal',
            onTap: () {
              Navigator.pop(context);
              onIrAlMapa();
            },
          ),

          const SizedBox(height: 12),

          // OPCIÓN 3: CONTACTAR ASISTENCIA O EMERGENCIA
          _buildOpcionCard(
            context: context,
            icono: Icons.phone_in_talk_rounded,
            colorIcono: AppColors.rojoEmergencia,
            titulo: 'Asistencia y primeros auxilios',
            subtitulo: 'Llamar a central médica o puesto de guardaparques',
            onTap: () {
              Navigator.pop(context);
              EmergencyService.instance.mostrarModalEmergencia(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOpcionCard({
    required BuildContext context,
    required IconData icono,
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorIcono.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: colorIcono, size: 22),
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
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textoGris,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
