import os

# 1. Update pantalla_mapa.dart
path_mapa = r'c:\Users\USUARIO\Desktop\Universidad\flutter\zoologico_front\zoologico_front\lib\features\mapa\screens\pantalla_mapa.dart'
with open(path_mapa, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace cream background with white
content = content.replace('Color(0xFFFDF6EC)', 'Colors.white')
content = content.replace('AppColors.fondoApp', 'Colors.white')

# Replace Mostaza (Amber) with verdeAzulado (Teal)
content = content.replace('AppColors.amarilloMostaza', 'AppColors.verdeAzulado')
content = content.replace('Color(0xFFDF9F1D)', 'AppColors.verdeAzulado')
content = content.replace('Color(0xFFFDE1A9)', 'AppColors.verdeAzulado.withValues(alpha: 0.7)')

# Update the Bottom Sheet Banner
old_banner = """                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDF9F1D), Color(0xFFFDE1A9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: const Color(0xFFDF9F1D).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.explore, color: Color(0xFFDF9F1D), size: 36),
                      ),"""
                      
new_banner = """                  decoration: BoxDecoration(
                    color: AppColors.verdePrincipal, // Dark green from the seal card
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppColors.verdePrincipal.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.explore, color: AppColors.verdePrincipal, size: 36),
                      ),"""
content = content.replace(old_banner, new_banner)

with open(path_mapa, 'w', encoding='utf-8') as f:
    f.write(content)


# 2. Update marcador_animado.dart
path_marcador = r'c:\Users\USUARIO\Desktop\Universidad\flutter\zoologico_front\zoologico_front\lib\features\mapa\widgets\marcador_animado.dart'
with open(path_marcador, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('AppColors.amarilloMostaza', 'AppColors.verdeAzulado')
content = content.replace('AppColors.fondoApp', 'Colors.white')

with open(path_marcador, 'w', encoding='utf-8') as f:
    f.write(content)


# 3. Update ruta_painter.dart
path_ruta = r'c:\Users\USUARIO\Desktop\Universidad\flutter\zoologico_front\zoologico_front\lib\features\mapa\widgets\ruta_painter.dart'
with open(path_ruta, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('const Color(0xFFDF9F1D)', 'const Color(0xFF0E6568)') # verdeAzulado

with open(path_ruta, 'w', encoding='utf-8') as f:
    f.write(content)


# 4. Update tutorial_overlay.dart
path_tutorial = r'c:\Users\USUARIO\Desktop\Universidad\flutter\zoologico_front\zoologico_front\lib\features\mapa\widgets\tutorial_overlay.dart'
with open(path_tutorial, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('AppColors.amarilloMostaza', 'AppColors.verdeAzulado')

with open(path_tutorial, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updates applied to all files.")
