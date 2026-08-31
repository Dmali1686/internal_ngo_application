import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/providers/task_provider.dart';
import '../screens/department_tasks_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// My Departments — vertical list of horizontal department cards.
// Only shows departments that have tasks assigned to this employee.
// Tapping a card navigates to DepartmentTasksScreen.
// ─────────────────────────────────────────────────────────────────────────────

class EmployeeDepartmentsGrid extends StatelessWidget {
  const EmployeeDepartmentsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final grouped = taskProvider.myTasksGrouped;

    // Only show departments that have at least one task
    final List<DepartmentTaskGroup> activeDepts = grouped?.departments
            .where((d) => d.tasks.isNotEmpty)
            .toList() ??
        [];

    if (activeDepts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Departments',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
          GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14.w,
              mainAxisSpacing: 14.h,
              childAspectRatio: 0.9,
            ),
            itemCount: activeDepts.length,
            itemBuilder: (context, index) {
              return _DepartmentCard(dept: activeDepts[index]);
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual horizontal department card
// ─────────────────────────────────────────────────────────────────────────────

class _DepartmentCard extends StatelessWidget {
  final DepartmentTaskGroup dept;

  const _DepartmentCard({required this.dept});

  IconData _iconForDept(String name) {
    final l = name.toLowerCase();
    if (l.contains('medic') || l.contains('treatment')) return Icons.medical_services_rounded;
    if (l.contains('rescue') || l.contains('transport')) return Icons.local_shipping_rounded;
    if (l.contains('food') || l.contains('diet')) return Icons.restaurant_rounded;
    if (l.contains('clean')) return Icons.cleaning_services_rounded;
    if (l.contains('social') || l.contains('media')) return Icons.campaign_rounded;
    if (l.contains('fund')) return Icons.volunteer_activism_rounded;
    return Icons.business_rounded;
  }

  Color _colorForDept(String name) {
    final l = name.toLowerCase();
    if (l.contains('medic') || l.contains('treatment')) return const Color(0xFF2563EB);
    if (l.contains('rescue') || l.contains('transport')) return const Color(0xFFEF4444);
    if (l.contains('food') || l.contains('diet')) return const Color(0xFFF59E0B);
    if (l.contains('clean')) return const Color(0xFF06B6D4);
    if (l.contains('social') || l.contains('media')) return const Color(0xFF8B5CF6);
    if (l.contains('fund')) return const Color(0xFFEC4899);
    return AppColors.primaryGreen;
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForDept(dept.departmentName);
    final icon = _iconForDept(dept.departmentName);

    final activeTasks = dept.tasks
        .where((t) => t.status.toUpperCase() != 'COMPLETED' &&
            t.status.toUpperCase() != 'CANCELLED')
        .length;
    final urgentTasks = dept.tasks
        .where((t) =>
            t.priority.toUpperCase() == 'HIGH' &&
            t.status.toUpperCase() != 'COMPLETED')
        .length;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DepartmentTasksScreen(
            departmentName: dept.departmentName,
            tasks: dept.tasks,
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top: Icon & Arrow ─────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(icon, color: color, size: 24.w),
                ),
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.chevron_right_rounded, color: color, size: 18.w),
                ),
              ],
            ),
            const Spacer(),
            // ── Bottom: Name + counts ────────────────────────────────────
            Text(
              dept.departmentName,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),
            Text(
              '$activeTasks Active Task${activeTasks == 1 ? '' : 's'}',
              style: GoogleFonts.nunitoSans(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            if (urgentTasks > 0) ...[
              SizedBox(height: 3.h),
              Row(
                children: [
                  Icon(Icons.priority_high_rounded,
                      size: 11.w,
                      color: const Color(0xFFEF4444)),
                  SizedBox(width: 2.w),
                  Text(
                    '$urgentTasks Urgent',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
