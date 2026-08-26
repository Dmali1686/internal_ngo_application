import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DoctorPanelScreen extends StatelessWidget {
  const DoctorPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textMain,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Doctor Panel',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            color: AppColors.textMain,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
        children: [
          _buildPatientHeader(),
          SizedBox(height: 24.h),

          Text(
            'Patient Care Management',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Set instructions and schedules for the staff',
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 20.h),

          _buildManagementCard(
            context,
            title: 'Medical Orders',
            subtitle: 'Update condition, prescribe meds & vitals',
            icon: Icons.medical_services_outlined,
            color: const Color(0xFF3B82F6),
            route: '/doctor-medical-orders',
            status: 'Last updated today, 09:30 AM',
          ),
          SizedBox(height: 16.h),

          _buildManagementCard(
            context,
            title: 'Food Schedule',
            subtitle: 'Set feeding times and diet instructions',
            icon: Icons.restaurant_outlined,
            color: const Color(0xFFF59E0B),
            route: '/doctor-food-schedule',
            status: '4 slots scheduled',
          ),
          SizedBox(height: 16.h),

          _buildManagementCard(
            context,
            title: 'Cleaning Schedule',
            subtitle: 'Assign cage cleaning and grooming tasks',
            icon: Icons.cleaning_services_outlined,
            color: const Color(0xFF14B8A6),
            route: '/doctor-cleaning-schedule',
            status: '5 tasks scheduled',
          ),
        ],
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundImage: const NetworkImage(
              'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=200&q=80',
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bella',
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.healing,
                            size: 14.sp,
                            color: const Color(0xFF3B82F6),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Recovery',
                            style: GoogleFonts.nunitoSans(
                              color: const Color(0xFF3B82F6),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '#PT-2938 • Golden Retriever',
                  style: GoogleFonts.nunitoSans(
                    color: AppColors.textMuted,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Cage 04, Ward A',
                  style: GoogleFonts.nunitoSans(
                    color: AppColors.textMuted,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
    required String status,
  }) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 14.sp, color: color),
                      SizedBox(width: 4.w),
                      Text(
                        status,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12.sp,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24.sp),
          ],
        ),
      ),
    );
  }
}
