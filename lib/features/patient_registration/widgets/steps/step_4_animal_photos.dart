import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/registration_provider.dart';

/// Step 4 — Animal Photos
///
/// Requires the user to capture/select exactly two photos:
/// - [frontImage] : front-facing shot of the animal
/// - [sideImage]  : side-facing shot
///
/// Both are mandatory. The screen prevents advancing until both are set.
class Step4AnimalPhotos extends StatefulWidget {
  const Step4AnimalPhotos({super.key});

  @override
  State<Step4AnimalPhotos> createState() => _Step4AnimalPhotosState();
}

class _Step4AnimalPhotosState extends State<Step4AnimalPhotos> {
  final ImagePicker _picker = ImagePicker();

  static const Color _green = Color(0xFF006E1C);

  Future<void> _pickImage({
    required bool isFront,
    required ImageSource source,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,   // keep size under 5 MB
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (picked == null || !mounted) return;
    final provider = context.read<RegistrationProvider>();
    if (isFront) {
      provider.setFrontImage(picked);
    } else {
      provider.setSideImage(picked);
    }
  }

  void _showSourceSheet(bool isFront) {
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
                  child: _SourceTile(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: _green,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(isFront: isFront, source: ImageSource.camera);
                    },
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: _SourceTile(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: const Color(0xFF0057A8),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(isFront: isFront, source: ImageSource.gallery);
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          // Header
          Text(
            'Animal Photos',
            style: GoogleFonts.nunitoSans(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B1C1C),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Capture a clear front and side photo of the animal. Both are required for registration.',
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          SizedBox(height: 28.h),

          // Tip card
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4EC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: _green.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates_rounded,
                    color: _green, size: 20.w),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Take photos in good lighting. Max 5 MB each. JPEG / PNG / WEBP accepted.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12.sp,
                      color: const Color(0xFF1B4A24),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 28.h),

          // Photo pickers
          Row(
            children: [
              Expanded(
                child: _PhotoPicker(
                  label: 'Front Photo',
                  description: 'Facing the camera',
                  icon: Icons.face_rounded,
                  file: provider.frontImage,
                  color: _green,
                  onTap: () => _showSourceSheet(true),
                  onRemove: () => provider.setFrontImage(null),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: _PhotoPicker(
                  label: 'Side Photo',
                  description: 'Profile / side view',
                  icon: Icons.switch_camera_rounded,
                  file: provider.sideImage,
                  color: const Color(0xFF0057A8),
                  onTap: () => _showSourceSheet(false),
                  onRemove: () => provider.setSideImage(null),
                ),
              ),
            ],
          ),

          // Status row
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatusDot(filled: provider.frontImage != null, label: 'Front'),
              SizedBox(width: 16.w),
              _StatusDot(filled: provider.sideImage != null, label: 'Side'),
            ],
          ),

          if (provider.frontImage == null || provider.sideImage == null) ...[
            SizedBox(height: 16.h),
            Center(
              child: Text(
                '⚠ Both photos are required to continue',
                style: GoogleFonts.nunitoSans(
                  fontSize: 13.sp,
                  color: const Color(0xFFB45309),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          SizedBox(height: 100.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Photo picker tile
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoPicker extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final XFile? file;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PhotoPicker({
    required this.label,
    required this.description,
    required this.icon,
    required this.file,
    required this.color,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = file != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: 200.h,
        decoration: BoxDecoration(
          color: hasImage ? Colors.transparent : color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: hasImage ? color : color.withOpacity(0.35),
            width: hasImage ? 2.5 : 1.5,
            style: hasImage ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17.r),
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(file!.path),
                      fit: BoxFit.cover,
                    ),
                    // Remove button
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
                    // Label at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.h, horizontal: 10.w),
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
                      width: 52.w,
                      height: 52.w,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 26.w),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      label,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B1C1C),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 6.h),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Source selection tile
// ─────────────────────────────────────────────────────────────────────────────

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Status dot
// ─────────────────────────────────────────────────────────────────────────────

class _StatusDot extends StatelessWidget {
  final bool filled;
  final String label;

  const _StatusDot({required this.filled, required this.label});

  @override
  Widget build(BuildContext context) {
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
}
