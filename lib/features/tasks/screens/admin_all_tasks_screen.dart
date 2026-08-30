import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'task_details_screen.dart';

/// Super-Admin view: shows ALL tasks in the system via GET /api/v1/tasks.
/// Supports filter by status + live Cancel action.
class AdminAllTasksScreen extends StatefulWidget {
  const AdminAllTasksScreen({super.key});

  @override
  State<AdminAllTasksScreen> createState() => _AdminAllTasksScreenState();
}

class _AdminAllTasksScreenState extends State<AdminAllTasksScreen> {
  int _selectedFilter = 0;

  static const Color _primary = Color(0xFF1E293B);
  static const Color _accent = Color(0xFF0F766E);

  final List<String> _filters = [
    'All',
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled',
    'Urgent',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchAllTasks();
    });
  }

  List<TaskModel> _filtered(List<TaskModel> all) {
    switch (_selectedFilter) {
      case 1:
        return all.where((t) => t.status == 'PENDING').toList();
      case 2:
        return all.where((t) => t.status == 'IN_PROGRESS').toList();
      case 3:
        return all.where((t) => t.status == 'COMPLETED').toList();
      case 4:
        return all.where((t) => t.status == 'CANCELLED').toList();
      case 5:
        return all.where((t) => t.priority == 'URGENT').toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: SafeArea(
        bottom: false,
        child: Consumer<TaskProvider>(
          builder: (context, provider, _) {
            final all = provider.allTasks;
            final filtered = _filtered(all);

            // Derived stats
            final total = all.length;
            final pending = all.where((t) => t.status == 'PENDING').length;
            final active = all.where((t) => t.status == 'IN_PROGRESS').length;
            final done = all.where((t) => t.status == 'COMPLETED').length;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(provider)),
                SliverToBoxAdapter(
                    child: _buildStatsRow(
                        total: total,
                        pending: pending,
                        active: active,
                        done: done)),
                SliverToBoxAdapter(child: _buildFilters()),
                if (provider.isLoading && all.isEmpty)
                  SliverToBoxAdapter(child: _buildLoading())
                else if (filtered.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState())
                else
                  SliverToBoxAdapter(
                      child: _buildTaskList(context, provider, filtered)),
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(TaskProvider provider) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Tasks',
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                ),
                Text(
                  'System-wide overview',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Refresh
          GestureDetector(
            onTap: () => provider.fetchAllTasks(),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: provider.isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_accent)),
                    )
                  : Icon(Icons.refresh_rounded, color: _accent, size: 22.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Row ───────────────────────────────────────────────────────────────

  Widget _buildStatsRow({
    required int total,
    required int pending,
    required int active,
    required int done,
  }) {
    final stats = [
      [total.toString(), 'Total', Icons.list_alt_rounded, const Color(0xFF3B82F6)],
      [pending.toString(), 'Pending', Icons.pending_actions_rounded, const Color(0xFFF59E0B)],
      [active.toString(), 'Active', Icons.autorenew_rounded, const Color(0xFF8B5CF6)],
      [done.toString(), 'Done', Icons.task_alt_rounded, const Color(0xFF10B981)],
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      child: Row(
        children: stats.map((s) {
          final color = s[3] as Color;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: s == stats.last ? 0 : 10.w),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(s[2] as IconData, color: color, size: 14.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    s[0] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                    ),
                  ),
                  Text(
                    s[1] as String,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 9.sp,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Filters ─────────────────────────────────────────────────────────────────

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: SizedBox(
        height: 36.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: _filters.length,
          itemBuilder: (context, index) {
            final selected = _selectedFilter == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? _primary : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: selected ? _primary : Colors.grey.withOpacity(0.2),
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: _primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  _filters[index],
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Task List ───────────────────────────────────────────────────────────────

  Widget _buildTaskList(
      BuildContext context, TaskProvider provider, List<TaskModel> tasks) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.assignment_rounded,
                    size: 14.sp, color: _primary),
              ),
              SizedBox(width: 8.w),
              Text(
                '${tasks.length} Task${tasks.length != 1 ? 's' : ''}',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...tasks.map((task) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildTaskCard(context, provider, task),
              )),
        ],
      ),
    );
  }

  // ── Task Card ───────────────────────────────────────────────────────────────

  Widget _buildTaskCard(
      BuildContext context, TaskProvider provider, TaskModel task) {
    final pColor = _priorityColor(task.priority);
    final pBg = _priorityBg(task.priority);
    final sColor = _statusColor(task.status);
    final sLabel = _statusLabel(task.status);

    final canCancel =
        task.status != 'COMPLETED' && task.status != 'CANCELLED';

    return GestureDetector(
      onTap: () async {
        final didUpdate = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
              builder: (_) => TaskDetailsScreen(task: task)),
        );
        if (didUpdate == true && context.mounted) {
          provider.fetchAllTasks();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: pColor.withOpacity(0.2), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Priority accent bar
              Container(
                height: 3.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [pColor, pColor.withOpacity(0.4)],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + priority badge
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
                                  color: _primary,
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
                            color: pColor,
                            bg: pBg),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Description
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
                    // Assignee + department chips
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      children: [
                        if (task.assignedTo != null)
                          _infoChip(
                              Icons.person_rounded,
                              task.assignedTo!.name),
                        if (task.department != null)
                          _infoChip(
                              Icons.business_rounded,
                              task.department!.name),
                        if (task.dueDate != null)
                          _infoChip(
                              Icons.calendar_today_rounded,
                              _formatDate(task.dueDate!)),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    // Bottom row: status + cancel button
                    Row(
                      children: [
                        _badge(
                          label: sLabel,
                          color: sColor,
                          bg: sColor.withOpacity(0.1),
                        ),
                        const Spacer(),
                        if (canCancel)
                          GestureDetector(
                            onTap: () => _handleCancel(context, provider, task),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                    color: Colors.redAccent.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.cancel_rounded,
                                      size: 13.sp,
                                      color: Colors.redAccent),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

  // ── Cancel Handler ──────────────────────────────────────────────────────────

  Future<void> _handleCancel(
      BuildContext context, TaskProvider provider, TaskModel task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('Cancel Task?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to cancel "${task.title}"?',
          style: GoogleFonts.nunitoSans(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('No',
                style: GoogleFonts.poppins(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Yes, Cancel',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.cancelTask(task.id);
    if (!mounted) return;

    messenger.showSnackBar(SnackBar(
      content: Text(success
          ? 'Task cancelled successfully.'
          : (provider.errorMessage ?? 'Failed to cancel task.')),
      backgroundColor: success ? Colors.green : Colors.red,
    ));

    if (success) provider.fetchAllTasks();
  }

  // ── Loading & Empty ─────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Padding(
      padding: EdgeInsets.only(top: 50.h),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_accent),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.only(top: 50.h),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.task_alt_rounded,
                size: 54.sp, color: _accent.withOpacity(0.35)),
            SizedBox(height: 12.h),
            Text('No tasks found',
                style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: _primary)),
            SizedBox(height: 4.h),
            Text('Try a different filter.',
                style: GoogleFonts.nunitoSans(
                    fontSize: 13.sp, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  // ── Shared Helpers ──────────────────────────────────────────────────────────

  Widget _badge(
      {required String label, required Color color, required Color bg}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(label,
          style: GoogleFonts.nunitoSans(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11.sp, color: AppColors.textMuted),
        SizedBox(width: 3.w),
        Text(label,
            style: GoogleFonts.nunitoSans(
                fontSize: 11.sp,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'URGENT':
        return const Color(0xFFEF4444);
      case 'IMPORTANT':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Color _priorityBg(String p) {
    switch (p) {
      case 'URGENT':
        return const Color(0xFFFEF2F2);
      case 'IMPORTANT':
        return const Color(0xFFFFFBEB);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'IN_PROGRESS':
        return const Color(0xFF8B5CF6);
      case 'COMPLETED':
        return const Color(0xFF10B981);
      case 'CANCELLED':
        return Colors.grey;
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      const m = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) {
      return iso;
    }
  }
}
