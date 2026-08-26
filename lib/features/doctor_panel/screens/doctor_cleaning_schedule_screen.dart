import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/voice_service.dart';

class DoctorCleaningScheduleScreen extends StatefulWidget {
  const DoctorCleaningScheduleScreen({super.key});

  @override
  State<DoctorCleaningScheduleScreen> createState() =>
      _DoctorCleaningScheduleScreenState();
}

class _DoctorCleaningScheduleScreenState
    extends State<DoctorCleaningScheduleScreen> {
  final List<_CleaningTaskEditor> _tasks = [
    _CleaningTaskEditor(
      time: '07:00 AM',
      taskName: 'Morning Cage Cleaning',
      checklist:
          'Remove soiled bedding • Sweep cage floor • Replace with fresh bedding',
      instructions:
          'Start by carefully moving the patient to the holding area before cleaning. Remove all soiled newspaper and bedding from the cage.',
    ),
    _CleaningTaskEditor(
      time: '09:00 AM',
      taskName: 'Disinfection',
      checklist:
          'Spray disinfectant solution • Wipe bars and floor • Air dry for 15 min',
      instructions:
          'Use the green-label veterinary disinfectant. Spray on all cage bars and floor.',
    ),
  ];

  final VoiceService _voiceService = VoiceService();
  int? _activeListeningIndex;

  @override
  void dispose() {
    for (var task in _tasks) {
      task.dispose();
    }
    super.dispose();
  }

  void _toggleListening(int index) async {
    if (_activeListeningIndex == index) {
      await _voiceService.stopListening();
      setState(() => _activeListeningIndex = null);
    } else {
      if (_activeListeningIndex != null) {
        await _voiceService.stopListening();
      }
      setState(() => _activeListeningIndex = index);
      await _voiceService.startListening(
        onResultFinalized: (text) {
          setState(() {
            _tasks[index].instructionController.text = text;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textMain,
        title: Text(
          'Cleaning Schedule',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            color: AppColors.textMain,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cleaning schedule updated successfully'),
                  backgroundColor: Color(0xFF34A853),
                ),
              );
              context.pop();
            },
            icon: const Icon(Icons.check, color: Color(0xFF34A853)),
            label: Text(
              'Save',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF34A853),
                fontSize: 15.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cleaning Tasks',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _tasks.add(_CleaningTaskEditor(time: 'Select Time'));
                  });
                },
                icon: Icon(Icons.add, size: 18.sp),
                label: const Text('Add Task'),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          ...List.generate(_tasks.length, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _buildTaskEditorCard(index),
            );
          }),

          SizedBox(height: 16.h),
          _buildSafetyInstructionsCard(),
          SizedBox(height: 32.h),

          // Main Save Button
          ElevatedButton.icon(
            onPressed: () {
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'All cleaning schedule changes saved successfully',
                  ),
                  backgroundColor: Color(0xFF34A853),
                ),
              );
            },
            icon: Icon(Icons.save, size: 20.sp, color: Colors.white),
            label: Text(
              'Save Full Schedule',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34A853),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }

  Widget _buildTaskEditorCard(int index) {
    final task = _tasks[index];
    final isListening = _activeListeningIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6).withOpacity(0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null && mounted) {
                      setState(() {
                        task.time = time.format(context);
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18.sp,
                        color: const Color(0xFF14B8A6),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        task.time,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF14B8A6),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: const Color(0xFF14B8A6),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: const Color(0xFFEF4444),
                    size: 20.sp,
                  ),
                  onPressed: () {
                    setState(() {
                      _tasks.removeAt(index);
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Name',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: task.taskNameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Disinfection',
                    hintStyle: GoogleFonts.nunitoSans(
                      color: Colors.grey[400],
                      fontSize: 13.sp,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  style: GoogleFonts.nunitoSans(fontSize: 14.sp),
                ),
                SizedBox(height: 12.h),

                Text(
                  'Checklist Items (Optional)',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: task.checklistController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Spray solution • Wipe bars • Air dry',
                    hintStyle: GoogleFonts.nunitoSans(
                      color: Colors.grey[400],
                      fontSize: 13.sp,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  style: GoogleFonts.nunitoSans(fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Supervisor Instructions (Dictate)',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain,
                      ),
                    ),
                    InkWell(
                      onTap: () => _toggleListening(index),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: isListening
                              ? const Color(0xFFEF4444).withOpacity(0.1)
                              : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          size: 18.sp,
                          color: isListening
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: task.instructionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Speak or type instructions for the worker...',
                    hintStyle: GoogleFonts.nunitoSans(
                      color: Colors.grey[400],
                      fontSize: 13.sp,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.all(12.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: Color(0xFF3B82F6),
                        width: 1.5.w,
                      ),
                    ),
                  ),
                  style: GoogleFonts.nunitoSans(fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task details saved'),
                          backgroundColor: Color(0xFF3B82F6),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.check,
                      size: 16.sp,
                      color: const Color(0xFF3B82F6),
                    ),
                    label: Text(
                      'Save Task',
                      style: TextStyle(
                        color: const Color(0xFF3B82F6),
                        fontSize: 13.sp,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3B82F6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
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

  Widget _buildSafetyInstructionsCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                color: const Color(0xFFEF4444),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Safety Reminders',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g. Always wear gloves. Do not disturb the wound.',
              hintStyle: GoogleFonts.nunitoSans(
                color: Colors.grey[400],
                fontSize: 13.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: AppColors.backgroundLightGray,
            ),
            style: GoogleFonts.nunitoSans(fontSize: 14.sp),
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Safety reminders saved'),
                    backgroundColor: Color(0xFF3B82F6),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(
                Icons.check,
                size: 16.sp,
                color: const Color(0xFF3B82F6),
              ),
              label: Text(
                'Save Reminders',
                style: TextStyle(
                  color: const Color(0xFF3B82F6),
                  fontSize: 13.sp,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF3B82F6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CleaningTaskEditor {
  String time;
  final TextEditingController taskNameController;
  final TextEditingController checklistController;
  final TextEditingController instructionController;

  _CleaningTaskEditor({
    required this.time,
    String taskName = '',
    String checklist = '',
    String instructions = '',
  }) : taskNameController = TextEditingController(text: taskName),
       checklistController = TextEditingController(text: checklist),
       instructionController = TextEditingController(text: instructions);

  void dispose() {
    taskNameController.dispose();
    checklistController.dispose();
    instructionController.dispose();
  }
}
