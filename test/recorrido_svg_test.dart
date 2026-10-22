import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:zoologico_front/core/models/marcador_mapa.dart';
import 'package:zoologico_front/features/mapa/utils/servicio_rutas_svg.dart';
import 'package:zoologico_front/features/mapa/widgets/recorrido_animado_svg.dart';
import 'package:zoologico_front/features/mapa/widgets/ruta_svg_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Trazo extraído directamente de trazo.svg
  const String trazoSvgTest =
      'M610.691,731.409C610.691,731.409 567.312,690.512 567.196,628.788C567.094,574.777 616.81,511.365 616.81,511.365';

  group('Verificación de Trazo SVG con path_drawing y PathMetrics', () {
    test('Parsea string SVG d="..." a un objeto Path válido con path_drawing', () {
      final path = parseSvgPathData(trazoSvgTest);
      expect(path, isNotNull);

      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(0));
      expect(bounds.height, greaterThan(0));
    });

    test('PathMetrics calcula longitud total y getTangentForOffset extrae coordenadas (x, y)', () {
      final path = parseSvgPathData(trazoSvgTest);
      final metrics = path.computeMetrics().toList();

      expect(metrics.isNotEmpty, isTrue);
      final metric = metrics.first;
      final totalLength = metric.length;
      expect(totalLength, greaterThan(100.0));

      // Extraer punto inicial (0%)
      final tangentInicio = metric.getTangentForOffset(0.0);
      expect(tangentInicio, isNotNull);
      expect(tangentInicio!.position.dx, closeTo(610.69, 1.0));
      expect(tangentInicio.position.dy, closeTo(731.40, 1.0));

      // Extraer punto intermedio (50%)
      final tangentMedio = metric.getTangentForOffset(totalLength * 0.5);
      expect(tangentMedio, isNotNull);
      expect(tangentMedio!.position.dx, greaterThan(0));
      expect(tangentMedio.position.dy, greaterThan(0));

      // Extraer punto final (100%)
      final tangentFin = metric.getTangentForOffset(totalLength);
      expect(tangentFin, isNotNull);
      expect(tangentFin!.position.dx, closeTo(616.81, 1.0));
      expect(tangentFin.position.dy, closeTo(511.36, 1.0));
    });

    test('Parsea archivo completo trazo_mapa.svg extrayendo todos los paths', () {
      final file = File('assets/images/trazo_mapa.svg');
      expect(file.existsSync(), isTrue);

      final svgContent = file.readAsStringSync();
      final combinedPath = RecorridoAnimadoSvg.parsearSvgCompleto(svgContent);

      final metrics = combinedPath.computeMetrics().toList();
      expect(metrics.length, greaterThanOrEqualTo(30));

      final totalLength = metrics.fold(0.0, (acc, m) => acc + m.length);
      expect(totalLength, greaterThan(3000.0));
    });
  });

  group('Pruebas de Widget y CustomPainter', () {
    testWidgets('RutaSvgPainter dibuja con color rojo semitransparente y grosor 4px', (tester) async {
      final path = parseSvgPathData(trazoSvgTest);
      final painter = RutaSvgPainter(path: path);

      expect(painter.color, equals(const Color(0x80FF0000)));
      expect(painter.grosor, equals(4.0));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(1920, 1080),
              painter: painter,
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('RecorridoAnimadoSvg anima el marcador Positioned a lo largo de la ruta', (tester) async {
      Offset? posicionCapturada;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecorridoAnimadoSvg(
              svgPathData: trazoSvgTest,
              incluirImagenMapa: false, // Desactivar imagen para test sin assets
              duracion: const Duration(seconds: 2),
              repetirEnBucle: false,
              onPosicionActualizada: (pos) {
                posicionCapturada = pos;
              },
            ),
          ),
        ),
      );

      // Frame inicial (inicio de la ruta)
      await tester.pump();
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byType(Positioned), findsWidgets);
      expect(posicionCapturada, isNotNull);
      expect(posicionCapturada!.dx, closeTo(610.69, 1.0));
      expect(posicionCapturada!.dy, closeTo(731.40, 1.0));

      // Avanzar al 50% de la animación
      await tester.pump(const Duration(seconds: 1));
      expect(posicionCapturada, isNotNull);
      final midX = posicionCapturada!.dx;
      final midY = posicionCapturada!.dy;

      // El marcador se ha desplazado tanto en X como en Y
      expect(midX, isNot(equals(610.69)));
      expect(midY, isNot(equals(731.40)));

      // Avanzar al 100% de la animación (destino)
      await tester.pump(const Duration(seconds: 1));
      expect(posicionCapturada!.dx, closeTo(616.81, 1.0));
      expect(posicionCapturada!.dy, closeTo(511.36, 1.0));
    });

    test('ServicioRutasSvg genera rutas curvas válidas hacia animales de diferentes hábitats', () {
      final chimpance = MarcadorMapa(
        id: 'A01',
        nombre: 'Chimpancé',
        x: 346.0,
        y: 287.0,
        habitat: 'Selva Tropical',
      );
      final leon = MarcadorMapa(
        id: 'A10',
        nombre: 'León',
        x: 1451.0,
        y: 414.0,
        habitat: 'Sabana Africana',
      );
      final vaca = MarcadorMapa(
        id: 'A18',
        nombre: 'Vaca',
        x: 273.0,
        y: 638.0,
        habitat: 'La Granja',
      );

      final rutaChimpance = ServicioRutasSvg.obtenerRutaHacia(chimpance);
      final rutaLeon = ServicioRutasSvg.obtenerRutaHacia(leon);
      final rutaVaca = ServicioRutasSvg.obtenerRutaHacia(vaca);

      expect(rutaChimpance.computeMetrics().isNotEmpty, isTrue);
      expect(rutaLeon.computeMetrics().isNotEmpty, isTrue);
      expect(rutaVaca.computeMetrics().isNotEmpty, isTrue);

      // Verificar que el punto final coincide con la posición del animal
      final ultimoM = rutaChimpance.computeMetrics().last;
      final tangentFinal = ultimoM.getTangentForOffset(ultimoM.length);
      expect(tangentFinal!.position.dx, closeTo(346.0, 1.0));
      expect(tangentFinal.position.dy, closeTo(287.0, 1.0));
    });
  });
}
