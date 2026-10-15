import 'package:flutter/material.dart';

import '../models/marcador_mapa.dart';
import '../theme/app_colors.dart';

/// Las cinco superficies de fauna comparten el mismo asset y tratamiento de error.
class ImagenAnimal extends StatefulWidget {
  final MarcadorMapa animal;
  final BoxFit fit;

  const ImagenAnimal({
    super.key,
    required this.animal,
    this.fit = BoxFit.cover,
  });

  @override
  State<ImagenAnimal> createState() => _ImagenAnimalState();
}

class _ImagenAnimalState extends State<ImagenAnimal> {
  int _intento = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.animal.esBanio) {
      return const Icon(Icons.wc_rounded, color: Colors.blue);
    }
    final ruta = widget.animal.imagen;
    if (ruta == null || ruta.isEmpty) return _error();
    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final escala = MediaQuery.devicePixelRatioOf(context);
        final resolucion = ancho.isFinite
            ? (ancho * escala).ceil().clamp(96, 1200).toInt()
            : 900;
        return Image.asset(
          ruta,
          key: ValueKey('$ruta-$_intento'),
          width: double.infinity,
          height: double.infinity,
          fit: widget.fit,
          cacheWidth: resolucion,
          filterQuality: FilterQuality.medium,
          semanticLabel: 'Fotografía de ${widget.animal.nombre}',
          errorBuilder: (context, error, stackTrace) => _error(),
        );
      },
    );
  }

  Widget _error() => LayoutBuilder(
    builder: (context, constraints) {
      final compacto =
          constraints.maxWidth < 140 || constraints.maxHeight < 100;
      return ColoredBox(
        color: AppColors.verdeAzulado.withValues(alpha: 0.08),
        child: Semantics(
          label:
              'No se pudo cargar la foto de ${widget.animal.nombre}. Reintentar',
          button: true,
          child: InkWell(
            onTap: () async {
              if (widget.animal.imagen case final ruta?) {
                await AssetImage(ruta).evict();
              }
              if (mounted) setState(() => _intento++);
            },
            child: Center(
              child: compacto
                  ? const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.verdeAzulado,
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'No se pudo cargar la foto. Toca para reintentar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.verdeAzulado),
                      ),
                    ),
            ),
          ),
        ),
      );
    },
  );
}
