/// Voice language configuration for multilingual task creation voice flow.
///
/// Supports English, Marathi, and Hindi. Priority keyword matching is
/// intentionally mixed-language so users can say "urgent" in any mode.
library;

enum VoiceLanguage { english, marathi, hindi }

class VoiceLanguageConfig {
  final VoiceLanguage language;

  /// TTS language code used by flutter_tts (e.g. 'mr-IN').
  final String ttsCode;

  /// STT locale ID used by speech_to_text (e.g. 'mr_IN').
  final String sttLocale;

  /// Short display name shown in the picker (e.g. 'English').
  final String displayName;

  /// Native-script name shown below displayName (e.g. 'मराठी').
  final String nativeName;

  /// Flag emoji representing the language.
  final String flag;

  // ── Voice prompts ───────────────────────────────────────────────────

  /// System asks for task title.
  final String askTitle;

  /// System asks for task description.
  final String askDescription;

  /// System asks for priority level.
  final String askPriority;

  /// Said when the system didn't catch the user's input.
  final String retryMessage;

  /// Said when voice mode is cancelled.
  final String cancelMessage;

  /// Said after all fields are filled.
  final String finishMessage;

  /// Said when max retries exceeded.
  final String maxRetriesMessage;

  const VoiceLanguageConfig({
    required this.language,
    required this.ttsCode,
    required this.sttLocale,
    required this.displayName,
    required this.nativeName,
    required this.flag,
    required this.askTitle,
    required this.askDescription,
    required this.askPriority,
    required this.retryMessage,
    required this.cancelMessage,
    required this.finishMessage,
    required this.maxRetriesMessage,
  });

  // ── Priority matching ────────────────────────────────────────────────

  /// Returns 'URGENT', 'IMPORTANT', or 'NORMAL' from a recognized text.
  ///
  /// Mixed-language: English keywords always match regardless of selected language.
  String matchPriority(String text) {
    final t = text.toLowerCase();

    // English keywords always match (mixed-language support)
    if (t.contains('urgent') || t.contains('emergency')) return 'URGENT';
    if (t.contains('important') || t.contains('high')) return 'IMPORTANT';

    // Marathi keywords
    if (t.contains('तातडी') ||
        t.contains('तातडीचे') ||
        t.contains('तातडीचा') ||
        t.contains('अर्जंट')) { return 'URGENT'; }
    if (t.contains('महत्त्वाचे') ||
        t.contains('महत्वाचे') ||
        t.contains('महत्त्वाचा') ||
        t.contains('महत्वाचा')) { return 'IMPORTANT'; }
    if (t.contains('सामान्य') || t.contains('साधारण')) { return 'NORMAL'; }

    // Hindi keywords
    if (t.contains('तत्काल') ||
        t.contains('अत्यावश्यक') ||
        t.contains('इमर्जेंसी')) { return 'URGENT'; }
    if (t.contains('महत्वपूर्ण') || t.contains('महत्त्वपूर्ण')) {
      return 'IMPORTANT';
    }
    if (t.contains('सामान्य') || t.contains('साधारण')) { return 'NORMAL'; }

    // Default fallback
    return 'NORMAL';
  }

  // ── Predefined configs ───────────────────────────────────────────────

  static const VoiceLanguageConfig english = VoiceLanguageConfig(
    language: VoiceLanguage.english,
    ttsCode: 'en-IN',
    sttLocale: 'en_IN',
    displayName: 'English',
    nativeName: 'English',
    flag: '🇬🇧',
    askTitle: 'What is the title of the task?',
    askDescription: 'Please say the task description.',
    askPriority: 'Is this task normal, important, or urgent?',
    retryMessage: "I didn't catch that. Please repeat.",
    cancelMessage: 'Task creation voice mode cancelled.',
    finishMessage:
        'Task details filled. Please select the department and assignee manually.',
    maxRetriesMessage: 'Too many retries. Please continue manually.',
  );

  static const VoiceLanguageConfig marathi = VoiceLanguageConfig(
    language: VoiceLanguage.marathi,
    ttsCode: 'mr-IN',
    sttLocale: 'mr_IN',
    displayName: 'Marathi',
    nativeName: 'मराठी',
    flag: '🇮🇳',
    askTitle: 'कार्याचे शीर्षक काय आहे?',
    askDescription: 'कृपया कार्याचे वर्णन सांगा.',
    askPriority:
        'हे कार्य सामान्य आहे, महत्त्वाचे आहे, किंवा तातडीचे आहे?',
    retryMessage: 'मला समजले नाही. कृपया पुन्हा सांगा.',
    cancelMessage: 'व्हॉइस मोड रद्द केला.',
    finishMessage:
        'कार्याचे तपशील भरले. कृपया विभाग आणि नियुक्तकर्ता स्वहस्ते निवडा.',
    maxRetriesMessage: 'जास्त वेळा चुकले. कृपया स्वहस्ते पुढे सुरू ठेवा.',
  );

  static const VoiceLanguageConfig hindi = VoiceLanguageConfig(
    language: VoiceLanguage.hindi,
    ttsCode: 'hi-IN',
    sttLocale: 'hi_IN',
    displayName: 'Hindi',
    nativeName: 'हिंदी',
    flag: '🇮🇳',
    askTitle: 'कार्य का शीर्षक क्या है?',
    askDescription: 'कृपया कार्य का विवरण बताएं।',
    askPriority: 'यह कार्य सामान्य है, महत्वपूर्ण है, या तत्काल है?',
    retryMessage: 'मुझे समझ नहीं आया। कृपया दोबारा बताएं।',
    cancelMessage: 'वॉइस मोड रद्द किया गया।',
    finishMessage:
        'कार्य का विवरण भर दिया। कृपया विभाग और असाइनी मैन्युअल रूप से चुनें।',
    maxRetriesMessage: 'बहुत बार गलत हुआ। कृपया मैन्युअल रूप से जारी रखें।',
  );

  /// All available language configs, in display order.
  static const List<VoiceLanguageConfig> all = [english, marathi, hindi];
}
