import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onProfileTap;

  const HomeHeader({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.only(
        top: 60.h,
        left: 20.w,
        right: 20.w,
        bottom: 20.h,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          Icon(Icons.notifications_none, size: 28.w),
                          Positioned(
                            right: 2.w,
                            top: 2.h,
                            child: Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '5',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 15.w),
                      GestureDetector(
                        onTap: onProfileTap,
                        child: CircleAvatar(
                          radius: 18.r,
                          backgroundImage: const NetworkImage(
                            'https://randomuser.me/api/portraits/women/44.jpg',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 25.h),
              Text(
                'NGO',
                style: GoogleFonts.poppins(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                  height: 1.1,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Operational Hub',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Text(
                    'Care. Heal. Protect. ',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Icon(
                    Icons.favorite,
                    color: AppColors.primaryGreen,
                    size: 16.w,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
          Positioned(
            right: 0.w,
            bottom: 0.h,
            child: Image.asset(
              'assets/images/dog_transparent.png',
              width: 140.w,
              height: 140.h,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
