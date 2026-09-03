import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/registration_provider.dart';
import '../../services/registration_voice_assistant.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../core/services/voice_language_provider.dart';

class Step5MedicalAssessment extends StatelessWidget {
  const Step5MedicalAssessment({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _buildHeader(),
          SizedBox(height: 24.h),
          _buildAssessmentArea(context),
          SizedBox(height: 24.h),
          _buildTestsAndVitals(context),
          SizedBox(height: 24.h),
          _buildWardAssignment(context),
          SizedBox(height: 24.h),
          _buildDoctorTreatment(context),
          SizedBox(height: 120.h),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFD98900).withOpacity(0.15),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            'M3 PROFESSIONAL CLINICAL',
            style: GoogleFonts.nunitoSans(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF865300),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Medical Assessment',
          style: GoogleFonts.nunitoSans(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B1C1C),
          ),
        ),
        Text(
          'Perform a thorough veterinarian evaluation and document the findings below.',
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildAssessmentArea(BuildContext context) {
    final formProvider = context.watch<RegistrationProvider>();
    final voiceService = context.watch<VoiceService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Physical Symptoms',
              style: GoogleFonts.nunitoSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B1C1C),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (voiceService.isVoiceModeActive) {
                  voiceService.abortVoice();
                } else {
                  final assistant = RegistrationVoiceAssistant(
                    voiceService,
                    formProvider,
                    context.read<VoiceLanguageProvider>(),
                  );
                  assistant.startStep5();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: voiceService.isListening
                      ? const Color(0xFFFFEBEE)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: voiceService.isListening
                        ? Colors.red.withOpacity(0.3)
                        : const Color(0xFF4CAF50).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      voiceService.isListening ? Icons.mic : Icons.mic_none,
                      color: voiceService.isListening
                          ? Colors.red
                          : const Color(0xFF006E1C),
                      size: 16.w,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Voice Note',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: voiceService.isListening
                            ? Colors.red
                            : const Color(0xFF006E1C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        voiceService.isVoiceModeActive
            ? Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3F3),
                  borderRadius: BorderRadius.circular(16.r),
                  border: (formProvider.activeVoiceField == 'symptoms')
                      ? Border.all(color: const Color(0xFF006E1C), width: 2.w)
                      : Border.all(color: Colors.transparent, width: 0.w),
                ),
                child: Text(
                  formProvider.symptomsController.text.isEmpty
                      ? 'Describe visual symptoms, behavior...'
                      : formProvider.symptomsController.text,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    color: formProvider.symptomsController.text.isEmpty
                        ? Colors.grey.shade400
                        : const Color(0xFF1B1C1C),
                  ),
                ),
              )
            : TextField(
                controller: formProvider.symptomsController,
                focusNode: formProvider.symptomsFocus,
                maxLines: 4,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  color: const Color(0xFF1B1C1C),
                ),
                decoration: InputDecoration(
                  hintText: 'Describe visual symptoms, behavior...',
                  filled: true,
                  fillColor: const Color(0xFFF5F3F3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: Color(0xFF006E1C),
                      width: 2.w,
                    ),
                  ),
                ),
              ),
        SizedBox(height: 16.h),
        Text(
          'Quick Symptom Tags',
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            'Fracture',
            'Maggot Wound',
            'Tick Fever',
            'Viral',
            'Paralysis',
            'Poisoning',
            'Skin Disease',
            'Accident',
            'Dehydration',
          ].map((tag) => _buildSymptomChip(tag, formProvider)).toList(),
        ),
      ],
    );
  }

  Widget _buildSymptomChip(String tag, RegistrationProvider formProvider) {
    bool isSelected = formProvider.symptomTags.contains(tag);
    return GestureDetector(
      onTap: () {
        formProvider.toggleSymptomTag(tag);
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
          tag,
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildTestsAndVitals(BuildContext context) {
    final formProvider = context.watch<RegistrationProvider>();
    final voiceService = context.watch<VoiceService>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3F3),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.biotech,
                      color: const Color(0xFF006E1C),
                      size: 20.w,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Required Tests',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ...formProvider.requiredTests.keys
                    .map((test) => _buildTestCheckbox(test, formProvider))
                    .toList(),
              ],
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3F3),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.thermostat,
                      color: const Color(0xFF006E1C),
                      size: 20.w,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Vital Checks',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDDB9).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info,
                        color: const Color(0xFF865300),
                        size: 16.w,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Ensure animal is calm before taking vitals.',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 10.sp,
                            color: const Color(0xFF865300),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestCheckbox(String title, RegistrationProvider formProvider) {
    return Theme(
      data: ThemeData(unselectedWidgetColor: Colors.grey.shade400),
      child: CheckboxListTile(
        title: Text(title, style: GoogleFonts.nunitoSans(fontSize: 12.sp)),
        value: formProvider.requiredTests[title],
        activeColor: const Color(0xFF006E1C),
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.trailing,
        onChanged: (val) {
          formProvider.updateRequiredTest(title, val!);
        },
      ),
    );
  }

  Widget _buildWardAssignment(BuildContext context) {
    final formProvider = context.watch<RegistrationProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ward Assignment',
          style: GoogleFonts.nunitoSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8.h,
          crossAxisSpacing: 8.w,
          children: [
            _buildWardCard('ICU', Icons.emergency, formProvider),
            _buildWardCard('Isolation', Icons.flip_camera_ios, formProvider),
            _buildWardCard('General', Icons.bedroom_parent, formProvider),
            _buildWardCard('Tick Fever', Icons.pest_control, formProvider),
            _buildWardCard('Cancer', Icons.healing, formProvider),
            _buildWardCard('Viral', Icons.coronavirus, formProvider),
            _buildWardCard('Surgery', Icons.content_cut, formProvider),
            _buildOtherWardCard(),
          ],
        ),
      ],
    );
  }

  Widget _buildWardCard(
    String title,
    IconData icon,
    RegistrationProvider formProvider,
  ) {
    bool isSelected = formProvider.wardAssignment == title;
    return GestureDetector(
      onTap: () {
        formProvider.updateWardAssignment(title);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF5F3F3),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
            width: 2.w,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF006E1C)
                  : Colors.grey.shade500,
              size: 24.w,
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF003C0B)
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherWardCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3F3),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: Colors.grey.shade500, size: 24.w),
          SizedBox(height: 4.h),
          Text(
            'Other',
            style: GoogleFonts.nunitoSans(
              fontSize: 10.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorTreatment(BuildContext context) {
    final formProvider = context.watch<RegistrationProvider>();
    final voiceService = context.watch<VoiceService>();
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF006E1C).withOpacity(0.05),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFF006E1C).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundImage: const NetworkImage(
                  'https://images.unsplash.com/photo-1559839734-2b71ea197ec2',
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. Sarah Jenkins',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Lead Veterinarian • Active Duty',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Initial Treatment',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    voiceService.isVoiceModeActive
                        ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border:
                                  (formProvider.activeVoiceField ==
                                      'initialTreatment')
                                  ? Border.all(
                                      color: const Color(0xFF006E1C),
                                      width: 2.w,
                                    )
                                  : Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              formProvider
                                      .initialTreatmentController
                                      .text
                                      .isEmpty
                                  ? 'e.g. Saline drip...'
                                  : formProvider
                                        .initialTreatmentController
                                        .text,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 14.sp,
                                color:
                                    formProvider
                                        .initialTreatmentController
                                        .text
                                        .isEmpty
                                    ? Colors.grey.shade400
                                    : const Color(0xFF1B1C1C),
                              ),
                            ),
                          )
                        : TextField(
                            controller: formProvider.initialTreatmentController,
                            focusNode: formProvider.initialTreatmentFocus,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14.sp,
                              color: const Color(0xFF1B1C1C),
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. Saline drip...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
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
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medicine Started',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    TextField(
                      controller: formProvider.medicineStartedController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Meloxicam...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
