import 'package:flutter/material.dart';
import '../../../core/services/voice_service.dart';
import '../../../core/services/voice_text_processor.dart';
import '../../../core/services/voice_language_provider.dart';
import '../../../core/services/voice_prompts.dart';
import '../../../core/utils/logger.dart';
import '../providers/registration_provider.dart';

/// Voice-guided registration assistant with retry limits, correction commands,
/// confirmation for critical fields, multi-language TTS/STT, and readback.
class RegistrationVoiceAssistant {
  final VoiceService voiceService;
  final RegistrationProvider formProvider;
  final VoiceLanguageProvider languageProvider;

  /// Max retries per field before falling back to manual input.
  static const int _maxRetries = 3;

  /// Tracks retry count per field key.
  final Map<String, int> _retryCounts = {};

  RegistrationVoiceAssistant(
    this.voiceService,
    this.formProvider,
    this.languageProvider,
  );

  // =====================================================================
  //  HELPERS
  // =====================================================================

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

  // --- Language helpers ---

  VoiceLanguage get _lang => languageProvider.language;
  String get _sttLocale => languageProvider.sttLocaleId;
  String get _ttsLang => languageProvider.ttsLanguageCode;

  /// Get a translated prompt.
  String _prompt(VoicePromptKey key) => VoicePrompts.get(_lang, key);

  /// Get a translated prompt with placeholder substitution.
  String _promptFmt(VoicePromptKey key, Map<String, String> params) =>
      VoicePrompts.format(_lang, key, params);

  /// Speak in the user's preferred language.
  void _speak(String text, {VoidCallback? onComplete}) {
    voiceService.speak(text, onComplete: onComplete, languageCode: _ttsLang);
  }

  /// Increment retry count and return true if max retries exceeded.
  bool _isMaxRetriesReached(String fieldKey) {
    _retryCounts[fieldKey] = (_retryCounts[fieldKey] ?? 0) + 1;
    return _retryCounts[fieldKey]! > _maxRetries;
  }

  /// Reset retry count for a field.
  void _resetRetry(String fieldKey) {
    _retryCounts.remove(fieldKey);
  }

  /// Fallback when max retries exceeded — speak message and end voice mode.
  void _fallbackToManual(String fieldName) {
    AppLogger.info(
      'RegistrationVoiceAssistant',
      'Max retries for $fieldName, falling back to manual',
    );
    formProvider.setActiveVoiceField(null);
    _speak(
      _promptFmt(VoicePromptKey.maxRetriesFallback, {'field': fieldName}),
      onComplete: () {
        voiceService.setVoiceModeActive(false);
      },
    );
  }

  /// Listen and handle cancel/redo commands automatically.
  /// Returns: calls [onResult] with the text, or handles redo/cancel internally.
  void _listenWithCommands({
    required String fieldKey,
    required Function(String text) onResult,
    Function(String text)? onPartial,
    Function()? onRedo,
  }) {
    voiceService.startListening(
      localeId: _sttLocale,
      onResultPartial: (text) {
        if (onPartial != null &&
            !VoiceTextProcessor.isCancelCommand(text) &&
            !VoiceTextProcessor.isRedoCommand(text)) {
          onPartial(text);
        }
      },
      onResultFinalized: (text) {
        AppLogger.info(
          'RegistrationVoiceAssistant',
          'Heard for $fieldKey: "$text"',
        );

        // Handle cancel command
        if (VoiceTextProcessor.isCancelCommand(text)) {
          AppLogger.info(
            'RegistrationVoiceAssistant',
            'Cancel command detected',
          );
          formProvider.setActiveVoiceField(null);
          voiceService.setVoiceModeActive(false);
          _speak(_prompt(VoicePromptKey.voiceCancelled));
          return;
        }

        // Handle redo command
        if (VoiceTextProcessor.isRedoCommand(text)) {
          AppLogger.info('RegistrationVoiceAssistant', 'Redo command detected');
          if (onRedo != null) {
            _resetRetry(fieldKey);
            onRedo();
          }
          return;
        }

        // Handle empty result with retry
        if (text.isEmpty) {
          if (_isMaxRetriesReached(fieldKey)) {
            _fallbackToManual(fieldKey);
          } else {
            _speak(
              _prompt(VoicePromptKey.didntCatchThat),
              onComplete: () {
                if (onRedo != null) onRedo();
              },
            );
          }
          return;
        }

        _resetRetry(fieldKey);
        onResult(text);
      },
    );
  }

