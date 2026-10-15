import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/datos_animal.dart';
import '../../../core/models/marcador_mapa.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/imagen_animal.dart';

/// Información que ayuda a reconocer al animal y a observarlo con respeto.
class InformacionAmpliadaAnimal extends StatelessWidget {
  final MarcadorMapa animal;
  final DatosAnimal datos;
  final Color accent;

  const InformacionAmpliadaAnimal({
    super.key,
    required this.animal,
    required this.datos,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 1.6,
          child: ImagenAnimal(animal: animal),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        datos.notaImagen,
        style: GoogleFonts.urbanist(
          fontSize: 11,
          color: Colors.grey[600],
          height: 1.35,
        ),
      ),
      _seccion('Conoce a este animal', Icons.menu_book_rounded, [
        _texto(datos.descripcion),
      ]),
      _seccion('Cómo reconocerlo', Icons.visibility_rounded, [
        _texto(datos.reconocimiento),
      ]),
      _seccion('Para disfrutar tu visita', Icons.explore_rounded, [
        for (final consejo in datos.recomendaciones) _punto(consejo),
      ]),
      _seccion('Reproducción y crianza', Icons.family_restroom_rounded, [
        _texto(datos.reproduccion),
      ]),
      _seccion('Su papel en la naturaleza', Icons.eco_rounded, [
        _texto(datos.rolEcologico),
        if (datos.amenazas.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Amenazas y cuidados',
            style: GoogleFonts.urbanist(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          for (final amenaza in datos.amenazas) _punto(amenaza),
        ],
      ]),
      _seccion('Registro y fuentes', Icons.fact_check_rounded, [
        _texto(datos.referenciaPresencia),
        const SizedBox(height: 8),
        _texto(
          datos.registroHistorico
              ? 'Esta ficha incluye un registro histórico de supervisión. La presencia y exhibición actual pueden cambiar por cuidados, traslados o manejo. Confirma con la señalética o el equipo del parque.'
              : 'La fecha de la publicación indica cuándo se reportó el animal. Su visibilidad puede variar durante la visita por cuidados o manejo.',
        ),
        if (!animal.tieneUbicacionMapa) ...[
          const SizedBox(height: 8),
          _texto(
            'Este registro no tiene un recinto confirmado en el plano. Consulta al personal para ubicarlo.',
          ),
        ],
        const SizedBox(height: 8),
        for (final fuente in datos.fuentes)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _abrir(context, fuente.url),
              icon: const Icon(Icons.open_in_new_rounded, size: 15),
              label: Text(fuente.titulo, softWrap: true),
              style: TextButton.styleFrom(
                foregroundColor: accent,
                textStyle: GoogleFonts.urbanist(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        const SizedBox(height: 4),
        Text(
          'Los resúmenes de Wikipedia se consultan mediante iNaturalist. Texto bajo CC BY-SA; detalles y autores en la fuente enlazada.',
          style: GoogleFonts.urbanist(
            fontSize: 10.5,
            color: Colors.grey[600],
            height: 1.35,
          ),
        ),
      ]),
      Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Text(
            'Créditos de la fotografía',
            style: GoogleFonts.urbanist(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          children: [
            _texto('${datos.autorImagen} · ${datos.licenciaImagen}'),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _abrir(context, datos.urlImagen),
                icon: const Icon(Icons.open_in_new_rounded, size: 15),
                label: const Text('Ver imagen original y licencia'),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _seccion(String titulo, IconData icono, List<Widget> children) =>
      Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, size: 17, color: accent),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    titulo,
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textoOscuro,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      );

  Widget _texto(String texto) => Text(
    texto,
    style: GoogleFonts.urbanist(
      fontSize: 12.5,
      color: Colors.grey[700],
      height: 1.45,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _punto(String texto) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Icon(Icons.circle, size: 5, color: accent),
        ),
        const SizedBox(width: 9),
        Expanded(child: _texto(texto)),
      ],
    ),
  );

  Future<void> _abrir(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !{'https', 'http'}.contains(uri.scheme)) return;
    try {
      final abierto = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!abierto && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir la fuente. Inténtalo nuevamente.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La fuente no está disponible en este momento.'),
          ),
        );
      }
    }
  }
}
