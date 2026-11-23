import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/di/injection_container.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/services/idioma_service.dart';
import 'package:zoologico_front/core/services/notification_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/carga_pagina/pantalla_inicio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MiApp());

  // Inicializaciones auxiliares en segundo plano (sin bloquear el hilo principal)
  sl<NotificationService>().init().catchError(
    (e) => debugPrint('Notif init: $e'),
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        sl<AccesibilidadService>(),
        sl<IdiomaService>(),
      ]),
      builder: (context, _) {
        final escalaTexto = sl<AccesibilidadService>().multiplicadorEscalaTexto;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'App Zoológico',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.verdePrincipal,
              primary: AppColors.verdePrincipal,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.urbanistTextTheme(),
            fontFamily: GoogleFonts.urbanist().fontFamily,
          ),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(escalaTexto)),
              child: child!,
            );
          },
          home: const PantallaInicio(),
        );
      },
    );
  }
}
