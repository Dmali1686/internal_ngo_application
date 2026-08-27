import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Performance', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 18.sp)),
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
            _buildOverallScore(),
            SizedBox(height: 24.h),
            Text(
              'Key Metrics',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Task Completion', '92%', Icons.task_alt, AppColors.primaryGreen)),
                SizedBox(width: 12.w),
                Expanded(child: _buildMetricCard('On-time Rate', '88%', Icons.timer, Colors.blue)),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              'Top Performers',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 16.h),
            _buildPerformerCard('Dr. Priya Sharma', 'Doctor', '98%', 1),
            _buildPerformerCard('Ravi Desai', 'Nurse', '95%', 2),
            _buildPerformerCard('Suresh Patil', 'Driver', '91%', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallScore() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark slate
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text('Overall Org Performance', style: GoogleFonts.nunitoSans(fontSize: 14.sp, color: Colors.white.withValues(alpha: 0.8))),
          SizedBox(height: 16.h),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120.w,
                height: 120.w,
                child: CircularProgressIndicator(
                  value: 0.85,
                  strokeWidth: 8.w,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                ),
              ),
              Column(
                children: [
                  Text('85%', style: GoogleFonts.poppins(fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('Good', style: GoogleFonts.nunitoSans(fontSize: 12.sp, color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.w),
          ),
          SizedBox(height: 12.h),
          Text(value, style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          Text(title, style: GoogleFonts.nunitoSans(fontSize: 12.sp, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildPerformerCard(String name, String role, String score, int rank) {
    Color rankColor;
    if (rank == 1) {
      rankColor = Colors.amber;
    } else if (rank == 2) {
      rankColor = Colors.grey.shade400;
    } else {
      rankColor = Colors.brown.shade300;
    }

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
          backgroundColor: rankColor.withValues(alpha: 0.1),
          child: Text('#$rank', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: rankColor, fontSize: 14.sp)),
        ),
        title: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14.sp)),
        subtitle: Text(role, style: GoogleFonts.nunitoSans(fontSize: 12.sp, color: AppColors.textMuted)),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(score, style: GoogleFonts.poppins(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13.sp)),
        ),
      ),
    );
  }
}
