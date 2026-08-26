import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TreatmentTimelineScreen extends StatefulWidget {
  const TreatmentTimelineScreen({super.key});

  @override
  State<TreatmentTimelineScreen> createState() =>
      _TreatmentTimelineScreenState();
}

class _TreatmentTimelineScreenState extends State<TreatmentTimelineScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  // Track which active tasks are logged
  final Map<String, bool> _loggedTasks = {};

  static const int _totalDays = 14;
  static const int _completedDays = 2;
  static const int _currentDay = 3;

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

  double get _recoveryProgress => _completedDays / _totalDays;

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

                    // Day 1 – Completed
                    _buildCompletedDay(
                      day: 'Day 1',
                      date: 'Oct 24',
                      tasks: const [
                        _TaskData(
                          icon: Icons.vaccines_rounded,
                          label: 'IV Fluids & Antibiotics',
                          emoji: '💉',
                        ),
                        _TaskData(
                          icon: Icons.restaurant_rounded,
                          label: 'Special Diet Feeding',
                          emoji: '🍽️',
                        ),
                      ],
                      photoUrl:
                          'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=600&q=80',
                      photoLabel: 'Progress Photo — Arrival',
                    ),

                    // Day 2 – Completed
                    _buildCompletedDay(
                      day: 'Day 2',
                      date: 'Oct 25',
                      tasks: const [
                        _TaskData(
                          icon: Icons.medication_rounded,
                          label: 'Morning Meds',
                          emoji: '💊',
                        ),
                        _TaskData(
                          icon: Icons.medical_services_rounded,
                          label: 'Doctor Check-up',
                          emoji: '🩺',
                        ),
                        _TaskData(
                          icon: Icons.healing_rounded,
                          label: 'Dressing Change',
                          emoji: '🩹',
                        ),
                      ],
                    ),

                    // Day 3 – Active (Today)
                    _buildActiveDay(
                      day: 'Day 3 (Today)',
                      date: 'Oct 26',
                      tasks: [
                        _ActiveTaskData(
                          key: 'midday_med',
                          icon: Icons.access_time_rounded,
                          label: 'Mid-day Medication',
                          time: 'Due by 2:00 PM',
                          emoji: '💊',
                        ),
                        _ActiveTaskData(
                          key: 'afternoon_feed',
                          icon: Icons.restaurant_rounded,
                          label: 'Afternoon Feeding',
                          time: 'Due by 4:00 PM',
                          emoji: '🍽️',
                        ),
                        _ActiveTaskData(
                          key: 'blood_test',
                          icon: Icons.science_rounded,
                          label: 'Blood Test Panel',
                          time: 'Scheduled for 5:30 PM',
                          emoji: '🔬',
                        ),
                      ],
                    ),

                    // Day 4 – Future
                    _buildFutureDay(
                      day: 'Day 4',
                      date: 'Oct 27',
                      tasks: const ['Morning Meds', 'Wound Check'],
                    ),

                    // Missed Task
                    _buildMissedDay(),
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
              Icon(Icons.calendar_today_rounded,
                  size: 14.sp, color: Colors.white),
              SizedBox(width: 6.w),
              Text(
                'Day $_currentDay/$_totalDays',
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
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E293B), Color(0xFF065F46)],
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
                'Treatment Timeline',
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
                                color: const Color(0xFF34A853).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                    color: const Color(0xFF34A853)
                                        .withOpacity(0.6)),
                              ),
                              child: Text(
                                'Day 3 of 14',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF86EFAC),
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
                              'Tick Fever Recovery  •  Cage 04, Ward A',
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
          colors: [Color(0xFF065F46), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF065F46).withOpacity(0.4),
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
                  progress: _progressAnimation.value * _recoveryProgress,
                  trackColor: Colors.white.withOpacity(0.12),
                  progressColor: const Color(0xFF34D399),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_completedDays/$_totalDays',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      Text(
                        'days',
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
                  'Recovery Progress',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$_completedDays of $_totalDays treatment days completed',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
                SizedBox(height: 12.h),
                // Mini day pills
                Wrap(
                  spacing: 4.w,
                  runSpacing: 4.h,
                  children: List.generate(_totalDays, (i) {
                    Color pillColor;
                    if (i < _completedDays) {
                      pillColor = const Color(0xFF34D399);
                    } else if (i == _completedDays) {
                      pillColor = const Color(0xFFF59E0B);
                    } else {
                      pillColor = Colors.white.withOpacity(0.15);
                    }
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
          child: Icon(Icons.timeline_rounded,
              size: 18.sp, color: const Color(0xFF1E293B)),
        ),
        SizedBox(width: 10.w),
        Text(
          'Treatment Timeline',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── Completed Day ─────────────────────────

  Widget _buildCompletedDay({
    required String day,
    required String date,
    required List<_TaskData> tasks,
    String? photoUrl,
    String? photoLabel,
  }) {
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
              height: photoUrl != null ? 290.h : 160.h,
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
                    day,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '— $date',
                    style: GoogleFonts.nunitoSans(
                      color: const Color(0xFF64748B),
                      fontSize: 13.sp,
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
                      '✓ Done',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF34A853),
                      ),
                    ),
                  ),
                ],
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
                      // Left green accent bar
                      Container(
                        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                        child: Column(
                          children: tasks.map((t) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(7.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF34A853)
                                          .withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(t.emoji,
                                        style: TextStyle(fontSize: 13.sp)),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      t.label,
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF34A853)
                                          .withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      'Completed',
                                      style: GoogleFonts.nunitoSans(
                                        color: const Color(0xFF34A853),
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      if (photoUrl != null) ...[
                        Divider(
                            height: 1, color: const Color(0xFF34A853).withOpacity(0.1)),
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(18.r),
                                bottomRight: Radius.circular(18.r),
                              ),
                              child: Image.network(
                                photoUrl,
                                height: 120.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 120.h,
                                  color: const Color(0xFF34A853)
                                      .withOpacity(0.1),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.0),
                                      Colors.black.withOpacity(0.45),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 12.w,
                              bottom: 10.h,
                              child: Row(
                                children: [
                                  Icon(Icons.photo_camera_rounded,
                                      size: 14.sp, color: Colors.white),
                                  SizedBox(width: 6.w),
                                  Text(
                                    photoLabel ?? 'Progress Photo',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // ───────────────────────── Active Day ─────────────────────────

  Widget _buildActiveDay({
    required String day,
    required String date,
    required List<_ActiveTaskData> tasks,
  }) {
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
                    day,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '— $date',
                    style: GoogleFonts.nunitoSans(
                      color: const Color(0xFF64748B),
                      fontSize: 13.sp,
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
                      '● Today',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
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
                        padding: EdgeInsets.all(14.w),
                        child: Column(
                          children: tasks.map((t) {
                            final isLogged = _loggedTasks[t.key] == true;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 14.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: isLogged
                                          ? const Color(0xFF34A853)
                                              .withOpacity(0.1)
                                          : const Color(0xFFF59E0B)
                                              .withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(t.emoji,
                                        style: TextStyle(fontSize: 14.sp)),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.label,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.sp,
                                            color: isLogged
                                                ? const Color(0xFF34A853)
                                                : const Color(0xFF1E293B),
                                            decoration: isLogged
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          isLogged ? 'Logged ✓' : t.time,
                                          style: GoogleFonts.nunitoSans(
                                            color: isLogged
                                                ? const Color(0xFF34A853)
                                                : const Color(0xFF64748B),
                                            fontSize: 11.sp,
                                            fontWeight: isLogged
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _loggedTasks[t.key] =
                                            !isLogged;
                                      });
                                      if (!isLogged) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                    size: 18),
                                                SizedBox(width: 8.w),
                                                Text(
                                                    '${t.label} logged'),
                                              ],
                                            ),
                                            backgroundColor:
                                                const Color(0xFF34A853),
                                            behavior:
                                                SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.r)),
                                            duration: const Duration(
                                                seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14.w, vertical: 8.h),
                                      decoration: BoxDecoration(
                                        gradient: isLogged
                                            ? const LinearGradient(colors: [
                                                Color(0xFF34A853),
                                                Color(0xFF059669),
                                              ])
                                            : const LinearGradient(colors: [
                                                Color(0xFFF59E0B),
                                                Color(0xFFFF6B35),
                                              ]),
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isLogged
                                                    ? const Color(0xFF34A853)
                                                    : const Color(0xFFF59E0B))
                                                .withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        isLogged ? '✓ Done' : 'Log',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
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

  // ───────────────────────── Future Day ─────────────────────────

  Widget _buildFutureDay({
    required String day,
    required String date,
    required List<String> tasks,
  }) {
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
              height: 110.h,
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
                    day,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '— $date',
                    style: GoogleFonts.nunitoSans(
                        color: Colors.grey[400], fontSize: 13.sp),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: tasks.map((t) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Icon(Icons.medication_rounded,
                              color: Colors.grey[350], size: 18.sp),
                          SizedBox(width: 10.w),
                          Text(
                            t,
                            style: GoogleFonts.nunitoSans(
                              color: Colors.grey[400],
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────── Missed Task ─────────────────────────

  Widget _buildMissedDay() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(Icons.priority_high_rounded,
              color: Colors.white, size: 16.sp),
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
                    'Missed Task',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Action Required',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.25),
                      width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.r),
                  child: Column(
                    children: [
                      Container(
                        height: 4.h,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text('🧹',
                                  style: TextStyle(fontSize: 16.sp)),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Deep Clean Kennel',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                      color: const Color(0xFF7F1D1D),
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Was due yesterday — needs immediate action',
                                    style: GoogleFonts.nunitoSans(
                                      color: const Color(0xFFEF4444),
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFEF4444),
                                      Color(0xFFEC4899),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFEF4444)
                                          .withOpacity(0.35),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Resolve',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

// ───────────────────────── Data Models ─────────────────────────

class _TaskData {
  final IconData icon;
  final String label;
  final String emoji;

  const _TaskData({
    required this.icon,
    required this.label,
    required this.emoji,
  });
}

class _ActiveTaskData {
  final String key;
  final IconData icon;
  final String label;
  final String time;
  final String emoji;

  const _ActiveTaskData({
    required this.key,
    required this.icon,
    required this.label,
    required this.time,
    required this.emoji,
  });
}

