import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../super_admin/providers/super_admin_provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late TaskModel _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _handleStart() async {
    final provider = context.read<TaskProvider>();
    final success = await provider.startTask(_task.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task started!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _handleComplete() async {
    final provider = context.read<TaskProvider>();
    final success = await provider.completeTask(_task.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task completed!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _handleCancel() async {
    final provider = context.read<TaskProvider>();
    final success = await provider.cancelTask(_task.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task cancelled.'), backgroundColor: Colors.orange),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to cancel task. You might not have permission.'), 
          backgroundColor: Colors.red
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // For MVP, if they are Super Admin, they can cancel any task.
    final isSuperAdmin = context.watch<SuperAdminProvider>().isSuperAdmin;
    
    // In a real scenario, you'd check if `_task.assignedTo?.id == currentUserId`
    // Since we don't have a rigid AuthUser model here, we will just simulate it:
    // If they are not SuperAdmin, assume they are the employee (Assignee).
    final isAssignee = !isSuperAdmin;

    final canStart = isAssignee && _task.status == 'PENDING';
    final canComplete = isAssignee && _task.status == 'IN_PROGRESS';
    final canCancel = isSuperAdmin && (_task.status != 'COMPLETED' && _task.status != 'CANCELLED');

    Color statusColor = AppColors.textMuted;
    if (_task.status == 'PENDING') statusColor = Colors.orange;
    if (_task.status == 'IN_PROGRESS') statusColor = Colors.blue;
    if (_task.status == 'COMPLETED') statusColor = Colors.green;
    if (_task.status == 'CANCELLED') statusColor = Colors.red;

    return Scaffold(
      backgroundColor: AppColors.backgroundSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Task Details',
          style: GoogleFonts.inter(
            color: AppColors.textMain,
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.w, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _task.status,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
                Text(
                  _task.priority,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: _task.priority == 'URGENT' || _task.priority == 'HIGH' ? Colors.red : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              _task.title,
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Description',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _task.description,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            _buildInfoRow('Department', _task.department?.name ?? 'N/A'),
            _buildInfoRow('Assigned To', _task.assignedTo?.name ?? 'N/A'),
            _buildInfoRow('Assigned By', _task.assignedBy?.name ?? 'N/A'),
            if (_task.dueDate != null) _buildInfoRow('Due Date', _task.dueDate!),
            
            SizedBox(height: 40.h),
            
            // Action Buttons
            if (canStart)
              _buildActionButton(
                label: 'Start Task',
                color: Colors.blue,
                onPressed: _handleStart,
              ),
            if (canComplete)
              _buildActionButton(
                label: 'Mark as Complete',
                color: Colors.green,
                onPressed: _handleComplete,
              ),
            if (canCancel) ...[
              if (canStart || canComplete) SizedBox(height: 12.h),
              _buildActionButton(
                label: 'Cancel Task',
                color: Colors.red,
                isOutlined: true,
                onPressed: _handleCancel,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: isOutlined
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: onPressed,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: onPressed,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}
