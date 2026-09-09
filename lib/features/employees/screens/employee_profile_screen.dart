import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../admin/models/employee_model.dart';

class EmployeeProfileScreen extends StatelessWidget {
  final EmployeeModel? employee;
  const EmployeeProfileScreen({super.key, this.employee});

  static const Map<String, Color> _roleColors = {
    'doctor': Color(0xFF6366F1),
    'nurse': Color(0xFFEC4899),
    'caretaker': Color(0xFF14B8A6),
    'driver': Color(0xFFF97316),
    'receptionist': Color(0xFF8B5CF6),
  };

  static const Map<String, IconData> _roleIcons = {
    'doctor': Icons.medical_information_rounded,
    'nurse': Icons.local_hospital_rounded,
    'caretaker': Icons.pets_rounded,
    'driver': Icons.directions_car_rounded,
    'receptionist': Icons.record_voice_over_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final emp = employee ?? EmployeeModel(id: '1', name: 'Dr. Priya Sharma', email: 'priya@mh14.org', phone: '+91 9876543210', role: 'doctor', status: 'active');
    final isActive = emp.isActive;
    final statusColor = isActive ? AppColors.primaryGreen : Colors.red;
    final roleColor = _roleColors[emp.role] ?? AppColors.primaryGreen;
    final roleIcon = _roleIcons[emp.role] ?? Icons.person_rounded;
    final initials = emp.name.trim().split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').take(2).join();

    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      body: CustomScrollView(
        slivers: [
          // ── Gradient Header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240.h,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.w),
              onPressed: () => context.pop(),
            ),
            title: Text('Employee Profile', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF1E293B), roleColor],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40.h),
                      // Avatar
                      Container(
                        width: 86.w,
                        height: 86.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [roleColor.withValues(alpha: 0.6), roleColor],
                          ),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                        ),
                        child: Center(child: Text(initials, style: GoogleFonts.poppins(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Colors.white))),
                      ),
                      SizedBox(height: 12.h),
                      Text(emp.name, style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20.r)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(roleIcon, size: 12.w, color: Colors.white),
                                SizedBox(width: 4.w),
                                Text(emp.roleLabel, style: GoogleFonts.nunitoSans(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 6.w, height: 6.w, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                                SizedBox(width: 4.w),
                                Text(isActive ? 'Active' : 'Inactive', style: GoogleFonts.nunitoSans(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Employee Details Card ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: Offset(0, 4.h))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Employee Details', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                  SizedBox(height: 16.h),
                  _buildInfoTile(Icons.badge_rounded, 'Role', emp.roleLabel, roleColor),
                  _buildInfoTile(Icons.email_rounded, 'Email', emp.email, const Color(0xFF6366F1)),
                  _buildInfoTile(Icons.phone_rounded, 'Phone', emp.phone, const Color(0xFF14B8A6)),
                  _buildInfoTile(Icons.calendar_today_rounded, 'Joined', emp.joinedAt ?? 'January 15, 2024', const Color(0xFFF97316)),
                  _buildInfoTile(Icons.location_on_rounded, 'Location', 'Mumbai, Maharashtra', const Color(0xFFEC4899)),
                ],
              ),
            ),
          ),

          // ── Stats Row ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: Offset(0, 4.h))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Performance Summary', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(child: _buildMiniStat('32', 'Tasks Assigned', const Color(0xFF6366F1))),
                      SizedBox(width: 10.w),
                      Expanded(child: _buildMiniStat('28', 'Completed', AppColors.primaryGreen)),
                      SizedBox(width: 10.w),
                      Expanded(child: _buildMiniStat('4', 'Pending', AppColors.warningOrange)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Action Buttons ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
              child: Column(
                children: [
                  _buildActionButton(Icons.message_rounded, 'Send Message', const Color(0xFF1E293B), const Color(0xFF0F766E), () {}),
                  SizedBox(height: 10.h),
                  _buildActionButton(Icons.task_alt_rounded, 'Assign Task', const Color(0xFF6366F1), const Color(0xFF4338CA), () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
            child: Icon(icon, size: 18.w, color: color),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.nunitoSans(fontSize: 11.sp, color: AppColors.textMuted)),
                Text(value, style: GoogleFonts.nunitoSans(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14.r)),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w800, color: color)),
          SizedBox(height: 2.h),
          Text(label, textAlign: TextAlign.center, style: GoogleFonts.nunitoSans(fontSize: 10.sp, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String title, Color from, Color to, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [from, to]),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [BoxShadow(color: from.withValues(alpha: 0.3), blurRadius: 10, offset: Offset(0, 4.h))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20.w),
            SizedBox(width: 10.w),
            Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