  /// Ask a confirmation question: "You said X. Is that correct?"
  void _confirmValue({
    required String fieldKey,
    required String value,
    required String fieldLabel,
    required Function() onConfirmed,
    required Function() onDenied,
  }) {
    _speak(
      _promptFmt(VoicePromptKey.confirmValue, {'value': value}),
      onComplete: () {
        voiceService.startListening(
          localeId: _sttLocale,
          onResultFinalized: (text) {
            if (VoiceTextProcessor.isConfirmation(text)) {
              onConfirmed();
            } else if (VoiceTextProcessor.isDenial(text) ||
                VoiceTextProcessor.isRedoCommand(text)) {
              onDenied();
            } else {
              // Ambiguous — treat as confirmed to keep flow moving
              onConfirmed();
            }
          },
        );
      },
    );
  }

  // =====================================================================
  //  STEP 1: Reporter Details
  // =====================================================================

  void startStep1() {
    AppLogger.info('RegistrationVoiceAssistant', 'Starting Step 1');
    voiceService.setVoiceModeActive(true);
    _askForName();
  }

  void _askForName() {
    if (formProvider.reporterNameController.text.isNotEmpty) {
      _askForMobile();
      return;
    }
    formProvider.setActiveVoiceField('reporterName');
    _scrollTo(formProvider.reporterNameFocus);
    _speak(
      _prompt(VoicePromptKey.askReporterName),
      onComplete: () {
        AppLogger.info(
          'RegistrationVoiceAssistant',
          'TTS complete, starting to listen for Name',
        );
        _listenWithCommands(
          fieldKey: 'reporterName',
          onPartial: (text) {
            formProvider.reporterNameController.text =
                VoiceTextProcessor.capitalizeName(text);
          },
          onResult: (text) {
            AppLogger.info(
              'RegistrationVoiceAssistant',
              'Name finalized: "$text"',
            );
            formProvider.reporterNameController.text =
                VoiceTextProcessor.capitalizeName(text);
            _askForMobile();
          },
          onRedo: _askForName,
        );
      },
    );
  }

