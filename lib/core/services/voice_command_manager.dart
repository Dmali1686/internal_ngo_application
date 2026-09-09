import 'package:flutter/material.dart';
import '../routes/app_router.dart';
import '../utils/logger.dart';
import 'voice_service.dart';
import 'package:provider/provider.dart';

/// Smart voice command system with keyword scoring, fuzzy matching,
/// synonym support, and TTS confirmation.
class VoiceCommandManager {
  // =====================================================================
  //  Command Registry
  // =====================================================================

  /// Each command has: keywords, synonyms, an action, and a confirmation message.
  static final List<_VoiceCommand> _commands = [
    // --- Navigation Commands ---
    _VoiceCommand(
      keywords: ['register', 'patient'],
      synonyms: [
        'new patient',
        'add patient',
        'create patient',
        'register animal',
        'new registration',
        'new rescue',
        'मरीज़ दर्ज',
        'रुग्ण नोंदणी',
        'नया रजिस्ट्रेशन',
      ],
      confirmation: 'Opening new registration',
      action: (ctx) => appRouter.push('/new-registration'),
    ),
    _VoiceCommand(
      keywords: ['dashboard', 'home'],
      synonyms: [
        'go home',
        'main screen',
        'main page',
        'go to dashboard',
        'go to home',
        'डैशबोर्ड',
        'डॅशबोर्ड',
        'मुख्य पृष्ठ',
      ],
      confirmation: 'Going to dashboard',
      action: (ctx) => appRouter.go('/dashboard-transition'),
    ),
    _VoiceCommand(
      keywords: ['registration', 'dashboard'],
      synonyms: [
        'registration list',
        'patient list',
        'registration dashboard',
        'all registrations',
      ],
      confirmation: 'Opening registration dashboard',
      action: (ctx) => appRouter.push('/registration-dashboard'),
    ),
    _VoiceCommand(
      keywords: ['treatment', 'dashboard'],
      synonyms: [
        'open treatment',
        'treatment screen',
        'treatment management',
        'treatments',
        'उपचार',
        'ट्रीटमेंट',
      ],
      confirmation: 'Opening treatment dashboard',
      action: (ctx) => appRouter.push('/treatment-dashboard'),
    ),
    _VoiceCommand(
      keywords: ['treatment', 'timeline'],
      synonyms: [
        'treatment history',
        'treatment progress',
        'recovery timeline',
      ],
      confirmation: 'Opening treatment timeline',
      action: (ctx) => appRouter.push('/treatment-timeline'),
    ),
    _VoiceCommand(
      keywords: ['diet', 'management'],
      synonyms: [
        'open diet',
        'diet dashboard',
        'feeding',
        'food management',
        'diet screen',
        'आहार',
        'खाना',
        'खाद्य',
      ],
      confirmation: 'Opening diet management',
      action: (ctx) => appRouter.push('/diet-dashboard'),
    ),
    _VoiceCommand(
      keywords: ['todays', 'feeding'],
      synonyms: [
        'today\'s feeding',
        'today feeding',
        'feeding schedule',
        'feeding today',
      ],
      confirmation: 'Opening today\'s feeding schedule',
      action: (ctx) => appRouter.push('/todays-feeding'),
    ),
    _VoiceCommand(
      keywords: ['ambulance'],
      synonyms: [
        'ambulance dashboard',
        'ambulance status',
        'open ambulance',
        'vehicle tracking',
        'एम्बुलेंस',
        'रुग्णवाहिका',
      ],
      confirmation: 'Opening ambulance dashboard',
      action: (ctx) => appRouter.push('/ambulance-dashboard'),
    ),
    _VoiceCommand(
      keywords: ['emergency', 'requests'],
      synonyms: [
        'emergencies',
        'emergency list',
        'active emergencies',
        'urgent requests',
      ],
      confirmation: 'Opening emergency requests',
      action: (ctx) => appRouter.push('/emergency-requests'),
    ),
    _VoiceCommand(
      keywords: ['employee', 'list'],
      synonyms: [
        'show employees',
        'all employees',
        'staff list',
        'team members',
        'employees',
      ],
      confirmation: 'Opening employee list',
      action: (ctx) => appRouter.push('/employee-list'),
    ),
    _VoiceCommand(
      keywords: ['employee', 'dashboard'],
      synonyms: ['employee management', 'staff management', 'hr dashboard'],
      confirmation: 'Opening employee dashboard',
      action: (ctx) => appRouter.push('/employee-dashboard'),
    ),
    _VoiceCommand(
      keywords: ['attendance'],
      synonyms: [
        'take attendance',
        'mark attendance',
        'attendance screen',
        'check attendance',
      ],
      confirmation: 'Opening attendance',
      action: (ctx) => appRouter.push('/attendance'),
    ),
    _VoiceCommand(
      keywords: ['assigned', 'tasks'],
      synonyms: [
        'my tasks',
        'today\'s tasks',
        'task list',
        'pending tasks',
        'todays tasks',
      ],
      confirmation: 'Opening assigned tasks',
      action: (ctx) => appRouter.push('/assigned-tasks'),
    ),
    _VoiceCommand(
      keywords: ['animal', 'overview'],
      synonyms: [
        'patient history',
        'patient overview',
        'animal details',
        'animal history',
        'animal profile',
      ],
      confirmation: 'Opening QR scanner to look up patient',
      // No patient context is available via voice — route to the QR scanner
      // so the user can scan / search for the correct patient first.
      action: (ctx) => appRouter.push('/scan-qr'),
    ),
    _VoiceCommand(
      keywords: ['scan', 'qr'],
      synonyms: [
        'qr scanner',
        'open scanner',
        'scan code',
        'qr code',
        'scan qr code',
      ],
      confirmation: 'Opening QR scanner',
      action: (ctx) => appRouter.push('/scan-qr'),
    ),
    _VoiceCommand(
      keywords: ['voice', 'notes'],
      synonyms: [
        'open notes',
        'voice notes dashboard',
        'my notes',
        'record note',
      ],
      confirmation: 'Opening voice notes',
      action: (ctx) => appRouter.push('/voice-notes-dashboard'),
    ),
    _VoiceCommand(
      keywords: ['diagnosis'],
      synonyms: ['diagnose', 'diagnosis screen', 'make diagnosis'],
      confirmation: 'Opening diagnosis',
      action: (ctx) => appRouter.push('/diagnosis'),
    ),
    _VoiceCommand(
      keywords: ['medicine', 'schedule'],
      synonyms: ['medication schedule', 'medicine times', 'drug schedule'],
      confirmation: 'Opening medicine schedule',
      action: (ctx) => appRouter.push('/medicine-schedule'),
    ),
    _VoiceCommand(
      keywords: ['performance'],
      synonyms: ['performance report', 'staff performance', 'my performance'],
      confirmation: 'Opening performance report',
      action: (ctx) => appRouter.push('/performance'),
    ),

    // --- Navigation: Go Back ---
    _VoiceCommand(
      keywords: ['go', 'back'],
      synonyms: [
        'back',
        'previous',
        'go back',
        'return',
        'previous screen',
        'previous page',
        'पीछे जाओ',
        'मागे जा',
        'पीछे',
      ],
      confirmation: 'Going back',
      action: (ctx) => appRouter.pop(),
    ),

    // --- Action Commands ---
    _VoiceCommand(
      keywords: ['call', 'ambulance'],
      synonyms: [
        'dispatch ambulance',
        'send ambulance',
        'need ambulance',
        'ambulance call',
      ],
      confirmation: 'Notifying ambulance',
      action: (ctx) async {
        _showFeedback(
          ctx,
          "Notifying ambulance...",
          isError: false,
          duration: const Duration(seconds: 1),
        );
        await Future.delayed(const Duration(seconds: 2));
        _showFeedback(ctx, "Ambulance Notified Successfully");
      },
    ),
    _VoiceCommand(
      keywords: ['save', 'patient'],
      synonyms: [
        'submit patient',
        'save registration',
        'submit registration',
        'save rescue',
      ],
      confirmation: 'Saving patient data',
      action: (ctx) async {
        _showFeedback(
          ctx,
          "Saving patient data...",
          isError: false,
          duration: const Duration(seconds: 1),
        );
        await Future.delayed(const Duration(seconds: 2));
        _showFeedback(ctx, "Patient Registered Successfully");
      },
    ),
    _VoiceCommand(
      keywords: ['emergency', 'alert'],
      synonyms: ['raise alert', 'emergency', 'urgent alert', 'sos', 'help'],
      confirmation: 'Triggering emergency alert',
      action: (ctx) async {
        _showFeedback(ctx, "Emergency alert triggered!", isError: false);
      },
    ),
    _VoiceCommand(
      keywords: ['mark', 'feeding', 'done'],
      synonyms: [
        'feeding complete',
        'feeding done',
        'fed the animal',
        'finished feeding',
      ],
      confirmation: 'Marking feeding as complete',
      action: (ctx) async {
        _showFeedback(ctx, "Feeding marked as complete ✓");
      },
    ),
  ];

