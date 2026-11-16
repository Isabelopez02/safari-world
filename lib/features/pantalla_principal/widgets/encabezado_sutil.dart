import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Encabezado sutil, moderno y limpio para la pantalla principal.
/// Destaca el saludo de aventura con tipografía ligera y elegante,
/// sin contrastes agresivos ni saturación visual.
class EncabezadoSutil extends StatelessWidget {
  final String nombreParque;
  final VoidCallback? onNotificacionesTap;
  final VoidCallback? onPerfilTap;

  const EncabezadoSutil({
    super.key,
    this.nombreParque = 'Parque de las Leyendas',
    this.onNotificacionesTap,
    this.onPerfilTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FILA SUPERIOR: CHIP DE ESTADO Y BOTONES DE ACCIÓN RÁPIDA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chip sutil del parque / estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.verdePrincipal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.verdePrincipal.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Abierto hoy • 9:00 AM - 5:30 PM',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.verdePrincipal,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón Selector Rápido de Idioma (ES, EN, QU, AY)
                  ListenableBuilder(
                    listenable: IdiomaService.instance,
                    builder: (context, _) {
                      return InkWell(
                        onTap: () {
                          SoundService.instance.playButtonTap();
                          _mostrarModalSeleccionIdioma(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.verdePrincipal.withValues(alpha: 0.25),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                IdiomaService.instance.banderaIdioma,
                                style: GoogleFonts.urbanist(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textoOscuro,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: AppColors.verdePrincipal,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),

                  // Botón de notificaciones o campana sutil
                  InkWell(
                    onTap: () {
                      SoundService.instance.playButtonTap();
                      if (onNotificacionesTap != null) {
                        onNotificacionesTap!();
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.06),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.textoOscuro,
                            size: 22,
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.amarilloMostaza,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // OVERLINE: "TU AVENTURA EMPIEZA AQUÍ"
          Text(
            'tu_aventura'.tr.toUpperCase(),
            style: GoogleFonts.urbanist(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.2,
              color: AppColors.verdePrincipal.withValues(alpha: 0.75),
            ),
          ),

          const SizedBox(height: 4),

          // TÍTULO PRINCIPAL: "Bienvenido a ..."
          RichText(
            text: TextSpan(
              style: GoogleFonts.urbanist(
                fontSize: 27,
                fontWeight: FontWeight.w900,
                color: AppColors.textoOscuro,
                letterSpacing: -0.5,
                height: 1.15,
              ),
              children: [
                TextSpan(
                  text: '${'parque_nombre'.tr} 🌿',
                  style: GoogleFonts.urbanist(
                    color: AppColors.verdePrincipal,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarModalSeleccionIdioma(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'seleccionar_idioma'.tr,
                  style: GoogleFonts.urbanist(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textoOscuro,
                  ),
                ),
                const SizedBox(height: 14),
                _buildItemIdiomaModal(
                  context: ctx,
                  titulo: 'Español',
                  subtitulo: 'Predeterminado (Perú)',
                  bandera: '🇵🇪',
                  idioma: AppIdioma.es,
                ),
                const SizedBox(height: 8),
                _buildItemIdiomaModal(
                  context: ctx,
                  titulo: 'English',
                  subtitulo: 'International tourists',
                  bandera: '🇺🇸',
                  idioma: AppIdioma.en,
                ),
                const SizedBox(height: 8),
                _buildItemIdiomaModal(
                  context: ctx,
                  titulo: 'Runasimi / Quechua',
                  subtitulo: 'Piruwpa paqarisqa simin',
                  bandera: '🏔️',
                  idioma: AppIdioma.qu,
                ),
                const SizedBox(height: 8),
                _buildItemIdiomaModal(
                  context: ctx,
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

  Widget _buildItemIdiomaModal({
    required BuildContext context,
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
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado
              ? AppColors.verdePrincipal.withValues(alpha: 0.10)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: seleccionado
                ? AppColors.verdePrincipal
                : Colors.grey.shade200,
            width: seleccionado ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(bandera, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: seleccionado ? FontWeight.w900 : FontWeight.w700,
                      color: AppColors.textoOscuro,
                    ),
                  ),
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
            if (seleccionado)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.verdePrincipal,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
