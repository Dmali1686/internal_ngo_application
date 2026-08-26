import 'voice_language_provider.dart';

/// All voice prompts used in the app, translated to English, Hindi, and Marathi.
///
/// Usage: `VoicePrompts.get(language, VoicePromptKey.askReporterName)`
class VoicePrompts {
  VoicePrompts._();

  /// Get a prompt string for the given language and key.
  static String get(VoiceLanguage lang, VoicePromptKey key) {
    return _prompts[key]![lang]!;
  }

  static final Map<VoicePromptKey, Map<VoiceLanguage, String>> _prompts = {
    // =====================================================================
    //  STEP 1: Reporter Details
    // =====================================================================
    VoicePromptKey.askReporterName: {
      VoiceLanguage.english: "What is the reporter's name?",
      VoiceLanguage.hindi: "रिपोर्टर का नाम क्या है?",
      VoiceLanguage.marathi: "रिपोर्टरचे नाव काय आहे?",
    },
    VoicePromptKey.askMobileNumber: {
      VoiceLanguage.english: "What is the mobile number?",
      VoiceLanguage.hindi: "मोबाइल नंबर क्या है?",
      VoiceLanguage.marathi: "मोबाइल नंबर काय आहे?",
    },
    VoicePromptKey.askAlternateNumber: {
      VoiceLanguage.english:
          "What is the alternate number? Say 'skip' to skip.",
      VoiceLanguage.hindi:
          "वैकल्पिक नंबर क्या है? 'छोड़ो' बोलकर छोड़ सकते हैं।",
      VoiceLanguage.marathi:
          "पर्यायी नंबर काय आहे? 'सोडा' बोला स्किप करण्यासाठी.",
    },
    VoicePromptKey.reporterDetailsCompleted: {
      VoiceLanguage.english: "Reporter details completed.",
      VoiceLanguage.hindi: "रिपोर्टर की जानकारी पूरी हुई।",
      VoiceLanguage.marathi: "रिपोर्टरची माहिती पूर्ण झाली.",
    },

    // =====================================================================
    //  STEP 2: Rescue Location
    // =====================================================================
    VoicePromptKey.askAddress: {
      VoiceLanguage.english: "What is the detailed address?",
      VoiceLanguage.hindi: "पूरा पता क्या है?",
      VoiceLanguage.marathi: "संपूर्ण पत्ता काय आहे?",
    },
    VoicePromptKey.askLandmark: {
      VoiceLanguage.english: "Is there a landmark? Say 'skip' if none.",
      VoiceLanguage.hindi: "कोई लैंडमार्क है? नहीं है तो 'छोड़ो' बोलें।",
      VoiceLanguage.marathi: "कोणता लँडमार्क आहे? नसल्यास 'सोडा' बोला.",
    },
    VoicePromptKey.askArea: {
      VoiceLanguage.english: "Which area or locality?",
      VoiceLanguage.hindi: "कौन सा इलाका या मोहल्ला?",
      VoiceLanguage.marathi: "कोणता परिसर किंवा भाग?",
    },
    VoicePromptKey.askCity: {
      VoiceLanguage.english: "Which city?",
      VoiceLanguage.hindi: "कौन सा शहर?",
      VoiceLanguage.marathi: "कोणते शहर?",
    },
    VoicePromptKey.askPincode: {
      VoiceLanguage.english: "What is the pin code?",
      VoiceLanguage.hindi: "पिन कोड क्या है?",
      VoiceLanguage.marathi: "पिन कोड काय आहे?",
    },
    VoicePromptKey.locationCompleted: {
      VoiceLanguage.english: "Location details completed.",
      VoiceLanguage.hindi: "स्थान की जानकारी पूरी हुई।",
      VoiceLanguage.marathi: "स्थानाची माहिती पूर्ण झाली.",
    },

    // =====================================================================
    //  STEP 3: Animal Details
    // =====================================================================
    VoicePromptKey.askAnimalType: {
      VoiceLanguage.english:
          "What type of animal is it? Dog, Cat, Cow, Bird, or Horse?",
      VoiceLanguage.hindi:
          "यह कौन सा जानवर है? कुत्ता, बिल्ली, गाय, पक्षी, या घोड़ा?",
      VoiceLanguage.marathi:
          "हे कोणते प्राणी आहे? कुत्रा, मांजर, गाय, पक्षी, किंवा घोडा?",
    },
    VoicePromptKey.askBreed: {
      VoiceLanguage.english: "What is the breed? Say skip if unknown.",
      VoiceLanguage.hindi: "नस्ल क्या है? पता नहीं तो 'छोड़ो' बोलें।",
      VoiceLanguage.marathi: "जात कोणती आहे? माहित नसल्यास 'सोडा' बोला.",
    },
    VoicePromptKey.askGender: {
      VoiceLanguage.english: "Is it male or female? Say skip if unknown.",
      VoiceLanguage.hindi: "नर है या मादा? पता नहीं तो 'छोड़ो' बोलें।",
      VoiceLanguage.marathi: "नर आहे की मादी? माहित नसल्यास 'सोडा' बोला.",
    },
    VoicePromptKey.askWeight: {
      VoiceLanguage.english:
          "What is the approximate weight in kilograms? Say skip if unknown.",
      VoiceLanguage.hindi:
          "अनुमानित वजन कितना है किलोग्राम में? पता नहीं तो 'छोड़ो' बोलें।",
      VoiceLanguage.marathi:
          "अंदाजे वजन किती आहे किलोग्रॅममध्ये? माहित नसल्यास 'सोडा' बोला.",
    },
    VoicePromptKey.animalDetailsCompleted: {
      VoiceLanguage.english: "Animal details completed.",
      VoiceLanguage.hindi: "जानवर की जानकारी पूरी हुई।",
      VoiceLanguage.marathi: "प्राण्याची माहिती पूर्ण झाली.",
    },

    // =====================================================================
    //  STEP 5: Medical Assessment
    // =====================================================================
    VoicePromptKey.askSymptoms: {
      VoiceLanguage.english: "Please describe the physical symptoms.",
      VoiceLanguage.hindi: "कृपया शारीरिक लक्षणों का वर्णन करें।",
      VoiceLanguage.marathi: "कृपया शारीरिक लक्षणे सांगा.",
    },
    VoicePromptKey.askTemperature: {
      VoiceLanguage.english:
          "What is the body temperature? Say skip if not measured.",
      VoiceLanguage.hindi:
          "शरीर का तापमान क्या है? नहीं लिया तो 'छोड़ो' बोलें।",
      VoiceLanguage.marathi:
          "शरीराचे तापमान काय आहे? मोजले नसल्यास 'सोडा' बोला.",
    },
    VoicePromptKey.askInitialTreatment: {
      VoiceLanguage.english:
          "What is the initial treatment? Say skip if none given.",
      VoiceLanguage.hindi:
          "प्रारंभिक उपचार क्या है? नहीं दिया तो 'छोड़ो' बोलें।",
      VoiceLanguage.marathi: "प्रारंभिक उपचार काय आहे? नसल्यास 'सोडा' बोला.",
    },
    VoicePromptKey.medicalCompleted: {
      VoiceLanguage.english: "Medical assessment completed.",
      VoiceLanguage.hindi: "चिकित्सा मूल्यांकन पूरा हुआ।",
      VoiceLanguage.marathi: "वैद्यकीय मूल्यांकन पूर्ण झाले.",
    },

    // =====================================================================
    //  Confirmation & Errors
    // =====================================================================
    VoicePromptKey.confirmValue: {
      VoiceLanguage.english: "You said {value}. Is that correct?",
      VoiceLanguage.hindi: "आपने कहा {value}. क्या यह सही है?",
      VoiceLanguage.marathi: "तुम्ही म्हणालात {value}. हे बरोबर आहे का?",
    },
    VoicePromptKey.didntCatchThat: {
      VoiceLanguage.english: "I didn't catch that. Please try again.",
      VoiceLanguage.hindi: "मुझे सुनाई नहीं दिया। कृपया फिर से बोलें।",
      VoiceLanguage.marathi: "मला ऐकू आले नाही. कृपया पुन्हा बोला.",
    },
    VoicePromptKey.maxRetriesFallback: {
      VoiceLanguage.english:
          "I couldn't hear {field} clearly. Please type it manually.",
      VoiceLanguage.hindi: "{field} स्पष्ट सुनाई नहीं दिया। कृपया टाइप करें।",
      VoiceLanguage.marathi: "{field} स्पष्ट ऐकू आले नाही. कृपया टाइप करा.",
    },
    VoicePromptKey.voiceCancelled: {
      VoiceLanguage.english: "Voice input cancelled.",
      VoiceLanguage.hindi: "आवाज इनपुट रद्द किया गया।",
      VoiceLanguage.marathi: "आवाज इनपुट रद्द केले.",
    },
    VoicePromptKey.noDataToReview: {
      VoiceLanguage.english: "No registration data to review.",
      VoiceLanguage.hindi: "समीक्षा करने के लिए कोई डेटा नहीं है।",
      VoiceLanguage.marathi: "पुनरावलोकनासाठी कोणताही डेटा नाही.",
    },

    // =====================================================================
    //  Step 6 Readback Phrases
    // =====================================================================
    VoicePromptKey.readbackIntro: {
      VoiceLanguage.english: "Here is the registration summary.",
      VoiceLanguage.hindi: "यह है पंजीकरण का सारांश।",
      VoiceLanguage.marathi: "हे नोंदणीचे सारांश आहे.",
    },
    VoicePromptKey.readbackReporterName: {
      VoiceLanguage.english: "Reporter name is {value}.",
      VoiceLanguage.hindi: "रिपोर्टर का नाम {value} है।",
      VoiceLanguage.marathi: "रिपोर्टरचे नाव {value} आहे.",
    },
    VoicePromptKey.readbackMobile: {
      VoiceLanguage.english: "Mobile number is {value}.",
      VoiceLanguage.hindi: "मोबाइल नंबर {value} है।",
      VoiceLanguage.marathi: "मोबाइल नंबर {value} आहे.",
    },
    VoicePromptKey.readbackAddress: {
      VoiceLanguage.english: "Address is {value}.",
      VoiceLanguage.hindi: "पता {value} है।",
      VoiceLanguage.marathi: "पत्ता {value} आहे.",
    },
    VoicePromptKey.readbackArea: {
      VoiceLanguage.english: "Area is {value}.",
      VoiceLanguage.hindi: "इलाका {value} है।",
      VoiceLanguage.marathi: "परिसर {value} आहे.",
    },
    VoicePromptKey.readbackCity: {
      VoiceLanguage.english: "City is {value}.",
      VoiceLanguage.hindi: "शहर {value} है।",
      VoiceLanguage.marathi: "शहर {value} आहे.",
    },
    VoicePromptKey.readbackAnimalType: {
      VoiceLanguage.english: "Animal type is {value}.",
      VoiceLanguage.hindi: "जानवर का प्रकार {value} है।",
      VoiceLanguage.marathi: "प्राण्याचा प्रकार {value} आहे.",
    },
    VoicePromptKey.readbackBreed: {
      VoiceLanguage.english: "Breed is {value}.",
      VoiceLanguage.hindi: "नस्ल {value} है।",
      VoiceLanguage.marathi: "जात {value} आहे.",
    },
    VoicePromptKey.readbackGender: {
      VoiceLanguage.english: "Gender is {value}.",
      VoiceLanguage.hindi: "लिंग {value} है।",
      VoiceLanguage.marathi: "लिंग {value} आहे.",
    },
    VoicePromptKey.readbackWeight: {
      VoiceLanguage.english: "Weight is {value} kilograms.",
      VoiceLanguage.hindi: "वजन {value} किलोग्राम है।",
      VoiceLanguage.marathi: "वजन {value} किलोग्रॅम आहे.",
    },
    VoicePromptKey.readbackSymptoms: {
      VoiceLanguage.english: "Symptoms: {value}.",
      VoiceLanguage.hindi: "लक्षण: {value}।",
      VoiceLanguage.marathi: "लक्षणे: {value}.",
    },
    VoicePromptKey.readbackTemperature: {
      VoiceLanguage.english: "Temperature is {value} degrees.",
      VoiceLanguage.hindi: "तापमान {value} डिग्री है।",
      VoiceLanguage.marathi: "तापमान {value} अंश आहे.",
    },
    VoicePromptKey.readbackTreatment: {
      VoiceLanguage.english: "Initial treatment: {value}.",
      VoiceLanguage.hindi: "प्रारंभिक उपचार: {value}।",
      VoiceLanguage.marathi: "प्रारंभिक उपचार: {value}.",
    },
    VoicePromptKey.readbackOutro: {
      VoiceLanguage.english: "Please review on screen and submit when ready.",
      VoiceLanguage.hindi:
          "कृपया स्क्रीन पर जांचें और तैयार होने पर सबमिट करें।",
      VoiceLanguage.marathi:
          "कृपया स्क्रीनवर पुनरावलोकन करा आणि तयार असल्यास सबमिट करा.",
    },

    // =====================================================================
    //  Voice Command Feedback
    // =====================================================================
    VoicePromptKey.commandNotRecognized: {
      VoiceLanguage.english:
          "Command not recognized. Say 'help' for available commands.",
      VoiceLanguage.hindi:
          "कमांड पहचान में नहीं आई। उपलब्ध कमांड के लिए 'मदद' बोलें।",
      VoiceLanguage.marathi: "कमांड ओळखली नाही. उपलब्ध कमांडसाठी 'मदत' बोला.",
    },
    VoicePromptKey.helpCommands: {
      VoiceLanguage.english:
          "You can say: register patient, go to dashboard, open treatment, open diet, call ambulance, scan QR, take attendance, open voice notes, or go back.",
      VoiceLanguage.hindi:
          "आप बोल सकते हैं: मरीज़ दर्ज करो, डैशबोर्ड खोलो, उपचार खोलो, आहार खोलो, एम्बुलेंस बुलाओ, QR स्कैन करो, हाज़िरी लो, वॉइस नोट्स खोलो, या पीछे जाओ।",
      VoiceLanguage.marathi:
          "तुम्ही बोलू शकता: रुग्ण नोंदणी करा, डॅशबोर्ड उघडा, उपचार उघडा, आहार उघडा, रुग्णवाहिका बोलवा, QR स्कॅन करा, हजेरी घ्या, व्हॉइस नोट्स उघडा, किंवा मागे जा.",
    },
  };

