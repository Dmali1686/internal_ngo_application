import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'task_details_screen.dart';

class TasksDashboardScreen extends StatefulWidget {
  const TasksDashboardScreen({super.key});

  @override
  State<TasksDashboardScreen> createState() => _TasksDashboardScreenState();
}

class _TasksDashboardScreenState extends State<TasksDashboardScreen> {
  int _selectedFilter = 0;

  static const Color _primary = Color(0xFF1E293B);
  static const Color _accent = Color(0xFF0F766E);

  final List<String> _filters = [
    'All',
    'Pending',
    'In Progress',
    'Completed',
    'Urgent',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchMyTasks();
    });
  }

  List<TaskModel> _filteredTasks(List<TaskModel> all) {
    switch (_selectedFilter) {
      case 1:
        return all.where((t) => t.status == 'PENDING').toList();
      case 2:
        return all.where((t) => t.status == 'IN_PROGRESS').toList();
      case 3:
        return all.where((t) => t.status == 'COMPLETED').toList();
      case 4:
        return all.where((t) => t.priority == 'URGENT').toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        bottom: false,
        child: Consumer<TaskProvider>(
          builder: (context, provider, _) {
            final myTasks = provider.myTasks;
            final total = myTasks.length;
            final pending = myTasks.where((t) => t.status == 'PENDING').length;
            final active = myTasks.where((t) => t.status == 'IN_PROGRESS').length;
            final done = myTasks.where((t) => t.status == 'COMPLETED').length;
            final completionRatio = total > 0 ? done / total : 0.0;

            final filtered = _filteredTasks(myTasks);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(
                  child: _buildWelcomeCard(
                    pending: pending,
                    done: done,
                    total: total,
                    ratio: completionRatio,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildStatsRow(
                    total: total,
                    pending: pending,
                    active: active,
                    done: done,
                  ),
                ),
                SliverToBoxAdapter(child: _buildFilters()),
                if (provider.isLoading && myTasks.isEmpty)
                  SliverToBoxAdapter(child: _buildLoading())
                else if (filtered.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState())
                else
                  SliverToBoxAdapter(
                    child: _buildTaskList(context, provider, filtered),
                  ),
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── Header ───

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F766E)],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.task_alt_rounded,
                      color: Colors.white, size: 20.sp),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'My Tasks',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
            ],
          ),
          // Refresh button
          Consumer<TaskProvider>(
            builder: (context, provider, _) => GestureDetector(
              onTap: () => provider.fetchMyTasks(),
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
                              AlwaysStoppedAnimation<Color>(_accent),
                        ),
                      )
                    : Icon(Icons.refresh_rounded, color: _accent, size: 22.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Welcome Card ───

  Widget _buildWelcomeCard({
    required int pending,
    required int done,
    required int total,
    required double ratio,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F766E)],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Overview",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  pending > 0 ? '$pending Tasks Pending' : 'All Done! 🎉',
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                if (pending > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color:
                              const Color(0xFFF59E0B).withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Color(0xFFFBBF24), size: 14),
                        SizedBox(width: 4.w),
                        Text(
                          '$pending task${pending != 1 ? 's' : ''} pending',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFBBF24),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          // Completion ring
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 72.w,
                height: 72.w,
                child: CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF2DD4BF),
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(ratio * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$done/$total',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 9.sp,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Stats Row ───

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
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Row(
        children: stats.map((s) {
          final color = s[3] as Color;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: s == stats.last ? 0 : 10.w),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
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
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(s[2] as IconData, color: color, size: 16.sp),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    s[0] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                    ),
                  ),
                  Text(
                    s[1] as String,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 10.sp,
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

  // ─── Filters ───

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
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
                padding: EdgeInsets.symmetric(horizontal: 18.w),
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

  // ─── Task List ───

  Widget _buildTaskList(
      BuildContext context, TaskProvider provider, List<TaskModel> tasks) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child:
                    Icon(Icons.assignment_rounded, size: 16.sp, color: _primary),
              ),
              SizedBox(width: 10.w),
              Text(
                '${tasks.length} Task${tasks.length != 1 ? 's' : ''}',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...tasks.map(
            (task) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildTaskCard(context, provider, task),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Task Card ───

  Widget _buildTaskCard(
      BuildContext context, TaskProvider provider, TaskModel task) {
    final priorityColor = _priorityColor(task.priority);
    final priorityBg = _priorityBg(task.priority);
    final statusColor = _statusColor(task.status);
    final statusLabel = _statusLabel(task.status);

    final canStart = task.status == 'PENDING';
    final canComplete = task.status == 'IN_PROGRESS';

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
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
              color: priorityColor.withOpacity(0.2), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coloured top accent bar
              Container(
                height: 3.5.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [priorityColor, priorityColor.withOpacity(0.4)],
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
                                  fontSize: 15.sp,
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
                          color: priorityColor,
                          bg: priorityBg,
                        ),
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
                    // Meta: department + due date
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 4.h,
                      children: [
                        if (task.department != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.business_rounded,
                                  size: 12.sp, color: AppColors.textMuted),
                              SizedBox(width: 4.w),
                              Text(
                                task.department!.name,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 11.sp,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        if (task.dueDate != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  size: 12.sp, color: AppColors.textMuted),
                              SizedBox(width: 4.w),
                              Text(
                                _formatDate(task.dueDate!),
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 11.sp,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    // Action row
                    Row(
                      children: [
                        if (canStart)
                          Expanded(
                            child: _actionButton(
                              label: 'Start Task',
                              icon: Icons.play_arrow_rounded,
                              colors: [_primary, _accent],
                              onTap: () => _handleStart(context, provider, task),
                            ),
                          )
                        else if (canComplete)
                          Expanded(
                            child: _actionButton(
                              label: 'Mark Done',
                              icon: Icons.check_circle_rounded,
                              colors: const [
                                Color(0xFF10B981),
                                Color(0xFF059669)
                              ],
                              onTap: () =>
                                  _handleComplete(context, provider, task),
                            ),
                          )
                        else
                          Expanded(
                            child: _badge(
                              label: statusLabel,
                              color: statusColor,
                              bg: statusColor.withOpacity(0.1),
                            ),
                          ),
                        SizedBox(width: 8.w),
                        // Info button → detail screen
                        Container(
                          padding: EdgeInsets.all(9.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(Icons.info_outline_rounded,
                              size: 18.sp, color: AppColors.textMuted),
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

  // ─── Handlers ───

  Future<void> _handleStart(
      BuildContext context, TaskProvider provider, TaskModel task) async {
    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.startTask(task.id);
    if (mounted) {
      messenger.showSnackBar(
        SnackBar(
          content:
              Text(success ? 'Task started!' : (provider.errorMessage ?? 'Failed')),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _handleComplete(
      BuildContext context, TaskProvider provider, TaskModel task) async {
    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.completeTask(task.id);
    if (mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
              success ? 'Task completed! 🎉' : (provider.errorMessage ?? 'Failed')),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  // ─── Loading & Empty ───

  Widget _buildLoading() {
    return Padding(
      padding: EdgeInsets.only(top: 40.h),
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
                size: 54.sp,
                color: _accent.withOpacity(0.4)),
            SizedBox(height: 12.h),
            Text(
              'No tasks here!',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Try a different filter.',
              style: GoogleFonts.nunitoSans(
                fontSize: 13.sp,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Shared Widgets ───

  Widget _badge({
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.35)),
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
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 9.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ───

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'URGENT':
        return const Color(0xFFEF4444);
      case 'IMPORTANT':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Color _priorityBg(String priority) {
    switch (priority) {
      case 'URGENT':
        return const Color(0xFFFEF2F2);
      case 'IMPORTANT':
        return const Color(0xFFFFFBEB);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
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

  String _statusLabel(String status) {
    switch (status) {
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

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
