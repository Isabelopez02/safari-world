import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_detalle_animal.dart';
import 'package:zoologico_front/features/modo_facil/pantalla_modo_facil.dart';
import 'package:zoologico_front/features/pantalla_principal/widgets/footer_navegacion.dart';
import 'package:zoologico_front/features/perfil/widgets/selector_idioma_perfil.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await IdiomaService.instance.cambiarIdioma(AppIdioma.es);
  });

  group('Pruebas de Idiomas (Español, English, Quechua, Aimara)', () {
    test('IdiomaService soporta los 4 idiomas solicitados', () {
      expect(AppIdioma.values, containsAll([
        AppIdioma.es,
        AppIdioma.en,
        AppIdioma.qu,
        AppIdioma.ay,
      ]));
    });

    test('Cambio a Español, Inglés, Quechua y Aimara traduce claves esenciales', () async {
      // 1. Español
      await IdiomaService.instance.cambiarIdioma(AppIdioma.es);
      expect(IdiomaService.instance.idioma, equals(AppIdioma.es));
      expect(IdiomaService.instance.codigoIdioma, equals('es'));
      expect(IdiomaService.instance.nombreIdioma, equals('Español'));
      expect('nav_inicio'.tr, equals('Inicio'));
      expect('modo_facil'.tr, equals('Modo Fácil'));
      expect('salir'.tr, equals('Salir'));
      expect('cambiar_idioma'.tr, equals('Cambiar Idioma'));

      // 2. Inglés
      await IdiomaService.instance.cambiarIdioma(AppIdioma.en);
      expect(IdiomaService.instance.idioma, equals(AppIdioma.en));
      expect(IdiomaService.instance.codigoIdioma, equals('en'));
      expect(IdiomaService.instance.nombreIdioma, equals('English'));
      expect('nav_inicio'.tr, equals('Home'));
      expect('modo_facil'.tr, equals('Easy Mode'));
      expect('salir'.tr, equals('Exit'));
      expect('cambiar_idioma'.tr, equals('Change Language'));

      // 3. Quechua
      await IdiomaService.instance.cambiarIdioma(AppIdioma.qu);
      expect(IdiomaService.instance.idioma, equals(AppIdioma.qu));
      expect(IdiomaService.instance.codigoIdioma, equals('qu'));
      expect(IdiomaService.instance.nombreIdioma, equals('Quechua (Runasimi)'));
      expect('nav_inicio'.tr, equals('Qallariy'));
      expect('modo_facil'.tr, equals('Ch\'uya Ñan'));
      expect('salir'.tr, equals('Lluqsiy'));
      expect('cambiar_idioma'.tr, equals('Simita Tiyachiy'));

      // 4. Aimara
      await IdiomaService.instance.cambiarIdioma(AppIdioma.ay);
      expect(IdiomaService.instance.idioma, equals(AppIdioma.ay));
      expect(IdiomaService.instance.codigoIdioma, equals('ay'));
      expect(IdiomaService.instance.nombreIdioma, equals('Aimara (Aymar aru)'));
      expect('nav_inicio'.tr, equals('Qallta'));
      expect('modo_facil'.tr, equals('Modo Fácil'));
      expect('salir'.tr, equals('Mistuña'));
      expect('cambiar_idioma'.tr, equals('Aru Mayjt’ayaña'));
    });

    test('Los nombres de los animales y fichas se traducen en los 4 idiomas', () async {
      // 1. Español
      await IdiomaService.instance.cambiarIdioma(AppIdioma.es);
      expect('Leones'.tr, equals('Leones'));
      expect('Vacas Holstein'.tr, equals('Vacas Holstein'));
      expect('Cóndor Andino'.tr, equals('Cóndor Andino'));
      expect('Herbívoro'.tr, equals('Herbívoro'));
      expect('Carnívoro'.tr, equals('Carnívoro'));

      // 2. Inglés
      await IdiomaService.instance.cambiarIdioma(AppIdioma.en);
      expect('Leones'.tr, equals('Lions'));
      expect('Vacas Holstein'.tr, equals('Holstein Cows'));
      expect('Cóndor Andino'.tr, equals('Andean Condor'));
      expect('Herbívoro'.tr, equals('Herbivore'));
      expect('Carnívoro'.tr, equals('Carnivore'));
      expect(
        'Leones_curiosidad'.tr,
        contains('more than 8 kilometers'),
      );

      // 3. Quechua
      await IdiomaService.instance.cambiarIdioma(AppIdioma.qu);
      expect('Leones'.tr, equals('Liyunkuna'));
      expect('Vacas Holstein'.tr, equals('Holstein Wakakuna'));
      expect('Cóndor Andino'.tr, equals('Antikuna Kuntur'));
      expect('Herbívoro'.tr, equals('Qura mikhuq'));
      expect('Carnívoro'.tr, equals('Aycha mikhuq'));

      // 4. Aimara
      await IdiomaService.instance.cambiarIdioma(AppIdioma.ay);
      expect('Leones'.tr, equals('Liyunnaka'));
      expect('Vacas Holstein'.tr, equals('Holstein Wakanaka'));
      expect('Cóndor Andino'.tr, equals('Antinaka Kunturi'));
      expect('Herbívoro'.tr, equals('Ch\'illi manq\'iri'));
      expect('Carnívoro'.tr, equals('Aycha manq\'iri'));
    });

    testWidgets('SelectorIdiomaPerfil muestra las 4 opciones de idioma (incluyendo Aimara)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SelectorIdiomaPerfil(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Español'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Runasimi / Quechua'), findsOneWidget);
      expect(find.text('Aymar aru / Aimara'), findsOneWidget);

      // Cambiar a Aimara tocando en la opción
      await tester.tap(find.text('Aymar aru / Aimara'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(IdiomaService.instance.idioma, equals(AppIdioma.ay));
    });
  });

  group('Pruebas de Modo Fácil y Footer en Modo Fácil y Modo Animal', () {
    testWidgets('PantallaModoFacil tiene barra superior con botón de idioma y salir',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool salio = false;
      await tester.pumpWidget(
        MaterialApp(
          home: PantallaModoFacil(
            onSalirModoFacil: () => salio = true,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Modo Fácil'), findsOneWidget);
      expect(find.text('Salir'), findsOneWidget);
      expect(find.text('🇵🇪 ES'), findsOneWidget);

      // Botón Salir funciona
      await tester.tap(find.text('Salir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(salio, isTrue);
    });

    testWidgets('PantallaModoFacil incluye Footer con 5 pestañas de navegación',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: PantallaModoFacil(
            onSalirModoFacil: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verificar elementos del footer
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Animales'), findsOneWidget);
      expect(find.text('Mapa'), findsOneWidget);
      expect(find.text('Shows'), findsOneWidget);
      expect(find.text('Ayuda'), findsOneWidget);
    });

    testWidgets('En Modo Fácil, al cambiar de idioma en el selector, los textos se actualizan reactivamente',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: PantallaModoFacil(
            onSalirModoFacil: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Cambiar a Aimara programáticamente
      await IdiomaService.instance.cambiarIdioma(AppIdioma.ay);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Comprobar actualización de textos en modo fácil
      expect(find.text('☀️ AY'), findsOneWidget);
      expect(find.text('Mistuña'), findsOneWidget); // Salir en Aimara
      expect(find.text('Qallta'), findsOneWidget); // Inicio en Aimara
      expect(find.text('Uywanaka'), findsOneWidget); // Animales en Aimara
      expect(find.text('Yanapt’a'), findsOneWidget); // Ayuda en Aimara
    });

    testWidgets('PantallaDetalleAnimal (Modo Animal) incluye FooterNavegacion en la parte inferior',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final animalTest = MarcadorMapa.desdePorcentaje(
        id: 'I02',
        nombre: 'León',
        porcentajeX: 30,
        porcentajeY: 50,
        icono: Icons.pets,
        habitat: 'Zona Internacional',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PantallaDetalleAnimal(animal: animalTest),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verificar que Detalle Animal tiene FooterNavegacion
      expect(find.byType(FooterNavegacion), findsOneWidget);
      expect(find.text('León'), findsOneWidget);
      expect(find.text('Marcar en mi pasaporte de visitas 🐾'), findsOneWidget);
    });

    testWidgets('Modo Fácil incluye botón de Micrófono para búsqueda por voz y activa modal',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: PantallaModoFacil(
            onSalirModoFacil: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verificar que el botón de micrófono está presente en el encabezado
      final micIcon = find.byIcon(Icons.mic_rounded);
      expect(micIcon, findsWidgets);

      // Tocar el botón de micrófono
      await tester.tap(micIcon.first);
      await tester.pumpAndSettle();

      // Verificar que el modal de búsqueda por voz se abre
      expect(find.text('Búsqueda por Voz'), findsNWidgets(2));
      expect(find.text('🦁 Leones'), findsOneWidget);
      expect(find.text('🚻 Baño'), findsOneWidget);
    });

    testWidgets('Modo Fácil incluye Botón SOS y activa alerta de emergencia',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: PantallaModoFacil(
            onSalirModoFacil: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tocar el botón SOS en el encabezado
      final sosIcon = find.byIcon(Icons.sos_rounded);
      expect(sosIcon, findsWidgets);

      await tester.tap(sosIcon.first);
      await tester.pumpAndSettle();

      // Verificar que se activa el protocolo SOS con alerta visible
      expect(find.text('¡ALERTA SOS ACTIVADA!'), findsOneWidget);
      expect(find.text('Desactivar Alerta SOS'), findsOneWidget);
      expect(find.textContaining('Tópico'), findsWidgets);
    });
  });
}
