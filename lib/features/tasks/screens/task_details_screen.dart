import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/text_to_speech_player.dart';
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
    if (_task.status == 'COMPLETED') statusColor = const Color(0xFF10B981);
    if (_task.status == 'CANCELLED') statusColor = Colors.red;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Background Gradient Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250.h,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E293B), Color(0xFF0F766E)],
                ),
              ),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        'Task Details',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Main Content Card
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 40.h),
                    child: Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Badges Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(color: statusColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  _task.status,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    _task.priority == 'URGENT' ? Icons.error_rounded : _task.priority == 'IMPORTANT' ? Icons.warning_rounded : Icons.info_rounded,
                                    size: 16.sp,
                                    color: _task.priority == 'URGENT' ? Colors.red : _task.priority == 'IMPORTANT' ? Colors.orange : Colors.blue,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    _task.priority,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: _task.priority == 'URGENT' ? Colors.red : _task.priority == 'IMPORTANT' ? Colors.orange : Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          
                          // Title
                          Text(
                            _task.title,
                            style: GoogleFonts.poppins(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMain,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          
                          // Description
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Description',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMain,
                                ),
                              ),
                              // 🔊 TTS — tap to hear the description read aloud
                              TextToSpeechPlayer(
                                text: _task.description,
                                languageCode: 'en-IN',
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              _task.description,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textMuted,
                                height: 1.6,
                              ),
                            ),
                          ),
                          SizedBox(height: 32.h),
                          
                          // Meta Info Section
                          Text(
                            'Details',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMain,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow('Department', _task.department?.name ?? 'N/A', Icons.business_rounded),
                                Divider(color: const Color(0xFFE2E8F0), height: 24.h),
                                _buildInfoRow('Assigned To', _task.assignedTo?.name ?? 'N/A', Icons.person_rounded),
                                Divider(color: const Color(0xFFE2E8F0), height: 24.h),
                                _buildInfoRow('Assigned By', _task.assignedBy?.name ?? 'N/A', Icons.assignment_ind_rounded),
                                if (_task.dueDate != null) ...[
                                  Divider(color: const Color(0xFFE2E8F0), height: 24.h),
                                  _buildInfoRow('Due Date', _formatDate(_task.dueDate!), Icons.calendar_today_rounded),
                                ],
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 40.h),
                          
                          // Action Buttons
                          if (canStart)
                            _buildActionButton(
                              label: 'Start Task',
                              icon: Icons.play_arrow_rounded,
                              colors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                              shadowColor: const Color(0xFF2563EB),
                              onPressed: _handleStart,
                            ),
                          if (canComplete)
                            _buildActionButton(
                              label: 'Mark as Complete',
                              icon: Icons.check_circle_rounded,
                              colors: const [Color(0xFF10B981), Color(0xFF059669)],
                              shadowColor: const Color(0xFF10B981),
                              onPressed: _handleComplete,
                            ),
                          if (canCancel) ...[
                            if (canStart || canComplete) SizedBox(height: 16.h),
                            _buildCancelButton(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate; // Fallback
    }
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFF94A3B8)),
        SizedBox(width: 8.w),
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
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
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required List<Color> colors,
    required Color shadowColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
        color: Colors.redAccent.withOpacity(0.05),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleCancel,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Text(
              'Cancel Task',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
