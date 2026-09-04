import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/auth_storage_service.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/providers/task_provider.dart';
import '../../food_dept/screens/food_dept_task_screen.dart';
import '../../food_dept/providers/food_dept_provider.dart';
import '../screens/department_tasks_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// My Departments — vertical list of horizontal department cards.
//
// Shows EVERY department the employee belongs to, regardless of whether tasks
// have been assigned yet. This means a newly created employee always sees their
// department card the moment they log in.
//
// Data sources (in priority order):
//   1. API response  — DepartmentTaskGroup list from GET /tasks/my
//      (contains real task counts for known departments)
//   2. Auth storage  — departmentId + departmentName saved at login
//      (used as a fallback when the API returns no departments, e.g. 0 tasks)
// ─────────────────────────────────────────────────────────────────────────────

class EmployeeDepartmentsGrid extends StatefulWidget {
  const EmployeeDepartmentsGrid({super.key});

  @override
  State<EmployeeDepartmentsGrid> createState() =>
      _EmployeeDepartmentsGridState();
}

class _EmployeeDepartmentsGridState extends State<EmployeeDepartmentsGrid> {
  @override
  void initState() {
    super.initState();
    // Trigger a live fetch every time the employee dashboard loads so that
    // newly assigned tasks (e.g. from Super Admin) appear without requiring
    // a manual pull-to-refresh.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TaskProvider>().fetchMyTasks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final grouped = taskProvider.myTasksGrouped;

    // Show loading indicator while the first fetch is in progress
    if (taskProvider.isLoading && grouped == null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
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
            SizedBox(height: 20.h),
            Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      );
    }

    // ── Build the department list ─────────────────────────────────────────────
    //
    // Start with all departments returned from the API (they may have 0 tasks
    // if the backend returns the bucket with an empty tasks array).
    final List<DepartmentTaskGroup> apiDepts =
        grouped?.departments.toList() ?? [];

    // Ensure the employee's own department always appears, even when the API
    // returned no department buckets at all (e.g. brand new employee, 0 tasks).
    final auth = AuthStorageService();
    final storedDeptId = auth.departmentId;
    final storedDeptName = auth.departmentName;

    // Decide whether we need to inject a fallback card.
    final apiHasStoredDept = storedDeptId == null ||
        storedDeptId.isEmpty ||
        apiDepts.any((d) => d.departmentId == storedDeptId);

    final List<DepartmentTaskGroup> displayDepts = List.from(apiDepts);

    if (!apiHasStoredDept) {
      // The employee's department wasn't returned by the API — inject a
      // placeholder group with 0 tasks so the card still renders.
      final fallbackName = storedDeptName ??
          _inferDeptNameFromPosition(auth.positionTitle ?? '');
      displayDepts.insert(
        0,
        DepartmentTaskGroup(
          departmentId: storedDeptId,
          departmentCode: '',
          departmentName: fallbackName,
          tasks: const [],
        ),
      );
    }

    // If there's absolutely nothing to show, render nothing.
    if (displayDepts.isEmpty) return const SizedBox.shrink();

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
          SizedBox(height: 16.h),
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
            itemCount: displayDepts.length,
            itemBuilder: (context, index) {
              return _DepartmentCard(dept: displayDepts[index]);
            },
          ),
        ],
      ),
    );
  }

  /// Infer a human-readable department name from the position title when
  /// `department_name` wasn't returned by the backend profile API.
  String _inferDeptNameFromPosition(String positionTitle) {
    final p = positionTitle.toLowerCase();
    if (p.contains('food') || p.contains('cook')) return 'Food Department';
    if (p.contains('medic') || p.contains('vet') || p.contains('doctor')) {
      return 'Medical Department';
    }
    if (p.contains('transport') || p.contains('rescue') ||
        p.contains('ambulan') || p.contains('driver') ||
        p.contains('catch')) {
      return 'Transport / Rescue';
    }
    if (p.contains('clean')) return 'Cleaning Department';
    if (p.contains('admin')) return 'Administration';
    if (positionTitle.isNotEmpty) return positionTitle; // use raw title as fallback
    return 'My Department';
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
        .where((t) =>
            t.status.toUpperCase() != 'COMPLETED' &&
            t.status.toUpperCase() != 'CANCELLED')
        .length;
    final urgentTasks = dept.tasks
        .where((t) =>
            t.priority.toUpperCase() == 'HIGH' &&
            t.status.toUpperCase() != 'COMPLETED')
        .length;

    final hasNoTasks = dept.tasks.isEmpty;

    // ── Food Dept cards open the feeding schedule screen ─────────────────
    final deptLower = dept.departmentName.toLowerCase();
    final isFoodDept = deptLower.contains('food') || deptLower.contains('cook');

    void handleTap() {
      if (isFoodDept) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => ChangeNotifierProvider.value(
              value: ctx.read<FoodDeptProvider>(),
              child: const FoodDeptTaskScreen(),
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DepartmentTasksScreen(
              departmentName: dept.departmentName,
              tasks: dept.tasks,
            ),
          ),
        );
      }
    }

    return GestureDetector(
      onTap: handleTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(icon, color: color, size: 24.w),
                ),
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
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
            if (hasNoTasks)
              // ── No tasks yet — show a welcoming "ready" label ──────────
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      size: 11.w,
                      color: AppColors.primaryGreen),
                  SizedBox(width: 4.w),
                  Text(
                    'No tasks yet',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              )
            else ...[
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
          ],
        ),
      ),
    );
  }
}
