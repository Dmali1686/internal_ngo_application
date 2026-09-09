import 'package:flutter/material.dart';
import '../../../core/services/voice_service.dart';
import '../../../core/services/voice_language_config.dart';
import '../../../core/services/voice_text_processor.dart';
import '../../../core/utils/logger.dart';
import '../providers/task_form_provider.dart';

class TaskVoiceAssistant {
  final VoiceService voiceService;
  final TaskFormProvider formProvider;

  bool _isDisposed = false;

  static const int _maxRetries = 3;
  final Map<String, int> _retryCounts = {};

  /// The active language config for this voice session.
  VoiceLanguageConfig _lang = VoiceLanguageConfig.english;

  TaskVoiceAssistant(this.voiceService, this.formProvider);

  /// Call this when the screen is disposed to stop all pending callbacks.
  void abort() {
    _isDisposed = true;
    voiceService.abortVoice();
  }

  void _scrollTo(FocusNode node) {
    if (node.context != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (node.context != null && node.context!.mounted) {
          Scrollable.ensureVisible(
            node.context!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _speak(String text, {VoidCallback? onComplete}) {
    if (_isDisposed) return;
    AppLogger.info('TaskVoiceAssistant', 'Speaking [${_lang.ttsCode}]: $text');
    voiceService.speak(text, languageCode: _lang.ttsCode, onComplete: () {
      if (!_isDisposed && onComplete != null) onComplete();
    });
  }

  void _finishStep(String message) {
    if (_isDisposed) return;
    formProvider.setActiveVoiceField(null);
    _speak(message, onComplete: () {
      voiceService.setVoiceModeActive(false);
    });
  }

  bool _isMaxRetriesReached(String fieldKey) {
    _retryCounts[fieldKey] = (_retryCounts[fieldKey] ?? 0) + 1;
    return _retryCounts[fieldKey]! > _maxRetries;
  }

  void _resetRetry(String fieldKey) {
    _retryCounts.remove(fieldKey);
  }

  void _listenWithCommands({
    required String fieldKey,
    required Function(String text) onResult,
    Function(String text)? onPartial,
    Function()? onRedo,
  }) {
    if (_isDisposed) return;
    voiceService.startListening(
      localeId: _lang.sttLocale,
      onResultPartial: (text) {
        if (_isDisposed) return;
        if (onPartial != null &&
            !VoiceTextProcessor.isCancelCommand(text) &&
            !VoiceTextProcessor.isRedoCommand(text)) {
          onPartial(text);
        }
      },
      onResultFinalized: (text) {
        if (_isDisposed) return;
        if (VoiceTextProcessor.isCancelCommand(text)) {
          formProvider.setActiveVoiceField(null);
          voiceService.setVoiceModeActive(false);
          _speak(_lang.cancelMessage);
          return;
        }

        if (VoiceTextProcessor.isRedoCommand(text)) {
          if (onRedo != null) {
            _resetRetry(fieldKey);
            onRedo();
          }
          return;
        }

        if (text.isEmpty) {
          if (_isMaxRetriesReached(fieldKey)) {
            formProvider.setActiveVoiceField(null);
            _speak(_lang.maxRetriesMessage, onComplete: () {
              voiceService.setVoiceModeActive(false);
            });
          } else {
            _speak(_lang.retryMessage, onComplete: onRedo);
          }
          return;
        }

        _resetRetry(fieldKey);
        onResult(text);
      },
    );
  }

  /// Start the full voice flow using the given language config.
  ///
  /// Pass [VoiceLanguageConfig.english] for the original English-only behavior.
  void startVoiceFlow([VoiceLanguageConfig? config]) {
    _isDisposed = false; // Reset in case assistant is restarted
    _lang = config ?? VoiceLanguageConfig.english;
    voiceService.setVoiceModeActive(true);
    _askForTitle();
  }

  void _askForTitle() {
    if (formProvider.titleController.text.isNotEmpty) {
      _askForDescription();
      return;
    }
    formProvider.setActiveVoiceField('title');
    _scrollTo(formProvider.titleFocus);
    _speak(
      _lang.askTitle,
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'title',
          onPartial: (text) {
            formProvider.titleController.text = text;
          },
          onResult: (text) {
            formProvider.titleController.text =
                VoiceTextProcessor.capitalizeName(text);
            _askForDescription();
          },
          onRedo: _askForTitle,
        );
      },
    );
  }

  void _askForDescription() {
    if (formProvider.descriptionController.text.isNotEmpty) {
      _askForPriority();
      return;
    }
    formProvider.setActiveVoiceField('description');
    _scrollTo(formProvider.descriptionFocus);
    _speak(
      _lang.askDescription,
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'description',
          onPartial: (text) {
            formProvider.descriptionController.text = text;
          },
          onResult: (text) {
            formProvider.descriptionController.text = text;
            _askForPriority();
          },
          onRedo: _askForDescription,
        );
      },
    );
  }

  void _askForPriority() {
    formProvider.setActiveVoiceField('priority');
    _speak(
      _lang.askPriority,
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'priority',
          onResult: (text) {
            // Mixed-language priority matching via VoiceLanguageConfig
            final priority = _lang.matchPriority(text);
            formProvider.setPriority(priority);
            _finishStep(_lang.finishMessage);
          },
          onRedo: _askForPriority,
        );
      },
    );
  }
}