  void _askForMobile() {
    if (formProvider.mobileNumberController.text.isNotEmpty) {
      _askForAlternate();
      return;
    }
    formProvider.setActiveVoiceField('mobileNumber');
    _scrollTo(formProvider.mobileNumberFocus);
    _speak(
      _prompt(VoicePromptKey.askMobileNumber),
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'mobileNumber',
          onPartial: (text) {
            final digits = VoiceTextProcessor.extractDigits(text);
            formProvider.mobileNumberController.text = digits;
          },
          onResult: (text) {
            final digits = VoiceTextProcessor.extractDigits(text);
            final validated = VoiceTextProcessor.validateIndianPhone(digits);
            formProvider.mobileNumberController.text = validated ?? digits;

            // Confirm critical field
            _confirmValue(
              fieldKey: 'mobileNumber',
              value: (validated ?? digits).split('').join(' '),
              fieldLabel: 'mobile number',
              onConfirmed: _askForAlternate,
              onDenied: () {
                formProvider.mobileNumberController.clear();
                _askForMobile();
              },
            );
          },
          onRedo: _askForMobile,
        );
      },
    );
  }

  void _askForAlternate() {
    if (formProvider.alternateNumberController.text.isNotEmpty) {
      _finishStep(_prompt(VoicePromptKey.reporterDetailsCompleted));
      return;
    }
    formProvider.setActiveVoiceField('alternateNumber');
    _scrollTo(formProvider.alternateNumberFocus);
    _speak(
      _prompt(VoicePromptKey.askAlternateNumber),
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'alternateNumber',
          onPartial: (text) {
            if (!VoiceTextProcessor.isSkipCommand(text)) {
              final digits = VoiceTextProcessor.extractDigits(text);
              formProvider.alternateNumberController.text = digits;
            }
          },
          onResult: (text) {
            if (VoiceTextProcessor.isSkipCommand(text)) {
              _finishStep(_prompt(VoicePromptKey.reporterDetailsCompleted));
            } else {
              final digits = VoiceTextProcessor.extractDigits(text);
              final validated = VoiceTextProcessor.validateIndianPhone(digits);
              formProvider.alternateNumberController.text = validated ?? digits;
              _finishStep(_prompt(VoicePromptKey.reporterDetailsCompleted));
            }
          },
          onRedo: _askForAlternate,
        );
      },
    );
  }

  // =====================================================================
  //  STEP 2: Rescue Location
  // =====================================================================

  void startStep2() {
    AppLogger.info('RegistrationVoiceAssistant', 'Starting Step 2');
    voiceService.setVoiceModeActive(true);
    _askForAddress();
  }

  void _askForAddress() {
    if (formProvider.addressController.text.isNotEmpty) {
      _askForLandmark();
      return;
    }
    formProvider.setActiveVoiceField('address');
    _scrollTo(formProvider.addressFocus);
    _speak(
      _prompt(VoicePromptKey.askAddress),
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'address',
          onPartial: (text) {
            formProvider.addressController.text = text;
          },
          onResult: (text) {
            formProvider.addressController.text = text;
            _askForLandmark();
          },
          onRedo: _askForAddress,
        );
      },
    );
  }

  void _askForLandmark() {
    if (formProvider.landmarkController.text.isNotEmpty) {
      _askForArea();
      return;
    }
    formProvider.setActiveVoiceField('landmark');
    _scrollTo(formProvider.landmarkFocus);
    _speak(
      _prompt(VoicePromptKey.askLandmark),
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'landmark',
          onPartial: (text) {
            if (!VoiceTextProcessor.isSkipCommand(text)) {
              formProvider.landmarkController.text = text;
            }
          },
          onResult: (text) {
            if (!VoiceTextProcessor.isSkipCommand(text)) {
              formProvider.landmarkController.text = text;
            }
            _askForArea();
          },
          onRedo: _askForLandmark,
        );
      },
    );
  }

  void _askForArea() {
    if (formProvider.areaController.text.isNotEmpty) {
      _askForCity();
      return;
    }
    formProvider.setActiveVoiceField('area');
    _scrollTo(formProvider.areaFocus);
    _speak(
      _prompt(VoicePromptKey.askArea),
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'area',
          onPartial: (text) {
            formProvider.areaController.text = text;
          },
          onResult: (text) {
            formProvider.areaController.text = text;
            _askForCity();
          },
          onRedo: _askForArea,
        );
      },
    );
  }

  void _askForCity() {
    if (formProvider.cityController.text.isNotEmpty) {
      _askForPincode();
      return;
    }
    formProvider.setActiveVoiceField('city');
    _scrollTo(formProvider.cityFocus);
    _speak(
      _prompt(VoicePromptKey.askCity),
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'city',
          onPartial: (text) {
            formProvider.cityController.text = text;
          },
          onResult: (text) {
            formProvider.cityController.text = text;
            _askForPincode();
          },
          onRedo: _askForCity,
        );
      },
    );
  }

  void _askForPincode() {
    if (formProvider.pincodeController.text.isNotEmpty) {
      _finishStep("Location details completed.");
      return;
    }
    formProvider.setActiveVoiceField('pincode');
    _scrollTo(formProvider.pincodeFocus);
    _speak(
      _prompt(VoicePromptKey.askPincode),
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'pincode',
          onPartial: (text) {
            if (!VoiceTextProcessor.isSkipCommand(text)) {
              final digits = VoiceTextProcessor.extractDigits(text);
              formProvider.pincodeController.text = digits;
            }
          },
          onResult: (text) {
            if (VoiceTextProcessor.isSkipCommand(text)) {
              _finishStep("Location details completed.");
              return;
            }
            final digits = VoiceTextProcessor.extractDigits(text);
            final validated = VoiceTextProcessor.validatePincode(digits);
            formProvider.pincodeController.text = validated ?? digits;

            // Confirm critical field
            _confirmValue(
              fieldKey: 'pincode',
              value: (validated ?? digits).split('').join(' '),
              fieldLabel: 'pin code',
              onConfirmed: () => _finishStep("Location details completed."),
              onDenied: () {
                formProvider.pincodeController.clear();
                _askForPincode();
              },
            );
          },
          onRedo: _askForPincode,
        );
      },
    );
  }

  // =====================================================================
  //  STEP 3: Animal Details
  // =====================================================================

  void startStep3() {
    AppLogger.info('RegistrationVoiceAssistant', 'Starting Step 3');
    voiceService.setVoiceModeActive(true);
    _askForAnimalType();
  }

  void _askForAnimalType() {
    if (formProvider.breedController.text.isNotEmpty) {
      _askForBreed();
      return;
    }
    formProvider.setActiveVoiceField('breed');
    _scrollTo(formProvider.breedFocus);
    _speak(
      _prompt(VoicePromptKey.askAnimalType),
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'animalType',
          onResult: (text) {
            String t = text.toLowerCase();
            if (t.contains('dog') ||
                t.contains('कुत्रा') ||
                t.contains('कुत्ता')) {
              formProvider.updateAnimalType('Dog');
            } else if (t.contains('cat') ||
                t.contains('मांजर') ||
                t.contains('बिल्ली')) {
              formProvider.updateAnimalType('Cat');
            } else if (t.contains('cow') || t.contains('गाय')) {
              formProvider.updateAnimalType('Cow');
            } else if (t.contains('bird') ||
                t.contains('पक्षी') ||
                t.contains('चिड़िया')) {
              formProvider.updateAnimalType('Bird');
            } else if (t.contains('horse') ||
                t.contains('घोडा') ||
                t.contains('घोड़ा')) {
              formProvider.updateAnimalType('Horse');
            } else {
              formProvider.updateAnimalType('Other');
            }
            _askForBreed();
          },
          onRedo: _askForAnimalType,
        );
      },
    );
  }

  void _askForBreed() {
    if (formProvider.breedController.text.isNotEmpty) {
      _askForGender();
      return;
    }
    formProvider.setActiveVoiceField('breed');
    _scrollTo(formProvider.breedFocus);
    _speak(
      _prompt(VoicePromptKey.askBreed),
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'breed',
          onPartial: (text) {
            if (!VoiceTextProcessor.isSkipCommand(text)) {
              formProvider.breedController.text =
                  VoiceTextProcessor.capitalizeName(text);
            }
          },
          onResult: (text) {
            if (!VoiceTextProcessor.isSkipCommand(text)) {
              formProvider.breedController.text =
                  VoiceTextProcessor.capitalizeName(text);
            }
            _askForGender();
          },
          onRedo: _askForBreed,
        );
      },
    );
  }

  void _askForGender() {
    if (formProvider.gender != 'Unknown' && formProvider.gender.isNotEmpty) {
      _askForWeight();
      return;
    }
    formProvider.setActiveVoiceField('weight');
    _scrollTo(formProvider.weightFocus);
    _speak(
      _prompt(VoicePromptKey.askGender),
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'gender',
          onResult: (text) {
            if (!VoiceTextProcessor.isSkipCommand(text)) {
              final lower = text.toLowerCase();
              final isFemale =
                  lower.contains('female') ||
                  lower.contains('मादी') ||
                  lower.contains('स्त्री');
              final isMale =
                  lower.contains('male') ||
                  lower.contains('नर') ||
                  lower.contains('पुरुष');

              if (isFemale) {
                formProvider.updateGender('Female');
              } else if (isMale) {
                formProvider.updateGender('Male');
              }
            }
            _askForWeight();
          },
          onRedo: _askForGender,
        );
      },
    );
  }

  void _askForWeight() {
    if (formProvider.weightController.text.isNotEmpty) {
      _finishStep(_prompt(VoicePromptKey.animalDetailsCompleted));
      return;
    }
    formProvider.setActiveVoiceField('weight');
    _scrollTo(formProvider.weightFocus);
    _speak(
      _prompt(VoicePromptKey.askWeight),
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'weight',
          onPartial: (text) {
            if (!VoiceTextProcessor.isSkipCommand(text)) {
              final digits = VoiceTextProcessor.extractDecimalNumber(text);
              formProvider.weightController.text = digits;
            }
          },
          onResult: (text) {
            if (!VoiceTextProcessor.isSkipCommand(text)) {
              final digits = VoiceTextProcessor.extractDecimalNumber(text);
              formProvider.weightController.text = digits;
            }
            _finishStep(_prompt(VoicePromptKey.animalDetailsCompleted));
          },
          onRedo: _askForWeight,
        );
      },
    );
  }

  // =====================================================================
  //  STEP 5: Medical Assessment
  // =====================================================================

  void startStep5() {
    AppLogger.info('RegistrationVoiceAssistant', 'Starting Step 5');
    voiceService.setVoiceModeActive(true);
    _askForSymptoms();
  }

  void _askForSymptoms() {
    if (formProvider.symptomsController.text.isNotEmpty) {
      _askForTemperature();
      return;
    }
    formProvider.setActiveVoiceField('symptoms');
    _scrollTo(formProvider.symptomsFocus);
    _speak(
      _prompt(VoicePromptKey.askSymptoms),
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'symptoms',
          onPartial: (text) {
            formProvider.symptomsController.text = text;
          },
          onResult: (text) {
            formProvider.symptomsController.text = text;

            // Auto-tag symptoms from spoken text
            String t = text.toLowerCase();
            if (t.contains('fracture') ||
                t.contains('broken') ||
                t.contains('फ्रॅक्चर') ||
                t.contains('तुटलेले') ||
                t.contains('टूटा')) {
              formProvider.toggleSymptomTag('Fracture');
            }
            if (t.contains('maggot') ||
                t.contains('अळी') ||
                t.contains('कीड़े')) {
              formProvider.toggleSymptomTag('Maggot Wound');
            }
            if (t.contains('fever') ||
                t.contains('ताप') ||
                t.contains('बुखार')) {
              formProvider.toggleSymptomTag('Tick Fever');
            }
            if (t.contains('bleeding') ||
                t.contains('blood') ||
                t.contains('accident') ||
                t.contains('रक्त') ||
                t.contains('खून') ||
                t.contains('अपघात') ||
                t.contains('दुर्घटना')) {
              formProvider.toggleSymptomTag('Accident');
            }

            _askForTemperature();
          },
          onRedo: _askForSymptoms,
        );
      },
    );
  }

  void _askForTemperature() {
    if (formProvider.temperatureController.text.isNotEmpty) {
      _askForInitialTreatment();
      return;
    }
    formProvider.setActiveVoiceField('temperature');
    _scrollTo(formProvider.temperatureFocus);
    _speak(
      _prompt(VoicePromptKey.askTemperature),
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'temperature',
          onPartial: (text) {
            if (!VoiceTextProcessor.isSkipCommand(text)) {
              final digits = VoiceTextProcessor.extractDecimalNumber(text);
              formProvider.temperatureController.text = digits;
            }
          },
          onResult: (text) {
            if (!VoiceTextProcessor.isSkipCommand(text)) {
              final digits = VoiceTextProcessor.extractDecimalNumber(text);
              formProvider.temperatureController.text = digits;
            }
            _askForInitialTreatment();
          },
          onRedo: _askForTemperature,
        );
      },
    );
  }

  void _askForInitialTreatment() {
    if (formProvider.initialTreatmentController.text.isNotEmpty) {
      _finishStep(_prompt(VoicePromptKey.medicalCompleted));
      return;
    }
    formProvider.setActiveVoiceField('initialTreatment');
    _scrollTo(formProvider.initialTreatmentFocus);
    _speak(
      _prompt(VoicePromptKey.askInitialTreatment),
      onComplete: () {
        _listenWithCommands(
          fieldKey: 'initialTreatment',
          onPartial: (text) {
            if (!VoiceTextProcessor.isSkipCommand(text)) {
              formProvider.initialTreatmentController.text = text;
            }
          },
          onResult: (text) {
            if (!VoiceTextProcessor.isSkipCommand(text)) {
              formProvider.initialTreatmentController.text = text;
            }
            _finishStep(_prompt(VoicePromptKey.medicalCompleted));
          },
          onRedo: _askForInitialTreatment,
        );
      },
    );
  }

  // =====================================================================
  //  STEP 6: Review Readback (TTS reads back all collected data)
  // =====================================================================

  void startStep6Readback() {
    AppLogger.info('RegistrationVoiceAssistant', 'Starting Step 6 Readback');

    final parts = <String>[];

    // Reporter details
    final name = formProvider.reporterNameController.text;
    final mobile = formProvider.mobileNumberController.text;
    if (name.isNotEmpty)
      parts.add(
        _promptFmt(VoicePromptKey.readbackReporterName, {'value': name}),
      );
    if (mobile.isNotEmpty)
      parts.add(
        _promptFmt(VoicePromptKey.readbackMobile, {
          'value': mobile.split('').join(' '),
        }),
      );

    // Location
    final address = formProvider.addressController.text;
    final city = formProvider.cityController.text;
    final area = formProvider.areaController.text;
    if (address.isNotEmpty)
      parts.add(_promptFmt(VoicePromptKey.readbackAddress, {'value': address}));
    if (area.isNotEmpty)
      parts.add(_promptFmt(VoicePromptKey.readbackArea, {'value': area}));
    if (city.isNotEmpty)
      parts.add(_promptFmt(VoicePromptKey.readbackCity, {'value': city}));

    // Animal
    parts.add(
      _promptFmt(VoicePromptKey.readbackAnimalType, {
        'value': formProvider.animalType,
      }),
    );
    final breed = formProvider.breedController.text;
    if (breed.isNotEmpty)
      parts.add(_promptFmt(VoicePromptKey.readbackBreed, {'value': breed}));
    if (formProvider.gender != 'Unknown')
      parts.add(
        _promptFmt(VoicePromptKey.readbackGender, {
          'value': formProvider.gender,
        }),
      );
    final weight = formProvider.weightController.text;
    if (weight.isNotEmpty)
      parts.add(_promptFmt(VoicePromptKey.readbackWeight, {'value': weight}));

    // Medical
    final symptoms = formProvider.symptomsController.text;
    if (symptoms.isNotEmpty)
      parts.add(
        _promptFmt(VoicePromptKey.readbackSymptoms, {'value': symptoms}),
      );
    final temp = formProvider.temperatureController.text;
    if (temp.isNotEmpty)
      parts.add(
        _promptFmt(VoicePromptKey.readbackTemperature, {'value': temp}),
      );
    final treatment = formProvider.initialTreatmentController.text;
    if (treatment.isNotEmpty)
      parts.add(
        _promptFmt(VoicePromptKey.readbackTreatment, {'value': treatment}),
      );

    if (parts.isEmpty) {
      _speak(_prompt(VoicePromptKey.noDataToReview));
      return;
    }

    final fullReadback =
        "${_prompt(VoicePromptKey.readbackIntro)} ${parts.join(' ')} "
        "${_prompt(VoicePromptKey.readbackOutro)}";

    _speak(fullReadback);
  }

  // =====================================================================
  //  FINISH
  // =====================================================================

  void _finishStep(String msg) {
    AppLogger.info('RegistrationVoiceAssistant', msg);
    _retryCounts.clear();
    formProvider.setActiveVoiceField(null);
    FocusManager.instance.primaryFocus?.unfocus();
    voiceService.setVoiceModeActive(false);
    _speak(
      msg,
      onComplete: () {
        formProvider.onNextStepRequested?.call(true);
      },
    );
  }
}
