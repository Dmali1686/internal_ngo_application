import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/text_to_speech_player.dart';

class DietDashboardScreen extends StatefulWidget {
  const DietDashboardScreen({super.key});

  @override
  State<DietDashboardScreen> createState() => _DietDashboardScreenState();
}

class _DietDashboardScreenState extends State<DietDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  final List<_FeedingSlot> _feedingSlots = [
    _FeedingSlot(
      time: '08:00 AM',
      label: 'Morning Feed',
      icon: Icons.wb_sunny_rounded,
      color: const Color(0xFFF59E0B),
      gradient: [const Color(0xFFF59E0B), const Color(0xFFFF6B35)],
      foodItems: ['Boiled Chicken 200g', 'Rice 100g', 'Multivitamin'],
      foodEmojis: ['🍗', '🍚', '💊'],
      imageUrl:
          'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=600&q=80',
      doctorNote:
          'Give boiled chicken mixed with plain rice. Ensure the multivitamin tablet is crushed and mixed into the food. Patient should eat slowly. Check if the patient finishes the full portion. If appetite is low, report immediately.',
      isServed: false,
      servedTime: null,
    ),
    _FeedingSlot(
      time: '12:30 PM',
      label: 'Midday Feed',
      icon: Icons.wb_cloudy_rounded,
      color: const Color(0xFF3B82F6),
      gradient: [const Color(0xFF3B82F6), const Color(0xFF06B6D4)],
      foodItems: ['Curd 150g', 'Glucose Water 200ml'],
      foodEmojis: ['🥛', '💧'],
      imageUrl:
          'https://images.unsplash.com/photo-1571167529151-3516f3b1f67b?auto=format&fit=crop&w=600&q=80',
      doctorNote:
          'Serve fresh curd at room temperature, not cold from the fridge. Mix two spoons of glucose powder in 200ml lukewarm water. This helps with hydration and digestion after surgery. Make sure patient drinks the full glass of glucose water.',
      isServed: false,
      servedTime: null,
    ),
    _FeedingSlot(
      time: '05:00 PM',
      label: 'Evening Feed',
      icon: Icons.wb_twilight_rounded,
      color: const Color(0xFFEF4444),
      gradient: [const Color(0xFFEF4444), const Color(0xFFEC4899)],
      foodItems: ['Boiled Eggs ×2', 'Pumpkin Mash 150g', 'Calcium Syrup 5ml'],
      foodEmojis: ['🥚', '🎃', '🧴'],
      imageUrl:
          'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?auto=format&fit=crop&w=600&q=80',
      doctorNote:
          'Boil the eggs fully — no runny yolk. Mash the pumpkin well so it is easy to swallow. Give 5ml calcium syrup using the syringe after the meal. Do not mix the syrup into the food. Wait 10 minutes after feeding before giving the syrup.',
      isServed: false,
      servedTime: null,
    ),
    _FeedingSlot(
      time: '09:00 PM',
      label: 'Night Feed',
      icon: Icons.nightlight_round,
      color: const Color(0xFF8B5CF6),
      gradient: [const Color(0xFF8B5CF6), const Color(0xFF6366F1)],
      foodItems: ['Warm Milk 250ml', 'Honey 1 tsp'],
      foodEmojis: ['🥛', '🍯'],
      imageUrl:
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=600&q=80',
      doctorNote:
          'Give warm milk, not hot. Add one teaspoon of honey and stir well. This is the last meal of the day. After this, do not give any solid food. Keep fresh water available in the cage for the night.',
      isServed: false,
      servedTime: null,
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
      duration: const Duration(milliseconds: 1200),
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

  int get _servedCount => _feedingSlots.where((s) => s.isServed).length;
  double get _progress =>
      _feedingSlots.isEmpty ? 0.0 : _servedCount / _feedingSlots.length;

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
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    _buildProgressCard(),
                    SizedBox(height: 16.h),
                    _buildInfoCard(),
                    SizedBox(height: 24.h),
                    _buildSectionHeader(),
                    SizedBox(height: 14.h),
                    ...List.generate(_feedingSlots.length, (i) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: _buildFeedingCard(i),
                      );
                    }),
                    _buildSpecialInstructions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────── Sliver App Bar ────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.h,
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
              Icon(Icons.restaurant, size: 16.sp, color: Colors.white),
              SizedBox(width: 6.w),
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (_, __) => Text(
                  '$_servedCount/${_feedingSlots.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
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
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E293B), Color(0xFF0F4C81)],
                ),
              ),
            ),
            Positioned(
              right: -30.w,
              top: -20.h,
              child: Container(
                width: 140.w,
                height: 140.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              left: -20.w,
              bottom: 10.h,
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
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
                                color:
                                    const Color(0xFF34A853).withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                    color: const Color(0xFF34A853)
                                        .withOpacity(0.5)),
                              ),
                              child: Text(
                                'Day 3',
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
                        Text(
                          '#PT-2938  •  Cage 04, Ward A',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12.sp,
                            color: Colors.white.withOpacity(0.65),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            Icon(Icons.local_hospital_outlined,
                                size: 12.sp,
                                color: Colors.white.withOpacity(0.55)),
                            SizedBox(width: 4.w),
                            Text(
                              'Post-Surgery Recovery Diet',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 11.sp,
                                color: Colors.white.withOpacity(0.55),
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
            Positioned(
              left: 16.w,
              bottom: 118.h,
              child: Text(
                'Food Updates',
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────── Progress Card ────────────────────────────

  Widget _buildProgressCard() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F4C81), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C81).withOpacity(0.35),
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
                  progressColor: const Color(0xFFF59E0B),
                ),
                child: Center(
                  child: Text(
                    '$_servedCount/${_feedingSlots.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
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
                  'Feeding Progress',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$_servedCount of ${_feedingSlots.length} meals served today',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 6.w,
                  children: _feedingSlots.map((slot) {
                    return Container(
                      width: 28.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color: slot.isServed
                            ? const Color(0xFF34A853)
                            : Colors.white.withOpacity(0.2),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────── Info Card ────────────────────────────

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.info_outline,
                size: 18.sp, color: const Color(0xFF3B82F6)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How it works',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'The doctor has described each meal below. Tap the 🔊 Listen button to hear instructions. After serving the food, mark the checkbox to confirm delivery.',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────── Section Header ────────────────────────────

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.textMain.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.schedule_rounded,
              size: 18.sp, color: AppColors.textMain),
        ),
        SizedBox(width: 10.w),
        Text(
          "Today's Feeding Schedule",
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────── Feeding Card ────────────────────────────

  Widget _buildFeedingCard(int index) {
    final slot = _feedingSlots[index];
    final isServed = slot.isServed;
    final gradStart = slot.gradient[0];
    final gradEnd = slot.gradient[1];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: isServed
            ? Border.all(
                color: const Color(0xFF34A853).withOpacity(0.4), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: isServed
                ? const Color(0xFF34A853).withOpacity(0.1)
                : Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(
          children: [
            // ── Image Banner ──
            Stack(
              children: [
                SizedBox(
                  height: 120.h,
                  width: double.infinity,
                  child: Image.network(
                    slot.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient:
                            LinearGradient(colors: [gradStart, gradEnd]),
                      ),
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
                          gradStart.withOpacity(0.25),
                          gradStart.withOpacity(0.88),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isServed)
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFF34A853).withOpacity(0.6),
                      child: Center(
                        child: Icon(Icons.check_circle_rounded,
                            size: 48.sp, color: Colors.white),
                      ),
                    ),
                  ),
                Positioned(
                  left: 14.w,
                  right: 14.w,
                  bottom: 12.h,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1.5),
                        ),
                        child: Icon(slot.icon,
                            size: 18.sp, color: Colors.white),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slot.label,
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 11.sp,
                                    color: Colors.white.withOpacity(0.75)),
                                SizedBox(width: 3.w),
                                Text(
                                  'Scheduled: ${slot.time}',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 11.sp,
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: isServed
                              ? const Color(0xFF34A853)
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isServed
                                  ? Icons.check_circle
                                  : Icons.pending_outlined,
                              size: 12.sp,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              isServed ? 'Served' : 'Pending',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [gradStart, gradEnd],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Food item chips ──
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lunch_dining_rounded,
                          size: 14.sp, color: slot.color),
                      SizedBox(width: 6.w),
                      Text(
                        'Meal Items',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: slot.color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: List.generate(slot.foodItems.length, (i) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: slot.color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                              color: slot.color.withOpacity(0.2), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(slot.foodEmojis[i],
                                style: TextStyle(fontSize: 14.sp)),
                            SizedBox(width: 6.w),
                            Text(
                              slot.foodItems[i],
                              style: GoogleFonts.nunitoSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMain,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // ── Doctor's Instructions ──
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.medical_services_rounded,
                            size: 13.sp,
                            color: const Color(0xFF3B82F6)),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Doctor's Instructions",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                          color: const Color(0xFF3B82F6).withOpacity(0.12)),
                    ),
                    child: Text(
                      slot.doctorNote,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        color: AppColors.textMain,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Listen row ──
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
              child: Row(
                children: [
                  TextToSpeechPlayer(text: slot.doctorNote),
                  SizedBox(width: 8.w),
                  Text(
                    'Listen to instructions',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // ── Served timestamp ──
            if (isServed && slot.servedTime != null)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34A853).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                        color: const Color(0xFF34A853).withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 15.sp,
                          color: const Color(0xFF34A853)),
                      SizedBox(width: 8.w),
                      Text(
                        'Served at ${slot.servedTime}',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E8B57),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Divider ──
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Divider(height: 1, color: Colors.grey.shade100),
            ),

            // ── Checkbox row ──
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 0, 16.w, 14.h),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 1.15,
                    child: Checkbox(
                      value: isServed,
                      onChanged: (val) {
                        setState(() {
                          _feedingSlots[index].isServed = val ?? false;
                          if (val == true) {
                            final now = TimeOfDay.now();
                            final hour = now.hourOfPeriod == 0
                                ? 12
                                : now.hourOfPeriod;
                            final minute =
                                now.minute.toString().padLeft(2, '0');
                            final period =
                                now.period == DayPeriod.am ? 'AM' : 'PM';
                            _feedingSlots[index].servedTime =
                                '$hour:$minute $period';
                          } else {
                            _feedingSlots[index].servedTime = null;
                          }
                        });
                        if (val == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8.w),
                                  Text('${slot.label} marked as served'),
                                ],
                              ),
                              backgroundColor: const Color(0xFF2E8B57),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      activeColor: const Color(0xFF34A853),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      isServed
                          ? '✅ Food has been served'
                          : 'Mark as served after delivering food',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 13.sp,
                        fontWeight:
                            isServed ? FontWeight.w700 : FontWeight.w500,
                        color: isServed
                            ? const Color(0xFF2E8B57)
                            : AppColors.textMuted,
                      ),
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

  // ──────────────────────────── Special Instructions ────────────────────────────

  Widget _buildSpecialInstructions() {
    final items = [
      _InstructionItem(
        icon: Icons.no_food_outlined,
        text: 'No spicy or oily food — patient is on post-surgery diet',
        color: const Color(0xFFEF4444),
      ),
      _InstructionItem(
        icon: Icons.water_drop_outlined,
        text: 'Ensure fresh drinking water is available at all times',
        color: const Color(0xFF3B82F6),
      ),
      _InstructionItem(
        icon: Icons.notifications_active_outlined,
        text: 'If patient refuses to eat, inform Dr. Sarah immediately',
        color: const Color(0xFFF59E0B),
      ),
      _InstructionItem(
        icon: Icons.block_outlined,
        text: 'Do not give any food not listed in the schedule above',
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.warning_amber_rounded,
                    size: 18.sp, color: Colors.white),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Special Instructions',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  Text(
                    'Follow strictly — do not deviate',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(item.icon, size: 14.sp, color: item.color),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        item.text,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 13.sp,
                          color: AppColors.textMain,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          SizedBox(height: 4.h),
          TextToSpeechPlayer(
            text:
                'Special instructions. No spicy or oily food, patient is on post-surgery diet. Ensure fresh drinking water is available at all times. If patient refuses to eat, inform Doctor Sarah immediately. Do not give any food not listed in the schedule.',
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────── Circle Progress Painter ────────────────────────────

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _CircleProgressPainter({
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

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter old) => old.progress != progress;
}

// ──────────────────────────── Data Models ────────────────────────────

class _FeedingSlot {
  final String time;
  final String label;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final List<String> foodItems;
  final List<String> foodEmojis;
  final String imageUrl;
  final String doctorNote;
  bool isServed;
  String? servedTime;

  _FeedingSlot({
    required this.time,
    required this.label,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.foodItems,
    required this.foodEmojis,
    required this.imageUrl,
    required this.doctorNote,
    required this.isServed,
    this.servedTime,
  });
}

class _InstructionItem {
  final IconData icon;
  final String text;
  final Color color;
  const _InstructionItem(
      {required this.icon, required this.text, required this.color});
}
