import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class RecentAdmissions extends StatelessWidget {
  const RecentAdmissions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Admissions',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              Row(
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.primaryGreen,
                    size: 20.w,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 5,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&q=80&w=100&h=100',
                    width: 60.w,
                    height: 60.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60.w,
                        height: 60.w,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.pets,
                          color: Colors.grey[400],
                          size: 24.w,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bruno',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'ID: ANM-2024-0568',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12.sp,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 4.h,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.pets, size: 14.w, color: Colors.grey),
                              SizedBox(width: 4.w),
                              Text(
                                'Dog',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 12.sp,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14.w,
                                color: AppColors.textMuted,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '12 May 2024',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 12.sp,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E8B57).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Treatment',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.chevron_right, color: Colors.grey, size: 24.w),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
