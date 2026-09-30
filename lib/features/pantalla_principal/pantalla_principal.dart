import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_mapa.dart';
import 'package:zoologico_front/core/data/mock_data.dart';
import 'package:zoologico_front/core/models/area.dart';

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // FAB MÁS ELEGANTE
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: FloatingActionButton.extended(
          elevation: 3,
          backgroundColor: AppColors.verdeAzulado,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PantallaMapa()),
            );
          },
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedMapPin,
            color: Colors.white,
            size: 20,
          ),
          label: const Text(
            'Ver Mapa',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============ 1. HEADER HERO ============
              _buildHero(),

              const SizedBox(height: 28),

              // ============ 2. CONOCE NUESTRAS ÁREAS ============
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Conoce nuestras áreas',
                    style: TextStyle(
                      color: AppColors.textoOscuro,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Ver todas',
                    style: TextStyle(
                      color: AppColors.verdeAzulado,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: MockData.areas
                    .map((area) => _buildAreaCirculo(area))
                    .toList(),
              ),

              const SizedBox(height: 28),

              // ============ 3. TARJETAS ANIMALES / HISTORIA ============
              Row(
                children: [
                  Expanded(
                    child: _buildCardAccion(
                      titulo: 'Conoce a todos\nlos animales',
                      boton: 'Ver animales',
                      icono: Icons.pets,
                      colorFondo: AppColors.fondoGrisClaro,
                      colorBoton: AppColors.verdeAzulado,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildCardAccion(
                      titulo: 'Escucha la historia\ndel animal',
                      boton: 'Escuchar',
                      icono: Icons.headphones_rounded,
                      colorFondo: AppColors.fondoGrisClaro,
                      colorBoton: AppColors.verdeAzulado,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ============ 4. BAÑOS Y EMERGENCIA ============
              Row(
                children: [
                  Expanded(
                    child: _buildCardBano(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildCardEmergencia(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER HERO
  // ============================================================
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/images/pantalla_principal/header.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.15).toInt()),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Capa oscura para que resalte el texto
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.black.withAlpha((255 * 0.35).toInt()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¡Sé parte de la acción!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Únete a nuestros shows interactivos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withAlpha((255 * 0.9).toInt()),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdeAzulado,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'VER HORARIO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CÍRCULO DE ÁREA → FONDO DEL COLOR DEL ÁREA + ÍCONO BLANCO
  // ============================================================
  Widget _buildAreaCirculo(Area area) {
  return Column(
    children: [
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          // 👇 Fondo verde (el mismo que tenías en el ícono)
          color: AppColors.verdeAzulado,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.verdeAzulado.withAlpha((255 * 0.30).toInt()),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        // 👇 Ícono blanco
        child: Icon(
          area.icono,
          color: Colors.white,
          size: 30,
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: 70,
        child: Text(
          area.nombre,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textoOscuro,
          ),
        ),
      ),
    ],
  );
}

  // ============================================================
  // CARD GENÉRICA (animales / historia)
  // ============================================================
  Widget _buildCardAccion({
    required String titulo,
    required String boton,
    required IconData icono,
    required Color colorFondo,
    required Color colorBoton,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono circular arriba
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icono,
              color: colorBoton,
              size: 22,
            ),
          ),
          const Spacer(),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textoOscuro,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorBoton,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                boton,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARD BAÑOS
  // ============================================================
  Widget _buildCardBano() {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: AppColors.fondoAmarillo,
        borderRadius: BorderRadius.circular(20),
      ),
      // 🔑 Recorta los círculos que sobresalgan
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // ============ CÍRCULOS DECORATIVOS ============
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amarilloMostaza.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -25,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amarilloMostaza.withOpacity(0.10),
              ),
            ),
          ),

          // ============ CONTENIDO ============
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🦒 Imagen grande a la izquierda
                Expanded(
                  flex: 5,
                  child: Image.asset(
                    'assets/images/pantalla_principal/bano.png',
                    fit: BoxFit.contain,
                    height: 130,
                  ),
                ),
                const SizedBox(width: 10),
                // 📝 Texto + botón a la derecha
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Encuentra tu baño\nmás cercano',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textoOscuro,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.amarilloMostaza,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Ver baños',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // CARD EMERGENCIA
  // ============================================================
Widget _buildCardEmergencia() {
  return Container(
    height: 170,
    decoration: BoxDecoration(
      color: AppColors.rojoEmergencia,
      borderRadius: BorderRadius.circular(20),
    ),
    clipBehavior: Clip.hardEdge,
    child: Stack(
      children: [
        // ============ CÍRCULOS DECORATIVOS ============
        Positioned(
          top: -30,
          right: -20,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7A1313).withOpacity(0.20),
            ),
          ),
        ),
        Positioned(
          bottom: -25,
          left: -20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7A1313).withOpacity(0.15),
            ),
          ),
        ),

        // ============ CONTENIDO ============
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Image.asset(
                  'assets/images/pantalla_principal/emergencia.png',
                  fit: BoxFit.contain,
                  height: 130,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '¿TIENES ALGUNA\nEMERGENCIA?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '912 321 232',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF7A1313),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7A1313),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'LLAMAR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}