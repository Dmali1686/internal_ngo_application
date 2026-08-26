/// Utility class for post-processing speech-to-text results.
///
/// Handles number word→digit conversion, Indian English phone patterns,
/// name capitalization, and common STT misrecognition fixes.
class VoiceTextProcessor {
  VoiceTextProcessor._();

  // --- Number Word to Digit Conversion ---

  static const Map<String, String> _numberWords = {
    'zero': '0',
    'one': '1',
    'two': '2',
    'to': '2',
    'too': '2',
    'three': '3',
    'four': '4',
    'for': '4',
    'five': '5',
    'six': '6',
    'seven': '7',
    'eight': '8',
    'ate': '8',
    'nine': '9',
    'niner': '9',
  };

  /// Normalizes Devnagari (Hindi/Marathi) digits to Arabic digits (0-9).
  static String normalizeDevnagariDigits(String input) {
    const devnagariDigits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
    String output = input;
    for (int i = 0; i <= 9; i++) {
      output = output.replaceAll(devnagariDigits[i], i.toString());
    }
    return output;
  }

  /// Converts spoken number words to digit strings.
  ///
  /// Examples:
  /// - "nine eight seven six" → "9876"
  /// - "double five three" → "553"
  /// - "triple nine" → "999"
  /// - "9876543210" → "9876543210" (already digits, pass through)
  static String convertSpokenNumbersToDigits(String rawInput) {
    // Normalize Devnagari digits first so they aren't stripped
    final input = normalizeDevnagariDigits(rawInput);

    // If the input is already mostly digits, just strip non-digits
    final digitOnly = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitOnly.length >= input.replaceAll(' ', '').length * 0.7) {
      return digitOnly;
    }

    final words = input.toLowerCase().split(RegExp(r'\s+'));
    final buffer = StringBuffer();
    String? pendingMultiplier;

    for (int i = 0; i < words.length; i++) {
      final word = words[i].replaceAll(RegExp(r'[^a-z0-9]'), '');

      if (word == 'double') {
        pendingMultiplier = 'double';
        continue;
      }
      if (word == 'triple') {
        pendingMultiplier = 'triple';
        continue;
      }

      String? digit = _numberWords[word];

      // If it's a single digit character
      if (digit == null &&
          word.length == 1 &&
          RegExp(r'[0-9]').hasMatch(word)) {
        digit = word;
      }

      if (digit != null) {
        if (pendingMultiplier == 'double') {
          buffer.write(digit * 2);
        } else if (pendingMultiplier == 'triple') {
          buffer.write(digit * 3);
        } else {
          buffer.write(digit);
        }
        pendingMultiplier = null;
      } else {
        // Not a number word — if we have accumulated digits, keep them
        // Otherwise this might be a non-number word, skip it for digit extraction
        pendingMultiplier = null;
      }
    }

