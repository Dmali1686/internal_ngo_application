import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../tasks/providers/task_provider.dart';
import '../../super_admin/providers/super_admin_provider.dart';

class EmployeeDepartmentsGrid extends StatelessWidget {
  const EmployeeDepartmentsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final myTasks = taskProvider.myTasks;
    final superAdminProvider = context.watch<SuperAdminProvider>();
    
    // Group tasks by department name (only pending/in-progress)
    final Map<String, int> deptTaskCounts = {};
    for (var task in myTasks) {
      if (task.status != 'COMPLETED' && task.status != 'CANCELLED') {
        final deptName = task.department?.name ?? 'General';
        deptTaskCounts[deptName] = (deptTaskCounts[deptName] ?? 0) + 1;
      }
    }

    // If no tasks are assigned yet, we could either show empty or show mock departments.
    // For a realistic UI, let's also pull from superAdminProvider.departments if we want to show 
    // departments that have 0 tasks. But since auth is mocked, we'll just use the grouped tasks,
    // plus ensure at least some departments show up if they exist in superAdminProvider.
    // To be safe and show exactly what the user wants:
    
    final displayDepts = <String, int>{};
    
    if (deptTaskCounts.isNotEmpty) {
      displayDepts.addAll(deptTaskCounts);
    } else if (superAdminProvider.departments.isNotEmpty) {
      // Mock some departments if they have no tasks but we know they exist
      for (var i = 0; i < superAdminProvider.departments.length && i < 2; i++) {
        displayDepts[superAdminProvider.departments[i].name] = 0;
      }
    }

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
          SizedBox(height: 12.h),
          GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.85,
            ),
            itemCount: displayDepts.length,
            itemBuilder: (context, index) {
              final deptName = displayDepts.keys.elementAt(index);
              final count = displayDepts[deptName]!;
              return _DeptCard(
                name: deptName,
                taskCount: count,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DeptCard extends StatefulWidget {
  final String name;
  final int taskCount;

  const _DeptCard({required this.name, required this.taskCount});

  @override
  State<_DeptCard> createState() => _DeptCardState();
}

class _DeptCardState extends State<_DeptCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIconForDept(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('medic') || lower.contains('treatment')) return Icons.medical_services_rounded;
    if (lower.contains('rescue') || lower.contains('transport')) return Icons.local_shipping_rounded;
    if (lower.contains('food') || lower.contains('diet')) return Icons.restaurant_rounded;
    if (lower.contains('clean')) return Icons.cleaning_services_rounded;
    return Icons.business_rounded;
  }

  Color _getColorForDept(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('medic') || lower.contains('treatment')) return const Color(0xFF2563EB);
    if (lower.contains('rescue') || lower.contains('transport')) return const Color(0xFFEF4444);
    if (lower.contains('food') || lower.contains('diet')) return const Color(0xFFF59E0B);
    if (lower.contains('clean')) return const Color(0xFF06B6D4);
    return const Color(0xFF34A853);
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconForDept(widget.name);
    final color = _getColorForDept(widget.name);

    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) => _controller.forward(),
      onTapCancel: () => _controller.forward(),
      onTap: () {
        // Could navigate to a filtered task list
      },
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 24.w, color: color),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${widget.taskCount} Tasks',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
