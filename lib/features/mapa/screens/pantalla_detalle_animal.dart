import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';

import '../widgets/marcador_animado.dart';

class DatosAnimal {
  final String dieta;
  final List<String> alimentos;
  final String horaApertura;
  final String horaCierre;
  final String habitat;
  final String comportamiento;
  final String nombreCientifico;
  final String curiosidad;

  const DatosAnimal({
    required this.dieta,
    required this.alimentos,
    required this.horaApertura,
    required this.horaCierre,
    required this.habitat,
    required this.comportamiento,
    required this.nombreCientifico,
    required this.curiosidad,
  });
}

final Map<String, DatosAnimal> baseDatosAnimales = {
  'Elefante': const DatosAnimal(
    dieta: 'Herbívoro',
    alimentos: ['🌿 Pasto', '🍌 Banano', '🥦 Verduras', '🫐 Frutas'],
    horaApertura: '8:00 AM',
    horaCierre: '5:00 PM',
    habitat: 'Sabana africana',
    comportamiento: 'Social y familiar. Vive en manadas lideradas por la hembra más anciana.',
    nombreCientifico: 'Loxodonta africana',
    curiosidad: 'Pueden recordar el rostro de hasta 1,000 individuos de su manada por décadas.',
  ),
  'León': const DatosAnimal(
    dieta: 'Carnívoro',
    alimentos: ['🥩 Carne roja', '🍗 Aves', '🫀 Vísceras'],
    horaApertura: '9:00 AM',
    horaCierre: '4:30 PM',
    habitat: 'Sabana y pastizales africanos',
    comportamiento: 'Territorial. Vive en manadas llamadas "prides" de hasta 30 individuos.',
    nombreCientifico: 'Panthera leo',
    curiosidad:
        'El rugido de un león puede escucharse hasta 8 km de distancia.',
  ),
  'Tigre': const DatosAnimal(
    dieta: 'Carnívoro',
    alimentos: ['🥩 Carne roja', '🍗 Aves', '🐟 Pescado'],
    horaApertura: '9:00 AM',
    horaCierre: '4:30 PM',
    habitat: 'Bosques tropicales y manglares asiáticos',
    comportamiento: 'Solitario y territorial. Excelente nadador.',
    nombreCientifico: 'Panthera tigris',
    curiosidad: 'El patrón de rayas de cada tigre es único, como las huellas digitales humanas.',
  ),
  'Jirafa': const DatosAnimal(
    dieta: 'Herbívoro',
    alimentos: ['🌿 Hojas de acacia', '🌾 Pasto tierno', '🍃 Ramas altas'],
    horaApertura: '8:00 AM',
    horaCierre: '5:00 PM',
    habitat: 'Sabana africana con árboles altos',
    comportamiento: 'Pacífico. Vive en grupos llamados torres. Duerme solo 30 minutos por día.',
    nombreCientifico: 'Giraffa camelopardalis',
    curiosidad: 'Su lengua mide hasta 45 cm y es de color morado para protegerse del sol.',
  ),
  'Pingüino': const DatosAnimal(
    dieta: 'Carnívoro',
    alimentos: ['🐟 Sardinas', '🦐 Krill', '🦑 Calamares pequeños'],
    horaApertura: '9:00 AM',
    horaCierre: '5:00 PM',
    habitat: 'Costas antárticas y sub-antárticas',
    comportamiento: 'Muy social. Forma colonias de miles de individuos. Monógamo de por vida.',
    nombreCientifico: 'Spheniscidae',
    curiosidad: 'Los pingüinos pueden bucear hasta 500 metros de profundidad.',
  ),
  'Foca': const DatosAnimal(
    dieta: 'Carnívoro',
    alimentos: ['🐟 Peces', '🦑 Calamares', '🦀 Crustáceos'],
    horaApertura: '10:00 AM',
    horaCierre: '4:00 PM',
    habitat: 'Aguas frías y costas rocosas',
    comportamiento: 'Social. Nada en grupos. Muy juguetona en cautiverio.',
    nombreCientifico: 'Phoca vitulina',
    curiosidad: 'Las focas pueden aguantar la respiración hasta 30 minutos bajo el agua.',
  ),
  'Chimpancé': const DatosAnimal(
    dieta: 'Omnívoro',
    alimentos: ['🍌 Frutas', '🌿 Hojas', '🥜 Nueces', '🪲 Insectos'],
    horaApertura: '8:30 AM',
    horaCierre: '4:30 PM',
    habitat: 'Bosques tropicales de África central',
    comportamiento: 'Social. Vive en comunidades jerárquicas complejas con lenguaje propio.',
    nombreCientifico: 'Pan troglodytes',
    curiosidad: 'Los chimpancés fabrican y usan herramientas para obtener alimentos, igual que los humanos.',
  ),
  'Nutria': const DatosAnimal(
    dieta: 'Carnívoro',
    alimentos: ['🐟 Peces', '🦀 Cangrejos', '🐚 Moluscos'],
    horaApertura: '10:00 AM',
    horaCierre: '4:30 PM',
    habitat: 'Ríos y costas del Pacífico',
    comportamiento: 'Social. Descansa flotando en grupos cogidas de la mano para no separarse.',
    nombreCientifico: 'Enhydra lutris',
    curiosidad: 'Las nutrias usan piedras para romper mariscos. Cada una tiene su piedra favorita.',
  ),
};

