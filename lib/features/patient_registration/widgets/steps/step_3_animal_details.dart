import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/registration_provider.dart';
import '../../services/registration_voice_assistant.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../core/services/voice_language_provider.dart';


class Step3AnimalDetails extends StatelessWidget {
  const Step3AnimalDetails({super.key});

  static const List<String> _animalTypes = [
    'Dog',
    'Cat',
    'Bird',
    'Cow',
    'Buffalo',
    'Horse',
    'Donkey',
    'Monkey',
    'Snake',
    'Other',
  ];

  final List<String> _observations = const [
    'Conscious',
    'Injured',
    'Bleeding',
    'Unable to Walk',
    'Aggressive',
    'Pregnant',
    'Puppy/Kitten',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _buildPhotoGrid(),
          SizedBox(height: 24.h),
          _buildBasicInformation(context),
          SizedBox(height: 24.h),
          _buildIdentificationHealth(context),
          SizedBox(height: 24.h),
          _buildStatusObservations(context),
          SizedBox(height: 24.h),
          _buildAdditionalInfo(context),
          SizedBox(height: 120.h),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos of the Animal',
          style: GoogleFonts.nunitoSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B1C1C),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF9F9),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                      width: 2.w,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        color: Colors.grey.shade500,
                        size: 32.w,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Primary',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1552053831-71594a27632d',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 12.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF9F9),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                      width: 2.w,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.grey.shade500,
                      size: 32.w,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBasicInformation(BuildContext context) {
    final formProvider = context.watch<RegistrationProvider>();
    final voiceService = context.watch<VoiceService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Basic Details',
              style: GoogleFonts.nunitoSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B1C1C),
              ),
            ),
            IconButton(
              icon: Icon(
                voiceService.isListening ? Icons.mic : Icons.mic_none,
                color: voiceService.isListening
                    ? Colors.red
                    : const Color(0xFF006E1C),
              ),
              onPressed: () {
                if (voiceService.isVoiceModeActive) {
                  voiceService.abortVoice();
                } else {
                  final assistant = RegistrationVoiceAssistant(
                    voiceService,
                    formProvider,
                    context.read<VoiceLanguageProvider>(),
                  );
                  assistant.startStep3();
                }
              },
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          'Animal Name (Optional)',
          'e.g. Luna',
          formProvider.animalNameController,
          readOnly: voiceService.isVoiceModeActive,
          fieldKey: 'animalName',
        ),
        SizedBox(height: 16.h),
        Text(
          'Animal Type',
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _animalTypes
              .map((typeName) => _buildTypeChip(typeName, formProvider))
              .toList(),
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          'Breed / Mix',
          'e.g. Labrador, Persian, Mixed',
          formProvider.breedController,
          focusNode: formProvider.breedFocus,
          readOnly: voiceService.isVoiceModeActive,
          fieldKey: 'breed',
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          'Color',
          'e.g. Brown, Black, White, Mixed',
          formProvider.colorController,
          focusNode: formProvider.colorFocus,
          readOnly: voiceService.isVoiceModeActive,
          fieldKey: 'color',
        ),
        SizedBox(height: 16.h),
        Text(
          'Gender',
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Expanded(child: _buildGenderSegment('Male', formProvider)),
              Expanded(child: _buildGenderSegment('Female', formProvider)),
              Expanded(child: _buildGenderSegment('Unknown', formProvider)),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated Age',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF9F9),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: formProvider.age,
                        isExpanded: true,
                        items:
                            [
                              'Baby / Infant',
                              'Young Adult',
                              'Adult',
                              'Senior',
                              'Unknown',
                            ].map((age) {
                              return DropdownMenuItem(
                                value: age,
                                child: Text(
                                  age,
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 14.sp,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (val) {
                          formProvider.updateAge(val!);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildTextField(
                'Weight (Approx kg)',
                '0.0',
                formProvider.weightController,
                focusNode: formProvider.weightFocus,
                keyboardType: TextInputType.number,
                readOnly: voiceService.isVoiceModeActive,
                fieldKey: 'weight',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(
    String typeName,
    RegistrationProvider formProvider,
  ) {
    bool isSelected = formProvider.animalType == typeName;
    return GestureDetector(
      onTap: () {
        formProvider.updateAnimalType(typeName);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006E1C) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF006E1C) : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Text(
          typeName,
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSegment(String gender, RegistrationProvider formProvider) {
    bool isSelected = formProvider.gender == gender;
    return GestureDetector(
      onTap: () {
        formProvider.updateGender(gender);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            gender,
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF006E1C)
                  : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdentificationHealth(BuildContext context) {
    final formProvider = context.watch<RegistrationProvider>();
    final voiceService = context.watch<VoiceService>();
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sterilized',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                  Text(
                    'Confirmed by reporter',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Switch(
                value: formProvider.isSterilized,
                onChanged: (val) => formProvider.updateSterilized(val),
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF006E1C),
                inactiveThumbColor: Colors.grey.shade600,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Collar Present',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                  Text(
                    'Wears an identification collar',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Switch(
                value: formProvider.hasCollar,
                onChanged: (val) => formProvider.updateCollar(val),
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF006E1C),
                inactiveThumbColor: Colors.grey.shade600,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            'Ear Tag / Microchip ID',
            'Enter ID number if visible',
            formProvider.microchipController,
            readOnly: voiceService.isVoiceModeActive,
            fieldKey: 'microchip',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusObservations(BuildContext context) {
    final formProvider = context.watch<RegistrationProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Current Status Observations',
              style: GoogleFonts.nunitoSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B1C1C),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.info, color: const Color(0xFF006E1C), size: 18.w),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _observations
              .map((obs) => _buildObservationChip(obs, formProvider))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildObservationChip(
    String observation,
    RegistrationProvider formProvider,
  ) {
    bool isSelected = formProvider.observations.contains(observation);
    bool isRedObservation =
        observation == 'Injured' || observation == 'Bleeding';

    Color textColor = Colors.grey.shade700;
    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade300;

    if (isSelected) {
      if (isRedObservation) {
        textColor = const Color(0xFFBA1A1A);
        bgColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFBA1A1A);
      } else {
        textColor = const Color(0xFF006E1C);
        bgColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF006E1C);
      }
    }

    return GestureDetector(
      onTap: () {
        formProvider.toggleObservation(observation);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Text(
          observation,
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    final formProvider = context.watch<RegistrationProvider>();
    final voiceService = context.watch<VoiceService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Medical & Transport Info',
          style: GoogleFonts.nunitoSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B1C1C),
          ),
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          'Diagnosis (Optional)',
          'Enter suspected diagnosis if any',
          formProvider.diagnosisController,
          focusNode: formProvider.diagnosisFocus,
          readOnly: voiceService.isVoiceModeActive,
          fieldKey: 'diagnosis',
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          'Required Tests (Optional)',
          'e.g. Blood Test, X-Ray',
          formProvider.testsController,
          focusNode: formProvider.testsFocus,
          readOnly: voiceService.isVoiceModeActive,
          fieldKey: 'tests',
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          'Transporter Contact (Optional)',
          'Enter driver/volunteer contact',
          formProvider.transporterContactController,
          focusNode: formProvider.transporterContactFocus,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          readOnly: voiceService.isVoiceModeActive,
          fieldKey: 'transporterContact',
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          'Assign Cage Number (Optional)',
          'e.g. C-142',
          formProvider.cageNumberController,
          focusNode: formProvider.cageNumberFocus,
          readOnly: voiceService.isVoiceModeActive,
          fieldKey: 'cageNumber',
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    FocusNode? focusNode,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    IconData? icon,
    String? fieldKey,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Builder(
      builder: (context) {
        final formProvider = context.watch<RegistrationProvider>();
        final voiceService = context.watch<VoiceService>();
        bool isActiveVoiceField =
            voiceService.isVoiceModeActive &&
            formProvider.activeVoiceField == fieldKey &&
            fieldKey != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.nunitoSans(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8.h),
            voiceService.isVoiceModeActive
                ? Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF9F9),
                      borderRadius: BorderRadius.circular(12.r),
                      border: isActiveVoiceField
                          ? Border.all(
                              color: const Color(0xFF006E1C),
                              width: 2.w,
                            )
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.grey.shade400, size: 20.w),
                          SizedBox(width: 12.w),
                        ],
                        Expanded(
                          child: Text(
                            controller.text.isEmpty ? hint : controller.text,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14.sp,
                              color: controller.text.isEmpty
                                  ? Colors.grey.shade400
                                  : const Color(0xFF1B1C1C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14.sp,
                      color: const Color(0xFF1B1C1C),
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.nunitoSans(
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: icon != null
                          ? Icon(icon, color: Colors.grey.shade400, size: 20.w)
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFFBF9F9),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Color(0xFF006E1C),
                          width: 2.w,
                        ),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}
