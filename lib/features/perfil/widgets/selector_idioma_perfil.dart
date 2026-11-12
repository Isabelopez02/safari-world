import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Selector de idioma global con opciones en tarjetas (Español, English, Quechua)
class SelectorIdiomaPerfil extends StatelessWidget {
  const SelectorIdiomaPerfil({super.key});

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
              onTap: () {
                SoundService.instance.playButtonTap();
                IdiomaService.instance.cambiarIdioma(AppIdioma.es);
              },
            ),
            const Divider(height: 1, indent: 56),
            _buildOpcionIdioma(
              titulo: 'English',
              subtitulo: 'International tourists',
              bandera: '🇺🇸',
              seleccionado: idiomaActual == AppIdioma.en,
              onTap: () {
                SoundService.instance.playButtonTap();
                IdiomaService.instance.cambiarIdioma(AppIdioma.en);
              },
            ),
            const Divider(height: 1, indent: 56),
            _buildOpcionIdioma(
              titulo: 'Runasimi / Quechua',
              subtitulo: 'Piruwpa paqarisqa simin',
              bandera: '🏔️',
              seleccionado: idiomaActual == AppIdioma.qu,
              onTap: () {
                SoundService.instance.playButtonTap();
                IdiomaService.instance.cambiarIdioma(AppIdioma.qu);
              },
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
                      fontWeight:
                          seleccionado ? FontWeight.w900 : FontWeight.w700,
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
