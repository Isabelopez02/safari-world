import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/core/widgets/imagen_animal.dart';
import 'package:zoologico_front/core/data/catalogo_fauna.dart';

/// Modal interactivo que muestra los animales por descubrir y visitados
/// categorizados por hábitats con barra de progreso safari.
class ModalAnimalesPorVisitar extends StatefulWidget {
  final ValueChanged<MarcadorMapa> onSeleccionarAnimal;

  const ModalAnimalesPorVisitar({super.key, required this.onSeleccionarAnimal});

  /// Método estático de utilidad para desplegar el modal
  static void mostrar(
    BuildContext context, {
    required ValueChanged<MarcadorMapa> onSeleccionarAnimal,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ModalAnimalesPorVisitar(onSeleccionarAnimal: onSeleccionarAnimal),
    );
  }

  @override
  State<ModalAnimalesPorVisitar> createState() =>
      _ModalAnimalesPorVisitarState();
}

class _ModalAnimalesPorVisitarState extends State<ModalAnimalesPorVisitar> {
  final _busqueda = TextEditingController();
  String _consulta = '';

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  void _mostrarFuentes() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sobre este catálogo'),
      content: SingleChildScrollView(
        child: Text(
          'La Municipalidad de Lima reportó $especiesReportadasHuachipa especies en Huachipa el $fechaReporteEspeciesHuachipa.\n\n'
          'Este catálogo reúne 133 registros de la supervisión de OSINFOR del 22/05/2023 y especies documentadas en publicaciones posteriores. Las filas del inventario incluyen especies, subespecies y un híbrido; el número de fichas no equivale a un censo actual de especies o individuos.\n\n'
          'Cada ficha incluye la fecha de su fuente, una foto de referencia de la especie y sus créditos. Los registros sin recinto confirmado abren su ficha sin inventar una ubicación en el mapa.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AnimalService.instance,
      builder: (context, _) {
        final visitados = AnimalService.instance.totalVisitados;
        final total = AnimalService.instance.totalAnimales;
        final pct = AnimalService.instance.porcentajeVisitados;
        final zonas = AnimalService.instance.obtenerHabitats();

        final screen = MediaQuery.of(context).size;
        final altoHoja = screen.height < 500 ? 0.97 : 0.85;
        return Container(
          height: screen.height * altoHoja,
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
                                  'Catálogo de animales',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '$total fichas disponibles · $visitados exploradas',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _mostrarFuentes,
                            tooltip: 'Cantidad y fuentes del catálogo',
                            icon: const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white,
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: TextField(
                  controller: _busqueda,
                  onChanged: (valor) => setState(() => _consulta = valor),
                  decoration: InputDecoration(
                    hintText: 'Nombre común o científico',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.verdeAzulado,
                    ),
                    suffixIcon: _consulta.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar búsqueda',
                            onPressed: () {
                              _busqueda.clear();
                              setState(() => _consulta = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.verdeAzulado.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // PESTAÑAS POR HÁBITAT
              Expanded(
                child: DefaultTabController(
                  length: zonas.length + 1,
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
                        tabs: [
                          Tab(text: '🌿 Todos ($total)'),
                          for (final zona in zonas)
                            Tab(text: '${_iconoZona(zona)} $zona'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildGridCategorias(context, 'Todos'),
                            for (final zona in zonas)
                              _buildGridCategorias(context, zona),
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

  String _iconoZona(String zona) => switch (zona) {
    'Costa' => '🐊',
    'Sierra' => '🦙',
    'Selva' => '🌴',
    'Selva-Internacional' => '🦒',
    'Felinario' => '🐅',
    'Zona Marina' => '🐧',
    'Bosque de Aves' => '🦜',
    'Serpentario' => '🐍',
    'Mundo Anfibio' => '🐸',
    _ => '🌿',
  };

  Widget _buildGridCategorias(BuildContext context, String habitat) {
    final items = AnimalService.instance
        .buscarAnimales(_consulta)
        .where((animal) => habitat == 'Todos' || animal.habitat == habitat)
        .toList(growable: false);
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_off_rounded, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No encontramos coincidencias en este ambiente.',
              style: GoogleFonts.urbanist(
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final columnas = ancho >= 1100
            ? 5
            : ancho >= 820
            ? 4
            : ancho >= 560
            ? 3
            : 2;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: ancho < 360 ? 0.72 : 0.82,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final marcador = items[index];
            final bool visitado = AnimalService.instance.esVisitado(
              marcador.id,
            );

            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.onSeleccionarAnimal(marcador);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen de fondo
                    ImagenAnimal(animal: marcador),

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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            marcador.tieneUbicacionMapa
                                ? marcador.habitat
                                : 'Consultar ficha · Ubicación por confirmar',
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
      },
    );
  }
}
