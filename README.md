# 🐾 ZooExplorer · Guía Interactiva & Expedición Safari

<p align="center">
  <img src="assets/images/logo_zoologico.png" alt="Logo Zoológico" width="180"/>
</p>

<p align="center">
  <strong>Aplicación móvil interactiva para la exploración, educación ambiental y navegación inteligente en el zoológico.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Platforms"/>
  <img src="https://img.shields.io/badge/Design-Urbanist%20%26%20Safari%20UI-2E7D32?style=for-the-badge" alt="Design"/>
  <img src="https://img.shields.io/badge/Audio-Text--To--Speech-E65100?style=for-the-badge&logo=soundcharts&logoColor=white" alt="TTS"/>
</p>

---

## 📖 ¿De qué trata este proyecto?

**ZooExplorer** es una aplicación móvil multiplataforma desarrollada en **Flutter** concebida para transformar por completo la visita tradicional a un parque zoológico. Integra un mapa topológico interactivo en alta resolución, navegación paso a paso con cálculo de rutas mínimas (pathfinding), fichas biológicas interactivas personalizadas por hábitat, audioguías con voz natural y un sistema de gamificación basado en un pasaporte de explorador.

El objetivo es ofrecer una experiencia **intuitiva, animalista y minimalista**, eliminando la fatiga visual de los mapas tradicionales en papel y facilitando el aprendizaje sobre la biodiversidad y conservación de la fauna silvestre.

---

## 🌱 ¿De qué nació este proyecto? (Origen y Motivación)

Este proyecto nació en el ámbito universitario al identificar una problemática común en los parques zoológicos y centros de rescate animal:

1. **Desorientación y mapas estáticos**: Los visitantes suelen depender de folletos de papel que se deterioran fácilmente, no indican la posición del usuario ni ofrecen rutas optimizadas, ocasionando que muchas familias se pierdan o no alcancen a ver a sus animales favoritos.
2. **Falta de accesibilidad y dinamismo**: Los carteles informativos en los recintos suelen tener textos densos que generan fatiga visual en niños y adultos mayores, careciendo de recursos auditivos para personas con baja visión o dificultades de lectura.
3. **Pérdida de espectáculos y actividades**: Los horarios de funciones especiales (como espectáculos acuáticos y charlas biológicas) no cuentan con alertas ni cupos visibles, lo que provoca aglomeraciones o funciones perdidas.
4. **Desconexión con la conservación**: La visita muchas veces se limita a observar sin interactuar ni registrar el aprendizaje.

**La solución:** Crear una herramienta digital moderna que combine **tecnología móvil**, **accesibilidad inclusiva** y **diseño biofílico**, convirtiendo cada visita en una expedición educativa inolvidable.

---

## 🎯 Propósito Central

* **Guiar al visitante en tiempo real:** Facilitar la orientación fluida desde el punto de entrada hacia cualquier recinto animal, servicio higiénico o punto de atención médica.
* **Fomentar la educación y conservación animal:** Brindar datos científicos, dietas, comportamientos y curiosidades validadas sobre cada especie.
* **Inclusión y accesibilidad:** Permitir que cualquier usuario pueda escuchar la audioguía narrada en español en alta voz con un solo toque.
* **Gamificación sana:** Estimular a las familias y niños a recorrer todos los hábitats mediante un pasaporte de explorador con sello digital animado.

---

## 🚀 Características Principales

### 🗺️ 1. Mapa Interactivo y Navegación Inteligente
* Mapa en alta definición con zoom y paneo continuo mediante `InteractiveViewer`.
* **Cálculo de rutas en tiempo real:** Algoritmo de pathfinding basado en un grafo de senderos que traza la ruta más corta hacia el animal seleccionado con animaciones de trazo dinámico (`CustomPainter`).
* **Filtro de Baños y Servicios:** Localización y direccionamiento inmediato al baño más cercano.
* **Punto de ubicación actual:** Indicador visual tipo radar que marca en todo momento la posición del explorador.

