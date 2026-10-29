import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/data/datos_marcadores.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

class _MetaHabitat {
  final String nombre;
  final String emoji;
  final IconData icono;
  final Color color;
  final String subtitulo;

  const _MetaHabitat({
    required this.nombre,
    required this.emoji,
    required this.icono,
    required this.color,
    required this.subtitulo,
  });
}

const Map<String, _MetaHabitat> _metadatosHabitats = {
  'Granja Interactiva': _MetaHabitat(
    nombre: 'Granja Interactiva',
    emoji: '🚜',
    icono: Icons.agriculture_rounded,
    color: ColoresZonas.granja,
    subtitulo: 'Vacas, ovejas, alpacas y aves de corral',
  ),
  'Zona Internacional': _MetaHabitat(
    nombre: 'Zona Internacional',
    emoji: '🌍',
    icono: Icons.public_rounded,
    color: ColoresZonas.internacional,
    subtitulo: 'Leones, jirafas, tigres, cebras y fauna exótica',
  ),
  'Zona Costa': _MetaHabitat(
    nombre: 'Zona Costa',
    emoji: '🌊',
    icono: Icons.water_rounded,
    color: ColoresZonas.costa,
    subtitulo: 'Pingüinos, lobos de mar y aves guaneras',
  ),
  'Zona Sierra': _MetaHabitat(
    nombre: 'Zona Sierra',
    emoji: '⛰️',
    icono: Icons.terrain_rounded,
    color: ColoresZonas.sierra,
    subtitulo: 'Cóndor andino, vicuñas, caballos y camélidos',
  ),
  'Zona Selva': _MetaHabitat(
    nombre: 'Zona Selva',
    emoji: '🌴',
    icono: Icons.forest_rounded,
    color: ColoresZonas.selva,
    subtitulo: 'Otorongo, anaconda, monos y fauna amazónica',
  ),
};

/// Modal jerárquico de exploraciones: primero muestra todos los hábitats con
/// contador tipo "16 / 34" y al seleccionar un hábitat despliega sus animales.
class ModalAnimalesPorVisitar extends StatefulWidget {
  final ValueChanged<MarcadorMapa> onSeleccionarAnimal;
  final String? habitatInicial;

  const ModalAnimalesPorVisitar({
    super.key,
    required this.onSeleccionarAnimal,
    this.habitatInicial,
  });

  /// Método de conveniencia para desplegar el modal
  static void mostrar(
    BuildContext context, {
    required ValueChanged<MarcadorMapa> onSeleccionarAnimal,
    String? habitatInicial,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalAnimalesPorVisitar(
        onSeleccionarAnimal: onSeleccionarAnimal,
        habitatInicial: habitatInicial,
      ),
    );
  }

  @override
  State<ModalAnimalesPorVisitar> createState() => _ModalAnimalesPorVisitarState();
}

class _ModalAnimalesPorVisitarState extends State<ModalAnimalesPorVisitar> {
  String? _habitatSeleccionado;

  @override
  void initState() {
    super.initState();
    _habitatSeleccionado = widget.habitatInicial;
  }

  void _seleccionarHabitat(String habitat) {
    SoundService.instance.playButtonTap();
    setState(() {
      _habitatSeleccionado = habitat;
    });
  }

