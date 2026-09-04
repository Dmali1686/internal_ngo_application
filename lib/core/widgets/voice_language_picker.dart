import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/voice_language_config.dart';

/// Shows a language selection bottom sheet.
///
/// Returns the selected [VoiceLanguageConfig] or null if dismissed.
Future<VoiceLanguageConfig?> showVoiceLanguagePicker(
    BuildContext context) async {
  return showModalBottomSheet<VoiceLanguageConfig>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _VoiceLanguagePickerSheet(),
  );
}

class _VoiceLanguagePickerSheet extends StatefulWidget {
  const _VoiceLanguagePickerSheet();

  @override
  State<_VoiceLanguagePickerSheet> createState() =>
      _VoiceLanguagePickerSheetState();
}

class _VoiceLanguagePickerSheetState extends State<_VoiceLanguagePickerSheet>
    with SingleTickerProviderStateMixin {
  VoiceLanguage _selected = VoiceLanguage.english;

  late AnimationController _entryController;
  late Animation<double> _entryAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _entryAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  VoiceLanguageConfig get _selectedConfig =>
      VoiceLanguageConfig.all.firstWhere((c) => c.language == _selected);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entryAnimation,
      builder: (context, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_entryAnimation),
        child: FadeTransition(
          opacity: _entryAnimation,
          child: child,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 20.h),

                // Title row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.mic_rounded,
                          color: Colors.white, size: 22.sp),
                    ),
                    SizedBox(width: 14.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Voice Language',
                          style: GoogleFonts.poppins(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          'Fields will be asked in the chosen language',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Language cards
                Row(
                  children: VoiceLanguageConfig.all
                      .map((config) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: _LanguageCard(
                                config: config,
                                isSelected: _selected == config.language,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(
                                      () => _selected = config.language);
                                },
                              ),
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: 28.h),

                // Start button
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F766E).withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16.r),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop(_selectedConfig);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mic_rounded,
                                color: Colors.white, size: 20.sp),
                            SizedBox(width: 10.w),
                            Text(
                              'Start Voice Input',
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final VoiceLanguageConfig config;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.config,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF0F766E).withOpacity(0.07)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF0F766E)
              : const Color(0xFFE2E8F0),
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF0F766E).withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Flag with subtle animated scale
                AnimatedScale(
                  scale: isSelected ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    config.flag,
                    style: TextStyle(fontSize: 30.sp),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  config.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF0F766E)
                        : const Color(0xFF1E293B),
                  ),
                ),
                if (config.nativeName != config.displayName) ...[
                  SizedBox(height: 2.h),
                  Text(
                    config.nativeName,
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF0F766E).withOpacity(0.8)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
                SizedBox(height: 8.h),
                // Selected indicator dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 8.w : 0,
                  height: isSelected ? 8.h : 0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