### 🦁 2. Fichas de Campo Personalizadas por Hábitat
Cada ficha de animal adapta automáticamente sus tonalidades, gradientes y acentos de acuerdo con su hábitat natural:
* 🦁 **Sabana Africana**: Paleta cálida safari y ámbar dorado.
* 🌴 **Selva Tropical**: Fondo de bruma esmeralda y follaje selvático.
* 🐬 **Mundo Acuático**: Tonos de agua cristalina y azul océano profundo.
* 🚜 **La Granja**: Praderas campestres en tonos verde oliva suave.
* 🏔️ **Bosque & Montaña**: Niebla de montaña y pizarra fresca.

Incluye información clave de campo: nombre científico, dieta diaria, estado de conservación, horarios de exhibición y la sección **"¿Sabías que? 💡"**.

### 🐾 3. Pasaporte de Explorador con Sello Animado
* Al marcar un animal como visitado, la aplicación ejecuta una animación de impacto con rebote elástico (`Curves.elasticOut`) que estampa un **sello oficial de explorador** inclinado a -15° con estilo de tinta de pasaporte.
* La tarjeta del animal conserva su sello de validación permanente.
* Barra de progreso safari en tiempo real que contabiliza el porcentaje total de la expedición completada.

### 🎧 4. Audioguía Oficial (Text-To-Speech Nativo)
* Integración con síntesis de voz real (`flutter_tts`) configurada en español natural.
* Reproductor minimalista con ecualizador de ondas animadas y controles de pausar/reanudar para cada animal y espectáculo.

### 🐬 5. Show Acuático de Focas & Lobos Marinos
* Presentación orgánica y tierna con la imagen transparente del animal marino sobre un header suave sin recortes artificiales.
* Selector de turnos de funciones (mañana, estrella, atardecer) con cupos disponibles.
* Sistema de recordatorios con notificaciones y botón directo de navegación hacia el anfiteatro de las focas.

### 🚨 6. Asistencia de Emergencia SOS
* Botón flotante accesible desde cualquier punto del mapa para desplegar el protocolo de auxilio inmediato, números del guardaparque y primeros auxilios.

---

## 🛠️ Tecnologías y Librerías Utilizadas

