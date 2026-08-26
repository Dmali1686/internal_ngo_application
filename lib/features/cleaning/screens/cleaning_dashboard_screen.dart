import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/text_to_speech_player.dart';

class CleaningDashboardScreen extends StatefulWidget {
  const CleaningDashboardScreen({super.key});

  @override
  State<CleaningDashboardScreen> createState() =>
      _CleaningDashboardScreenState();
}

class _CleaningDashboardScreenState extends State<CleaningDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  final List<_CleaningTask> _cleaningTasks = [
    _CleaningTask(
      id: 'task_1',
      time: '07:00 AM',
      label: 'Morning Cage Cleaning',
      icon: Icons.wb_sunny_rounded,
      taskItems: [
        'Remove soiled bedding',
        'Sweep cage floor',
        'Replace with fresh bedding'
      ],
      emoji: '🧹',
      supervisorNote:
          'Start by carefully moving the patient to the holding area before cleaning. Remove all soiled newspaper and bedding from the cage. Sweep the cage floor thoroughly. Check for any sharp edges or broken parts in the cage. Place two layers of fresh newspaper and one clean blanket.',
      isDone: true,
      completedTime: '7:18 AM',
    ),
    _CleaningTask(
      id: 'task_2',
      time: '09:00 AM',
      label: 'Disinfection',
      icon: Icons.sanitizer_rounded,
      taskItems: [
        'Spray disinfectant solution',
        'Wipe bars and floor',
        'Air dry for 15 min'
      ],
      emoji: '🧽',
      supervisorNote:
          'Use the green-label veterinary disinfectant — dilute 20ml in 1 litre of water. Spray on all cage bars, floor, and the food and water bowls. Wipe everything with a clean cloth. Allow the cage to air dry for at least 15 minutes before placing the patient back inside. Do not use household bleach as it is toxic.',
      isDone: false,
      completedTime: null,
    ),
    _CleaningTask(
      id: 'task_3',
      time: '12:00 PM',
      label: 'Midday Check & Spot Clean',
      icon: Icons.wb_cloudy_rounded,
      taskItems: [
        'Check for soiling',
        'Spot clean if needed',
        'Refill water bowl'
      ],
      emoji: '🔍',
      supervisorNote:
          'Do a quick visual inspection of the cage. If there is any soiling from food or waste, spot clean that area immediately. Replace the newspaper in that section only. Refill the water bowl with fresh water. Check if the bedding is still dry — if wet, replace it fully.',
      isDone: false,
      completedTime: null,
    ),
    _CleaningTask(
      id: 'task_4',
      time: '03:00 PM',
      label: 'Grooming',
      icon: Icons.content_cut_rounded,
      taskItems: [
        'Gentle brushing',
        'Check wound area',
        'Clean around bandage'
      ],
      emoji: '✂️',
      supervisorNote:
          'Use the soft bristle brush for gentle coat brushing. Do not brush near the surgical wound on the left hind leg. Inspect the area around the bandage — if you see any discharge, redness, or swelling, do not touch it and report to Dr. Sarah immediately.',
      isDone: false,
      completedTime: null,
    ),
    _CleaningTask(
      id: 'task_5',
      time: '06:00 PM',
      label: 'Evening Full Clean',
      icon: Icons.wb_twilight_rounded,
      taskItems: [
        'Full bedding change',
        'Sanitize bowls',
        'Mop surrounding floor'
      ],
      emoji: '🪣',
      supervisorNote:
          'This is the full evening cleaning. Replace all bedding with fresh material. Wash the food bowl and water bowl with warm soapy water, rinse thoroughly, and dry before placing back. Mop the floor around the cage with the disinfectant solution.',
      isDone: false,
      completedTime: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _progressController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  int get _doneCount => _cleaningTasks.where((t) => t.isDone).length;
  int get _totalCount => _cleaningTasks.length;
  double get _progress => _totalCount == 0 ? 0 : _doneCount / _totalCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 80.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    _buildProgressCard(),
                    SizedBox(height: 20.h),
                    _buildSectionHeader(),
                    SizedBox(height: 16.h),
                    ..._buildTimeline(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Sliver App Bar ─────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 210.h,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1E293B),
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16.w, top: 8.h, bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.cleaning_services_rounded,
                  size: 14.sp, color: Colors.white),
              SizedBox(width: 6.w),
              Text(
                '$_doneCount/$_totalCount Done',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background (Deep Slate to Teal)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E293B), Color(0xFF0F766E)],
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              right: -30.w,
              top: -20.h,
              child: Container(
                width: 150.w,
                height: 150.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              left: -30.w,
              bottom: 0,
              child: Container(
                width: 110.w,
                height: 110.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            // Title
            Positioned(
              left: 16.w,
              bottom: 125.h,
              child: Text(
                'Cleaning Updates',
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            // Patient row
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 20.h,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 28.r,
                      backgroundImage: const NetworkImage(
                        'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=200&q=80',
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Bella',
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF14B8A6).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                    color: const Color(0xFF14B8A6)
                                        .withOpacity(0.6)),
                              ),
                              child: Text(
                                'Cage 04',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF5EEAD4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            Icon(Icons.local_hospital_outlined,
                                size: 12.sp,
                                color: Colors.white.withOpacity(0.55)),
                            SizedBox(width: 4.w),
                            Text(
                              'Ward A  •  Post-Surgery Care',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 11.sp,
                                color: Colors.white.withOpacity(0.6),
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
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Progress Card ─────────────────────────

  Widget _buildProgressCard() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (_, __) => SizedBox(
              width: 80.w,
              height: 80.w,
              child: CustomPaint(
                painter: _CircleProgressPainter(
                  progress: _progressAnimation.value * _progress,
                  trackColor: Colors.white.withOpacity(0.12),
                  progressColor: const Color(0xFF2DD4BF),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_doneCount/$_totalCount',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      Text(
                        'tasks',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 9.sp,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cleaning Progress',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$_doneCount out of $_totalCount tasks completed for today',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
                SizedBox(height: 12.h),
                // Mini task pills
                Wrap(
                  spacing: 4.w,
                  runSpacing: 4.h,
                  children: List.generate(_totalCount, (i) {
                    final isCompleted = _cleaningTasks[i].isDone;
                    Color pillColor = isCompleted
                        ? const Color(0xFF2DD4BF)
                        : Colors.white.withOpacity(0.15);
                    return Container(
                      width: 16.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.r),
                        color: pillColor,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Section Header ─────────────────────────

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.history_rounded,
              size: 18.sp, color: const Color(0xFF1E293B)),
        ),
        SizedBox(width: 10.w),
        Text(
          'Today\'s Cleaning Schedule',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── Timeline Generation ─────────────────────────

  List<Widget> _buildTimeline() {
    List<Widget> timelineWidgets = [];
    bool foundActive = false;

    for (int i = 0; i < _cleaningTasks.length; i++) {
      final task = _cleaningTasks[i];

      if (task.isDone) {
        timelineWidgets.add(_buildCompletedTask(task));
      } else {
        if (!foundActive) {
          timelineWidgets.add(_buildActiveTask(task, i));
          foundActive = true;
        } else {
          timelineWidgets.add(_buildFutureTask(task));
        }
      }
    }

    return timelineWidgets;
  }

  // ───────────────────────── Completed Task ─────────────────────────

  Widget _buildCompletedTask(_CleaningTask task) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline node
        Column(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF34A853), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF34A853).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.check_rounded,
                  color: Colors.white, size: 16.sp),
            ),
            Container(
              width: 2.w,
              height: 180.h, // Adjusted height for content
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF34A853), Color(0xFFD1FAE5)],
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    task.label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34A853).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '✓ Done at ${task.completedTime}',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF34A853),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'Scheduled for ${task.time}',
                style: GoogleFonts.nunitoSans(
                  color: const Color(0xFF64748B),
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                      color: const Color(0xFF34A853).withOpacity(0.2),
                      width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.r),
                  child: Column(
                    children: [
                      // Left green accent bar logic via padding/decoration
                      Container(
                        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(7.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF34A853)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(task.emoji,
                                      style: TextStyle(fontSize: 13.sp)),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Wrap(
                                    spacing: 6.w,
                                    runSpacing: 6.h,
                                    children: task.taskItems.map((item) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(6.r),
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: Text(
                                          item,
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF475569),
                                          ),
                                        ),
                                      );
                                    }).toList(),
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
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────── Active Task ─────────────────────────

  Widget _buildActiveTask(_CleaningTask task, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.radio_button_checked_rounded,
                  color: Colors.white, size: 14.sp),
            ),
            Container(
              width: 2.w,
              height: 290.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF59E0B), Color(0xFFFEF3C7)],
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    task.label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.4)),
                    ),
                    child: Text(
                      '● In Progress',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'Scheduled for ${task.time}',
                style: GoogleFonts.nunitoSans(
                  color: const Color(0xFF64748B),
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                      color: const Color(0xFFF59E0B).withOpacity(0.35),
                      width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.r),
                  child: Column(
                    children: [
                      // Top amber accent
                      Container(
                        height: 4.h,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFF59E0B),
                              Color(0xFFFF6B35),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(task.emoji,
                                      style: TextStyle(fontSize: 14.sp)),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Wrap(
                                    spacing: 6.w,
                                    runSpacing: 6.h,
                                    children: task.taskItems.map((item) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFFBEB),
                                          borderRadius:
                                              BorderRadius.circular(6.r),
                                          border: Border.all(
                                            color: const Color(0xFFFDE68A),
                                          ),
                                        ),
                                        child: Text(
                                          item,
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF92400E),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Divider(color: Colors.grey[200]),
                            SizedBox(height: 12.h),
                            // Supervisor Notes inside Active Task
                            Row(
                              children: [
                                Icon(Icons.person_pin_rounded,
                                    size: 16.sp, color: const Color(0xFF0F766E)),
                                SizedBox(width: 6.w),
                                Text(
                                  'Supervisor\'s Instructions',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F766E),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FAFA),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                    color: const Color(0xFFD6F0ED)),
                              ),
                              child: Text(
                                task.supervisorNote,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF334155),
                                  height: 1.5,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    TextToSpeechPlayer(text: task.supervisorNote),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Listen',
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _cleaningTasks[index].isDone = true;
                                      final now = TimeOfDay.now();
                                      final hour = now.hourOfPeriod == 0
                                          ? 12
                                          : now.hourOfPeriod;
                                      final minute = now.minute
                                          .toString()
                                          .padLeft(2, '0');
                                      final period = now.period == DayPeriod.am
                                          ? 'AM'
                                          : 'PM';
                                      _cleaningTasks[index].completedTime =
                                          '$hour:$minute $period';
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle,
                                                color: Colors.white, size: 18),
                                            SizedBox(width: 8.w),
                                            Text('${task.label} completed'),
                                          ],
                                        ),
                                        backgroundColor:
                                            const Color(0xFF34A853),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.r)),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 8.h),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [
                                        Color(0xFFF59E0B),
                                        Color(0xFFFF6B35),
                                      ]),
                                      borderRadius: BorderRadius.circular(20.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFF59E0B)
                                              .withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_rounded,
                                            size: 16.sp, color: Colors.white),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'Mark Done',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w700,
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
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────── Future Task ─────────────────────────

  Widget _buildFutureTask(_CleaningTask task) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[350]!, width: 2),
              ),
              child: Icon(Icons.schedule_rounded,
                  color: Colors.grey[400], size: 15.sp),
            ),
            Container(
              width: 2.w,
              height: 80.h,
              color: Colors.grey[200],
            ),
          ],
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    task.label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'Scheduled for ${task.time}',
                style: GoogleFonts.nunitoSans(
                    color: Colors.grey[400], fontSize: 13.sp),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(task.icon, color: Colors.grey[350], size: 18.sp),
                    SizedBox(width: 10.w),
                    Text(
                      'Pending execution',
                      style: GoogleFonts.nunitoSans(
                        color: Colors.grey[400],
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Circle Progress Painter ─────────────────────────

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  const _CircleProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter old) =>
      old.progress != progress;
}

// ───────────────────────── Data Model ─────────────────────────

class _CleaningTask {
  final String id;
  final String time;
  final String label;
  final IconData icon;
  final List<String> taskItems;
  final String emoji;
  final String supervisorNote;
  bool isDone;
  String? completedTime;

  _CleaningTask({
    required this.id,
    required this.time,
    required this.label,
    required this.icon,
    required this.taskItems,
    required this.emoji,
    required this.supervisorNote,
    required this.isDone,
    this.completedTime,
  });
}
