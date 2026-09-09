import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  static const _logs = [
    {'name': 'Dr. Priya Sharma', 'role': 'Doctor', 'time': '09:00 AM', 'present': true},
    {'name': 'Ravi Desai', 'role': 'Nurse', 'time': '08:45 AM', 'present': true},
    {'name': 'Anita Kulkarni', 'role': 'Caretaker', 'time': '-', 'present': false},
    {'name': 'Suresh Patil', 'role': 'Driver', 'time': '09:15 AM', 'present': true},
    {'name': 'Meera Joshi', 'role': 'Nurse', 'time': '09:30 AM', 'present': true},
    {'name': 'Arun Nair', 'role': 'Receptionist', 'time': '-', 'present': false},
  ];

  static const Map<String, Color> _roleColors = {
    'Doctor': Color(0xFF6366F1),
    'Nurse': Color(0xFFEC4899),
    'Caretaker': Color(0xFF14B8A6),
    'Driver': Color(0xFFF97316),
    'Receptionist': Color(0xFF8B5CF6),
  };

  @override
  Widget build(BuildContext context) {
    final presentCount = _logs.where((l) => l['present'] == true).length;
    final absentCount = _logs.length - presentCount;

    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      body: CustomScrollView(
        slivers: [
          // ── Gradient Header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200.h,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.w),
              onPressed: () => context.pop(),
            ),
            title: Text('Attendance', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E293B), Color(0xFF6366F1)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Today\'s Summary', style: GoogleFonts.nunitoSans(fontSize: 13.sp, color: Colors.white.withValues(alpha: 0.7))),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(child: _buildHeaderStat('Present', presentCount.toString(), Icons.check_circle_rounded, AppColors.primaryGreen)),
                            SizedBox(width: 10.w),
                            Expanded(child: _buildHeaderStat('Absent', absentCount.toString(), Icons.cancel_rounded, Colors.red.shade300)),
                            SizedBox(width: 10.w),
                            Expanded(child: _buildHeaderStat('Late', '2', Icons.access_time_rounded, AppColors.warningOrange)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Date selector ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: Offset(0, 3.h))],
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: AppColors.primaryGreen, size: 20.w),
                  SizedBox(width: 10.w),
                  Text('Thursday, 27 Aug 2026', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                  const Spacer(),
                  Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 20.w),
                ],
              ),
            ),
          ),

          // ── Section Title ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 12.h),
              child: Text('Staff Logs', style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textMain)),
            ),
          ),

          // ── Log Cards ────────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final log = _logs[index];
                final isPresent = log['present'] == true;
                final name = log['name'] as String;
                final role = log['role'] as String;
                final time = log['time'] as String;
                final statusColor = isPresent ? AppColors.primaryGreen : Colors.red;
                final roleColor = _roleColors[role] ?? AppColors.primaryGreen;
                final initials = name.trim().split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').take(2).join();

                return Container(
                  margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: Offset(0, 3.h))],
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 46.w,
                        height: 46.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [roleColor.withValues(alpha: 0.7), roleColor]),
                        ),
                        child: Center(child: Text(initials, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white))),
                      ),
                      SizedBox(width: 12.w),
                      // Name & role
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                            SizedBox(height: 3.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                              decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)),
                              child: Text(role, style: GoogleFonts.nunitoSans(fontSize: 10.sp, fontWeight: FontWeight.w700, color: roleColor)),
                            ),
                          ],
                        ),
                      ),
                      // Time & status
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(time, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: isPresent ? AppColors.textMain : AppColors.textMuted)),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20.r)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isPresent ? Icons.check_rounded : Icons.close_rounded, size: 10.w, color: statusColor),
                                SizedBox(width: 3.w),
                                Text(isPresent ? 'Present' : 'Absent', style: GoogleFonts.nunitoSans(fontSize: 10.sp, fontWeight: FontWeight.w700, color: statusColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              childCount: _logs.length,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 32.h)),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18.w),
          SizedBox(height: 4.h),
          Text(value, style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(label, style: GoogleFonts.nunitoSans(fontSize: 10.sp, color: Colors.white.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}
