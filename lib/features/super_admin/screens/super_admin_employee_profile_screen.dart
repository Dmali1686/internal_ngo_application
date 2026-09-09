import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../models/super_admin_models.dart';
import '../providers/super_admin_provider.dart';

/// Screen 3 — Super Admin Employee Profile
///
/// Full employee profile with photo, stats, assigned departments
/// (horizontal scroll), task list with color-coded status, and
/// an "Assign New Task" CTA button.
class SuperAdminEmployeeProfileScreen extends StatelessWidget {
  final DepartmentEmployeeModel employee;

  const SuperAdminEmployeeProfileScreen({super.key, required this.employee});

  static final Map<String, IconData> _deptIcons = {
    'medical': Icons.medical_services_rounded,
    'transport': Icons.local_shipping_rounded,
    'food': Icons.restaurant_rounded,
    'social_media': Icons.campaign_rounded,
    'fundraising': Icons.volunteer_activism_rounded,
    'operations': Icons.settings_rounded,
  };

  static final Map<String, Color> _deptColors = {
    'medical': Color(0xFF2563EB),
    'transport': Color(0xFF10B981),
    'food': Color(0xFFF59E0B),
    'social_media': Color(0xFF8B5CF6),
    'fundraising': Color(0xFFEF4444),
    'operations': Color(0xFF06B6D4),
  };

  static final Map<String, String> _deptNames = {
    'medical': 'Medical',
    'transport': 'Transport',
    'food': 'Food',
    'social_media': 'Social Media',
    'fundraising': 'Fundraising',
    'operations': 'Operations',
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuperAdminProvider>();
    final tasks = provider.tasksFor(employee.id);

    // Derive quick stats
    final deptCount = employee.departmentIds.length;
    final activeTasks = tasks
        .where((t) => t.status == TaskStatus.inProgress)
        .length +
        tasks.where((t) => t.status == TaskStatus.pending).length;
    final completedTasks =
        tasks.where((t) => t.status == TaskStatus.completed).length;
    final performance = tasks.isEmpty
        ? 0
        : ((completedTasks / tasks.length) * 100).round();

    return Scaffold(
      backgroundColor: AppColors.backgroundSurface,
      body: Stack(
        children: [
          // ── Content ─────────────────────────────────────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App bar
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
                  'Employee Profile',
                  style: GoogleFonts.inter(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
                centerTitle: true,
                actions: [
                  Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.textMuted,
                    size: 22.w,
                  ),
                  SizedBox(width: 14.w),
                ],
              ),

              // Profile hero card
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                  child: _buildProfileCard(),
                ),
              ),

              // Stats row
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                  child: _buildStatsRow(
                    deptCount: deptCount,
                    activeTasks: activeTasks,
                    completedTasks: completedTasks,
                    performance: performance,
                  ),
                ),
              ),

              // Assigned departments
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 20.w),
                        child: Text(
                          'Assigned Departments',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildDepartmentChips(provider),
                    ],
                  ),
                ),
              ),

              // Task list header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
                  child: Text(
                    'Task List',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
              ),

              // Task items
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
                    child: _TaskCard(task: tasks[i]),
                  ),
                  childCount: tasks.length,
                ),
              ),

              // Bottom padding for FAB
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),

          // ── Assign New Task CTA ──────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20.r,
                    offset: Offset(0, -4.h),
                  ),
                ],
              ),
              child: SizedBox(
                height: 52.h,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  icon: Icon(Icons.add_rounded, size: 20.w),
                  label: Text(
                    'Assign New Task',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile hero card ──────────────────────────────────────────────────────
  Widget _buildProfileCard() {
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
      child: Row(
        children: [
          // Avatar with blue ring
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
              ),
            ),
            child: CircleAvatar(
              radius: 36.r,
              backgroundImage: NetworkImage(employee.avatarUrl),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  employee.role,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.badge_outlined,
                        size: 13.w,
                        color: AppColors.primaryBlue,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        'EMP ID: ${employee.id.toUpperCase()}',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────
  Widget _buildStatsRow({
    required int deptCount,
    required int activeTasks,
    required int completedTasks,
    required int performance,
  }) {
    final items = [
      _ProfileStat(
        label: 'Departments',
        value: '$deptCount',
        color: AppColors.primaryBlue,
      ),
      _ProfileStat(
        label: 'Active Tasks',
        value: '$activeTasks',
        color: AppColors.warningAmber,
      ),
      _ProfileStat(
        label: 'Completed',
        value: '$completedTasks',
        color: AppColors.successGreen,
      ),
      _ProfileStat(
        label: 'Performance',
        value: '$performance%',
        color: AppColors.successGreen,
      ),
    ];

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
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      child: Row(
        children: items
            .map(
              (s) => Expanded(
                child: Column(
                  children: [
                    Text(
                      s.value,
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: s.color,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      s.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        color: AppColors.textMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ── Department chips (horizontal scroll) ───────────────────────────────────
  Widget _buildDepartmentChips(SuperAdminProvider provider) {
    return SizedBox(
      height: 90.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: 20.w),
        itemCount: employee.departmentIds.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, i) {
          final deptId = employee.departmentIds[i];
          final icon = _deptIcons[deptId] ?? Icons.business_rounded;
          final color = _deptColors[deptId] ?? AppColors.primaryBlue;
          final name = _deptNames[deptId] ?? deptId;
          return Column(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: color.withOpacity(0.20)),
                ),
                child: Icon(icon, color: color, size: 24.w),
              ),
              SizedBox(height: 6.h),
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task Card
// ─────────────────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final TaskItem task;
  const _TaskCard({required this.task});

  Color get _statusColor {
    switch (task.status) {
      case TaskStatus.completed:
        return AppColors.successGreen;
      case TaskStatus.inProgress:
        return AppColors.warningAmber;
      case TaskStatus.pending:
        return AppColors.dangerRed;
    }
  }

  String get _statusLabel {
    switch (task.status) {
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.pending:
        return 'Pending';
    }
  }

  IconData get _statusIcon {
    switch (task.status) {
      case TaskStatus.completed:
        return Icons.check_circle_rounded;
      case TaskStatus.inProgress:
        return Icons.access_time_rounded;
      case TaskStatus.pending:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          // Status icon
          Icon(_statusIcon, color: _statusColor, size: 22.w),
          SizedBox(width: 12.w),
          // Title + department
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  task.departmentName,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Deadline + status badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                task.deadline,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  _statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper data class
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileStat {
  final String label;
  final String value;
  final Color color;
  const _ProfileStat({
    required this.label,
    required this.value,
    required this.color,
  });
}
