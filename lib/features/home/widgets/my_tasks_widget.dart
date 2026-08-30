import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
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
              // ── Debug logging ──────────────────────────────────────────
              debugPrint('[MyTasksWidget] isLoading=${provider.isLoading}, '
                  'myTasks.length=${provider.myTasks.length}, '
                  'error=${provider.errorMessage}');
              for (final t in provider.myTasks) {
                debugPrint('[MyTasksWidget]   task: "${t.title}" status=${t.status}');
              }
              // ──────────────────────────────────────────────────────────

              if (provider.isLoading && provider.myTasks.isEmpty) {
                debugPrint('[MyTasksWidget] → showing shimmer');
                return _buildShimmer();
              }

              final tasks = provider.myTasks
                  .where((t) => t.status != 'COMPLETED' && t.status != 'CANCELLED')
                  .take(3)
                  .toList();

              debugPrint('[MyTasksWidget] → filtered (non-done) tasks: ${tasks.length}');

              if (tasks.isEmpty) {
                debugPrint('[MyTasksWidget] → showing empty state');
                return _buildEmptyState();
              }

              debugPrint('[MyTasksWidget] → rendering ${tasks.length} task card(s)');
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
