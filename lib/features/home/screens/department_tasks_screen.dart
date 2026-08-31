import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/screens/task_details_screen.dart';

/// Full-screen view of all tasks for a single department.
/// Reached by tapping a department card on the home screen.
class DepartmentTasksScreen extends StatefulWidget {
  final String departmentName;
  final List<TaskModel> tasks;

  const DepartmentTasksScreen({
    super.key,
    required this.departmentName,
    required this.tasks,
  });

  @override
  State<DepartmentTasksScreen> createState() =>
      _DepartmentTasksScreenState();
}

class _DepartmentTasksScreenState extends State<DepartmentTasksScreen> {
  String _activeFilter = 'All';

  static const _filters = ['All', 'Urgent', 'Pending', 'Completed'];

  List<TaskModel> get _filteredTasks {
    switch (_activeFilter) {
      case 'Urgent':
        return widget.tasks
            .where((t) =>
                t.priority.toUpperCase() == 'HIGH' &&
                t.status.toUpperCase() != 'COMPLETED')
            .toList();
      case 'Pending':
        return widget.tasks
            .where((t) => t.status.toUpperCase() == 'PENDING')
            .toList();
      case 'Completed':
        return widget.tasks
            .where((t) => t.status.toUpperCase() == 'COMPLETED')
            .toList();
      default:
        return widget.tasks;
    }
  }

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
    final color = _colorForDept(widget.departmentName);
    final icon = _iconForDept(widget.departmentName);
    final filtered = _filteredTasks;
    final totalPending = widget.tasks
        .where((t) => t.status.toUpperCase() != 'COMPLETED')
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded,
                  color: AppColors.textMain, size: 22.w),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: color, size: 18.w),
                ),
                SizedBox(width: 10.w),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.departmentName,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$totalPending Tasks Assigned',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 11.sp,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Filter chips ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((f) {
                    final isActive = _activeFilter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _activeFilter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: 10.w),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isActive ? color : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          f,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? Colors.white
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 12.h)),

          // ── Task list / empty state ───────────────────────────────────────
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 64.w,
                        color: AppColors.primaryGreen.withOpacity(0.5)),
                    SizedBox(height: 16.h),
                    Text(
                      'No Pending Tasks',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'You have completed all tasks\nassigned by the ${widget.departmentName}.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 13.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w).copyWith(bottom: 32.h),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _TaskCard(
                    task: filtered[index],
                    accent: color,
                  ),
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task card for the Department Tasks screen
// ─────────────────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final Color accent;

  const _TaskCard({required this.task, required this.accent});

  Color _priorityColor(String p) {
    switch (p.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFEF4444);
      case 'LOW':
        return const Color(0xFF22C55E);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'COMPLETED':
        return const Color(0xFF22C55E);
      case 'IN_PROGRESS':
        return const Color(0xFF3B82F6);
      case 'CANCELLED':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = dt.difference(DateTime(now.year, now.month, now.day)).inDays;
      if (diff == 0) return 'Due Today';
      if (diff == 1) return 'Due Tomorrow';
      if (diff < 0) return 'Overdue';
      const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return 'Due ${dt.day} ${m[dt.month]}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(task.priority);
    final statusColor = _statusColor(task.status);
    final dueText = _formatDate(task.dueDate);
    final assignedBy = task.assignedBy?.name ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task))),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title + Priority badge ─────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${task.priority} Priority',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // ── Meta row ──────────────────────────────────────────────────
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                // Status
                _metaChip(
                  task.status.replaceAll('_', ' '),
                  statusColor,
                  Icons.circle,
                ),
                // Due date
                if (dueText.isNotEmpty)
                  _metaChip(dueText, AppColors.textMuted, Icons.calendar_today_rounded),
                // Assigned by
                if (assignedBy.isNotEmpty)
                  _metaChip('By $assignedBy', AppColors.textMuted, Icons.person_outline_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11.w, color: color),
        SizedBox(width: 3.w),
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 11.sp,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
