import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          _buildPersonalInformationForm(context),
          SizedBox(height: 120.h),
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
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
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
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Capture Animal Photos (Required)',
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Take a clear front and side photo of the animal',
          style: GoogleFonts.nunitoSans(
            fontSize: 12.sp,
            color: Colors.grey.shade500,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildPhotoCard(
                context: context,
                label: 'Front Photo',
                subtitle: 'Facing the camera',
                icon: Icons.face_rounded,
                file: formProvider.frontImage,
                color: const Color(0xFF006E1C),
                isDisabled: voiceService.isVoiceModeActive,
                onTap: () => _showImageSourceSheet(context, isFront: true),
                onRemove: () => formProvider.setFrontImage(null),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildPhotoCard(
                context: context,
                label: 'Side Photo',
                subtitle: 'Profile / side view',
                icon: Icons.switch_camera_rounded,
                file: formProvider.sideImage,
                color: const Color(0xFF0057A8),
                isDisabled: voiceService.isVoiceModeActive,
                onTap: () => _showImageSourceSheet(context, isFront: false),
                onRemove: () => formProvider.setSideImage(null),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // Status row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusDot(
              filled: formProvider.frontImage != null,
              label: 'Front',
            ),
            SizedBox(width: 16.w),
            _buildStatusDot(
              filled: formProvider.sideImage != null,
              label: 'Side',
            ),
          ],
        ),
        if (formProvider.frontImage == null || formProvider.sideImage == null) ...[
          SizedBox(height: 8.h),
          Center(
            child: Text(
              '⚠ Both photos are required to continue',
              style: GoogleFonts.nunitoSans(
                fontSize: 12.sp,
                color: const Color(0xFFB45309),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoCard({
    required BuildContext context,
    required String label,
    required String subtitle,
    required IconData icon,
    required XFile? file,
    required Color color,
    required bool isDisabled,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final hasImage = file != null;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: 160.h,
        decoration: BoxDecoration(
          color: hasImage ? Colors.transparent : color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: hasImage ? color : color.withOpacity(0.35),
            width: hasImage ? 2.5 : 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.r),
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(file.path),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 6.h,
                      right: 6.w,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 16.w,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 6.h,
                          horizontal: 10.w,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.55),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 14.w),
                            SizedBox(width: 5.w),
                            Text(
                              label,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 22.w),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      label,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B1C1C),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_a_photo_rounded,
                              size: 13.w, color: color),
                          SizedBox(width: 5.w),
                          Text(
                            'Add Photo',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context, {required bool isFront}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 30.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              isFront ? 'Front Photo' : 'Side Photo',
              style: GoogleFonts.nunitoSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B1C1C),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Choose how you want to add the photo',
              style: GoogleFonts.nunitoSans(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: _buildSourceTile(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: const Color(0xFF006E1C),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(context, isFront: isFront, source: ImageSource.camera);
                    },
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: _buildSourceTile(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: const Color(0xFF0057A8),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(context, isFront: isFront, source: ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context, {
    required bool isFront,
    required ImageSource source,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (picked == null) return;
    final provider = context.read<RegistrationProvider>();
    if (isFront) {
      provider.setFrontImage(picked);
    } else {
      provider.setSideImage(picked);
    }
  }

  Widget _buildSourceTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 22.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 34.w, color: color),
            SizedBox(height: 10.h),
            Text(
              label,
              style: GoogleFonts.nunitoSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDot({required bool filled, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? const Color(0xFF006E1C) : Colors.grey.shade300,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: filled ? const Color(0xFF006E1C) : Colors.grey.shade500,
          ),
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
