import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_mapa.dart';

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2E24), // Verde aún más oscuro para igualar el borde
      body: Stack(
        children: [
          // 1. BACKGROUND JUNGLE IMAGE (Mitad superior)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Imagen original
                Image.asset(
                  'assets/images/pantalla_principal/hero_fondo.png',
                  fit: BoxFit.cover,
                ),
                // 🔑 Capa oscura encima
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.55), // arriba más oscuro
                        Colors.black.withOpacity(0.35), // abajo se aclara
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 2. CONTENIDO DESPLAZABLE SOBRE EL FONDO
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --- HEADER CONTENT ---
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0, right: 10.0, top: 20.0, bottom: 20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 13,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                'Visita todas nuestras\nzonas con nuestro mapa',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.urbanist(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaMapa()));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.verdeAzulado,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'EMPESAR A NAVEGAR',
                                  style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Image.asset(
                            'assets/images/pantalla_principal/investigador.png', // Cabra mágica
                            height: 140, // Un poco más pequeño para coincidir
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomRight,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, size: 80, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // --- CUERPO BLANCO Y TARJETA FLOTANTE ---
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Fondo blanco principal con borde redondeado superior
                      Container(
                        margin: const EdgeInsets.only(top: 55), // Reduce top margin to move white background higher
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 65), // Espacio para la tarjeta flotante
                            Text(
                              'Conoce otros de nuestros servicios',
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textoOscuro,
                              ),
                            ),
                            const SizedBox(height: 55),
                            
                            // TARJETAS 3D (Foca y Castor)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Row(
                                children: [
                                  Expanded(child: _buildPopOutCard(
                                    title: 'Show acuaticos',
                                    subtitle: '10am · 1pm · 4pm',
                                    imagePath: 'assets/images/pantalla_principal/foca.png',
                                    topColor: const Color(0xFF335746), // Verde de la foca
                                    onTap: () {},
                                  )),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildPopOutCard(
                                    title: 'Contacto emergencia',
                                    subtitle: '912321232',
                                    imagePath: 'assets/images/pantalla_principal/emergencia.png',
                                    topColor: const Color(0xFF552D37), // Rojo oscuro castor
                                    onTap: () {},
                                  )),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // BANNER DEL MAPA
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Explora nuestro mapa ',
                                        style: GoogleFonts.urbanist(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textoOscuro,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward, size: 16, color: AppColors.textoOscuro),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaMapa())),
                                    child: Container(
                                      height: 120, // Menos alto como en el diseño
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withAlpha((255*0.12).toInt()), blurRadius: 8, offset: const Offset(0, 4))
                                        ],
                                        image: const DecorationImage(
                                          image: AssetImage('assets/images/mapa_zoologico.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                      
                      // --- TARJETA FLOTANTE (Carrusel de Animales) ---
                      Positioned(
                        top: -5, 
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withAlpha((255*0.15).toInt()), blurRadius: 10, offset: const Offset(0, 5))
                            ]
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Expanded(child: Divider(indent: 20, endIndent: 12, color: Colors.grey, thickness: 1)),
                                  Text(
                                    '¿Que animales te falta visitar?',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textoOscuro,
                                    ),
                                  ),
                                  const Expanded(child: Divider(indent: 12, endIndent: 20, color: Colors.grey, thickness: 1)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Carrusel horizontal
                              SizedBox(
                                height: 32,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 15,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  itemBuilder: (context, index) {
                                    final icons = [Icons.flutter_dash, Icons.pets, Icons.cruelty_free, Icons.bug_report, Icons.catching_pokemon];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                      child: Icon(
                                        icons[index % icons.length],
                                        color: Colors.black87,
                                        size: 26,
                                      ),
                                    );
                                  },
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
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TARJETAS 3D VERTICALES
  // ============================================================
  Widget _buildPopOutCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required Color topColor,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Base de la tarjeta
        Container(
          height: 140, // Un poco más chaparrita para igualar proporciones
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha((255*0.08).toInt()), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              // Mitad superior de color (Más alta que la blanca)
              Expanded(
                flex: 13,
                child: Container(
                  decoration: BoxDecoration(
                    color: topColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
              ),
              // Mitad inferior blanca con textos
              Expanded(
                flex: 10,
                child: Container(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Título con línea inferior
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.urbanist(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.verdeAzulado,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            height: 1,
                            width: 60,
                            color: AppColors.verdeAzulado.withAlpha((255*0.5).toInt()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Subtítulo y botón
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.urbanist(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textoOscuro,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: onTap,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.verdeAzulado,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Imagen sobresaliendo
        Positioned(
          top: -40, // Sobresale menos pero con una imagen más grande
          child: Image.asset(
            imagePath,
            height: 125, // Imagen adaptada
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 110,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(100),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, size: 40),
            ),
          ),
        ),
      ],
    );
  }
}