import 'package:flutter/material.dart';
import 'package:zoologico_front/core/models/onboarding_item.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/pantalla_principal/pantalla_principal.dart';

class PantallaOnboarding extends StatefulWidget {
  const PantallaOnboarding({super.key});

  @override
  State<PantallaOnboarding> createState() => _PantallaOnboardingState();
}

class _PantallaOnboardingState extends State<PantallaOnboarding> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;

  final List<OnboardingItem> _paginas = [
    const OnboardingItem(
      imagePath: 'assets/images/onboarding/onboarding_1.png',
      title: 'Escoge a tu animal a\nvisitar primero',
      description: 'En tu mapa selecciona un animal y te apareceran opciones\npara escoger',
    ),
    const OnboardingItem(
      imagePath: 'assets/images/onboarding/onboarding_2.png',
      title: 'Aprende sobre tus\nanimales favoritos',
      description: 'Escucha sus historias y descubre datos curiosos\nmientras los visitas',
    ),
    const OnboardingItem(
      imagePath: 'assets/images/onboarding/onboarding_3.png',
      title: 'Participa en los\nshows interactivos',
      description: 'Revisa los horarios y no te pierdas la oportunidad\nde ser parte de la acción',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _siguientePagina() {
    if (_paginaActual < _paginas.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Finalizó el onboarding, ir a la pantalla principal
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Botón "Omitir" opcional en la parte superior derecha
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
                  );
                },
                child: const Text(
                  'Omitir',
                  style: TextStyle(
                    color: AppColors.textoGris,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Contenido desplazable (Imágenes, Título, Texto)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _paginaActual = index;
                  });
                },
                itemCount: _paginas.length,
                itemBuilder: (context, index) {
                  final pagina = _paginas[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Imagen central
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              // Aquí asegúrate de tener las imágenes en tu carpeta assets
                              // o usa un fallback en caso de error
                              pagina.imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 100,
                                  color: AppColors.fondoGris,
                                );
                              },
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Indicadores (Puntitos / Pill)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _paginas.length,
                            (indexPunto) => _buildPunto(indexPunto: indexPunto),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Título
                        Text(
                          pagina.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textoOscuro,
                            height: 1.2,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Descripción
                        Text(
                          pagina.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textoOscuro,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Botón Inferior "Siguiente"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _siguientePagina,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdeAzulado,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _paginaActual == _paginas.length - 1 ? 'Empezar' : 'Siguiente',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_paginaActual < _paginas.length - 1) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPunto({required int indexPunto}) {
    bool isActivo = _paginaActual == indexPunto;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 10,
      width: isActivo ? 30 : 10, // Pill ancho si está activo, sino círculo
      decoration: BoxDecoration(
        color: isActivo ? AppColors.verdeAzulado : AppColors.fondoGris,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
