import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/registration_provider.dart';
import '../../services/registration_voice_assistant.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../core/services/voice_language_provider.dart';

class Step1ReporterDetails extends StatelessWidget {
  const Step1ReporterDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildRequestIdBadge(), _buildEmergencyToggle(context)],
          ),
          SizedBox(height: 24.h),
          _buildPersonalInformationForm(context),
          SizedBox(height: 120.h),
        ],
      ),
    );
  }

  Widget _buildEmergencyToggle(BuildContext context) {
    final formProvider = context.watch<RegistrationProvider>();
    final isEmergency = formProvider.isEmergency;

    return GestureDetector(
      onTap: () {
        formProvider.updateIsEmergency(!isEmergency);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isEmergency
              ? const Color(0xFFEF4444).withOpacity(0.1)
              : Colors.grey.shade100,
          border: Border.all(
            color: isEmergency ? const Color(0xFFEF4444) : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_rounded,
              color: isEmergency
                  ? const Color(0xFFEF4444)
                  : Colors.grey.shade500,
              size: 16.w,
            ),
            SizedBox(width: 8.w),
            Text(
              'Emergency',
              style: GoogleFonts.nunitoSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: isEmergency
                    ? const Color(0xFFB91C1C)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestIdBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        border: Border.all(color: const Color(0xFF4CAF50)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fingerprint, color: const Color(0xFF006E1C), size: 16.w),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RESCUE REQUEST ID',
                style: GoogleFonts.nunitoSans(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF006E1C).withOpacity(0.7),
                  letterSpacing: 1,
                ),
              ),
              Text(
                'REQ-2023-8942',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF003C0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformationForm(BuildContext context) {
    final formProvider = context.watch<RegistrationProvider>();
    final voiceService = context.watch<VoiceService>();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: const Color(0xFF006E1C),
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Personal Information',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                ],
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
                    assistant.startStep1();
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildPhotoCaptureBox(context),
          SizedBox(height: 16.h),
          _buildTextField(
            'Reporter Name',
            'Full Name',
            formProvider.reporterNameController,
            focusNode: formProvider.reporterNameFocus,
            readOnly: voiceService.isVoiceModeActive,
            fieldKey: 'reporterName',
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            'Mobile Number',
            'Primary contact number',
            formProvider.mobileNumberController,
            focusNode: formProvider.mobileNumberFocus,
            keyboardType: TextInputType.phone,
            readOnly: voiceService.isVoiceModeActive,
            fieldKey: 'mobileNumber',
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            'Alternate Number (Optional)',
            'Secondary contact',
            formProvider.alternateNumberController,
            focusNode: formProvider.alternateNumberFocus,
            keyboardType: TextInputType.phone,
            readOnly: voiceService.isVoiceModeActive,
            fieldKey: 'alternateNumber',
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCaptureBox(BuildContext context) {
    final formProvider = context.watch<RegistrationProvider>();
    final voiceService = context.watch<VoiceService>();
    final angles = ['Front Angle', 'Left Side', 'Right Side', 'Back/Wound'];
    final placeholders = [
      'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1537151608804-ea6f1cb5b9f7?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=300&q=80',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Capture Animal Photos (Required 4 Angles)',
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final hasPhoto = index < formProvider.reporterPhotos.length;
            final isNext = index == formProvider.reporterPhotos.length;

            return GestureDetector(
              onTap: voiceService.isVoiceModeActive
                  ? null
                  : () async {
                      if (hasPhoto) {
                        formProvider.removeReporterPhoto(index);
                      } else if (isNext) {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.camera,
                        );
                        if (pickedFile != null) {
                          formProvider.addReporterPhoto(pickedFile);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please take the ${angles[formProvider.reporterPhotos.length]} photo first.',
                            ),
                          ),
                        );
                      }
                    },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF9F9),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: hasPhoto
                        ? const Color(0xFF4CAF50)
                        : (isNext
                              ? const Color(0xFF006E1C)
                              : Colors.grey.shade300),
                    style: BorderStyle.solid,
                    width: hasPhoto || isNext ? 2 : 1,
                  ),
                  image: hasPhoto
                      ? DecorationImage(
                          image: FileImage(
                            File(formProvider.reporterPhotos[index].path),
                          ),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: NetworkImage(placeholders[index]),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(isNext ? 0.6 : 0.85),
                            BlendMode.lighten,
                          ),
                        ),
                ),
                child: hasPhoto
                    ? Stack(
                        children: [
                          Positioned(
                            top: 8.h,
                            right: 8.w,
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16.w,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0.h,
                            left: 0.w,
                            right: 0.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(14.r),
                                ),
                              ),
                              child: Text(
                                angles[index],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunitoSans(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: isNext
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                              size: 20.w,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(
                                isNext ? 0.6 : 0.4,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              angles[index],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            );
          },
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
    String? fieldKey,
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
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
              child: Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
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
                      border: isActiveVoiceField
                          ? Border.all(
                              color: const Color(0xFF006E1C),
                              width: 2.w,
                            )
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      controller.text.isEmpty ? hint : controller.text,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        color: controller.text.isEmpty
                            ? Colors.grey.shade400
                            : const Color(0xFF1B1C1C),
                      ),
                    ),
                  )
                : TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: keyboardType,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14.sp,
                      color: const Color(0xFF1B1C1C),
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.nunitoSans(
                        color: Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: Colors.white,
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