  void _volverAHabitats() {
    SoundService.instance.playButtonTap();
    setState(() {
      _habitatSeleccionado = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitats = AnimalService.instance.obtenerHabitatsPrincipales();

    return ListenableBuilder(
      listenable: AnimalService.instance,
      builder: (context, _) {
        final visitadosGlobal = AnimalService.instance.totalVisitados;
        final totalGlobal = AnimalService.instance.totalAnimales;
        final pctGlobal = AnimalService.instance.porcentajeVisitados;

        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Barra de arrastre superior
              Container(
                width: 48,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 14),

              // BANNER DE PROGRESO DE AVENTURA GENERAL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
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
                            padding: const EdgeInsets.all(9),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.explore_rounded,
                              color: AppColors.verdeAzulado,
                              size: 28,
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
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Has descubierto $visitadosGlobal de $totalGlobal animales (${(pctGlobal * 100).toInt()}%)',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12.5,
                                    color: Colors.white.withValues(alpha: 0.92),
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
                          value: pctGlobal,
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

              // CONTENIDO: O LISTA DE HÁBITATS O ANIMALES DEL HÁBITAT SELECCIONADO
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _habitatSeleccionado == null
                      ? _buildListaHabitats(habitats)
                      : _buildVistaHabitatSeleccionado(_habitatSeleccionado!),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Nivel 1: Lista interactiva de hábitats con contador "visitados / total"
  Widget _buildListaHabitats(List<String> habitats) {
    return Column(
      key: const ValueKey('lista_habitats'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hábitats del Zoológico',
                style: GoogleFonts.urbanist(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                'Selecciona una zona',
                style: GoogleFonts.urbanist(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: habitats.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final habitat = habitats[index];
              final meta = _metadatosHabitats[habitat] ??
                  _MetaHabitat(
                    nombre: habitat,
                    emoji: '🐾',
                    icono: Icons.pets,
                    color: AppColors.verdeAzulado,
                    subtitulo: 'Especies de esta zona',
                  );

              final int visitados =
                  AnimalService.instance.totalVisitadosEnHabitat(habitat);
              final int total = AnimalService.instance.totalEnHabitat(habitat);
              final double progreso =
                  AnimalService.instance.porcentajeVisitadosEnHabitat(habitat);

              return InkWell(
                onTap: () => _seleccionarHabitat(habitat),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: meta.color.withValues(alpha: 0.22),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: meta.color.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // ÍCONO TEMÁTICO DE LA ZONA
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: meta.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(meta.icono, color: meta.color, size: 26),
                      ),
                      const SizedBox(width: 14),

                      // TÍTULO, SUBTÍTULO Y BARRA
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  meta.emoji,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    meta.nombre,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1E293B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              meta.subtitulo,
                              style: GoogleFonts.urbanist(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progreso,
                                backgroundColor:
                                    meta.color.withValues(alpha: 0.12),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  meta.color,
                                ),
                                minHeight: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // CONTADOR FORMATO VISITADOS/TOTAL (P. EJ. 16/34)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: meta.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: meta.color.withValues(alpha: 0.35),
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              '$visitados / $total',
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: meta.color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Nivel 2: Animales pertenecientes exclusivamente al hábitat escogido
  Widget _buildVistaHabitatSeleccionado(String habitat) {
    final meta = _metadatosHabitats[habitat] ??
        _MetaHabitat(
          nombre: habitat,
          emoji: '🐾',
          icono: Icons.pets,
          color: AppColors.verdeAzulado,
          subtitulo: 'Especies de esta zona',
        );

    final int visitados =
        AnimalService.instance.totalVisitadosEnHabitat(habitat);
    final int total = AnimalService.instance.totalEnHabitat(habitat);
    final items = AnimalService.instance.obtenerPorHabitat(habitat);

    return Column(
      key: ValueKey('habitat_$habitat'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // BOTÓN VOLVER Y HEADER DEL HÁBITAT
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            children: [
              InkWell(
                onTap: _volverAHabitats,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: Color(0xFF1E293B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Hábitats',
                        style: GoogleFonts.urbanist(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Text(meta.emoji, style: const TextStyle(fontSize: 17)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        meta.nombre,
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // BADGE VISITADOS / TOTAL
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: meta.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: meta.color.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  '$visitados / $total',
                  style: GoogleFonts.urbanist(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: meta.color,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 14, color: Color(0xFFF1F5F9)),

        // GRILLA DE ANIMALES DEL HÁBITAT
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.explore_off_rounded,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No hay animales registrados en este hábitat.',
                        style: GoogleFonts.urbanist(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final marcador = items[index];
                    final bool visitado =
                        AnimalService.instance.esVisitado(marcador.id);

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
                            marcador.imagen != null
                                ? Image.asset(
                                    marcador.imagen!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                          color: meta.color,
                                          child: Icon(
                                            marcador.icono,
                                            color: Colors.white,
                                            size: 44,
                                          ),
                                        ),
                                  )
                                : Container(
                                    color: meta.color,
                                    child: Icon(
                                      marcador.icono,
                                      color: Colors.white,
                                      size: 44,
                                    ),
                                  ),

                            // Gradiente oscuro para legibilidad
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.12),
                                    Colors.black.withValues(alpha: 0.78),
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
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.2,
                                    ),
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
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.navigation_rounded,
                                        color: Colors.white70,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Trazar ruta',
                                        style: GoogleFonts.urbanist(
                                          color: Colors.white70,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
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
                    );
                  },
                ),
        ),
      ],
    );
  }
}
