import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_detalle_animal.dart';
import '../data/habitat_ruta_item.dart';

/// Modal que lista todos los animales del hábitat seleccionado con:
/// - Buscador interactivo en vivo en la parte superior
/// - Animales explorados en tono grisáceo con indicador
/// - Acción para marcar visitado o trazar ruta directa en el mapa
class ModalAnimalesHabitat extends StatefulWidget {
  final HabitatRutaItem habitat;
  final ValueChanged<String>? onTrazarRuta;

  const ModalAnimalesHabitat({
    super.key,
    required this.habitat,
    this.onTrazarRuta,
  });

  static void mostrar(
    BuildContext context, {
    required HabitatRutaItem habitat,
    ValueChanged<String>? onTrazarRuta,
  }) {
    SoundService.instance.playButtonTap();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalAnimalesHabitat(
        habitat: habitat,
        onTrazarRuta: onTrazarRuta,
      ),
    );
  }

  @override
  State<ModalAnimalesHabitat> createState() => _ModalAnimalesHabitatState();
}

class _ModalAnimalesHabitatState extends State<ModalAnimalesHabitat> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AnimalService.instance,
      builder: (context, _) {
        final todos = AnimalService.instance.obtenerPorHabitat(widget.habitat.habitatFiltro);
        final explorados = todos.where((a) => a.visitado).length;
        final total = todos.length;

        final listaFiltrada = todos.where((a) {
          if (_busqueda.trim().isEmpty) return true;
          final q = _busqueda.trim().toLowerCase();
          return a.nombre.toLowerCase().contains(q) ||
              a.habitat.toLowerCase().contains(q) ||
              a.categoria.toLowerCase().contains(q);
        }).toList();

        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barra de arrastre superior
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
                    const SizedBox(height: 14),

                    // Cabecera con título del hábitat y botón de cerrar
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: widget.habitat.colorFondo,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: widget.habitat.colorBorde, width: 1.2),
                          ),
                          child: Icon(
                            Icons.pets_rounded,
                            color: widget.habitat.colorAcento,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.habitat.nombre,
                                style: GoogleFonts.urbanist(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textoOscuro,
                                ),
                              ),
                              Text(
                                '$explorados de $total animales explorados',
                                style: GoogleFonts.urbanist(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: explorados == total && total > 0
                                      ? const Color(0xFF16A34A)
                                      : widget.habitat.colorAcento,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color: AppColors.textoOscuro,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Barra de botón para trazar sendero en el mapa
                    InkWell(
                      onTap: () {
                        SoundService.instance.playButtonTap();
                        Navigator.pop(context);
                        if (widget.onTrazarRuta != null) {
                          widget.onTrazarRuta!(widget.habitat.habitatFiltro);
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: widget.habitat.colorFondo,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: widget.habitat.colorBorde),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.explore_rounded, color: widget.habitat.colorAcento, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Trazar sendero de ${widget.habitat.nombre} en el mapa',
                                style: GoogleFonts.urbanist(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: widget.habitat.colorAcento,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, color: widget.habitat.colorAcento, size: 13),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // BUSCADOR EN VIVO
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar animal en ${widget.habitat.nombre}...',
                        hintStyle: GoogleFonts.urbanist(color: AppColors.textoGris, fontSize: 13.5),
                        prefixIcon: Icon(Icons.search_rounded, color: widget.habitat.colorAcento, size: 22),
                        suffixIcon: _busqueda.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () => setState(() => _busqueda = ''),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() => _busqueda = val);
                      },
                    ),

                    const SizedBox(height: 12),

                    // LISTA DE ANIMALES
                    Expanded(
                      child: listaFiltrada.isEmpty
                          ? Center(
                              child: Text(
                                'No se encontraron animales que coincidan.',
                                style: GoogleFonts.urbanist(
                                  fontSize: 13,
                                  color: AppColors.textoGris,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              itemCount: listaFiltrada.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final animal = listaFiltrada[index];
                                final bool esExplorado = animal.visitado;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: esExplorado
                                        ? const Color(0xFFF8FAFC)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: esExplorado
                                          ? Colors.grey.shade300
                                          : Colors.black.withValues(alpha: 0.08),
                                      width: 1.2,
                                    ),
                                    boxShadow: esExplorado
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.04),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(18),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(18),
                                      onTap: () {
                                        SoundService.instance.playButtonTap();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PantallaDetalleAnimal(animal: animal),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          children: [
                                            // Foto del animal
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: SizedBox(
                                                width: 88,
                                                height: 88,
                                                child: esExplorado
                                                    ? ColorFiltered(
                                                        colorFilter: const ColorFilter.mode(
                                                          Colors.grey,
                                                          BlendMode.saturation,
                                                        ),
                                                        child: Opacity(
                                                          opacity: 0.70,
                                                          child: Image.asset(
                                                            animal.imagen ?? 'assets/images/animales_con_fondo/leon-card.jpg',
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (ctx, err, stack) => const Icon(Icons.pets, size: 36),
                                                          ),
                                                        ),
                                                      )
                                                    : Image.asset(
                                                        animal.imagen ?? 'assets/images/animales_con_fondo/leon-card.jpg',
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (ctx, err, stack) => const Icon(Icons.pets, size: 36),
                                                      ),
                                              ),
                                            ),
                                            const SizedBox(width: 14),

                                            // Información y acciones
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    animal.nombre,
                                                    style: GoogleFonts.urbanist(
                                                      fontSize: 15.5,
                                                      fontWeight: FontWeight.w900,
                                                      color: esExplorado
                                                          ? const Color(0xFF64748B)
                                                          : AppColors.textoOscuro,
                                                      height: 1.15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    animal.categoria,
                                                    style: GoogleFonts.urbanist(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: esExplorado
                                                          ? Colors.grey.shade500
                                                          : AppColors.textoGris,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),

                                                  Row(
                                                    children: [
                                                      // Badge Explorado / Por descubrir
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: esExplorado
                                                              ? const Color(0xFFE2E8F0)
                                                              : widget.habitat.colorFondo,
                                                          borderRadius: BorderRadius.circular(8),
                                                          border: Border.all(
                                                            color: esExplorado
                                                                ? Colors.grey.shade400
                                                                : widget.habitat.colorBorde,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              esExplorado ? Icons.check_circle_rounded : Icons.pending_rounded,
                                                              size: 11,
                                                              color: esExplorado
                                                                  ? const Color(0xFF16A34A)
                                                                  : widget.habitat.colorAcento,
                                                            ),
                                                            const SizedBox(width: 3.5),
                                                            Text(
                                                              esExplorado ? 'Explorado' : 'Por descubrir',
                                                              style: GoogleFonts.urbanist(
                                                                fontSize: 10,
                                                                fontWeight: FontWeight.w800,
                                                                color: esExplorado
                                                                    ? const Color(0xFF16A34A)
                                                                    : widget.habitat.colorAcento,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const Spacer(),

                                                      // Botón Trazar ruta rápida
                                                      InkWell(
                                                        onTap: () {
                                                          SoundService.instance.playButtonTap();
                                                          Navigator.pop(context);
                                                          if (widget.onTrazarRuta != null) {
                                                            widget.onTrazarRuta!(animal.id);
                                                          }
                                                        },
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                                          decoration: BoxDecoration(
                                                            color: widget.habitat.colorAcento.withValues(alpha: 0.1),
                                                            borderRadius: BorderRadius.circular(8),
                                                            border: Border.all(
                                                              color: widget.habitat.colorAcento.withValues(alpha: 0.28),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Icon(Icons.near_me_rounded, size: 11, color: widget.habitat.colorAcento),
                                                              const SizedBox(width: 3),
                                                              Text(
                                                                'Trazar',
                                                                style: GoogleFonts.urbanist(
                                                                  fontSize: 10.5,
                                                                  fontWeight: FontWeight.w900,
                                                                  color: widget.habitat.colorAcento,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),

                                                      // Botón marcar visitado
                                                      InkWell(
                                                        onTap: () {
                                                          SoundService.instance.playButtonTap();
                                                          AnimalService.instance.toggleVisitado(animal.id);
                                                        },
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(3.0),
                                                          child: Icon(
                                                            esExplorado
                                                                ? Icons.check_circle_rounded
                                                                : Icons.radio_button_unchecked_rounded,
                                                            color: esExplorado
                                                                ? const Color(0xFF16A34A)
                                                                : Colors.grey.shade400,
                                                            size: 22,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
