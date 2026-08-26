import 'package:flutter/material.dart';
import '../utils/logger.dart';

/// Supported voice languages for STT and TTS.
enum VoiceLanguage { english, hindi, marathi }

/// Provides language preference for voice interactions.
///
/// Stores the user's preferred language and exposes locale IDs
/// for both STT (speech_to_text) and TTS (flutter_tts).
class VoiceLanguageProvider extends ChangeNotifier {
  VoiceLanguage _language = VoiceLanguage.english;
  bool _hasSelectedLanguage = false;

  VoiceLanguage get language => _language;
  bool get hasSelectedLanguage => _hasSelectedLanguage;

  /// Display name for the current language.
  String get displayName => getDisplayName(_language);

  /// Short label for compact UI (e.g., language selector chip).
  String get shortLabel => getShortLabel(_language);

  /// Flag emoji for the language.
  String get flagEmoji {
    switch (_language) {
      case VoiceLanguage.english:
        return '🇬🇧';
      case VoiceLanguage.hindi:
        return '🇮🇳';
      case VoiceLanguage.marathi:
        return '🇮🇳';
    }
  }

  /// Locale ID for speech_to_text (underscore format).
  String get sttLocaleId {
    switch (_language) {
      case VoiceLanguage.english:
        return 'en_IN';
      case VoiceLanguage.hindi:
        return 'hi_IN';
      case VoiceLanguage.marathi:
        return 'mr_IN';
    }
  }

  /// Language code for flutter_tts (hyphen format).
  String get ttsLanguageCode {
    switch (_language) {
      case VoiceLanguage.english:
        return 'en-IN';
      case VoiceLanguage.hindi:
        return 'hi-IN';
      case VoiceLanguage.marathi:
        return 'mr-IN';
    }
  }

  /// Set the preferred voice language.
  void setLanguage(VoiceLanguage lang) {
    if (_language != lang) {
      _language = lang;
      AppLogger.info(
        'VoiceLanguageProvider',
        'Language changed to: ${getDisplayName(lang)}',
      );
      notifyListeners();
    }
  }

  /// Mark that the user has explicitly selected a language.
  void markLanguageSelected() {
    if (!_hasSelectedLanguage) {
      _hasSelectedLanguage = true;
      notifyListeners();
    }
  }

  /// Cycle to the next language (for quick toggle).
  void cycleLanguage() {
    final values = VoiceLanguage.values;
    final nextIndex = (values.indexOf(_language) + 1) % values.length;
    setLanguage(values[nextIndex]);
    markLanguageSelected();
  }

  // --- Static helpers ---

  static String getDisplayName(VoiceLanguage lang) {
    switch (lang) {
      case VoiceLanguage.english:
        return 'English';
      case VoiceLanguage.hindi:
        return 'हिन्दी';
      case VoiceLanguage.marathi:
        return 'मराठी';
    }
  }

  static String getShortLabel(VoiceLanguage lang) {
    switch (lang) {
      case VoiceLanguage.english:
        return 'EN';
      case VoiceLanguage.hindi:
        return 'हि';
      case VoiceLanguage.marathi:
        return 'मरा';
    }
  }
}
