import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoologico_front/core/services/accesibilidad_service.dart';
import 'package:zoologico_front/core/services/notification_service.dart';
import 'package:zoologico_front/core/theme/app_colors.dart';
import 'package:zoologico_front/features/carga_pagina/pantalla_inicio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
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
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AccesibilidadService.instance,
      builder: (context, _) {
        final escalaTexto =
            AccesibilidadService.instance.multiplicadorEscalaTexto;

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
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(escalaTexto),
              ),
              child: child!,
            );
          },
          home: const PantallaInicio(),
        );
      },
    );
  }
}
