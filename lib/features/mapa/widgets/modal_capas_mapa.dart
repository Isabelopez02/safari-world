import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

/// Modal estilo Google Maps / Disney para filtrar y elegir capas visibles en el mapa.
class ModalCapasMapa extends StatelessWidget {
  final String? habitatSeleccionado;
  final ValueChanged<String?> onHabitatCambiado;
  final ValueChanged<String> onServicioSeleccionado;
  final bool mostrarZonasCalma;
  final ValueChanged<bool> onToggleZonasCalma;

  const ModalCapasMapa({
    super.key,
    required this.habitatSeleccionado,
    required this.onHabitatCambiado,
    required this.onServicioSeleccionado,
    required this.mostrarZonasCalma,
    required this.onToggleZonasCalma,
  });

  static void mostrar(
    BuildContext context, {
    required String? habitatSeleccionado,
    required ValueChanged<String?> onHabitatCambiado,
    required ValueChanged<String> onServicioSeleccionado,
    required bool mostrarZonasCalma,
    required ValueChanged<bool> onToggleZonasCalma,
  }) {
    SoundService.instance.playButtonTap();
    bool estadoCalma = mostrarZonasCalma;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setModalState) => ModalCapasMapa(
          habitatSeleccionado: habitatSeleccionado,
          onHabitatCambiado: onHabitatCambiado,
          onServicioSeleccionado: onServicioSeleccionado,
          mostrarZonasCalma: estadoCalma,
          onToggleZonasCalma: (val) {
            setModalState(() {
              estadoCalma = val;
            });
            onToggleZonasCalma(val);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de agarre
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
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.verdePrincipal.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.layers_rounded,
                      color: AppColors.verdePrincipal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Capas y Filtros del Mapa',
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textoOscuro,
                    ),
                  ),
                ],
              ),
              if (habitatSeleccionado != null)
                TextButton(
                  onPressed: () {
                    SoundService.instance.playButtonTap();
                    onHabitatCambiado(null);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Ver todo',
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.w800,
                      color: AppColors.verdePrincipal,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'HÁBITATS Y ZONAS:',
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textoGris,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChipHabitat(context, 'Todos los animales', null),
              _buildChipHabitat(
                context,
                'Zona Internacional (Sabana)',
                'Zona Internacional',
              ),
              _buildChipHabitat(context, 'Zona Selva', 'Zona Selva'),
              _buildChipHabitat(context, 'Zona Costa', 'Zona Costa'),
              _buildChipHabitat(context, 'Zona Sierra', 'Zona Sierra'),
              _buildChipHabitat(
                context,
                'Granja Interactiva',
                'Granja Interactiva',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ACTIVADOR / SWITCH PARA ZONAS DE CALMA (TEA & DESCANSO)
          Text(
            'ZONAS ESPECIALES:',
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textoGris,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: mostrarZonasCalma
                  ? const Color(0xFFF0FDF4)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: mostrarZonasCalma
                    ? const Color(0xFF10B981).withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.06),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.spa_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zonas de Calma & Silencio',
                        style: GoogleFonts.urbanist(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textoOscuro,
                        ),
                      ),
                      Text(
                        'Espacios de descanso y reducción sensorial (TEA)',
                        style: GoogleFonts.urbanist(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textoGris,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: mostrarZonasCalma,
                  activeTrackColor: const Color(0xFF10B981),
                  onChanged: (val) {
                    SoundService.instance.playButtonTap();
                    onToggleZonasCalma(val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'SERVICIOS ESENCIALES:',
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textoGris,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildServiceCard(
                  context,
                  icono: Icons.wc_rounded,
                  color: AppColors.verdeAzulado,
                  titulo: 'Baños (WC)',
                  subtitulo: '4 módulos',
                  servicioId: 'banio',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildServiceCard(
                  context,
                  icono: Icons.local_cafe_rounded,
                  color: AppColors.amarilloMostaza,
                  titulo: 'Snacks & Café',
                  subtitulo: 'Comida y cafetería',
                  servicioId: 'snacks',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildServiceCard(
                  context,
                  icono: Icons.local_parking_rounded,
                  color: const Color(0xFF546E7A),
                  titulo: 'Parking / Salida',
                  subtitulo: 'Accesos',
                  servicioId: 'estacionamiento',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildServiceCard(
                  context,
                  icono: Icons.confirmation_number_rounded,
                  color: const Color(0xFFD97706),
                  titulo: 'Boletería',
                  subtitulo: 'Entrada oficial',
                  servicioId: 'boleteria',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipHabitat(
    BuildContext context,
    String etiqueta,
    String? valor,
  ) {
    final bool seleccionado = habitatSeleccionado == valor;
    return InkWell(
      onTap: () {
        SoundService.instance.playButtonTap();
        onHabitatCambiado(valor);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.verdePrincipal : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? AppColors.verdePrincipal : Colors.black12,
          ),
        ),
        child: Text(
          etiqueta,
          style: GoogleFonts.urbanist(
            fontSize: 12,
            fontWeight: seleccionado ? FontWeight.w800 : FontWeight.w600,
            color: seleccionado ? Colors.white : AppColors.textoOscuro,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icono,
    required Color color,
    required String titulo,
    required String subtitulo,
    required String servicioId,
  }) {
    return InkWell(
      onTap: () {
        SoundService.instance.playButtonTap();
        onServicioSeleccionado(servicioId);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textoOscuro,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: GoogleFonts.urbanist(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textoGris,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