  /// Get a prompt with placeholder replacement.
  ///
  /// Usage: `VoicePrompts.format(lang, VoicePromptKey.confirmValue, {'value': '9876543210'})`
  static String format(
    VoiceLanguage lang,
    VoicePromptKey key,
    Map<String, String> params,
  ) {
    String result = get(lang, key);
    params.forEach((placeholder, replacement) {
      result = result.replaceAll('{$placeholder}', replacement);
    });
    return result;
  }
}

/// Keys for all voice prompts.
enum VoicePromptKey {
  // Step 1
  askReporterName,
  askMobileNumber,
  askAlternateNumber,
  reporterDetailsCompleted,

  // Step 2
  askAddress,
  askLandmark,
  askArea,
  askCity,
  askPincode,
  locationCompleted,

  // Step 3
  askAnimalType,
  askBreed,
  askGender,
  askWeight,
  animalDetailsCompleted,

  // Step 5
  askSymptoms,
  askTemperature,
  askInitialTreatment,
  medicalCompleted,

  // Confirmation & Errors
  confirmValue,
  didntCatchThat,
  maxRetriesFallback,
  voiceCancelled,
  noDataToReview,

  // Step 6 Readback
  readbackIntro,
  readbackReporterName,
  readbackMobile,
  readbackAddress,
  readbackArea,
  readbackCity,
  readbackAnimalType,
  readbackBreed,
  readbackGender,
  readbackWeight,
  readbackSymptoms,
  readbackTemperature,
  readbackTreatment,
  readbackOutro,

  // Voice Command Feedback
  commandNotRecognized,
  helpCommands,
}
