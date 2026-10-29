import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_mapa.dart';
import 'package:zoologico_front/features/mapa/widgets/barra_filtros_mapa.dart';
import 'package:zoologico_front/features/mapa/widgets/modal_animales_por_visitar.dart';
import 'package:zoologico_front/features/pantalla_principal/widgets/dialogo_permiso_notificaciones.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Pruebas de Nuevas Funcionalidades: Baños, Accesos y Hábitats', () {
    test('Verifica que existen exactamente 4 servicios higiénicos (baños)', () {
      final banios = AnimalService.instance.obtenerBanios();
      expect(banios.length, equals(4));

      final ids = banios.map((b) => b.id).toList();
      expect(ids, containsAll(['B01', 'B02', 'B03', 'B04']));
      expect(banios.every((b) => b.esBanio), isTrue);
    });

    test('Verifica los accesos, entradas, salidas, estacionamientos y juegos', () {
      final accesos = AnimalService.instance.obtenerAccesos();
      expect(accesos.length, equals(5));

      final ids = accesos.map((a) => a.id).toList();
      expect(ids, containsAll(['ENT_01', 'SAL_01', 'EST_01', 'EST_02', 'JUE_01']));

      // Verifica que el estacionamiento coincide con la zona dibujada en el mapa oficial junto al acceso
      final est01 = accesos.firstWhere((a) => a.id == 'EST_01');
      expect(est01.porcentajeX, closeTo(58.5, 2.0));
      expect(est01.porcentajeY, closeTo(62.5, 2.0));
    });

    test('Verifica contadores de animales por hábitat', () {
      final habitats = AnimalService.instance.obtenerHabitatsPrincipales();
      expect(habitats.length, equals(5));

      int sumaAnimales = 0;
      for (final h in habitats) {
        final totalEnH = AnimalService.instance.totalEnHabitat(h);
        final visitadosEnH = AnimalService.instance.totalVisitadosEnHabitat(h);

        expect(totalEnH, greaterThan(0), reason: 'Hábitat $h no tiene animales');
        expect(visitadosEnH, lessThanOrEqualTo(totalEnH));
        sumaAnimales += totalEnH;
      }

      // La suma de los 5 hábitats debe dar los 41 animales del parque
      expect(sumaAnimales, equals(41));
    });

    testWidgets('ModalAnimalesPorVisitar muestra hábitats con contador "visitados / total" y permite navegación',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModalAnimalesPorVisitar(
              onSeleccionarAnimal: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Debe mostrar el título principal de hábitats
      expect(find.text('Hábitats del Zoológico'), findsOneWidget);
      expect(find.text('Granja Interactiva'), findsOneWidget);
      expect(find.text('Zona Internacional'), findsOneWidget);
      expect(find.text('Zona Costa'), findsOneWidget);

      // Al tocar "Granja Interactiva", debe entrar al nivel 2
      await tester.tap(find.text('Granja Interactiva'));
      await tester.pumpAndSettle();

      // Debe mostrar el botón para volver a los hábitats y la lista de animales
      expect(find.text('Hábitats'), findsOneWidget);
      expect(find.text('Vacas Holstein'), findsOneWidget);

      // Al tocar "Hábitats" vuelve al nivel 1
      await tester.tap(find.text('Hábitats'));
      await tester.pumpAndSettle();

      expect(find.text('Hábitats del Zoológico'), findsOneWidget);
    });

    testWidgets('DialogoPermisoNotificaciones guarda preferencia al permitir o rechazar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DialogoPermisoNotificaciones(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('¡Activa tus Alertas Safari!'), findsOneWidget);
      expect(find.text('Permitir Notificaciones'), findsOneWidget);
      expect(find.text('Quizás más tarde'), findsOneWidget);

      // Tocar en Permitir Notificaciones
      await tester.tap(find.text('Permitir Notificaciones'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(DialogoPermisoNotificaciones.prefKeySolicitadas), isTrue);
      expect(prefs.getBool(DialogoPermisoNotificaciones.prefKeyHabilitadas), isTrue);
    });

    testWidgets('BarraFiltrosMapa permite alternar filtros rápidos (Baños, Estacionamiento, etc.)',
        (WidgetTester tester) async {
      FiltroServicioMapa seleccionado = FiltroServicioMapa.todos;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return BarraFiltrosMapa(
                  filtroSeleccionado: seleccionado,
                  onFiltroCambiado: (f) {
                    setState(() => seleccionado = f);
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Baños'), findsOneWidget);
      expect(find.text('Estacionamiento'), findsOneWidget);
      expect(find.text('Boletería / Entrada'), findsOneWidget);

      // Tocar en Baños
      await tester.tap(find.text('Baños'));
      await tester.pumpAndSettle();
      expect(seleccionado, equals(FiltroServicioMapa.banio));

      // Tocar en Estacionamiento
      await tester.tap(find.text('Estacionamiento'));
      await tester.pumpAndSettle();
      expect(seleccionado, equals(FiltroServicioMapa.estacionamiento));
    });

    testWidgets('PantallaMapa compila y renderiza cabecera, filtros, mapa y cápsula inferior sin errores',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: PantallaMapa(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(PantallaMapa), findsOneWidget);
      expect(find.text('Regresar'), findsOneWidget);
      expect(find.text('SOS'), findsOneWidget);
      expect(find.text('Tus Exploraciones'), findsOneWidget);
      expect(find.text('Explorar'), findsOneWidget);
    });
  });
}
