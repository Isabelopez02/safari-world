import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Servicio singleton para la Audioguía con voz real Text-To-Speech en español.
class AudioGuiaService extends ChangeNotifier {
  AudioGuiaService._() {
    _initTts();
  }

  static final AudioGuiaService instance = AudioGuiaService._();

  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;
  String _currentText = '';

  bool get isPlaying => _isPlaying;
  String get currentText => _currentText;

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('es-ES');
      await _tts.setSpeechRate(0.48); // Velocidad natural y pausada
      await _tts.setPitch(1.0); // Tono natural humano
      await _tts.setVolume(1.0);

      _tts.setStartHandler(() {
        _isPlaying = true;
        notifyListeners();
      });

      _tts.setCompletionHandler(() {
        _isPlaying = false;
        _currentText = '';
        notifyListeners();
      });

      _tts.setCancelHandler(() {
        _isPlaying = false;
        _currentText = '';
        notifyListeners();
      });

      _tts.setPauseHandler(() {
        _isPlaying = false;
        notifyListeners();
      });

      _tts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        _isPlaying = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error inicializando FlutterTTS: $e');
    }
  }

  /// Reproduce o detiene el texto de la audioguía
  Future<void> toggleHablar(String texto) async {
    if (_isPlaying && _currentText == texto) {
      await detener();
    } else {
      await reproducir(texto);
    }
  }

  /// Reproduce el texto en voz alta
  Future<void> reproducir(String texto) async {
    try {
      if (_isPlaying) {
        await _tts.stop();
      }
      _currentText = texto;
      _isPlaying = true;
      notifyListeners();

      // Asegurar idioma español
      await _tts.setLanguage('es-ES');
      await _tts.speak(texto);
    } catch (e) {
      debugPrint('Error al reproducir audio: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Pausa o detiene la reproducción actual
  Future<void> detener() async {
    try {
      await _tts.stop();
      _isPlaying = false;
      _currentText = '';
      notifyListeners();
    } catch (e) {
      debugPrint('Error al detener audio: $e');
    }
  }
}
