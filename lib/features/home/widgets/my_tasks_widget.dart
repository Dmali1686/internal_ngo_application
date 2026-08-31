import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../super_admin/providers/super_admin_provider.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/providers/task_provider.dart';
import '../../tasks/screens/task_details_screen.dart';

class MyTasksWidget extends StatefulWidget {
  /// Called when the user taps "View All" — switches the bottom nav to Tasks tab.
  final VoidCallback onViewAll;

  const MyTasksWidget({super.key, required this.onViewAll});

  @override
  State<MyTasksWidget> createState() => _MyTasksWidgetState();
}

class _MyTasksWidgetState extends State<MyTasksWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchMyTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Tasks',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              GestureDetector(
                onTap: widget.onViewAll,
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.primaryGreen,
                      size: 20.w,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // ── Body ─────────────────────────────────────────────────────────
          Consumer<TaskProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.myTasks.isEmpty) {
                return _buildShimmer();
              }

              final grouped = provider.myTasksGrouped;
              final superAdminProvider = context.watch<SuperAdminProvider>();

              final displayDepts = <String, int>{};
              
              if (grouped != null && grouped.departments.isNotEmpty) {
                for (var dept in grouped.departments) {
                  displayDepts[dept.departmentName] = dept.tasks.length;
                }
              } else if (superAdminProvider.departments.isNotEmpty) {
                // Mock some departments if they have no tasks but we know they exist
                for (var i = 0; i < superAdminProvider.departments.length && i < 2; i++) {
                  displayDepts[superAdminProvider.departments[i].name] = 0;
                }
              }

              // Multiple departments → show a card per department
              if (displayDepts.length > 1) {
                return Column(
                  children: displayDepts.keys.map((deptName) {
                    final group = grouped?.departments.firstWhere(
                      (d) => d.departmentName == deptName,
                      orElse: () => DepartmentTaskGroup(
                        departmentId: '',
                        departmentCode: '',
                        departmentName: deptName,
                        tasks: const [],
                      ),
                    );
                    
                    final pending = (group?.tasks ?? [])
                        .where((t) => t.status != 'COMPLETED' && t.status != 'CANCELLED')
                        .toList();
                        
                    return _buildDepartmentCard(context, provider, deptName, pending);
                  }).toList(),
                );
              }

              // Single department → flat task list (original behaviour)
              final tasks = provider.myTasks
                  .where((t) => t.status != 'COMPLETED' && t.status != 'CANCELLED')
                  .take(3)
                  .toList();

              if (tasks.isEmpty) return _buildEmptyState();

              return Column(
                children: tasks
                    .map((task) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: _buildTaskCard(context, provider, task),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Department Summary Card (for multi-department employees) ──────────────

  Widget _buildDepartmentCard(
    BuildContext context,
    TaskProvider provider,
    String deptName,
    List<TaskModel> tasks,
  ) {
    return GestureDetector(
      onTap: widget.onViewAll,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coloured header bar
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                color: AppColors.primaryGreen.withOpacity(0.08),
                child: Row(
                  children: [
                    Icon(Icons.business_rounded,
                        size: 16.sp, color: AppColors.primaryGreen),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        deptName,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: tasks.isEmpty
                            ? Colors.grey.shade200
                            : AppColors.primaryGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        tasks.isEmpty ? 'All done' : '${tasks.length} pending',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: tasks.isEmpty
                              ? Colors.grey
                              : AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Show up to 2 tasks inline; or empty state
              if (tasks.isEmpty)
                Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Text(
                    'No pending tasks in this department 🎉',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                )
              else
                ...tasks.take(2).map((task) => Padding(
                      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
                      child: _buildInlineTaskRow(task),
                    )),
              if (tasks.length > 2)
                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 10.h),
                  child: Text(
                    '+${tasks.length - 2} more tasks',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12.sp,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInlineTaskRow(TaskModel task) {
    final priorityData = _priorityData(task.priority);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 3.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: priorityData['color'] as Color,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              task.title,
              style: GoogleFonts.nunitoSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          _badge(
            label: task.status == 'IN_PROGRESS' ? 'In Progress' : 'Pending',
            color: task.status == 'IN_PROGRESS'
                ? const Color(0xFF8B5CF6)
                : const Color(0xFFF59E0B),
            bg: task.status == 'IN_PROGRESS'
                ? const Color(0xFF8B5CF6).withOpacity(0.1)
                : const Color(0xFFFFFBEB),
          ),
        ],
      ),
    );
  }

  // ── Task Card ──────────────────────────────────────────────────────────────

  Widget _buildTaskCard(
      BuildContext context, TaskProvider provider, TaskModel task) {
    final priorityData = _priorityData(task.priority);
    final statusData = _statusData(task.status);

    return GestureDetector(
      onTap: () async {
        final didUpdate = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailsScreen(task: task),
          ),
        );
        if (didUpdate == true && context.mounted) {
          provider.fetchMyTasks();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: (priorityData['color'] as Color).withOpacity(0.3),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Accent bar matching priority colour
              Container(
                height: 3.h,
                color: priorityData['color'] as Color,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row + priority badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMain,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (task.taskCode != null) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  task.taskCode!,
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 11.sp,
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _badge(
                          label: task.priority,
                          color: priorityData['color'] as Color,
                          bg: priorityData['bg'] as Color,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Description snippet
                    Text(
                      task.description,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10.h),
                    // Bottom row: status + due date + quick-action
                    Row(
                      children: [
                        _badge(
                          label: statusData['label'] as String,
                          color: statusData['color'] as Color,
                          bg: (statusData['color'] as Color).withOpacity(0.1),
                        ),
                        if (task.dueDate != null) ...[
                          SizedBox(width: 8.w),
                          Icon(Icons.calendar_today_rounded,
                              size: 12.sp, color: AppColors.textMuted),
                          SizedBox(width: 3.w),
                          Text(
                            _formatDate(task.dueDate!),
                            style: GoogleFonts.nunitoSans(
                              fontSize: 11.sp,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (task.status == 'PENDING')
                          _actionButton(
                            label: 'Start',
                            icon: Icons.play_arrow_rounded,
                            color: const Color(0xFF3B82F6),
                            onTap: () async {
                              final success = await provider.startTask(task.id);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Task started!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                          )
                        else if (task.status == 'IN_PROGRESS')
                          _actionButton(
                            label: 'Done',
                            icon: Icons.check_rounded,
                            color: const Color(0xFF10B981),
                            onTap: () async {
                              final success =
                                  await provider.completeTask(task.id);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Task completed! 🎉'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.task_alt_rounded,
              size: 40.sp, color: AppColors.primaryGreen.withOpacity(0.5)),
          SizedBox(height: 10.h),
          Text(
            'All caught up! 🎉',
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'No pending tasks right now.',
            style: GoogleFonts.nunitoSans(
              fontSize: 13.sp,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ── Shimmer Loading ───────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return Column(
      children: List.generate(
        2,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Container(
            height: 100.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _badge({
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunitoSans(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 13.sp),
            SizedBox(width: 4.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _priorityData(String priority) {
    switch (priority) {
      case 'URGENT':
        return {'color': const Color(0xFFEF4444), 'bg': const Color(0xFFFEF2F2)};
      case 'IMPORTANT':
        return {'color': const Color(0xFFF59E0B), 'bg': const Color(0xFFFFFBEB)};
      default: // NORMAL
        return {'color': const Color(0xFF3B82F6), 'bg': const Color(0xFFEFF6FF)};
    }
  }

  Map<String, dynamic> _statusData(String status) {
    switch (status) {
      case 'IN_PROGRESS':
        return {'label': 'In Progress', 'color': const Color(0xFF8B5CF6)};
      case 'COMPLETED':
        return {'label': 'Completed', 'color': const Color(0xFF10B981)};
      case 'CANCELLED':
        return {'label': 'Cancelled', 'color': Colors.grey};
      default: // PENDING
        return {'label': 'Pending', 'color': const Color(0xFFF59E0B)};
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]}';
    } catch (_) {
      return isoDate;
    }
  }
}
