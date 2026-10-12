import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/sound_service.dart';

/// Servicio centralizado para gestionar llamadas telefónicas de emergencia,
/// asistencia médica y rescate dentro del parque.
class EmergencyService {
  EmergencyService._();
  static final EmergencyService instance = EmergencyService._();

  static const String telefonoEmergenciaZoo = '912321232';
  static const String telefonoCentralMedica = '911';

  /// Inicia directamente una llamada telefónica abriendo el dialer del dispositivo.
  Future<bool> llamar(String telefono) async {
    final cleaned = telefono.replaceAll(RegExp(r'\s+'), '');
    final Uri uri = Uri(scheme: 'tel', path: cleaned);

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      } else {
        return await launchUrl(Uri.parse('tel:$cleaned'));
      }
    } catch (e) {
      debugPrint('No se pudo abrir el marcador telefónico: $e');
      return false;
    }
  }

  /// Muestra una hoja de acción rápida (estilo Apple) para confirmar y contactar
  /// a emergencias o copiar el número telefónico.
  Future<void> mostrarModalEmergencia(BuildContext context) async {
    SoundService.instance.playButtonTap();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barra superior de agarre
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Encabezado con icono SOS
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFEF5350).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.phone_in_talk_rounded,
                  color: Color(0xFFD32F2F),
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'Llamada de Emergencia & Ayuda',
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF8B1E1E),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Atención inmediata 24/7 de primeros auxilios y rescate del parque zoológico.',
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),

              // Botón Principal: Emergencias Zoo
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    llamar(telefonoEmergenciaZoo);
                  },
                  icon: const Icon(
                    Icons.phone_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'Llamar a Emergencias Zoo: $telefonoEmergenciaZoo',
                    style: GoogleFonts.urbanist(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botón Secundario: Central Médica 911
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    llamar(telefonoCentralMedica);
                  },
                  icon: const Icon(
                    Icons.local_hospital_rounded,
                    color: Color(0xFFC62828),
                    size: 20,
                  ),
                  label: Text(
                    'Llamar a Central Médica ($telefonoCentralMedica)',
                    style: GoogleFonts.urbanist(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFC62828),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC62828),
                    side: const BorderSide(
                      color: Color(0xFFEF9A9A),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Botón Copiar Número / Cancelar
              TextButton(
                onPressed: () {
                  Clipboard.setData(
                    const ClipboardData(text: telefonoEmergenciaZoo),
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Número $telefonoEmergenciaZoo copiado al portapapeles',
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      backgroundColor: Colors.black87,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  'Copiar número',
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
