import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Attendance', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 18.sp)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.w),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            SizedBox(height: 24.h),
            Text(
              'Today\'s Logs',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 16.h),
            _buildLogCard('Dr. Priya Sharma', 'doctor', '09:00 AM', true),
            _buildLogCard('Ravi Desai', 'nurse', '08:45 AM', true),
            _buildLogCard('Anita Kulkarni', 'caretaker', '-', false),
            _buildLogCard('Suresh Patil', 'driver', '09:15 AM', true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryStat('Present', '18', Colors.white),
          Container(height: 40.h, width: 1, color: Colors.white.withValues(alpha: 0.3)),
          _buildSummaryStat('Absent', '4', Colors.white.withValues(alpha: 0.8)),
          Container(height: 40.h, width: 1, color: Colors.white.withValues(alpha: 0.3)),
          _buildSummaryStat('Late', '2', Colors.white.withValues(alpha: 0.8)),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 4.h),
        Text(label, style: GoogleFonts.nunitoSans(fontSize: 14.sp, color: color)),
      ],
    );
  }

  Widget _buildLogCard(String name, String role, String time, bool isPresent) {
    final statusColor = isPresent ? AppColors.primaryGreen : Colors.red;
    
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12.w),
        leading: CircleAvatar(
          radius: 20.r,
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(isPresent ? Icons.check : Icons.close, color: statusColor, size: 20.w),
        ),
        title: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14.sp)),
        subtitle: Text(role.toUpperCase(), style: GoogleFonts.nunitoSans(fontSize: 11.sp, color: AppColors.textMuted)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600)),
            Text(isPresent ? 'Checked In' : 'Absent', style: GoogleFonts.nunitoSans(fontSize: 11.sp, color: statusColor)),
          ],
        ),
      ),
    );
  }
}
