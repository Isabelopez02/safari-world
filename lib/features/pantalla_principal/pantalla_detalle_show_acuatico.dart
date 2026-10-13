import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/sound_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_mapa.dart';

/// Modal y pantalla interactiva del Gran Show Acuático de Focas y Lobos Marinos.
/// Diseñada con alto enfoque en UI/UX: divertida, interactiva y llena de sorpresas.
class PantallaDetalleShowAcuatico extends StatefulWidget {
  const PantallaDetalleShowAcuatico({super.key});

  @override
  State<PantallaDetalleShowAcuatico> createState() =>
      _PantallaDetalleShowAcuaticoState();
}

class _PantallaDetalleShowAcuaticoState extends State<PantallaDetalleShowAcuatico>
    with SingleTickerProviderStateMixin {
  // Estado interactivo de función seleccionada (0: 10:00 AM, 1: 01:00 PM, 2: 04:00 PM)
  int _funcionSeleccionada = 1;

  // Mini-juego interactivo: aplausos del público
  int _contadorAplausos = 148;
  String _mensajeDiversion = '¡Toca abajo para animar a las focas! 👏';

  // Recordatorio de asiento activado
  bool _recordatorioActivado = false;

  // Acrobacia expandida seleccionada
  int? _trucoExpandido = 0;

  late AnimationController _sealBounceController;
  late Animation<double> _sealBounceAnimation;

  final List<Map<String, dynamic>> _funciones = [
    {
      'numero': 'Función 1',
      'horario': '10:00 AM - 10:35 AM',
      'asientos': '8 asientos libres',
      'etiqueta': 'Mañana marina',
      'icono': Icons.wb_sunny_rounded,
    },
    {
      'numero': 'Función 2',
      'horario': '01:00 PM - 01:35 PM',
      'asientos': '14 asientos libres',
      'etiqueta': '¡Función estrella!',
      'icono': Icons.star_rounded,
    },
    {
      'numero': 'Función 3',
      'horario': '04:00 PM - 04:35 PM',
      'asientos': '22 asientos libres',
      'etiqueta': 'Atardecer oceánico',
      'icono': Icons.nights_stay_rounded,
    },
  ];

  final List<Map<String, dynamic>> _trucos = [
    {
      'icono': '⚽',
      'titulo': 'Equilibrio con Pelota',
      'detalle': '¡Sostienen la pelota con la nariz por más de 10 minutos mientras saludan con la aleta!',
    },
    {
      'icono': '🐬',
      'titulo': 'Salto Sincronizado',
      'detalle': '¡Se elevan hasta 3 metros fuera del agua pasando a través de aros de burbujas!',
    },
    {
      'icono': '🎵',
      'titulo': 'Coro de Voces Marinas',
      'detalle': '¡Cantan con divertidos sonidos y aplauden al compás de la música del zoológico!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _sealBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _sealBounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _sealBounceController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _sealBounceController.dispose();
    super.dispose();
  }

  void _aplaudirFocas() {
    SoundService.instance.playButtonTap();
    _sealBounceController.forward(from: 0).then((_) {
      _sealBounceController.reverse();
    });

    final frases = [
      '¡La foca dio una voltereta en el agua! 🌊🦭',
      '¡Te lanzó un saludo con sus aletas! 👏✨',
      '¡Atrapó un pez en pleno vuelo! 🐟🎉',
      '¡Salto triple con chapuzón refrescante! 💦🐬',
      '¡La foca cantó: "¡Honk honk!" 🎶🦭',
    ];

    setState(() {
      _contadorAplausos++;
      _mensajeDiversion = frases[_contadorAplausos % frases.length];
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0077B6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(milliseconds: 1400),
        content: Row(
          children: [
            const Text('👏', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _mensajeDiversion,
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FA),
      body: Stack(
        children: [
          // 1. HERO SUPERIOR CON DEGRADADO OCEÁNICO FESTIVO
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenH * 0.40,
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
                        const Color(0xFF003049).withValues(alpha: 0.85),
                        const Color(0xFF0288D1).withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
                // Burbujas y partículas decorativas
                Positioned(
                  top: 50,
                  right: 25,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. BARRA DE NAVEGACIÓN SUPERIOR
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        SoundService.instance.playButtonTap();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 6),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF003049),
                          size: 18,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('🌊', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            'Show Acuático Zoo',
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. TÍTULO Y PROTAGONISTA INTERACTIVO
          Positioned(
            top: 75,
            left: 20,
            right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB703),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: Text(
                          '🎉 ¡DIVERSIÓN GARANTIZADA!',
                          style: GoogleFonts.urbanist(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF003049),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gran Show de Focas\ny Lobos Marinos',
                        style: GoogleFonts.urbanist(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '📍 Ubicado en el Hábitat de Focas y Lobos Marinos.',
                        style: GoogleFonts.urbanist(
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                // FOCA INTERACTIVA (Al tocarla rebota alegremente)
                GestureDetector(
                  onTap: _aplaudirFocas,
                  child: AnimatedBuilder(
                    animation: _sealBounceAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _sealBounceAnimation.value,
                        child: Container(
                          width: 105,
                          height: 105,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFF00B4D8),
                              width: 3.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 4. CONTENIDO PRINCIPAL SCROLLEABLE E INTERACTIVO
          Positioned(
            top: screenH * 0.30,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // MINI-JUEGO DE APLAUSOS INTERACTIVOS (UX DE DIVERSIÓN)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE0F7FA), Color(0xFFE1F5FE)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFF00B4D8).withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('👏', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 6),
                                    Text(
                                      '¡Anima el Show en Vivo!',
                                      style: GoogleFonts.urbanist(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF0277BD),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '$_contadorAplausos aplausos de exploradores hoy',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    color: Colors.blueGrey[700],
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Botón interactivo de aplauso
                          ElevatedButton.icon(
                            onPressed: _aplaudirFocas,
                            icon: const Icon(Icons.touch_app_rounded, size: 16),
                            label: Text(
                              '¡Aplaudir! 🦭',
                              style: GoogleFonts.urbanist(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0288D1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // SELECTOR INTERACTIVO DE HORARIOS / FUNCIONES
                    Text(
                      'Escoge tu Función de Hoy 🎟️',
                      style: GoogleFonts.urbanist(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toca un horario para seleccionarlo y activar tu asiento:',
                      style: GoogleFonts.urbanist(
                        fontSize: 12.5,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // LISTA DE TARJETAS INTERACTIVAS DE FUNCIONES
                    Column(
                      children: List.generate(_funciones.length, (index) {
                        final item = _funciones[index];
                        final bool isSelected = _funcionSeleccionada == index;

                        return GestureDetector(
                          onTap: () {
                            SoundService.instance.playButtonTap();
                            setState(() {
                              _funcionSeleccionada = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE1F5FE)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0288D1)
                                    : Colors.grey.shade300,
                                width: isSelected ? 2.2 : 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? const Color(0xFF0288D1)
                                          .withValues(alpha: 0.18)
                                      : Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF0288D1)
                                        : Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item['icono'] as IconData,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            item['numero'] as String,
                                            style: GoogleFonts.urbanist(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color: isSelected
                                                  ? const Color(0xFF0277BD)
                                                  : AppColors.textoOscuro,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFF0288D1)
                                                      .withValues(alpha: 0.15)
                                                  : Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item['etiqueta'] as String,
                                              style: GoogleFonts.urbanist(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: isSelected
                                                    ? const Color(0xFF0288D1)
                                                    : Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        item['horario'] as String,
                                        style: GoogleFonts.urbanist(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textoOscuro,
                                        ),
                                      ),
                                      Text(
                                        item['asientos'] as String,
                                        style: GoogleFonts.urbanist(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? const Color(0xFF2E7D32)
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isSelected
                                      ? const Color(0xFF0288D1)
                                      : Colors.grey.shade400,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 14),

                    // BOTÓN INTERACTIVO DE RECORDATORIO DE ASIENTO
                    GestureDetector(
                      onTap: () {
                        SoundService.instance.playButtonTap();
                        setState(() {
                          _recordatorioActivado = !_recordatorioActivado;
                        });
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: _recordatorioActivado
                                ? const Color(0xFF2E7D32)
                                : Colors.grey.shade800,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            content: Row(
                              children: [
                                Icon(
                                  _recordatorioActivado
                                      ? Icons.notifications_active_rounded
                                      : Icons.notifications_off_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _recordatorioActivado
                                        ? '¡Recordatorio guardado para la ${_funciones[_funcionSeleccionada]['numero']}! 🔔'
                                        : 'Recordatorio cancelado',
                                    style: GoogleFonts.urbanist(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _recordatorioActivado
                              ? const Color(0xFFE8F5E9)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _recordatorioActivado
                                ? const Color(0xFF4CAF50)
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _recordatorioActivado
                                  ? Icons.check_circle_rounded
                                  : Icons.notifications_outlined,
                              color: _recordatorioActivado
                                  ? const Color(0xFF2E7D32)
                                  : AppColors.textoOscuro,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _recordatorioActivado
                                  ? 'Recordatorio Activo para mi Función ✓'
                                  : 'Notificarme 15 min antes del show 🔔',
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _recordatorioActivado
                                    ? const Color(0xFF2E7D32)
                                    : AppColors.textoOscuro,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // TRUCOS Y ACROBACIAS INTERACTIVAS (TOCA PARA DESCUBRIR)
                    Text(
                      'Acrobacias y Trucos del Show ✨',
                      style: GoogleFonts.urbanist(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toca cualquier truco para ver la sorpresa:',
                      style: GoogleFonts.urbanist(
                        fontSize: 12.5,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // LISTA INTERACTIVA DE TRUCOS
                    Column(
                      children: List.generate(_trucos.length, (index) {
                        final truco = _trucos[index];
                        final isAbierto = _trucoExpandido == index;

                        return GestureDetector(
                          onTap: () {
                            SoundService.instance.playButtonTap();
                            setState(() {
                              _trucoExpandido = isAbierto ? null : index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isAbierto
                                  ? const Color(0xFFFFF8E1)
                                  : const Color(0xFFF9FBFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isAbierto
                                    ? const Color(0xFFFFB74D)
                                    : Colors.grey.shade200,
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      truco['icono'] as String,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        truco['titulo'] as String,
                                        style: GoogleFonts.urbanist(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: isAbierto
                                              ? const Color(0xFFE65100)
                                              : AppColors.textoOscuro,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isAbierto
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: isAbierto
                                          ? const Color(0xFFE65100)
                                          : Colors.grey,
                                    ),
                                  ],
                                ),
                                if (isAbierto) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    truco['detalle'] as String,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 12.5,
                                      color: Colors.brown.shade800,
                                      fontWeight: FontWeight.w600,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    // BOTÓN NAVEGAR AL ACUARIO (UBICADO EN LAS FOCAS)
                    GestureDetector(
                      onTap: () {
                        SoundService.instance.playButtonTap();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PantallaMapa(
                              animalIdInicial: 'A09',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0288D1),
                              Color(0xFF00B4D8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0288D1)
                                  .withValues(alpha: 0.35),
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
                              'Ir a las Focas (Show Marino) 🧭',
                              style: GoogleFonts.urbanist(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16 + MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
