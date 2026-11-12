import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_detalle_animal.dart';

/// Modelo descriptivo de un hábitat / zona para la página de rutas
class HabitatRutaItem {
  final String id;
  final String nombre;
  final String etiqueta;
  final Color colorEtiqueta;
  final String animalesTexto;
  final String duracion;
  final String caracteristicas;
  final String imagen;
  final String habitatFiltro;
  final Color colorFondo;
  final Color colorBorde;
  final Color colorAcento;

  const HabitatRutaItem({
    required this.id,
    required this.nombre,
    required this.etiqueta,
    required this.colorEtiqueta,
    required this.animalesTexto,
    required this.duracion,
    required this.caracteristicas,
    required this.imagen,
    required this.habitatFiltro,
    required this.colorFondo,
    required this.colorBorde,
    required this.colorAcento,
  });
}

/// Página de "Tu Ruta": permite conocer los animales por hábitats
/// y trazar el recorrido hacia cada zona directamente en el mapa.
class PantallaRuta extends StatelessWidget {
  final ValueChanged<String>? onTrazarRuta;

  const PantallaRuta({
    super.key,
    this.onTrazarRuta,
  });

  static const List<HabitatRutaItem> _habitats = [
    HabitatRutaItem(
      id: 'sabana',
      nombre: 'Sabana Africana',
      etiqueta: '🌍 DESTACADA',
      colorEtiqueta: Color(0xFFD97706),
      animalesTexto: 'Leones, Jirafas, Cebras',
      duracion: '30 min',
      caracteristicas: 'Miradores amplios y cafetería',
      imagen: 'assets/images/animales_con_fondo/leon-card.jpg',
      habitatFiltro: 'Zona Internacional',
      colorFondo: Color(0xFFFFFBEB),
      colorBorde: Color(0xFFFDE68A),
      colorAcento: Color(0xFFD97706),
    ),
    HabitatRutaItem(
      id: 'selva',
      nombre: 'Selva Amazónica',
      etiqueta: '🌴 SELVA',
      colorEtiqueta: Color(0xFF2E7D32),
      animalesTexto: 'Otorongo, Monos, Aves',
      duracion: '25 min',
      caracteristicas: 'Senderos con sombra y descanso',
      imagen: 'assets/images/animales_con_fondo/otorongo.jpg',
      habitatFiltro: 'Zona Selva',
      colorFondo: Color(0xFFF0FDF4),
      colorBorde: Color(0xFFBBF7D0),
      colorAcento: Color(0xFF16A34A),
    ),
    HabitatRutaItem(
      id: 'costa',
      nombre: 'Costa Marina',
      etiqueta: '🌊 COSTA',
      colorEtiqueta: Color(0xFF0077B6),
      animalesTexto: 'Pingüinos, Lobos de Mar',
      duracion: '20 min',
      caracteristicas: 'Piscina interactiva y anfiteatro',
      imagen: 'assets/images/animales_con_fondo/pinguino-card.jpg',
      habitatFiltro: 'Zona Costa',
      colorFondo: Color(0xFFF0F9FF),
      colorBorde: Color(0xFFBAE6FD),
      colorAcento: Color(0xFF0284C7),
    ),
    HabitatRutaItem(
      id: 'sierra',
      nombre: 'Sierra Andina',
      etiqueta: '⛰️ ANDES',
      colorEtiqueta: Color(0xFF8D6E63),
      animalesTexto: 'Cóndor Andino, Vicuñas',
      duracion: '20 min',
      caracteristicas: 'Mirador panorámico y artesanía',
      imagen: 'assets/images/animales_con_fondo/condor.jpg',
      habitatFiltro: 'Zona Sierra',
      colorFondo: Color(0xFFFAF5F0),
      colorBorde: Color(0xFFE7D8CD),
      colorAcento: Color(0xFF8D6E63),
    ),
    HabitatRutaItem(
      id: 'granja',
      nombre: 'Granja Familiar',
      etiqueta: '🚜 FAMILIAR',
      colorEtiqueta: Color(0xFF8E24AA),
      animalesTexto: 'Vacas, Ovejas, Alpacas',
      duracion: '15 min',
      caracteristicas: 'Contacto directo y alimento',
      imagen: 'assets/images/animales_con_fondo/vaca-card.jpg',
      habitatFiltro: 'Granja Interactiva',
      colorFondo: Color(0xFFFAF5FF),
      colorBorde: Color(0xFFE9D5FF),
      colorAcento: Color(0xFF9333EA),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AnimalService.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFBF9F6),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            automaticallyImplyLeading: false,
            title: Text(
              'Rutas & Hábitats',
              style: GoogleFonts.urbanist(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textoOscuro,
                letterSpacing: -0.4,
              ),
            ),
          ),
          body: Builder(
            builder: (context) {
              final double screenWidth = MediaQuery.of(context).size.width;
              final bool esTablet = screenWidth >= 720;
              final int columnas = esTablet ? (screenWidth >= 1000 ? 4 : 3) : 2;
              final double childAspect = esTablet ? 0.78 : 0.72;

              final Widget content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // INTRODUCCIÓN EDITORIAL MINIMALISTA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CONOCE LOS HÁBITATS DEL PARQUE',
                          style: GoogleFonts.urbanist(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppColors.verdePrincipal.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Toca un hábitat para explorar sus animales o traza su sendero en el mapa.',
                          style: GoogleFonts.urbanist(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textoGris,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // CUADRÍCULA MINIMALISTA (2 POR FILA EN CELULAR, ADAPTABLE EN TABLET)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _habitats.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnas,
                      crossAxisSpacing: esTablet ? 16 : 12,
                      mainAxisSpacing: esTablet ? 16 : 14,
                      childAspectRatio: childAspect,
                    ),
                    itemBuilder: (context, index) {
                      final habitat = _habitats[index];
                      return _buildHabitatCard(context, habitat);
                    },
                  ),

                  // Margen inferior para que no quede tapado por el footer persistente
                  const SizedBox(height: 90),
                ],
              );

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: esTablet ? 24.0 : 16.0,
                  vertical: 4.0,
                ),
                child: esTablet
                    ? SizedBox(
                        width: double.infinity,
                        child: Center(
                          heightFactor: 1.0,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1040),
                            child: content,
                          ),
                        ),
                      )
                    : content,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHabitatCard(BuildContext context, HabitatRutaItem habitat) {
    final animalesZona = AnimalService.instance.obtenerPorHabitat(habitat.habitatFiltro);
    final totalZona = animalesZona.length;
    final exploradosZona = animalesZona.where((a) => a.visitado).length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          SoundService.instance.playButtonTap();
          // Apertura modal con todos los animales del hábitat y buscador en vivo
          ModalAnimalesHabitat.mostrar(
            context,
            habitat: habitat,
            onTrazarRuta: onTrazarRuta,
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: habitat.colorFondo,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: habitat.colorBorde,
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: habitat.colorAcento.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. FOTO PRINCIPAL VERTICAL CON BADGES SUTILES
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.asset(
                          habitat.imagen,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.nature_people, size: 36, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    // Gradiente suave para legibilidad
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.28),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.45),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Badge sutil de duración / tiempo
                    Positioned(
                      top: 8,
                      left: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.schedule_rounded, size: 10.5, color: Colors.white),
                                const SizedBox(width: 3.5),
                                Text(
                                  habitat.duracion,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // BADGE TIPO "34/47" EN LUGAR DE LA BRÚJULA (EXPLORACIÓN EN VIVO)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: (exploradosZona == totalZona && totalZona > 0)
                                  ? const Color(0xFF15803D).withValues(alpha: 0.85)
                                  : Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 0.9,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  exploradosZona == totalZona && totalZona > 0
                                      ? Icons.check_circle_rounded
                                      : Icons.pets_rounded,
                                  size: 11,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$exploradosZona/$totalZona',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. TEXTOS MINIMALISTAS AL PIE
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habitat.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.urbanist(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textoOscuro,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      habitat.animalesTexto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.urbanist(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: habitat.colorAcento,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 11.5,
                                color: habitat.colorAcento.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  'Ver animales ($totalZona)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: habitat.colorAcento,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            SoundService.instance.playButtonTap();
                            onTrazarRuta?.call(habitat.habitatFiltro);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: habitat.colorAcento.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: habitat.colorAcento.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.near_me_rounded, size: 10, color: habitat.colorAcento),
                                const SizedBox(width: 3),
                                Text(
                                  'Trazar',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: habitat.colorAcento,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

              // BUSCADOR EN VIVO (TextField interactivo en tiempo real)
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
                                      // FOTO MUCHO MÁS GRANDE (88x88)
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

                                      // INFORMACIÓN Y BOTONES DE ACCIÓN
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
