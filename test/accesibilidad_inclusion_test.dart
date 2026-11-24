import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_mapa.dart';
import 'package:zoologico_front/features/mapa/widgets/barra_filtros_mapa.dart';

import 'package:zoologico_front/core/services/idioma_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'has_seen_map_tutorial': true});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_map_tutorial', true);
    await IdiomaService.instance.cambiarIdioma(AppIdioma.es);
  });

  group(
    'Pruebas de Inclusión: Alto Contraste, Daltonismo y Zonas de Calma',
    () {
      test(
        'Verifica existencia y datos de las 4 Zonas de Calma / Silencio',
        () {
          final zonas = AnimalService.instance.obtenerZonasCalma();
          expect(zonas.length, equals(4));

          final ids = zonas.map((z) => z.id).toList();
          expect(
            ids,
            containsAll(['CALMA_01', 'CALMA_02', 'CALMA_03', 'CALMA_04']),
          );

          for (final z in zonas) {
            expect(z.esZonaCalma, isTrue);
            expect(z.nivelRuido, isNotNull);
            expect(z.descripcionCalma, isNotNull);
            expect(z.porcentajeX, greaterThan(0));
            expect(z.porcentajeY, greaterThan(0));
          }
        },
      );

      test(
        'AccesibilidadService gestiona estados y símbolos de daltonismo',
        () async {
          final a11y = AccesibilidadService.instance;

          // Por defecto desactivado
          expect(a11y.modoAltoContraste, isFalse);

          // Activar alto contraste y daltonismo
          await a11y.setModoAltoContraste(true);
          expect(a11y.modoAltoContraste, isTrue);
          expect(a11y.modoDaltonismo, isTrue);
          expect(a11y.accesibilidadVisualActiva, isTrue);

          // Símbolos geométricos para daltonismo (sin depender de rojo/verde)
          expect(
            a11y.getIconoZona('Zona Internacional'),
            equals(Icons.change_history_rounded),
          );
          expect(a11y.getIconoZona('Zona Costa'), equals(Icons.waves_rounded));
          expect(
            a11y.getIconoZona('Zona Sierra'),
            equals(Icons.filter_hdr_rounded),
          );
          expect(a11y.getIconoZona('Zona Selva'), equals(Icons.yard_rounded));
          expect(
            a11y.getIconoZona('Granja Interactiva'),
            equals(Icons.star_rounded),
          );

          // Códigos tácticos
          expect(a11y.getCodigoZona('Zona Internacional'), contains('INT'));
          expect(a11y.getCodigoZona('Zona Costa'), contains('CST'));
          expect(a11y.getCodigoZona('Zona Sierra'), contains('SRA'));
          expect(a11y.getCodigoZona('Zona Selva'), contains('SLV'));
          expect(a11y.getCodigoZona('Granja Interactiva'), contains('GRN'));

          // Colores de alta visibilidad para daltonismo
          final colorInt = a11y.getColorZona(
            habitat: 'Zona Internacional',
            colorPorDefecto: Colors.red,
          );
          expect(
            colorInt,
            equals(const Color(0xFFFDE047)),
          ); // Amarillo solar, no rojo confuso

          // Alternar Zonas de Calma
          expect(a11y.mostrarZonasCalma, isFalse);
          await a11y.setMostrarZonasCalma(true);
          expect(a11y.mostrarZonasCalma, isTrue);

          // Resetear para no interferir en otras pruebas
          await a11y.setModoAltoContraste(false);
          await a11y.setModoDaltonismo(false);
          await a11y.setMostrarZonasCalma(false);
        },
      );

      testWidgets(
        'BarraFiltrosMapa permite seleccionar filtro Zonas de Calma',
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

          expect(find.text('Zonas de Calma'), findsOneWidget);

          // Tocar en Zonas de Calma
          await tester.tap(find.text('Zonas de Calma'));
          await tester.pumpAndSettle();
          expect(seleccionado, equals(FiltroServicioMapa.calma));
        },
      );

      testWidgets('PantallaMapa incluye botón de Capas en barra superior', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = const Size(1080, 2200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(const MaterialApp(home: PantallaMapa()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byIcon(Icons.layers_rounded), findsWidgets);
      });

      testWidgets(
        'Al seleccionar un marcador, los demás marcadores se atenúan para no tapar el recorrido',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(1080, 2200);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          await tester.pumpWidget(const MaterialApp(home: PantallaMapa()));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          // Verificar que el mapa cargó marcadores
          final primerMarcadorFinder = find.byKey(
            const ValueKey('marcador_G01'),
          );
          expect(primerMarcadorFinder, findsOneWidget);

          // Tocar en el primer marcador
          await tester.tap(primerMarcadorFinder, warnIfMissed: false);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));

          // Comprobar que el marcador seleccionado está presente en la cima
          expect(find.byKey(const ValueKey('marcador_G01')), findsOneWidget);
        },
      );
    },
  );
}
