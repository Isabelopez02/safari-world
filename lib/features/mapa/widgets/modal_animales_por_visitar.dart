import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Modal interactivo que muestra los animales por descubrir y visitados
/// categorizados por hábitats con barra de progreso safari.
class ModalAnimalesPorVisitar extends StatelessWidget {
  final ValueChanged<MarcadorMapa> onSeleccionarAnimal;

  const ModalAnimalesPorVisitar({
    super.key,
    required this.onSeleccionarAnimal,
  });

  /// Método estático de utilidad para desplegar el modal
  static void mostrar(
    BuildContext context, {
    required ValueChanged<MarcadorMapa> onSeleccionarAnimal,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalAnimalesPorVisitar(
        onSeleccionarAnimal: onSeleccionarAnimal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AnimalService.instance,
      builder: (context, _) {
        final visitados = AnimalService.instance.totalVisitados;
        final total = AnimalService.instance.totalAnimales;
        final pct = AnimalService.instance.porcentajeVisitados;

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // BANNER DE PROGRESO DE AVENTURA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.verdeAzulado,
                        AppColors.verdePrincipal,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.verdeAzulado.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.explore,
                              color: AppColors.verdeAzulado,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¡Tu Aventura de Explorador!',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Has visitado $visitados de $total animales (${(pct * 100).toInt()}%)',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // PESTAÑAS POR HÁBITAT
              Expanded(
                child: DefaultTabController(
                  length: 6,
                  child: Column(
                    children: [
                      TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: AppColors.verdePrincipal,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppColors.verdeAzulado,
                        indicatorWeight: 3,
                        labelStyle: GoogleFonts.urbanist(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                        unselectedLabelStyle: GoogleFonts.urbanist(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: const [
                          Tab(text: '🌿 Todos'),
                          Tab(text: '🦁 Sabana'),
                          Tab(text: '🌴 Selva'),
                          Tab(text: '🐬 Acuático'),
                          Tab(text: '🚜 Granja'),
                          Tab(text: '🏔️ Montaña'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildGridCategorias(context, 'Todos'),
                            _buildGridCategorias(context, 'Sabana Africana'),
                            _buildGridCategorias(context, 'Selva Tropical'),
                            _buildGridCategorias(context, 'Mundo Acuático'),
                            _buildGridCategorias(context, 'La Granja'),
                            _buildGridCategorias(context, 'Bosque & Montaña'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridCategorias(BuildContext context, String habitat) {
    final items = AnimalService.instance.obtenerPorHabitat(habitat);
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_off_rounded, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No hay animales en este hábitat aún.',
              style: GoogleFonts.urbanist(
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final marcador = items[index];
        final bool visitado = AnimalService.instance.esVisitado(marcador.id);

        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
            onSeleccionarAnimal(marcador);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Imagen de fondo
                marcador.imagen != null
                    ? Image.asset(
                        marcador.imagen!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.verdePrincipal,
                          child: Icon(marcador.icono, color: Colors.white, size: 44),
                        ),
                      )
                    : Container(
                        color: AppColors.verdePrincipal,
                        child: Icon(marcador.icono, color: Colors.white, size: 44),
                      ),

                // Gradiente oscuro para legibilidad
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),

                // Badge de Visitado
                if (visitado)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'Explorado',
                            style: GoogleFonts.urbanist(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Información en la parte inferior
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        marcador.nombre,
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        marcador.habitat,
                        style: GoogleFonts.urbanist(
                          color: Colors.white70,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
