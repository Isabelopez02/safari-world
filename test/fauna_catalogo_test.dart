import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoologico_front/core/data/base_datos_animales.dart';
import 'package:zoologico_front/core/data/catalogo_fauna.dart';
import 'package:zoologico_front/core/data/datos_marcadores.dart';
import 'package:zoologico_front/core/services/animal_service.dart';
import 'package:zoologico_front/core/widgets/imagen_animal.dart';
import 'package:zoologico_front/features/mapa/screens/pantalla_detalle_animal.dart';
import 'package:zoologico_front/features/mapa/utils/datos_rutas.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  SharedPreferences.setMockInitialValues({});
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('flutter_tts'),
        (_) async => 1,
      );

  test(
    'Cada ficha tiene una foto, licencia, referencia e información de visita',
    () {
      expect(catalogoFauna.length, greaterThan(41));
      expect(
        marcadoresZoologico.map((a) => a.id).toSet().length,
        marcadoresZoologico.length,
      );
      expect(baseDatosAnimales.length, marcadoresZoologico.length);
      for (final animal in marcadoresZoologico) {
        final ficha = baseDatosAnimales[animal.nombre];
        expect(ficha, isNotNull, reason: animal.nombre);
        expect(animal.imagen, isNotEmpty, reason: animal.nombre);
        expect(ficha!.imagen, animal.imagen, reason: animal.nombre);
        expect(ficha.nombreCientifico, isNotEmpty);
        expect(ficha.descripcion, isNotEmpty);
        expect(ficha.reconocimiento, isNotEmpty);
        expect(ficha.reproduccion, isNotEmpty);
        expect(ficha.recomendaciones.length, greaterThanOrEqualTo(3));
        expect(ficha.referenciaPresencia, isNotEmpty);
        expect(ficha.fuentes.length, greaterThanOrEqualTo(2));
        expect(ficha.autorImagen, isNotEmpty);
        expect(ficha.licenciaImagen, isNotEmpty);
        expect(Uri.parse(ficha.urlImagen).hasAuthority, isTrue);
      }
    },
  );

  test(
    'Todas las fotos se incluyen en el bundle y Flutter puede decodificarlas',
    () async {
      for (final animal in marcadoresZoologico) {
        final bytes = await rootBundle.load(animal.imagen!);
        expect(bytes.lengthInBytes, greaterThan(1000), reason: animal.nombre);
        final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(),
        );
        final frame = await codec.getNextFrame();
        expect(
          frame.image.width,
          greaterThanOrEqualTo(100),
          reason: animal.nombre,
        );
        expect(
          frame.image.height,
          greaterThanOrEqualTo(100),
          reason: animal.nombre,
        );
        frame.image.dispose();
        codec.dispose();
      }
    },
  );

  test('Los registros sin recinto no inventan nodos de navegación', () {
    for (final animal in marcadoresZoologico) {
      if (animal.tieneUbicacionMapa) {
        expect(
          grafoMapa.encontrarRutaMasCorta('entrada', animal.id),
          isNotEmpty,
          reason: animal.nombre,
        );
      } else {
        expect(
          grafoMapa.nodos.containsKey(animal.id),
          isFalse,
          reason: animal.nombre,
        );
      }
    }
  });

  test('La búsqueda reconoce nombres científicos y nombres sin tildes', () {
    expect(
      AnimalService.instance.buscarAnimales('pinguino').single.nombre,
      'Pingüino de Humboldt',
    );
    expect(
      AnimalService.instance.buscarAnimales('Spheniscus humboldti').single.id,
      'A14',
    );
  });

  testWidgets('La foto del catálogo muestra un Image y su nombre accesible', (
    tester,
  ) async {
    final animal = marcadoresZoologico.firstWhere((a) => a.id == 'A14');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            height: 160,
            child: ImagenAnimal(animal: animal),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    expect(
      tester.widget<Image>(find.byType(Image)).semanticLabel,
      'Fotografía de Pingüino de Humboldt',
    );
    expect(find.textContaining('No se pudo cargar'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final ancho in [360.0, 1024.0]) {
    testWidgets('La ficha completa no desborda a ${ancho.toInt()} px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(ancho, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final animal = marcadoresZoologico.firstWhere((a) => a.id == 'A47');
      await tester.pumpWidget(
        MaterialApp(home: PantallaDetalleAnimal(animal: animal)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cómo reconocerlo'), findsOneWidget);
      expect(find.text('Para disfrutar tu visita'), findsOneWidget);
      expect(find.text('Reproducción y crianza'), findsOneWidget);
      expect(find.text('Registro y fuentes'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}
