import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class AssignedTasksScreen extends StatefulWidget {
  const AssignedTasksScreen({super.key});

  @override
  State<AssignedTasksScreen> createState() => _AssignedTasksScreenState();
}

class _AssignedTasksScreenState extends State<AssignedTasksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _pending = [
    {'title': 'Check on Patient #102', 'assignee': 'Dr. Priya Sharma', 'assigneeRole': 'Doctor', 'priority': 'High', 'time': 'Today, 10:00 AM', 'icon': Icons.medical_information_rounded},
    {'title': 'Update Medical Records', 'assignee': 'Ravi Desai', 'assigneeRole': 'Nurse', 'priority': 'Medium', 'time': 'Today, 02:00 PM', 'icon': Icons.edit_note_rounded},
    {'title': 'Animal Feeding Schedule', 'assignee': 'Anita Kulkarni', 'assigneeRole': 'Caretaker', 'priority': 'Low', 'time': 'Today, 04:00 PM', 'icon': Icons.pets_rounded},
  ];

  static const _inProgress = [
    {'title': 'Ambulance Maintenance', 'assignee': 'Suresh Patil', 'assigneeRole': 'Driver', 'priority': 'High', 'time': 'In Progress', 'icon': Icons.local_shipping_rounded},
    {'title': 'Ward Disinfection', 'assignee': 'Meera Joshi', 'assigneeRole': 'Nurse', 'priority': 'Medium', 'time': 'In Progress', 'icon': Icons.cleaning_services_rounded},
  ];

  static const _completed = [
    {'title': 'Morning Ward Rounds', 'assignee': 'Dr. Priya Sharma', 'assigneeRole': 'Doctor', 'priority': 'High', 'time': 'Done 8:00 AM', 'icon': Icons.check_circle_rounded},
    {'title': 'Reception Duty', 'assignee': 'Arun Nair', 'assigneeRole': 'Receptionist', 'priority': 'Low', 'time': 'Done 9:00 AM', 'icon': Icons.record_voice_over_rounded},
  ];

  static const Map<String, Color> _priorityColors = {
    'High': Color(0xFFEF4444),
    'Medium': Color(0xFFF97316),
    'Low': Color(0xFF22C55E),
  };

  static const Map<String, Color> _roleColors = {
    'Doctor': Color(0xFF6366F1),
    'Nurse': Color(0xFFEC4899),
    'Caretaker': Color(0xFF14B8A6),
    'Driver': Color(0xFFF97316),
    'Receptionist': Color(0xFF8B5CF6),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          SliverAppBar(
            expandedHeight: 160.h,
            pinned: true,
            forceElevated: innerBoxScrolled,
            backgroundColor: const Color(0xFF1E293B),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.w),
              onPressed: () => context.pop(),
            ),
            title: Text('Assigned Tasks', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E293B), Color(0xFFF97316)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            _buildMiniStat('${_pending.length}', 'Pending', AppColors.warningOrange),
                            SizedBox(width: 10.w),
                            _buildMiniStat('${_inProgress.length}', 'In Progress', const Color(0xFF6366F1)),
                            SizedBox(width: 10.w),
                            _buildMiniStat('${_completed.length}', 'Done', AppColors.primaryGreen),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48.h),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryGreen,
                  unselectedLabelColor: AppColors.textMuted,
                  indicatorColor: AppColors.primaryGreen,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12.sp),
                  unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12.sp),
                  tabs: [
                    Tab(text: 'Pending (${_pending.length})'),
                    Tab(text: 'In Progress (${_inProgress.length})'),
                    Tab(text: 'Done (${_completed.length})'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTaskList(_pending, showCheckAction: true),
            _buildTaskList(_inProgress),
            _buildTaskList(_completed, isDone: true),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primaryGreen,
        icon: Icon(Icons.add_task_rounded, color: Colors.white, size: 20.w),
        label: Text('Add Task', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13.sp)),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(label, style: GoogleFonts.nunitoSans(fontSize: 10.sp, color: Colors.white.withValues(alpha: 0.75))),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Map<String, Object>> tasks, {bool showCheckAction = false, bool isDone = false}) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_outlined, size: 56.w, color: Colors.grey.shade300),
            SizedBox(height: 16.h),
            Text('No tasks here', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
      itemCount: tasks.length,
      itemBuilder: (context, index) => _buildTaskCard(tasks[index], isDone: isDone, showCheckAction: showCheckAction),
    );
  }

  Widget _buildTaskCard(Map<String, Object> task, {bool isDone = false, bool showCheckAction = false}) {
    final priority = task['priority'] as String;
    final role = task['assigneeRole'] as String;
    final priorityColor = _priorityColors[priority] ?? AppColors.primaryGreen;
    final roleColor = _roleColors[role] ?? AppColors.primaryGreen;
    final icon = task['icon'] as IconData;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: Offset(0, 3.h))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Priority colour strip + content
          Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: isDone ? Colors.grey.shade300 : priorityColor, width: 4)),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: isDone ? Colors.grey.withValues(alpha: 0.08) : priorityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(icon, size: 18.w, color: isDone ? Colors.grey : priorityColor),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          task['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: isDone ? AppColors.textMuted : AppColors.textMain,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: (isDone ? Colors.grey : priorityColor).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          priority,
                          style: GoogleFonts.nunitoSans(fontSize: 10.sp, fontWeight: FontWeight.w800, color: isDone ? Colors.grey : priorityColor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_rounded, size: 11.w, color: roleColor),
                            SizedBox(width: 4.w),
                            Text(task['assignee'] as String, style: GoogleFonts.nunitoSans(fontSize: 10.sp, fontWeight: FontWeight.w700, color: roleColor)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.schedule_rounded, size: 13.w, color: AppColors.textMuted),
                      SizedBox(width: 4.w),
                      Text(task['time'] as String, style: GoogleFonts.nunitoSans(fontSize: 11.sp, color: AppColors.textMuted)),
                    ],
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
