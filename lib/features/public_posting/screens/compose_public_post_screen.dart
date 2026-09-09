import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/compose_post_provider.dart';
import 'publish_confirmation_sheet.dart';

/// Screen where the employee composes a public post for a rescued animal.
///
/// Auto-fills animal details from the registration data passed via
/// [GoRouterState.extra] and provides additional fields for description,
/// donation target, and emergency criteria.
class ComposePublicPostScreen extends StatefulWidget {
  const ComposePublicPostScreen({super.key});

  @override
  State<ComposePublicPostScreen> createState() =>
      _ComposePublicPostScreenState();
}

class _ComposePublicPostScreenState extends State<ComposePublicPostScreen> {
  @override
  void initState() {
    super.initState();
    // Defer provider data seeding until after the first frame so that
    // notifyListeners() calls don't fire during the build phase
    // (avoids the '!_dirty' / 'setState called during build' assertion).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<ComposePostProvider>();
      final extra = GoRouterState.of(context).extra;
      if (extra is Map<String, dynamic>) {
        provider.setPatientData(extra);

        // Pre-populate photos from registration
        if (extra['photos'] is List<XFile>) {
          provider.setInitialPhotos(extra['photos'] as List<XFile>);
        }

        // Pre-populate emergency level from registration urgency
        final urgency = extra['urgency']?.toString().toUpperCase() ?? '';
        if (urgency == 'CRITICAL' || urgency == 'URGENT') {
          provider.setEmergencyLevel(urgency);
        }
      }
    });
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (pickedFile != null && mounted) {
      context.read<ComposePostProvider>().addPhoto(pickedFile);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (pickedFile != null && mounted) {
      context.read<ComposePostProvider>().addPhoto(pickedFile);
    }
  }

  void _showPublishConfirmation() {
    final provider = context.read<ComposePostProvider>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ChangeNotifierProvider.value(
        value: provider,
        child: Consumer<ComposePostProvider>(
          builder: (ctx, p, _) => PublishConfirmationSheet(
            patientData: p.patientData,
            description: p.descriptionController.text.trim(),
            donationAmount:
                double.tryParse(p.donationAmountController.text.trim()) ?? 0,
            emergencyLevel: p.emergencyLevel,
            tagText: p.tagText,
            isLoading: p.isSubmitting,
            onConfirm: () async {
              final success = await p.submitPost();
              if (!ctx.mounted) return;

              if (success) {
                Navigator.of(ctx).pop(true);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                                'Post published to public app successfully!'),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF006E1C),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  context.pop();
                }
              } else {
                Navigator.of(ctx).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              p.errorMessage ?? 'Failed to publish the post.',
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red[700],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            onCancel: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The provider is already injected by the router via ChangeNotifierProvider.
    // We use Consumer below to rebuild on state changes.
    return Scaffold(
        backgroundColor: const Color(0xFFF5F9F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Share to Public App',
            style: GoogleFonts.nunitoSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B1C1C),
            ),
          ),
          centerTitle: true,
          foregroundColor: const Color(0xFF1B1C1C),
        ),
        body: Consumer<ComposePostProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Section 1: Animal Photos ─────────────────────────
                  _SectionHeader(
                    icon: Icons.photo_library_rounded,
                    title: 'Animal Photos',
                    subtitle: 'Photos captured during rescue',
                  ),
                  SizedBox(height: 12.h),
                  _PhotosCarousel(
                    photos: provider.photos,
                    onAddCamera: _pickPhoto,
                    onAddGallery: _pickFromGallery,
                    onRemove: provider.removePhoto,
                  ),
                  SizedBox(height: 28.h),

                  // ── Section 2: Animal Details (auto-filled) ──────────
                  _SectionHeader(
                    icon: Icons.pets_rounded,
                    title: 'Animal Details',
                    subtitle: 'Auto-filled from registration',
                  ),
                  SizedBox(height: 12.h),
                  _AnimalDetailsCard(provider: provider),
                  SizedBox(height: 28.h),

                  // ── Section 3: Post Description ──────────────────────
                  _SectionHeader(
                    icon: Icons.edit_note_rounded,
                    title: 'Post Description',
                    subtitle: 'Write a compelling story for the public',
                  ),
                  SizedBox(height: 12.h),
                  _DescriptionField(
                    controller: provider.descriptionController,
                  ),
                  SizedBox(height: 28.h),

                  // ── Section 4: Post Tag ──────────────────────────────
                  _SectionHeader(
                    icon: Icons.label_rounded,
                    title: 'Post Tag',
                    subtitle: 'Select a tag for the post badge',
                  ),
                  SizedBox(height: 12.h),
                  _TagSelector(
                    selectedTag: provider.tagText,
                    onTagSelected: provider.setTagText,
                  ),
                  SizedBox(height: 28.h),

                  // ── Section 5: Donation Details ──────────────────────
                  _SectionHeader(
                    icon: Icons.volunteer_activism_rounded,
                    title: 'Donation Details',
                    subtitle: 'Set a fundraising goal for this animal',
                  ),
                  SizedBox(height: 12.h),
                  _DonationField(
                    controller: provider.donationAmountController,
                  ),
                  SizedBox(height: 28.h),

                  // ── Section 6: Emergency Criteria ────────────────────
                  _SectionHeader(
                    icon: Icons.emergency_rounded,
                    title: 'Emergency Criteria',
                    subtitle: 'Set the urgency level for this case',
                  ),
                  SizedBox(height: 12.h),
                  _EmergencySelector(
                    selectedLevel: provider.emergencyLevel,
                    onLevelSelected: provider.setEmergencyLevel,
                  ),
                  SizedBox(height: 32.h),

                  // ── Section 7: Post Preview ──────────────────────────
                  _SectionHeader(
                    icon: Icons.preview_rounded,
                    title: 'Post Preview',
                    subtitle: 'How it will appear on the public app',
                  ),
                  SizedBox(height: 12.h),
                  _PostPreviewCard(provider: provider),
                  SizedBox(height: 32.h),

                  // ── Actions ──────────────────────────────────────────
                  ElevatedButton.icon(
                    onPressed:
                        provider.isFormValid ? _showPublishConfirmation : null,
                    icon: const Icon(Icons.publish_rounded),
                    label: const Text('Publish to Public App'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006E1C),
                      disabledBackgroundColor: Colors.grey[300],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      textStyle: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  OutlinedButton.icon(
                    onPressed: () {
                      // For now just show a message – draft saving
                      // can be implemented with the backend
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              'Draft saving will be available soon.'),
                          backgroundColor: Colors.grey[700],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save as Draft'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF006E1C),
                      side: const BorderSide(color: Color(0xFF006E1C)),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      textStyle: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            );
          },
        ),
      );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── Private widgets ──────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFF006E1C).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: const Color(0xFF006E1C), size: 20.w),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B1C1C),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: GoogleFonts.nunitoSans(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Photos carousel ──────────────────────────────────────────────────────────

class _PhotosCarousel extends StatelessWidget {
  final List<XFile> photos;
  final VoidCallback onAddCamera;
  final VoidCallback onAddGallery;
  final void Function(int) onRemove;

  const _PhotosCarousel({
    required this.photos,
    required this.onAddCamera,
    required this.onAddGallery,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length + 1,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          if (index == photos.length) {
            // Add photo button
            return Container(
              width: 120.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: const Color(0xFF006E1C).withOpacity(0.3),
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: onAddCamera,
                    icon: Icon(
                      Icons.camera_alt_rounded,
                      color: const Color(0xFF006E1C),
                      size: 28.w,
                    ),
                  ),
                  Text(
                    'Camera',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11.sp,
                      color: const Color(0xFF006E1C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  IconButton(
                    onPressed: onAddGallery,
                    icon: Icon(
                      Icons.photo_library_rounded,
                      color: const Color(0xFF006E1C),
                      size: 28.w,
                    ),
                  ),
                  Text(
                    'Gallery',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11.sp,
                      color: const Color(0xFF006E1C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              Container(
                width: 140.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  image: DecorationImage(
                    image: FileImage(File(photos[index].path)),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 6.h,
                right: 6.w,
                child: GestureDetector(
                  onTap: () => onRemove(index),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
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
              if (index == 0)
                Positioned(
                  bottom: 6.h,
                  left: 6.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006E1C),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Cover',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Animal details card ──────────────────────────────────────────────────────

class _AnimalDetailsCard extends StatelessWidget {
  final ComposePostProvider provider;

  const _AnimalDetailsCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildEditableField(Icons.pets_rounded, 'Type', provider.animalTypeController),
          _buildEditableField(Icons.category_rounded, 'Breed', provider.breedController),
          _buildEditableField(Icons.palette_rounded, 'Color', provider.colorController),
          _buildEditableField(Icons.wc_rounded, 'Gender', provider.genderController),
          _buildEditableField(Icons.cake_rounded, 'Age', provider.ageController),
          _buildEditableField(Icons.location_on_rounded, 'Rescued From', provider.rescueLocationController),
          _buildEditableField(Icons.medical_services_rounded, 'Condition', provider.conditionController),
          // Case ID is read-only
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Row(
              children: [
                Icon(Icons.tag_rounded, size: 18.w, color: const Color(0xFF006E1C)),
                SizedBox(width: 12.w),
                SizedBox(
                  width: 100.w,
                  child: Text(
                    'Case ID',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13.sp,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    provider.patientData['case_id']?.toString() ?? 'N/A',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(IconData icon, String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 18.w, color: const Color(0xFF006E1C)),
          SizedBox(width: 12.w),
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: GoogleFonts.nunitoSans(
                fontSize: 13.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.nunitoSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B1C1C),
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                hintText: 'Enter $label',
                hintStyle: GoogleFonts.nunitoSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Description field ────────────────────────────────────────────────────────

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const _DescriptionField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        maxLength: 500,
        style: GoogleFonts.nunitoSans(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText:
              'Tell the story of this rescued animal...\n\ne.g. "This brave pup was found injured near the highway. He needs surgery for a fractured leg and your support can help cover the costs."',
          hintStyle: GoogleFonts.nunitoSans(
            fontSize: 13.sp,
            color: Colors.grey[400],
            height: 1.5,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          counterStyle: GoogleFonts.nunitoSans(
            fontSize: 11.sp,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }
}

// ── Tag selector ─────────────────────────────────────────────────────────────

class _TagSelector extends StatelessWidget {
  final String selectedTag;
  final void Function(String) onTagSelected;

  const _TagSelector({
    required this.selectedTag,
    required this.onTagSelected,
  });

  Color _tagColor(String tag) {
    switch (tag) {
      case 'Critical':
        return const Color(0xFFD32F2F);
      case 'Need Help':
        return const Color(0xFFF57C00);
      case 'Recovering':
        return const Color(0xFF006E1C);
      case 'Adopted':
        return const Color(0xFF1565C0);
      case 'Looking for Home':
        return const Color(0xFF7B1FA2);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: ComposePostProvider.availableTags.map((tag) {
        final isSelected = selectedTag == tag;
        final color = _tagColor(tag);
        return GestureDetector(
          onTap: () => onTagSelected(tag),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: isSelected ? color : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              tag,
              style: GoogleFonts.nunitoSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Donation field ───────────────────────────────────────────────────────────

class _DonationField extends StatelessWidget {
  final TextEditingController controller;

  const _DonationField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Amount',
            style: GoogleFonts.nunitoSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.nunitoSans(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF006E1C),
            ),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: GoogleFonts.nunitoSans(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF006E1C),
              ),
              hintText: '0',
              hintStyle: GoogleFonts.nunitoSans(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[300],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide:
                    const BorderSide(color: Color(0xFF006E1C), width: 2),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
          SizedBox(height: 8.h),
          // Quick amount chips
          Row(
            children: [5000, 10000, 25000, 50000].map((amount) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: OutlinedButton(
                    onPressed: () => controller.text = amount.toString(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF006E1C),
                      side: BorderSide(
                          color: const Color(0xFF006E1C).withOpacity(0.3)),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      '₹${amount ~/ 1000}K',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Emergency selector ───────────────────────────────────────────────────────

class _EmergencySelector extends StatelessWidget {
  final String selectedLevel;
  final void Function(String) onLevelSelected;

  const _EmergencySelector({
    required this.selectedLevel,
    required this.onLevelSelected,
  });

  @override
  Widget build(BuildContext context) {
    final levels = [
      _EmergencyOption(
        'NORMAL',
        'Normal',
        'Standard case, no immediate danger',
        Icons.check_circle_outline_rounded,
        const Color(0xFF006E1C),
      ),
      _EmergencyOption(
        'URGENT',
        'Urgent',
        'Requires prompt attention & funding',
        Icons.priority_high_rounded,
        const Color(0xFFF57C00),
      ),
      _EmergencyOption(
        'CRITICAL',
        'Critical',
        'Life-threatening, needs immediate help',
        Icons.warning_amber_rounded,
        const Color(0xFFD32F2F),
      ),
    ];

    return Column(
      children: levels.map((level) {
        final isSelected = selectedLevel == level.value;
        return GestureDetector(
          onTap: () => onLevelSelected(level.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isSelected ? level.color.withOpacity(0.06) : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? level.color : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: level.color.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? level.color
                        : Colors.grey[200],
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 16.w)
                      : null,
                ),
                SizedBox(width: 14.w),
                Icon(level.icon, color: level.color, size: 24.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.label,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? level.color
                              : const Color(0xFF1B1C1C),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        level.description,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EmergencyOption {
  final String value;
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  _EmergencyOption(
      this.value, this.label, this.description, this.icon, this.color);
}

// ── Post preview card ────────────────────────────────────────────────────────

class _PostPreviewCard extends StatelessWidget {
  final ComposePostProvider provider;

  const _PostPreviewCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final data = provider.patientData;
    final animalType = data['animal_type']?.toString() ?? 'Animal';
    final description = provider.descriptionController.text.isNotEmpty
        ? provider.descriptionController.text
        : 'No description yet...';
    final donationTarget =
        double.tryParse(provider.donationAmountController.text) ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: const Color(0xFF006E1C),
                  child:
                      Icon(Icons.pets, color: Colors.white, size: 18.w),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MH14 Animal Rescue',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Just now • Pune',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Image placeholder
          Container(
            height: 180.h,
            width: double.infinity,
            color: Colors.grey[100],
            child: provider.photos.isNotEmpty
                ? Image.file(
                    File(provider.photos.first.path),
                    fit: BoxFit.cover,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_rounded,
                          size: 48.w, color: Colors.grey[300]),
                      SizedBox(height: 8.h),
                      Text(
                        'No photo added yet',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
          ),

          // Tag
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE0B2),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                provider.tagText,
                style: GoogleFonts.nunitoSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ),
          ),

          // Caption
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
            child: RichText(
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: GoogleFonts.nunitoSans(
                  fontSize: 13.sp,
                  color: const Color(0xFF1B1C1C),
                ),
                children: [
                  TextSpan(
                    text: '$animalType Rescue  ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),

          // Donation bar
          if (donationTarget > 0)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 0),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FUNDRAISER',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.grey[400],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '₹0 raised of ₹${donationTarget.toStringAsFixed(0)}',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF006E1C),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: 0,
                        minHeight: 6.h,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF006E1C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: 14.h),
        ],
      ),
    );
  }
}
