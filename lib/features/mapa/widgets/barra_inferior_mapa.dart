import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/core/widgets/imagen_animal.dart';

import 'marcador_animado.dart';
import '../screens/pantalla_detalle_animal.dart';

/// Barra inferior interactiva del mapa del zoológico.
/// Maneja los 3 estados con entrada animada y llamadas a la acción claras:
/// 1. Exploración general (resumen de animales descubiertos)
/// 2. Vista previa al seleccionar un paradero (con banner notorio y botones claros)
/// 3. Navegación activa hacia el destino con opción para cancelar.
class BarraInferiorMapa extends StatelessWidget {
  final GlobalKey keyAnimales;
  final MarcadorMapa? marcadorSeleccionado;
  final bool isNavigating;
  final List<MarcadorMapa> marcadores;
  final AnimationController bottomBarPulseController;
  final VoidCallback onTapExploraciones;
  final ValueChanged<MarcadorMapa> onSeleccionarAnimal;
  final VoidCallback onCerrarSeleccion;
  final VoidCallback onIniciarNavegacion;
  final VoidCallback onCancelarNavegacion;
  final bool compacta;

  const BarraInferiorMapa({
    super.key,
    required this.keyAnimales,
    required this.marcadorSeleccionado,
    required this.isNavigating,
    required this.marcadores,
    required this.bottomBarPulseController,
    required this.onTapExploraciones,
    required this.onSeleccionarAnimal,
    required this.onCerrarSeleccion,
    required this.onIniciarNavegacion,
    required this.onCancelarNavegacion,
    this.compacta = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        key: keyAnimales,
        padding: EdgeInsets.fromLTRB(
          compacta ? 14 : 22,
          compacta ? 10 : 14,
          compacta ? 14 : 22,
          (compacta ? 10 : 14) + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 14,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutBack,
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.12),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(
              '${marcadorSeleccionado?.id ?? -1}_${isNavigating ? "nav" : "view"}',
            ),
            child: marcadorSeleccionado == null
                ? _buildBarraExploracion(context)
                : (!isNavigating
                      ? _buildBarraVistaPrevia(context)
                      : _buildBarraNavegando(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildBarraExploracion(BuildContext context) {
    final servicio = AnimalService.instance;
    final animales = servicio.obtenerTodosLosAnimales();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onTapExploraciones,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Todos los animales (${animales.length})',
                    style: GoogleFonts.urbanist(
                      fontSize: compacta ? 15 : 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.verdePrincipal,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ver todos',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.verdeAzulado,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: AppColors.verdeAzulado,
                ),
              ],
            ),
          ),
        ),
        if (!compacta)
          Text(
            'Desliza para explorar · ${servicio.totalVisitados} fichas exploradas',
            style: GoogleFonts.urbanist(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.verdeAzulado,
            ),
          ),
        SizedBox(height: compacta ? 4 : 10),
        SizedBox(
          height: compacta ? 76 : 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: animales.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final animal = animales[index];
              return SizedBox(
                width: compacta ? 66 : 76,
                child: InkWell(
                  onTap: () => onSeleccionarAnimal(animal),
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    children: [
                      Container(
                        width: compacta ? 40 : 50,
                        height: compacta ? 40 : 50,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.verdeAzulado,
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(child: ImagenAnimal(animal: animal)),
                      ),
                      SizedBox(height: compacta ? 3 : 5),
                      Text(
                        animal.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.urbanist(
                          fontSize: compacta ? 10 : 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textoOscuro,
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

  Widget _buildBarraVistaPrevia(BuildContext context) {
    final sel = marcadorSeleccionado!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. BANNER NOTORIO DE ATENCIÓN: INDICA CLARAMENTE QUE SE SELECCIONÓ EL ANIMAL
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: sel.esBanio
                ? Colors.blue.shade50
                : AppColors.verdeAzulado.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: sel.esBanio
                  ? Colors.blue.shade300
                  : AppColors.verdeAzulado.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                sel.esBanio ? Icons.wc_rounded : Icons.pets_rounded,
                color: sel.esBanio
                    ? Colors.blue.shade700
                    : AppColors.verdeAzulado,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sel.esBanio
                      ? '📍 ¡Baños seleccionados! Elige una opción abajo 👇'
                      : '📍 ¡Seleccionaste a ${sel.nombre}! Elige una opción abajo 👇',
                  style: GoogleFonts.urbanist(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: sel.esBanio
                        ? Colors.blue.shade800
                        : AppColors.verdeAzulado,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. FILA DE INFORMACIÓN DEL ANIMAL / SERVICIO
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: sel.esBanio
                    ? Colors.blue.shade50
                    : AppColors.verdeAzulado.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: sel.esBanio
                      ? Colors.blue.shade200
                      : AppColors.verdeAzulado.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: sel.esBanio
                    ? Icon(
                        Icons.wc_rounded,
                        color: Colors.blue.shade700,
                        size: 28,
                      )
                    : ImagenAnimal(animal: sel),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sel.esBanio ? 'Servicios Higiénicos' : sel.nombre,
                    style: GoogleFonts.urbanist(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: sel.esBanio
                          ? Colors.blue.shade800
                          : AppColors.textoOscuro,
                    ),
                  ),
                  Text(
                    sel.esBanio
                        ? 'Baños públicos disponibles'
                        : '${sel.habitat} · Ubicación de referencia',
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (!sel.esBanio)
              GestureDetector(
                onTap: () async {
                  SoundService.instance.playButtonTap();
                  await AnimalService.instance.toggleVisitado(sel.id);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: sel.visitado
                        ? const Color(0xFFE8F5E9)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sel.visitado
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade300,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        sel.visitado
                            ? Icons.check_circle_rounded
                            : Icons.add_circle_outline_rounded,
                        size: 14,
                        color: sel.visitado
                            ? const Color(0xFF2E7D32)
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sel.visitado ? 'Visto' : 'Marcar',
                        style: GoogleFonts.urbanist(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: sel.visitado
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.black54, size: 18),
              ),
              onPressed: onCerrarSeleccion,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 3. BOTONES DE ACCIÓN: VER FICHA vs TRAZAR RUTA
        Row(
          children: [
            if (!sel.esBanio) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    SoundService.instance.playButtonTap();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PantallaDetalleAnimal(animal: sel),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.menu_book_rounded,
                    size: 18,
                    color: AppColors.verdePrincipal,
                  ),
                  label: Text(
                    'Ver Ficha',
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.verdePrincipal,
                    side: const BorderSide(
                      color: AppColors.verdePrincipal,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  SoundService.instance.playButtonTap();
                  onIniciarNavegacion();
                },
                icon: const Icon(
                  Icons.navigation_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  sel.esBanio ? 'Ir a los Baños' : 'Trazar ruta',
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sel.esBanio
                      ? Colors.blue.shade600
                      : AppColors.verdeAzulado,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarraNavegando(BuildContext context) {
    final sel = marcadorSeleccionado!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.verdePrincipal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_walk_rounded,
                color: AppColors.verdePrincipal,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navegando hacia ${sel.nombre}',
                    style: GoogleFonts.urbanist(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textoOscuro,
                    ),
                  ),
                  Text(
                    'Ruta peatonal desde la entrada',
                    style: GoogleFonts.urbanist(
                      fontSize: 12.5,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              onPressed: onCancelarNavegacion,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onCancelarNavegacion,
            icon: const Icon(Icons.stop_rounded, size: 18),
            label: Text(
              'Finalizar Navegación',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
