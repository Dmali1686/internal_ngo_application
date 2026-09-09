import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DoctorPanelScreen extends StatelessWidget {
  final Map<String, dynamic>? patientData;
  const DoctorPanelScreen({super.key, this.patientData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110.h,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primaryGreen,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryGreen, Color(0xFF2D9E47)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20.h,
                      right: -20.w,
                      child: Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30.h,
                      right: 60.w,
                      child: Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.w, bottom: 20.h, right: 20.w),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(Icons.medical_information_outlined, color: Colors.white, size: 24.sp),
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Doctor Panel',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Text(
                                  'Patient Care Management',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 13.sp,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientHeader(),
                  SizedBox(height: 24.h),
                  Text(
                    'Care Actions',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Set instructions and schedules for the staff',
                    style: GoogleFonts.nunitoSans(fontSize: 13.sp, color: AppColors.textMuted),
                  ),
                  SizedBox(height: 16.h),
                  _buildManagementCard(
                    context,
                    title: 'Medical Orders',
                    subtitle: 'Update condition, prescribe meds & vitals',
                    icon: Icons.medical_services_outlined,
                    accentColor: AppColors.softBlue,
                    route: (patientData?['case_id'] != null && patientData!['case_id'].toString().isNotEmpty) 
                        ? '/medical-orders/${patientData!['case_id']}' 
                        : '/doctor-medical-orders',
                    status: 'Last updated today, 09:30 AM',
                    statusIcon: Icons.update_rounded,
                  ),
                  SizedBox(height: 14.h),
                  _buildManagementCard(
                    context,
                    title: 'Food Schedule',
                    subtitle: 'Set feeding times and diet instructions',
                    icon: Icons.restaurant_outlined,
                    accentColor: AppColors.warningOrange,
                    route: '/doctor-food-schedule',
                    extra: {
                      'patientId': patientData?['id']?.toString() ?? patientData?['case_id']?.toString(),
                      'patientName': patientData?['animal_name']?.toString() ?? patientData?['animal_type']?.toString(),
                    },
                    status: '4 slots scheduled',
                    statusIcon: Icons.schedule_rounded,
                  ),
                  SizedBox(height: 14.h),
                  _buildManagementCard(
                    context,
                    title: 'Cleaning Schedule',
                    subtitle: 'Assign cage cleaning and grooming tasks',
                    icon: Icons.cleaning_services_outlined,
                    accentColor: AppColors.successGreen,
                    route: '/doctor-cleaning-schedule',
                    status: '5 tasks scheduled',
                    statusIcon: Icons.check_circle_outline_rounded,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientHeader() {
    print("====== DOCTOR PANEL PATIENT DATA ======");
    print(patientData);
    print("=======================================");

    final name = patientData?['animal_name']?.toString() ?? patientData?['animal_type']?.toString() ?? 'Unknown Patient';
    final caseId = patientData?['case_id']?.toString() ?? 'Unknown ID';
    final breed = patientData?['breed_name']?.toString() ?? patientData?['animal_type']?.toString() ?? 'Unknown Breed';
    final cage = patientData?['cage_number']?.toString() ?? 'Unassigned';
    final ward = patientData?['ward_name']?.toString() ?? '';
    final location = ward.isNotEmpty ? 'Cage $cage, $ward' : 'Cage $cage';
    final status = patientData?['status']?.toString().toUpperCase() ?? 'ADMITTED';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primaryGreen, Color(0xFF2D9E47)],
              ),
            ),
            child: CircleAvatar(
              radius: 30.r,
              backgroundImage: const NetworkImage(
                'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=200&q=80',
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: AppColors.softBlue.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.healing_rounded, size: 12.sp, color: AppColors.softBlue),
                          SizedBox(width: 4.w),
                          Text(
                            status,
                            style: GoogleFonts.nunitoSans(
                              color: AppColors.softBlue,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.pets_rounded, size: 13.sp, color: AppColors.textMuted),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        '#$caseId • $breed',
                        style: GoogleFonts.nunitoSans(
                          color: AppColors.textMuted,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 13.sp, color: AppColors.primaryGreen),
                    SizedBox(width: 3.w),
                    Text(
                      location,
                      style: GoogleFonts.nunitoSans(
                        color: AppColors.primaryGreen,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
    required Color accentColor,
    required String route,
    Object? extra,
    required String status,
    required IconData statusIcon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(route, extra: extra),
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: accentColor.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: accentColor, size: 26.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 11.sp, color: accentColor),
                          SizedBox(width: 4.w),
                          Text(
                            status,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 11.sp,
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLightGray,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
