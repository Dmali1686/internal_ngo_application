import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../models/super_admin_models.dart';
import '../providers/super_admin_provider.dart';
import 'super_admin_employee_profile_screen.dart';

/// Screen 2 — Department Detail
///
/// Shows department-level analytics, team members list,
/// and an active tasks overview with a progress bar.
class DepartmentDetailScreen extends StatelessWidget {
  final DepartmentModel department;

  const DepartmentDetailScreen({super.key, required this.department});

  static final Map<String, IconData> _icons = {
    'medical': Icons.medical_services_rounded,
    'transport': Icons.local_shipping_rounded,
    'food': Icons.restaurant_rounded,
    'social_media': Icons.campaign_rounded,
    'fundraising': Icons.volunteer_activism_rounded,
    'operations': Icons.settings_rounded,
  };

  static final Map<String, Color> _colors = {
    'medical': Color(0xFF2563EB),
    'transport': Color(0xFF10B981),
    'food': Color(0xFFF59E0B),
    'social_media': Color(0xFF8B5CF6),
    'fundraising': Color(0xFFEF4444),
    'operations': Color(0xFF06B6D4),
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuperAdminProvider>();
    final employees = provider.employeesFor(department.id);
    final color = _colors[department.iconKey] ?? AppColors.primaryBlue;
    final icon = _icons[department.iconKey] ?? Icons.business_rounded;

    return Scaffold(
      backgroundColor: AppColors.backgroundSurface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ───────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            pinned: true,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16.w,
                  color: AppColors.textMain,
                ),
              ),
            ),
            title: Text(
              department.name,
              style: GoogleFonts.inter(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            centerTitle: true,
            actions: [
              Container(
                margin: EdgeInsets.all(10.w),
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.settings_outlined,
                  size: 18.w,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          // ── Analytics Banner ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: _buildAnalyticsBanner(color, icon),
            ),
          ),

          // ── Team Members header ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Team Members',
                    style: GoogleFonts.inter(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                  Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Employee list ──────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                child: _EmployeeCard(
                  employee: employees[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SuperAdminEmployeeProfileScreen(
                        employee: employees[i],
                      ),
                    ),
                  ),
                ),
              ),
              childCount: employees.length,
            ),
          ),

          // ── Active Tasks Overview ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: _buildTasksOverview(color),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }

  // ── Analytics Banner Card ────────────────────────────────────────────────
  Widget _buildAnalyticsBanner(Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.75)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.30),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + name + subtitle
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: Colors.white, size: 22.w),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      department.name,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Manage healthcare & rescue operations',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // 4-stat row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BannerStat(
                  label: 'Total\nEmployees',
                  value: '${department.totalEmployees}'),
              _BannerDivider(),
              _BannerStat(
                  label: 'Tasks\nAssigned', value: '${department.totalTasks}'),
              _BannerDivider(),
              _BannerStat(
                  label: 'Completed', value: '${department.completedTasks}'),
              _BannerDivider(),
              _BannerStat(label: 'Pending', value: '${department.pendingTasks}'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Active Tasks Overview Card ───────────────────────────────────────────
  Widget _buildTasksOverview(Color color) {
    final completed = department.completedTasks;
    final pending = department.pendingTasks;
    final total = department.totalTasks;
    final completedPct = total == 0 ? 0.0 : completed / total;
    final pendingPct = total == 0 ? 0.0 : pending / total;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Tasks Overview',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _TaskStat(label: 'Total Tasks', value: '$total', color: AppColors.textMain),
              SizedBox(width: 24.w),
              _TaskStat(label: 'Completed', value: '$completed', color: AppColors.successGreen),
              SizedBox(width: 24.w),
              _TaskStat(label: 'Pending', value: '$pending', color: AppColors.dangerRed),
            ],
          ),
          SizedBox(height: 14.h),
          // Stacked progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: SizedBox(
              height: 8.h,
              child: Row(
                children: [
                  Flexible(
                    flex: (completedPct * 100).round(),
                    child: Container(color: AppColors.successGreen),
                  ),
                  Flexible(
                    flex: (pendingPct * 100).round(),
                    child: Container(color: AppColors.dangerRed),
                  ),
                  Flexible(
                    flex: 100 -
                        (completedPct * 100).round() -
                        (pendingPct * 100).round(),
                    child: Container(color: Colors.grey.shade200),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Employee Card
// ─────────────────────────────────────────────────────────────────────────────

class _EmployeeCard extends StatelessWidget {
  final DepartmentEmployeeModel employee;
  final VoidCallback onTap;

  const _EmployeeCard({required this.employee, required this.onTap});

  Color get _statusColor {
    switch (employee.status) {
      case EmployeeStatus.active:
        return AppColors.successGreen;
      case EmployeeStatus.busy:
        return AppColors.warningAmber;
      case EmployeeStatus.offline:
        return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (employee.status) {
      case EmployeeStatus.active:
        return 'Active';
      case EmployeeStatus.busy:
        return 'Busy';
      case EmployeeStatus.offline:
        return 'Offline';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24.r,
              backgroundImage: NetworkImage(employee.avatarUrl),
            ),
            SizedBox(width: 14.w),
            // Name + role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    employee.role,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Task count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${employee.assignedTasks}',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
                Text(
                  'Tasks',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),
            // Status + arrow
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: _statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _statusLabel,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18.w,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Banner Stat + Divider helpers
// ─────────────────────────────────────────────────────────────────────────────

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  const _BannerStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            color: Colors.white.withOpacity(0.75),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _BannerDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36.h,
      color: Colors.white.withOpacity(0.25),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task stat helper
// ─────────────────────────────────────────────────────────────────────────────

class _TaskStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _TaskStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
