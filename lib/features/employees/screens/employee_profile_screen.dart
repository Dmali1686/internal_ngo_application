import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../admin/models/employee_model.dart';

class EmployeeProfileScreen extends StatelessWidget {
  final EmployeeModel? employee;

  const EmployeeProfileScreen({super.key, this.employee});

  @override
  Widget build(BuildContext context) {
    // If no employee is passed, fallback to a mock one for testing UI
    final emp = employee ??
        EmployeeModel(
          id: '1',
          name: 'Dr. Priya Sharma',
          email: 'priya@mh14.org',
          phone: '+91 9876543210',
          role: 'doctor',
          status: 'active',
        );

    final isActive = emp.isActive;
    final statusColor = isActive ? AppColors.primaryGreen : Colors.red;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 18.sp)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.w),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.w),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                    child: Text(
                      emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
                      style: GoogleFonts.poppins(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 36.sp),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    emp.name,
                    style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.textMain),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: GoogleFonts.nunitoSans(
                        color: statusColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            // Info Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Employee Details',
                    style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textMain),
                  ),
                  SizedBox(height: 16.h),
                  _buildInfoRow(Icons.badge, 'Role', emp.roleLabel),
                  _buildDivider(),
                  _buildInfoRow(Icons.email, 'Email', emp.email),
                  _buildDivider(),
                  _buildInfoRow(Icons.phone, 'Phone', emp.phone),
                  _buildDivider(),
                  _buildInfoRow(Icons.calendar_today, 'Joined', emp.joinedAt ?? 'Jan 15, 2024'),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            // Actions Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _buildActionBtn(Icons.message, 'Message', AppColors.primaryGreen, () {}),
                  SizedBox(height: 12.h),
                  _buildActionBtn(Icons.task, 'Assign Task', Colors.blue, () {}),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.w, color: AppColors.textMuted),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.nunitoSans(fontSize: 12.sp, color: AppColors.textMuted)),
                Text(value, style: GoogleFonts.nunitoSans(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textMain)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 52.w),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }

  Widget _buildActionBtn(IconData icon, String title, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20.w, color: Colors.white),
        label: Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }
}