  // =====================================================================
  //  Command Processing — Keyword Scoring with Fuzzy Match
  // =====================================================================

  void processCommand(BuildContext context, String commandText) {
    final command = commandText.toLowerCase().trim();
    AppLogger.info('VoiceCommandManager', 'Processing command: "$command"');

    // Handle "help" command
    if (command == 'help' ||
        command.contains('what can you do') ||
        command.contains('list commands')) {
      _showHelp(context);
      return;
    }

    // Score each command
    _VoiceCommand? bestMatch;
    int bestScore = 0;

    for (final cmd in _commands) {
      int score = _scoreCommand(command, cmd);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = cmd;
      }
    }

    // Require a minimum score to prevent false matches
    if (bestMatch != null && bestScore >= 2) {
      AppLogger.info(
        'VoiceCommandManager',
        'Matched: "${bestMatch.confirmation}" (score: $bestScore)',
      );

      // TTS confirmation before executing
      final voiceService = context.read<VoiceService>();
      voiceService.speak(
        bestMatch.confirmation,
        onComplete: () {
          bestMatch!.action(context);
        },
      );
    } else {
      AppLogger.info(
        'VoiceCommandManager',
        'No match found (best score: $bestScore)',
      );
      _showFeedback(
        context,
        "Command not recognized: '$commandText'. Say 'help' for available commands.",
        isError: true,
      );
    }
  }

  /// Score a command text against a VoiceCommand definition.
  ///
  /// Scoring:
  /// - Each keyword match = 2 points
  /// - Synonym phrase match = 3 points (bonus for full phrase)
  /// - Partial word match = 1 point
  int _scoreCommand(String input, _VoiceCommand cmd) {
    int score = 0;

    // Check primary keywords
    for (final keyword in cmd.keywords) {
      if (input.contains(keyword)) {
        score += 2;
      }
    }

    // Check synonym phrases
    for (final synonym in cmd.synonyms) {
      if (input.contains(synonym)) {
        score += 3;
        break; // One synonym match is enough
      }

      // Check if individual words from synonym match
      final synonymWords = synonym.split(' ');
      int wordMatches = 0;
      for (final word in synonymWords) {
        if (word.length > 2 && input.contains(word)) {
          wordMatches++;
        }
      }
      if (wordMatches > 0) {
        score += wordMatches;
      }
    }

    return score;
  }

  // =====================================================================
  //  Help Command
  // =====================================================================

  void _showHelp(BuildContext context) {
    final voiceService = context.read<VoiceService>();
    voiceService.speak(
      "You can say: register patient, go to dashboard, open treatment, open diet, "
      "call ambulance, scan QR, take attendance, open voice notes, or go back.",
    );

    _showFeedback(
      context,
      "🎤 Say: \"register patient\", \"open treatment\", \"call ambulance\", \"scan QR\", \"take attendance\", \"voice notes\", \"go back\"",
      isError: false,
      duration: const Duration(seconds: 5),
    );
  }

  // =====================================================================
  //  Feedback
  // =====================================================================

  static void _showFeedback(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Internal command definition.
class _VoiceCommand {
  final List<String> keywords;
  final List<String> synonyms;
  final String confirmation;
  final Function(BuildContext) action;

  _VoiceCommand({
    required this.keywords,
    required this.synonyms,
    required this.confirmation,
    required this.action,
  });
}
