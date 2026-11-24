import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

import '../data/show_models.dart';

/// Tarjeta individual de espectáculo estilo Cineplanet con selector de alertas por horario
class TarjetaShowCartelera extends StatelessWidget {
  final ShowItemData show;
  final Function(ShowItemData show, String hora) onToggleNotificacion;
  final ValueChanged<ShowItemData> onAbrirDetalle;
  final bool Function(String showId, String hora) isHoraNotificada;

  const TarjetaShowCartelera({
    super.key,
    required this.show,
    required this.onToggleNotificacion,
    required this.onAbrirDetalle,
    required this.isHoraNotificada,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: show.esDestacado
              ? AppColors.verdePrincipal.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.06),
          width: show.esDestacado ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FILA PRINCIPAL: PÓSTER A LA IZQUIERDA + TÍTULO Y DETALLES A LA DERECHA
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => onAbrirDetalle(show),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Image.asset(
                        show.imagen,
                        width: 88,
                        height: 116,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 88,
                          height: 116,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.theater_comedy,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            show.duracion,
                            style: GoogleFonts.urbanist(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: show.colorEtiqueta.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            show.etiqueta,
                            style: GoogleFonts.urbanist(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: show.colorEtiqueta,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Text(
                            show.clasificacion,
                            style: GoogleFonts.urbanist(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textoOscuro,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => onAbrirDetalle(show),
                      child: Text(
                        show.titulo,
                        style: GoogleFonts.urbanist(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textoOscuro,
                          height: 1.2,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textoGris,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            show.ubicacion,
                            style: GoogleFonts.urbanist(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textoGris,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      show.formato,
                      style: GoogleFonts.urbanist(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.verdePrincipal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // SECCIÓN DE HORARIOS CON RECORDATORIOS
          Row(
            children: [
              Text(
                'HORARIOS:',
                style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textoGris,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Toca para que la app te avise',
                style: GoogleFonts.urbanist(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textoGris.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: show.horarios.map((hora) {
              final bool notificado = isHoraNotificada(show.id, hora);

              return InkWell(
                onTap: () {
                  SoundService.instance.playButtonTap();
                  onToggleNotificacion(show, hora);
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: notificado
                        ? const Color(0xFFDCFCE7) // Verde claro suave activo
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: notificado
                          ? const Color(0xFF22C55E) // Borde verde activo
                          : Colors.black.withValues(alpha: 0.12),
                      width: notificado ? 1.5 : 1,
                    ),
                    boxShadow: notificado
                        ? [
                            BoxShadow(
                              color: const Color(0xFF22C55E)
                                  .withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            notificado
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_none_rounded,
                            size: 14,
                            color: notificado
                                ? const Color(0xFF15803D)
                                : AppColors.textoOscuro,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            hora,
                            style: GoogleFonts.urbanist(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: notificado
                                  ? const Color(0xFF15803D)
                                  : AppColors.textoOscuro,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notificado ? '🔔 ¡Te avisaremos!' : 'Activar aviso',
                        style: GoogleFonts.urbanist(
                          fontSize: 10,
                          fontWeight: notificado
                              ? FontWeight.w900
                              : FontWeight.w700,
                          color: notificado
                              ? const Color(0xFF166534)
                              : AppColors.textoGris,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