DatosAnimal _getDatos(String nombre) {
  return baseDatosAnimales[nombre] ??
      const DatosAnimal(
        dieta: 'Omnívoro',
        alimentos: ['🌿 Vegetales', '🍖 Proteínas'],
        horaApertura: '9:00 AM',
        horaCierre: '5:00 PM',
        habitat: 'Zoológico',
        comportamiento: 'Adaptable a múltiples entornos.',
        nombreCientifico: 'Animalia sp.',
        curiosidad:
            '¡Cada animal del zoológico es único y especial a su manera!',
      );
}

class PantallaDetalleAnimal extends StatelessWidget {
  final MarcadorMapa animal;
  const PantallaDetalleAnimal({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    final datos = _getDatos(animal.nombre);
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // FONDO HERO IMAGEN
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenH * 0.44,
            child: Image.asset(
              'assets/images/pantalla_principal/hero_fondo.png',
              fit: BoxFit.cover,
            ),
          ),

          // GRADIENTE SUPERIOR para legibilidad
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // BOTÓN REGRESAR
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
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
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
                  ],
                ),
              ),
            ),
          ),

          // NOMBRE Y NOMBRE CIENTÍFICO
          Positioned(
            top: 90,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        animal.nombre,
                        style: GoogleFonts.urbanist(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: const [
                            Shadow(color: Colors.black45, blurRadius: 10),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      '#${animal.id}',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    datos.nombreCientifico,
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // IMAGEN CIRCULAR FLOTANTE
          Positioned(
            top: screenH * 0.28,
            left: 0,
            right: 0,
            child: Center(
              child: Hero(
                tag: 'animal_icon_${animal.id}',
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.verdeAzulado.withValues(alpha: 0.4),
                      width: 3,
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
                    child: animal.imagen != null
                        ? Image.asset(animal.imagen!, fit: BoxFit.cover)
                        : Icon(
                            animal.icono,
                            size: 75,
                            color: AppColors.verdeAzulado,
                          ),
                  ),
                ),
              ),
            ),
          ),

          // TARJETA BLANCA CONTENIDO
          Positioned(
            top: screenH * 0.4,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 90,
                  left: 24,
                  right: 24,
                  bottom: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BADGES DE ESTADO
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(
                          icon: Icons.restaurant_rounded,
                          label: datos.dieta,
                          color: AppColors.verdePrincipal,
                        ),
                        _buildBadge(
                          icon: Icons.terrain_rounded,
                          label: datos.habitat.split(' ').take(2).join(' '),
                          color: AppColors.verdeAzulado,
                        ),
                        if (animal.visitado)
                          _buildBadge(
                            icon: Icons.check_circle_rounded,
                            label: '✓ Visitado',
                            color: const Color(0xFF2E7D32),
                          ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // HORARIO
                    _sectionTitle('Horario de visita', Icons.schedule_rounded),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.verdeAzulado.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.verdeAzulado.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _scheduleItem(
                            'Abre',
                            datos.horaApertura,
                            Icons.wb_sunny_rounded,
                            Colors.orange,
                          ),
                          Container(
                            height: 36,
                            width: 1,
                            color: Colors.grey.withValues(alpha: 0.25),
                          ),
                          _scheduleItem(
                            'Cierra',
                            datos.horaCierre,
                            Icons.nights_stay_rounded,
                            AppColors.verdeAzulado,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ALIMENTACIÓN
                    _sectionTitle('¿Qué come?', Icons.restaurant_menu_rounded),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: datos.alimentos.map((a) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            a,
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textoOscuro,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    // COMPORTAMIENTO
                    _sectionTitle('Comportamiento', Icons.psychology_rounded),
                    const SizedBox(height: 8),
                    Text(
                      datos.comportamiento,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // CURIOSIDAD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8F5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.verdePrincipal.withValues(
                            alpha: 0.15,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 26)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¿Sabías que?',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.verdePrincipal,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  datos.curiosidad,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    height: 1.45,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.verdePrincipal),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.urbanist(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textoOscuro,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleItem(String label, String time, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.urbanist(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: AppColors.textoOscuro,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
