import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class StatCards extends StatelessWidget {
  const StatCards({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        'title': 'Today\'s\nAdmissions',
        'value': '24',
        'icon': Icons.pets,
        'color': const Color(0xFF34A853),
      },
      {
        'title': 'Emergency\nCases',
        'value': '6',
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFEF4444),
      },
      {
        'title': 'Available\nCages',
        'value': '42',
        'icon': Icons.home,
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'Pending\nTasks',
        'value': '12',
        'icon': Icons.assignment,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Transform.translate(
        offset: Offset(0, -20.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: stats.map((stat) {
              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: (stat['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        stat['icon'] as IconData,
                        color: stat['color'] as Color,
                        size: 24.w,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      stat['value'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      stat['title'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
