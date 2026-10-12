import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_mapa.dart';

class PantallaDetalleShowAcuatico extends StatelessWidget {
  const PantallaDetalleShowAcuatico({super.key});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. IMAGEN HERO CON FONDO ACUÁTICO
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenH * 0.44,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/pantalla_principal/hero_fondo.png',
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.65),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. BOTÓN REGRESAR SUPERIOR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        SoundService.instance.playButtonTap();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Experiencias Zoo',
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. TÍTULO Y BADGE SOBRE EL HERO
          Positioned(
            top: 95,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.verdeAzulado,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🌊 SHOW ESTRELLA EN VIVO',
                    style: GoogleFonts.urbanist(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gran Show de Focas\ny Lobos Marinos',
                  style: GoogleFonts.urbanist(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                    shadows: const [
                      Shadow(color: Colors.black45, blurRadius: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. ANIMAL PROTAGONISTA EN CÍRCULO 3D FLOTANTE
          Positioned(
            top: screenH * 0.28,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.verdeAzulado.withValues(alpha: 0.35),
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/pantalla_principal/foca.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // 5. CUERPO INFERIOR (TARJETA BLANCA SCROLLEABLE TIPO APPLE)
          Positioned(
            top: screenH * 0.40,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: 85,
                  left: 24,
                  right: 24,
                  bottom: 36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BADGES DE ESTADO
                    Row(
                      children: [
                        _buildPillBadge(
                          icon: Icons.place_rounded,
                          label: 'Acuario Central · Zona 09',
                          color: AppColors.verdeAzulado,
                        ),
                        const SizedBox(width: 8),
                        _buildPillBadge(
                          icon: Icons.timer_rounded,
                          label: '35 min de duración',
                          color: AppColors.verdePrincipal,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // DESCRIPCIÓN DEL SHOW
                    Text(
                      'Acerca del Show Acuático',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Disfruta de acrobacias marinas impresionantes, saltos sincronizados y actividades educativas guiadas por nuestros cuidadores certificados. Conoce de cerca la inteligencia de las focas y cómo contribuimos a la preservación del ecosistema oceánico.',
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --- RUTA CIRCULAR DE HORARIOS (INICIO Y FIN) ---
                    Text(
                      'Cronograma de Funciones',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ruta de horarios con inicio y finalización:',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TIMELINE DE 3 FUNCIONES CON NODOS CIRCULARES
                    _buildTimelineFunction(
                      numero: 'Función 1',
                      horaInicio: '10:00 AM',
                      horaFin: '10:35 AM',
                      estado: 'Finalizado',
                      isPast: true,
                    ),
                    const SizedBox(height: 14),
                    _buildTimelineFunction(
                      numero: 'Función 2',
                      horaInicio: '01:00 PM',
                      horaFin: '01:35 PM',
                      estado: 'Próxima función',
                      isHighlight: true,
                    ),
                    const SizedBox(height: 14),
                    _buildTimelineFunction(
                      numero: 'Función 3',
                      horaInicio: '04:00 PM',
                      horaFin: '04:35 PM',
                      estado: 'Por comenzar',
                    ),

                    const SizedBox(height: 32),

                    // BOTÓN VER UBICACIÓN EN EL MAPA
                    GestureDetector(
                      onTap: () {
                        SoundService.instance.playButtonTap();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PantallaMapa(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.verdeAzulado,
                              AppColors.verdePrincipal,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.verdeAzulado.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.near_me_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Cómo llegar al Acuario',
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para el nodo de la ruta circular de inicio a fin
  Widget _buildTimelineFunction({
    required String numero,
    required String horaInicio,
    required String horaFin,
    required String estado,
    bool isHighlight = false,
    bool isPast = false,
  }) {
    final Color mainColor = isHighlight
        ? AppColors.verdeAzulado
        : (isPast ? Colors.grey : AppColors.verdePrincipal);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.verdeAzulado.withValues(alpha: 0.06)
            : const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlight
              ? AppColors.verdeAzulado.withValues(alpha: 0.35)
              : Colors.grey.withValues(alpha: 0.2),
          width: isHighlight ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // NODO CIRCULAR DE INICIO
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mainColor.withValues(alpha: 0.12),
                  border: Border.all(color: mainColor, width: 2),
                ),
                child: Icon(
                  isPast
                      ? Icons.check_circle_rounded
                      : Icons.play_arrow_rounded,
                  color: mainColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Inicio',
                style: GoogleFonts.urbanist(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                horaInicio,
                style: GoogleFonts.urbanist(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textoOscuro,
                ),
              ),
            ],
          ),

          // LÍNEA DE RUTA CONECTORA CON FLECHA
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  Text(
                    numero,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: mainColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: mainColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          estado,
                          style: GoogleFonts.urbanist(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '35 mins',
                    style: GoogleFonts.urbanist(
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // NODO CIRCULAR DE FINALIZACIÓN
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPast
                      ? Colors.grey.withValues(alpha: 0.15)
                      : AppColors.verdePrincipal.withValues(alpha: 0.12),
                  border: Border.all(
                    color: isPast ? Colors.grey : AppColors.verdePrincipal,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.flag_rounded,
                  color: isPast ? Colors.grey : AppColors.verdePrincipal,
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fin',
                style: GoogleFonts.urbanist(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                horaFin,
                style: GoogleFonts.urbanist(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textoOscuro,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