| Tecnología | Insignia | Propósito en el Proyecto |
| :--- | :---: | :--- |
| **Flutter SDK** | ![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white) | Framework principal para el desarrollo de la interfaz de usuario multiplataforma (Android & iOS). |
| **Dart** | ![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white) | Lenguaje de programación reactivo, fuertemente tipado y de alto rendimiento. |
| **Google Fonts** | ![Google Fonts](https://img.shields.io/badge/Google_Fonts-Urbanist-4285F4?logo=google&logoColor=white) | Tipografía oficial **Urbanist**, seleccionada por su legibilidad en pantallas móviles y aspecto moderno. |
| **flutter_tts** | ![TTS](https://img.shields.io/badge/flutter__tts-4.2.5-FF6F00) | Motor de síntesis de voz nativo para la reproducción de las audioguías en español. |
| **vector_math** | ![Vector](https://img.shields.io/badge/vector__math-2.1.4-9C27B0) | Cálculo de transformaciones matriciales 2D/3D para el paneo y centrado suave de la cámara del mapa. |
| **shared_preferences** | ![Prefs](https://img.shields.io/badge/shared__preferences-2.5.6-00796B) | Persistencia local ligera para guardar el historial de visitas y estado del pasaporte. |
| **flutter_launcher_icons** | ![Icons](https://img.shields.io/badge/launcher__icons-0.13.1-4CAF50) | Generación y estandarización automática del ícono oficial de la aplicación para todas las densidades de pantalla. |
| **url_launcher** | ![URL](https://img.shields.io/badge/url__launcher-6.3.3-0288D1) | Enlaces externos para llamadas telefónicas de emergencia y servicios del parque. |

---

## 📁 Estructura del Proyecto

El código está estructurado siguiendo los principios de **Feature-First Architecture** y **Clean Code**, separando la lógica transversal (`core`) de los módulos de funcionalidad (`features`):

```text
zoologico_front/
├── assets/
│   └── images/
│       ├── logo_zoologico.png               # Ícono y logotipo oficial
│       ├── mapa_zoologico.png               # Mapa ilustrado de alta definición
│       ├── animales_con_fondo/              # Ilustraciones de recintos por animal
│       └── pantalla_principal/             # Assets (foca 3D, emergencia, fondo)
├── lib/
│   ├── main.dart                            # Punto de entrada de la aplicación
│   ├── core/                                # Núcleo compartido de la aplicación
│   │   ├── data/                            # Datos base, coordenadas y nodos del mapa
│   │   ├── models/                          # Modelos de datos (MarcadorMapa, DatosAnimal)
│   │   ├── services/                        # Servicios singleton (Animal, AudioGuía, Sonido, SOS)
│   │   └── theme/                           # Colores institucionales (AppColors)
│   └── features/                            # Módulos por funcionalidad
│       ├── carga_pagina/                    # Splash screen animado con hojas y logo
│       ├── mapa/                            # Pantalla principal del mapa
│       │   ├── screens/                     # PantallaMapa y PantallaDetalleAnimal
│       │   ├── utils/                       # Algoritmo de pathfinding y rutas
│       │   └── widgets/                     # BarraSuperior, BarraInferior, ModalVisitas, RutaPainter
│       └── pantalla_principal/              # Pantalla de bienvenida, carrusel y show acuático
│           ├── screens/                     # PantallaPrincipal y DetalleShowAcuático
│           └── widgets/                     # HeroHeader, ShowAcuaticoCard, EmergenciaCard
├── android/                                 # Configuración nativa de Android (manifiesto e íconos)
├── ios/                                     # Configuración nativa de iOS (Runner y AppIcon)
└── pubspec.yaml                             # Dependencias, assets y configuración del proyecto
```

---

## 🎨 Identidad Visual y Experiencia de Usuario (UI/UX)

* **Paleta Safari Natural**: Tonos verde bosque (`#2D5A27`), verde azulado laguna (`#1B5E20` / `#00897B`), ámbar safari (`#D97706`) y fondos orgánicos no fatigantes (`#F9FBF9`).
* **Protección contra la fatiga visual**: Se reemplazaron tarjetas saturadas por componentes con bordes suaves, microinteracciones táctiles y tipografía de alto peso visual (`Urbanist 900`).
* **Zonas seguras respetadas**: Todos los modales y barras inferiores consideran dinámicamente el `SafeArea` y los botones de navegación del sistema operativo para evitar superposiciones.

---

## 💻 Instalación y Ejecución

### Requisitos previos
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (versión 3.19.0 o superior).
* [Dart SDK](https://dart.dev/get-dart) (versión 3.3.0 o superior).
* Android Studio / VS Code con extensiones de Flutter y Dart.
* Dispositivo móvil o emulador Android/iOS con soporte de audio.

### Pasos de instalación

1. **Clonar o abrir el repositorio**:
   ```bash
   cd zoologico_front
   ```

2. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

3. **Verificar la integridad del código**:
   ```bash
   flutter analyze
   ```

4. **Ejecutar la aplicación en modo desarrollo**:
   ```bash
   flutter run
   ```

5. **Compilar el archivo APK para producción (Android)**:
   ```bash
   flutter build apk --release
   ```
   El instalador se generará en: `build/app/outputs/flutter-apk/app-release.apk`.

---

## 📄 Licencia y Créditos

Este proyecto ha sido desarrollado con fines académicos y de divulgación para el aprendizaje de desarrollo móvil avanzado en Flutter, arquitectura limpia y diseño de experiencia de usuario (UX) enfocado en la conservación animal.
