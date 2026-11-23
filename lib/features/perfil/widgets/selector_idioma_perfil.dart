import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Selector de idioma global con opciones en tarjetas (Español, English, Quechua)
class SelectorIdiomaPerfil extends StatelessWidget {
  const SelectorIdiomaPerfil({super.key});

  void _seleccionarIdioma(
    BuildContext context,
    AppIdioma nuevoIdioma,
    String titulo,
    String bandera,
  ) {
    SoundService.instance.playButtonTap();
    final idiomaActual = IdiomaService.instance.idioma;
    if (idiomaActual == nuevoIdioma) return;

    IdiomaService.instance.cambiarIdioma(nuevoIdioma);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: AppColors.verdePrincipal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Text(bandera, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'alerta_idioma_cambiado'.tr,
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${'idioma_activo'.tr}: $titulo',
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: IdiomaService.instance,
      builder: (context, _) {
        final idiomaActual = IdiomaService.instance.idioma;
        return Column(
          children: [
            _buildOpcionIdioma(
              titulo: 'Español',
              subtitulo: 'Predeterminado (Perú)',
              bandera: '🇵🇪',
              seleccionado: idiomaActual == AppIdioma.es,
              onTap: () =>
                  _seleccionarIdioma(context, AppIdioma.es, 'Español', '🇵🇪'),
            ),
            const Divider(height: 1, indent: 56),
            _buildOpcionIdioma(
              titulo: 'English',
              subtitulo: 'International tourists',
              bandera: '🇺🇸',
              seleccionado: idiomaActual == AppIdioma.en,
              onTap: () =>
                  _seleccionarIdioma(context, AppIdioma.en, 'English', '🇺🇸'),
            ),
            const Divider(height: 1, indent: 56),
            _buildOpcionIdioma(
              titulo: 'Runasimi / Quechua',
              subtitulo: 'Piruwpa paqarisqa simin',
              bandera: '🏔️',
              seleccionado: idiomaActual == AppIdioma.qu,
              onTap: () => _seleccionarIdioma(
                context,
                AppIdioma.qu,
                'Runasimi / Quechua',
                '🏔️',
              ),
            ),
            const Divider(height: 1, indent: 56),
            _buildOpcionIdioma(
              titulo: 'Aymar aru / Aimara',
              subtitulo: 'Qullasuyu jaqinakan arupa',
              bandera: '☀️',
              seleccionado: idiomaActual == AppIdioma.ay,
              onTap: () => _seleccionarIdioma(
                context,
                AppIdioma.ay,
                'Aymar aru / Aimara',
                '☀️',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOpcionIdioma({
    required String titulo,
    required String subtitulo,
    required String bandera,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: seleccionado
                    ? AppColors.verdePrincipal.withValues(alpha: 0.12)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(bandera, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: seleccionado
                          ? FontWeight.w900
                          : FontWeight.w700,
                      color: AppColors.textoOscuro,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: GoogleFonts.urbanist(
                      fontSize: 11.5,
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
