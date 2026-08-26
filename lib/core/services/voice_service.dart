import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/logger.dart';

class VoiceService extends ChangeNotifier with WidgetsBindingObserver {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isListening = false;
  String _recognizedText = '';
  bool _isInitialized = false;
  bool _isVoiceModeActive = false;
  bool _isSpeaking = false;

  Function(String)? _onResultFinalized;
  Function(String)? _onResultPartial;

  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;
  bool get isInitialized => _isInitialized;
  bool get isVoiceModeActive => _isVoiceModeActive;
  bool get isSpeaking => _isSpeaking;

  void setVoiceModeActive(bool active) {
    if (active) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    _isVoiceModeActive = active;
    notifyListeners();
  }

  VoiceService() {
    _initTts();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      stopSpeaking();
      if (_isListening) {
        cancelListening();
      }
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-IN");
    // Tuned for natural Indian English pace — 0.5 is conversational
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
    _flutterTts.setErrorHandler((msg) {
      AppLogger.error('VoiceService', 'TTS Error: $msg');
      _isSpeaking = false;
      notifyListeners();
    });
    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
  }

  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// Switch TTS language dynamically.
  Future<void> setTtsLanguage(String languageCode) async {
    AppLogger.info('VoiceService', 'Switching TTS language to: $languageCode');
    await _flutterTts.setLanguage(languageCode);
  }

  /// Speak text using TTS.
  ///
  /// Pass [languageCode] to switch TTS language before speaking (e.g. 'hi-IN').
  /// If null, uses the currently set TTS language.
  Future<void> speak(
    String text, {
    VoidCallback? onComplete,
    String? languageCode,
  }) async {
    if (languageCode != null) {
      await setTtsLanguage(languageCode);
    }
    AppLogger.info('VoiceService', 'TTS speaking: $text');
    final result = await _flutterTts.speak(text);
    AppLogger.info('VoiceService', 'TTS speak result: $result');
    if (onComplete != null) {
      // Delay slightly to prevent the microphone from turning on
      // while the speaker is still echoing/finishing.
      await Future.delayed(const Duration(milliseconds: 500));
      AppLogger.info('VoiceService', 'Calling onComplete after speak returns');
      onComplete();
    }
  }

  Future<void> initSpeech() async {
    if (_isInitialized) return;
    try {
      _isInitialized = await _speechToText.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
      );
      if (_isInitialized) {
        AppLogger.info(
          'VoiceService',
          'Speech recognition initialized successfully',
        );
      } else {
        AppLogger.error(
          'VoiceService',
          'User denied speech recognition permission',
        );
      }
    } catch (e) {
      // Reset so we can retry on next attempt
      _isInitialized = false;
      AppLogger.error(
        'VoiceService',
        'Error initializing speech recognition: $e',
      );
    }
    notifyListeners();
  }

  void _onSpeechError(SpeechRecognitionError error) {
    AppLogger.error(
      'VoiceService',
      'Speech recognition error: ${error.errorMsg}',
    );

    // Transient errors like 'error_no_match' or 'error_speech_timeout'
    // should NOT kill voice mode — they just mean the user didn't speak.
    // Only abort on permanent errors.
    final transientErrors = {'error_no_match', 'error_speech_timeout'};
    if (transientErrors.contains(error.errorMsg)) {
      _isListening = false;
      // Trigger the finalized callback with empty text so the retry logic kicks in.
      if (_onResultFinalized != null) {
        final callback = _onResultFinalized!;
        _onResultFinalized = null;
        _onResultPartial = null;
        callback('');
      }
      notifyListeners();
      return;
    }

    // Permanent error — fully abort.
    _isListening = false;
    _onResultFinalized = null;
    _onResultPartial = null;
    setVoiceModeActive(false);
    notifyListeners();
  }

  void _onSpeechStatus(String status) {
    AppLogger.info('VoiceService', 'Speech recognition status: $status');
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      notifyListeners();

      if (_onResultFinalized != null) {
        AppLogger.info(
          'VoiceService',
          'Triggering _onResultFinalized from status change: $status',
        );
        final callback = _onResultFinalized!;
        _onResultFinalized = null;
        _onResultPartial = null;
        callback(_recognizedText);
      } else {
        AppLogger.info(
          'VoiceService',
          '_onResultFinalized is null during status: $status',
        );
      }
    }
  }

  Future<void> startListening({
    required Function(String) onResultFinalized,
    Function(String)? onResultPartial,
    String? localeId,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    if (!_isInitialized) {
      await initSpeech();
    }

    if (_isInitialized) {
      _recognizedText = '';
      _isListening = true;
      notifyListeners();

      // Haptic feedback on listen start
      HapticFeedback.mediumImpact();

      _onResultFinalized = onResultFinalized;
      _onResultPartial = onResultPartial;

      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          AppLogger.info(
            'VoiceService',
            'onResult: recognizedWords="${result.recognizedWords}", finalResult=${result.finalResult}',
          );
          _recognizedText = result.recognizedWords;
          notifyListeners();

          if (_onResultPartial != null) {
            _onResultPartial!(_recognizedText);
          }

          if (result.finalResult) {
            AppLogger.info('VoiceService', 'Final result detected');
            HapticFeedback.lightImpact();
            if (_onResultFinalized != null) {
              final callback = _onResultFinalized!;
              _onResultFinalized = null;
              _onResultPartial = null;
              callback(_recognizedText);
            }
          }
        },
        listenFor: listenFor ?? const Duration(seconds: 20),
        pauseFor: pauseFor ?? const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        localeId: localeId ?? 'en_IN',
      );
    }
  }

  /// Hard cancel — stops TTS and STT without triggering finalization callback.
  Future<void> cancelListening() async {
    AppLogger.info('VoiceService', 'Cancelling listening (no callback)');
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
    _isListening = false;
    _onResultFinalized = null;
    _onResultPartial = null;
    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  Future<void> abortVoice() async {
    AppLogger.info('VoiceService', 'Aborting voice mode');
    await _flutterTts.stop();
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
    _isListening = false;
    _onResultFinalized = null;
    _onResultPartial = null;
    setVoiceModeActive(false);
    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
      _isListening = false;
      HapticFeedback.lightImpact();
      notifyListeners();

      if (_onResultFinalized != null) {
        final callback = _onResultFinalized!;
        _onResultFinalized = null;
        _onResultPartial = null;
        callback(_recognizedText);
      }
    }
  }

  /// Check if a specific locale is available for STT.
  Future<bool> isLocaleAvailable(String localeId) async {
    if (!_isInitialized) await initSpeech();
    final locales = await _speechToText.locales();
    return locales.any((l) => l.localeId == localeId);
  }
}
