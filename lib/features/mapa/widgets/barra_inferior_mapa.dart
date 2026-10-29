import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

import 'marcador_animado.dart';
import '../screens/pantalla_detalle_animal.dart';

/// Barra inferior interactiva del mapa del zoológico.
/// Maneja los 3 estados con entrada animada y llamadas a la acción claras:
/// 1. Exploración general (resumen de animales descubiertos)
/// 2. Vista previa al seleccionar un paradero (con banner notorio y botones claros)
/// 3. Navegación activa hacia el destino (con tiempo, distancia y cancelar)
class BarraInferiorMapa extends StatelessWidget {
  final GlobalKey keyAnimales;
  final MarcadorMapa? marcadorSeleccionado;
  final bool isNavigating;
  final List<MarcadorMapa> marcadores;
  final AnimationController bottomBarPulseController;
  final VoidCallback onTapExploraciones;
  final VoidCallback onCerrarSeleccion;
  final VoidCallback onIniciarNavegacion;
  final VoidCallback onCancelarNavegacion;

  const BarraInferiorMapa({
    super.key,
    required this.keyAnimales,
    required this.marcadorSeleccionado,
    required this.isNavigating,
    required this.marcadores,
    required this.bottomBarPulseController,
    required this.onTapExploraciones,
    required this.onCerrarSeleccion,
    required this.onIniciarNavegacion,
    required this.onCancelarNavegacion,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                key: keyAnimales,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarraExploracion(BuildContext context) {
    final int visitados = marcadores.where((m) => m.visitado).length;
    final double pct =
        marcadores.isEmpty ? 0.0 : (visitados / marcadores.length);

    return GestureDetector(
      onTap: onTapExploraciones,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: bottomBarPulseController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -2 * bottomBarPulseController.value),
                child: const Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: AppColors.verdeAzulado,
                  size: 22,
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.explore_rounded,
                          size: 18,
                          color: AppColors.verdeAzulado,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tus Exploraciones',
                          style: GoogleFonts.urbanist(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$visitados de ${marcadores.length} animales descubiertos (${(pct * 100).toInt()}%)',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.verdeAzulado,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        width: 160,
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor:
                              AppColors.verdeAzulado.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.verdeAzulado,
                          ),
                          minHeight: 4.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // BOTÓN ELEGANTE EXPLORAR (Reemplaza los 3 circulitos confusos)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
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
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.verdeAzulado.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Explorar',
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _buildBarraVistaPrevia(BuildContext context) {
    final sel = marcadorSeleccionado!;

    // Distancia y tiempo estimado desde la ubicación actual del usuario (58%, 58% -> 1113.6, 626.4)
    const userPos = Offset(1113.6, 626.4);
    final distPx = (Offset(sel.x, sel.y) - userPos).distance;
    final int metros = (distPx * (800 / 1920)).round().clamp(25, 950);
    final int minutos = math.max(1, (metros / 65).round());

    final bool esServicio = sel.esBanio || sel.tipoServicio != null;
    final Color colorAcento = sel.esBanio
        ? const Color(0xFF0284C7)
        : (sel.colorZona ?? AppColors.verdeAzulado);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. DRAG HANDLE SUTIL (Estilo Bottom Sheet moderno iOS / Material 3)
        Center(
          child: Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // 2. FILA DE INFORMACIÓN DEL ANIMAL / SERVICIO
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // AVATAR DEL ANIMAL O SERVICIO
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: colorAcento.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorAcento.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorAcento.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: sel.esBanio
                    ? const Icon(
                        Icons.wc_rounded,
                        color: Color(0xFF0284C7),
                        size: 28,
                      )
                    : (sel.imagen != null
                        ? Image.asset(sel.imagen!, fit: BoxFit.cover)
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorAcento.withValues(alpha: 0.15),
                                  colorAcento.withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                            child: Icon(
                              sel.icono,
                              color: colorAcento,
                              size: 28,
                            ),
                          )),
              ),
            ),
            const SizedBox(width: 12),

            // TÍTULO Y METADATOS HUMANOS (HÁBITAT + DISTANCIA REAL A PIE)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sel.esBanio ? 'Servicios Higiénicos' : sel.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.urbanist(
                      fontSize: 18.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textoOscuro,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: colorAcento,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          sel.esBanio
                              ? 'Baños públicos · ~$minutos min ($metros m)'
                              : '${sel.habitat} · ~$minutos min a pie ($metros m)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.urbanist(
                            fontSize: 12.5,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // BOTÓN MARCAR VISITADO (Si es animal)
            if (!esServicio) ...[
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
                            : Icons.add_task_rounded,
                        size: 15,
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
            ],

            // BOTÓN CERRAR SELECCIÓN
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.black54, size: 18),
              ),
              onPressed: onCerrarSeleccion,
            ),
          ],
        ),

        const SizedBox(height: 14),

        // 3. BOTONES DE ACCIÓN: VER FICHA vs INICIAR GUÍA
        Row(
          children: [
            if (!esServicio) ...[
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
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.verdePrincipal,
                    side: const BorderSide(
                      color: AppColors.verdePrincipal,
                      width: 1.8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                  sel.esBanio
                      ? 'Guiarme al Baño ($metros m)'
                      : 'Iniciar Guía ($metros m)',
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sel.esBanio
                      ? const Color(0xFF0284C7)
                      : AppColors.verdeAzulado,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                    'Sigue la línea punteada verde en el mapa',
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
                child: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
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