    final result = buffer.toString();
    return result.isNotEmpty ? result : digitOnly;
  }

  /// Extract only digits from text, with number word conversion.
  ///
  /// Best for phone numbers, pincodes, weights, temperatures.
  static String extractDigits(String rawInput) {
    // Normalize Devnagari digits first
    final input = normalizeDevnagariDigits(rawInput);

    // First try direct digit extraction
    final directDigits = input.replaceAll(RegExp(r'[^0-9.]'), '');
    if (directDigits.length >= 6) {
      // Likely already has enough digits (phone/pincode)
      return directDigits;
    }

    // Try number word conversion
    final converted = convertSpokenNumbersToDigits(input);
    if (converted.isNotEmpty) return converted;

    // Fallback to whatever digits we found
    return directDigits.isNotEmpty ? directDigits : input;
  }

  /// Extract a decimal number (for weight, temperature).
  static String extractDecimalNumber(String rawInput) {
    final input = normalizeDevnagariDigits(rawInput);
    // Look for existing decimal patterns
    final decimalMatch = RegExp(r'(\d+\.?\d*)').firstMatch(input);
    if (decimalMatch != null) {
      return decimalMatch.group(0)!;
    }

    // Handle spoken decimals: "thirty eight point five" etc.
    final lower = input.toLowerCase();
    if (lower.contains('point') || lower.contains('dot')) {
      final parts = lower.split(RegExp(r'point|dot'));
      if (parts.length == 2) {
        final intPart = _parseSpokenInteger(parts[0].trim());
        final decPart = convertSpokenNumbersToDigits(parts[1].trim());
        if (intPart.isNotEmpty) {
          return decPart.isNotEmpty ? '$intPart.$decPart' : intPart;
        }
      }
    }

    // Fallback
    final digits = input.replaceAll(RegExp(r'[^0-9.]'), '');
    return digits.isNotEmpty ? digits : input;
  }

  static String _parseSpokenInteger(String spoken) {
    final tenWords = {
      'ten': '10',
      'eleven': '11',
      'twelve': '12',
      'thirteen': '13',
      'fourteen': '14',
      'fifteen': '15',
      'sixteen': '16',
      'seventeen': '17',
      'eighteen': '18',
      'nineteen': '19',
      'twenty': '20',
      'thirty': '30',
      'forty': '40',
      'fifty': '50',
      'sixty': '60',
      'seventy': '70',
      'eighty': '80',
      'ninety': '90',
      'hundred': '100',
    };

    // Direct match
    if (tenWords.containsKey(spoken)) return tenWords[spoken]!;

    // Compound like "thirty eight"
    final parts = spoken.split(RegExp(r'\s+'));
    if (parts.length == 2) {
      final tens = tenWords[parts[0]];
      final ones = _numberWords[parts[1]];
      if (tens != null && ones != null) {
        return (int.parse(tens) + int.parse(ones)).toString();
      }
    }

    // Try digit extraction
    return convertSpokenNumbersToDigits(spoken);
  }

  // --- Name Processing ---

  /// Capitalize each word for proper name formatting.
  ///
  /// Example: "dinesh mali" → "Dinesh Mali"
  static String capitalizeName(String input) {
    if (input.isEmpty) return input;
    return input
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // --- Skip / Command Detection ---

  /// Check if the user said a skip command.
  static bool isSkipCommand(String input) {
    final lower = input.toLowerCase().trim();
    return lower == 'skip' ||
        lower == 'next' ||
        lower == 'सोडा' || // Marathi: skip
        lower == 'छोड़ो' || // Hindi: skip
        lower == 'पुढे' || // Marathi: next
        lower == 'आगे' || // Hindi: next
        lower.contains('skip it') ||
        lower.contains('skip this') ||
        lower.contains('move on') ||
        lower.contains('no need');
  }

  /// Check if the user said a go-back / redo command.
  static bool isRedoCommand(String input) {
    final lower = input.toLowerCase().trim();
    return lower == 'redo' ||
        lower == 'again' ||
        lower == 'परत' || // Marathi: again
        lower == 'फिर से' || // Hindi: again
        lower.contains('go back') ||
        lower.contains('repeat') ||
        lower.contains('say again') ||
        lower.contains('change it') ||
        lower.contains('wrong') ||
        lower.contains('मागे') || // Marathi: back
        lower.contains('पीछे'); // Hindi: back
  }

  /// Check if the user said a cancel command.
  static bool isCancelCommand(String input) {
    final lower = input.toLowerCase().trim();
    return lower == 'cancel' ||
        lower == 'stop' ||
        lower == 'रद्द' || // Marathi: cancel
        lower == 'थांबा' || // Marathi: stop
        lower == 'रुको' || // Hindi: stop
        lower == 'बंद' || // Hindi: stop
        lower.contains('cancel voice') ||
        lower.contains('stop voice') ||
        lower.contains('exit voice');
  }

  /// Check if user confirmed (yes).
  static bool isConfirmation(String input) {
    final lower = input.toLowerCase().trim();
    return lower == 'yes' ||
        lower == 'yeah' ||
        lower == 'yep' ||
        lower == 'correct' ||
        lower == 'right' ||
        lower == 'confirm' ||
        lower == 'ok' ||
        lower == 'okay' ||
        lower == 'हो' || // Marathi: yes
        lower == 'हां' || // Hindi: yes
        lower == 'बरोबर' || // Marathi: correct
        lower == 'सही' || // Hindi: correct
        lower.contains('that\'s right') ||
        lower.contains('that\'s correct');
  }

  /// Check if user denied (no).
  static bool isDenial(String input) {
    final lower = input.toLowerCase().trim();
    return lower == 'no' ||
        lower == 'nope' ||
        lower == 'wrong' ||
        lower == 'incorrect' ||
        lower == 'नाही' || // Marathi: no
        lower == 'नहीं' || // Hindi: no
        lower == 'चूक' || // Hindi/Marathi: wrong
        lower.contains('not correct') ||
        lower.contains('not right') ||
        lower.contains('change it') ||
        lower.contains('बदला'); // Hindi: change
  }

  // --- Phone Number Validation ---

  /// Validate and format Indian phone number.
  ///
  /// Returns formatted number or null if invalid.
  static String? validateIndianPhone(String digits) {
    // Remove any non-digit characters
    final clean = digits.replaceAll(RegExp(r'[^0-9]'), '');

    if (clean.length == 10 && RegExp(r'^[6-9]').hasMatch(clean)) {
      return clean;
    }
    // If 11 digits starting with 0, strip leading 0
    if (clean.length == 11 && clean.startsWith('0')) {
      return clean.substring(1);
    }
    // If 12 digits starting with 91, strip country code
    if (clean.length == 12 && clean.startsWith('91')) {
      return clean.substring(2);
    }

    // Return as-is if we can't validate
    return clean.isNotEmpty ? clean : null;
  }

  /// Validate Indian pincode (6 digits, first digit 1-9).
  static String? validatePincode(String digits) {
    final clean = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length == 6 && RegExp(r'^[1-9]').hasMatch(clean)) {
      return clean;
    }
    return clean.isNotEmpty ? clean : null;
  }
}
