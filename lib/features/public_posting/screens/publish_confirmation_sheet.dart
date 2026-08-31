import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// A confirmation bottom sheet shown before publishing a post
/// to the public NGO application.
///
/// Displays a summary of the post data and requires explicit
/// confirmation from the employee.
class PublishConfirmationSheet extends StatelessWidget {
  final Map<String, dynamic> patientData;
  final String description;
  final double donationAmount;
  final String emergencyLevel;
  final String tagText;
  final bool isLoading;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PublishConfirmationSheet({
    super.key,
    required this.patientData,
    required this.description,
    required this.donationAmount,
    required this.emergencyLevel,
    required this.tagText,
    this.isLoading = false,
    required this.onConfirm,
    required this.onCancel,
  });

  /// Static helper to show this sheet as a modal bottom sheet.
  static Future<bool?> show(
    BuildContext context, {
    required Map<String, dynamic> patientData,
    required String description,
    required double donationAmount,
    required String emergencyLevel,
    required String tagText,
    required bool isLoading,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PublishConfirmationSheet(
        patientData: patientData,
        description: description,
        donationAmount: donationAmount,
        emergencyLevel: emergencyLevel,
        tagText: tagText,
        isLoading: isLoading,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  Color _emergencyColor() {
    switch (emergencyLevel) {
      case 'CRITICAL':
        return const Color(0xFFD32F2F);
      case 'URGENT':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF006E1C);
    }
  }

  IconData _emergencyIcon() {
    switch (emergencyLevel) {
      case 'CRITICAL':
        return Icons.warning_amber_rounded;
      case 'URGENT':
        return Icons.priority_high_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final animalType = patientData['animal_type']?.toString() ?? 'Animal';
    final caseId = patientData['case_id']?.toString() ?? 'N/A';
    final color = patientData['color']?.toString();
    final gender = patientData['gender']?.toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ────────────────────────────────────────────
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),

          // ── Title ──────────────────────────────────────────────────
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _emergencyColor().withOpacity(0.1),
            ),
            child: Icon(
              Icons.publish_rounded,
              color: _emergencyColor(),
              size: 32.w,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Publish to Public App',
            style: GoogleFonts.nunitoSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B1C1C),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'This will make this animal\'s post visible\nto all users on the public MH14 app.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),

          // ── Summary card ───────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9F5),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFF006E1C).withOpacity(0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POST SUMMARY',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 12.h),
                _summaryRow(Icons.pets_rounded, '$animalType${color != null ? ' - $color' : ''}${gender != null ? ', $gender' : ''}'),
                SizedBox(height: 8.h),
                _summaryRow(Icons.tag_rounded, 'Case: $caseId'),
                SizedBox(height: 8.h),
                _summaryRow(
                  Icons.currency_rupee_rounded,
                  'Donation Target: ₹${donationAmount.toStringAsFixed(0)}',
                ),
                SizedBox(height: 8.h),
                _summaryRow(_emergencyIcon(), 'Priority: $emergencyLevel',
                    color: _emergencyColor()),
                SizedBox(height: 8.h),
                _summaryRow(Icons.label_rounded, 'Tag: $tagText'),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // ── Confirm button ─────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onConfirm,
              icon: isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_rounded),
              label: Text(isLoading ? 'Publishing...' : 'Confirm & Publish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006E1C),
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
          ),
          SizedBox(height: 12.h),

          // ── Cancel button ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: isLoading ? null : onCancel,
              child: Text(
                'Cancel',
                style: GoogleFonts.nunitoSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18.w, color: color ?? Colors.grey[700]),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.nunitoSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color ?? const Color(0xFF1B1C1C),
            ),
          ),
        ),
      ],
    );
  }
}
