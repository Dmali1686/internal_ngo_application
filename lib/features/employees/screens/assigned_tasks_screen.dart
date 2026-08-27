import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class AssignedTasksScreen extends StatelessWidget {
  const AssignedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Assigned Tasks', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 18.sp)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.w),
          onPressed: () => context.pop(),
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: AppColors.primaryGreen,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primaryGreen,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.sp),
                tabs: const [
                  Tab(text: 'Pending'),
                  Tab(text: 'In Progress'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTaskList(isPending: true),
                  _buildEmptyState('No tasks in progress'),
                  _buildTaskList(isPending: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList({required bool isPending}) {
    final tasks = isPending 
        ? [
            {'title': 'Check on Patient #102', 'assignee': 'Dr. Priya', 'priority': 'High', 'time': 'Today, 10:00 AM'},
            {'title': 'Update Medical Records', 'assignee': 'Ravi Desai', 'priority': 'Medium', 'time': 'Today, 02:00 PM'},
          ]
        : [
            {'title': 'Morning Rounds', 'assignee': 'Dr. Priya', 'priority': 'High', 'time': 'Done'},
          ];

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isHighPriority = task['priority'] == 'High';

        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isHighPriority ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        task['priority']!,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 10.sp, 
                          color: isHighPriority ? Colors.red : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(task['time']!, style: GoogleFonts.nunitoSans(fontSize: 12.sp, color: AppColors.textMuted)),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(task['title']!, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16.w, color: AppColors.textMuted),
                    SizedBox(width: 4.w),
                    Text(task['assignee']!, style: GoogleFonts.nunitoSans(fontSize: 13.sp, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_rounded, size: 48.w, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(message, style: GoogleFonts.nunitoSans(fontSize: 14.sp, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
