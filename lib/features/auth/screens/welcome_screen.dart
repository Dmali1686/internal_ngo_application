import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';

/// Premium welcome screen for MH14 Animal Hospital.
///
/// Features:
/// - Fully rounded top logo
/// - Strict single-screen layout (no scrolling, no overflow) using Flex/Expanded
/// - Distinct typography hierarchy (Montserrat for headers, Lato for body)
/// - Responsive sizing via [ScreenUtil]
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.lifecycle('WelcomeScreen', 'build');
    debugPrint('[DEBUG][WelcomeScreen] build called');

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      // Use SafeArea to avoid notches, and an absolute Column for a single-screen layout
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 12.h),

              // ── 1. Fully Rounded Small Logo ─────────────────────
              _buildTopLogo(),

              SizedBox(height: 20.h),

              // ── 2. Illustration Card (Flexible to fit screen) ───
              Expanded(flex: 4, child: _buildIllustrationCard()),

              SizedBox(height: 24.h),

              // ── 3. Typography: Montserrat for high importance ───
              Text(
                AppStrings.welcomeHeading,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),

              SizedBox(height: 10.h),

              // ── 4. Typography: Lato for secondary importance ────
              Text(
                AppStrings.welcomeDescription,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 16.h),

              // ── 5. Feature chips ────────────────────────────────
              _buildFeatureChips(),

              SizedBox(height: 24.h),

              // ── 6. Call to Action Buttons ───────────────────────
              _buildGetStartedButton(context),

              SizedBox(height: 16.h), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  /// Small MH14 logo at the top without a circle background.
  Widget _buildTopLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.asset(
        AppAssets.mh14Logo,
        width: 48.w,
        height: 48.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.pets, size: 24.w, color: AppColors.primaryGreen);
        },
      ),
    );
  }

  /// Large illustration card. Uses LayoutBuilder to maximize image size without overflow.
  Widget _buildIllustrationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16.r,
            spreadRadius: 0,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate banner height so the image can take the exact remaining space
            final bannerHeight = 40.h;

            return Column(
              children: [
                // ── "Find a Forever Friend" banner ────────────────────
                Container(
                  width: double.infinity,
                  height: bannerHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.06),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Find a Forever Friend',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.favorite,
                        size: 14.w,
                        color: AppColors.primaryGreen,
                      ),
                    ],
                  ),
                ),

                // ── Illustration image taking exact remaining space ───
                SizedBox(
                  height: constraints.maxHeight - bannerHeight,
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        AppAssets.welcomeIllustration,
                        fit: BoxFit
                            .contain, // Ensures image never crops or distorts
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Feature chips using Wrap to prevent horizontal overflow on very narrow screens.
  Widget _buildFeatureChips() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _buildChip(Icons.location_on_outlined, AppStrings.reportRescues),
        _buildChip(
          Icons.medical_services_outlined,
          AppStrings.supportTreatments,
        ),
        _buildChip(Icons.pets_outlined, AppStrings.adopt),
        _buildChip(Icons.volunteer_activism_outlined, AppStrings.volunteer),
      ],
    );
  }

  /// Individual feature chip with icon + label.
  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.w, color: AppColors.primaryGreen),
          SizedBox(width: 6.w),
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }

  /// Green "Get Started" CTA button.
  Widget _buildGetStartedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: () {
          AppLogger.action('WelcomeScreen', '"Get Started" button pressed');
          context.go('/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Text(
          AppStrings.getStarted,
          style: GoogleFonts.nunitoSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
