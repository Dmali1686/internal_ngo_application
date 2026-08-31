import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../models/employee_detail_model.dart';
import '../providers/employee_detail_provider.dart';

/// Full-screen Employee Detail view.
class EmployeeDetailScreen extends StatefulWidget {
  final String departmentId;
  final String userId;
  final Color accentColor;
  final String? employeeName;

  const EmployeeDetailScreen({
    super.key,
    required this.departmentId,
    required this.userId,
    required this.accentColor,
    this.employeeName,
  });

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeDetailProvider>().load(
            departmentId: widget.departmentId,
            userId: widget.userId,
          );
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeDetailProvider>();

    if (provider.hasData && _fadeCtrl.status == AnimationStatus.dismissed) {
      _fadeCtrl.forward();
      _slideCtrl.forward();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, provider),
          SliverToBoxAdapter(child: _buildBody(provider)),
          SliverToBoxAdapter(child: SizedBox(height: 60.h)),
        ],
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context, EmployeeDetailProvider provider) {
    final name = provider.data?.fullName ?? widget.employeeName ?? 'Employee';
    final position = provider.data?.positionName ?? '';

    return SliverAppBar(
      pinned: true,
      expandedHeight: 190.h,
      backgroundColor: widget.accentColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16.w,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        Consumer<EmployeeDetailProvider>(
          builder: (_, p, __) => GestureDetector(
            onTap: p.isLoading
                ? null
                : () => p.refresh(
                      departmentId: widget.departmentId,
                      userId: widget.userId,
                    ),
            child: Container(
              margin: EdgeInsets.all(10.w),
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 18.w,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _buildHeroHeader(name, position, provider.data),
      ),
    );
  }

  Widget _buildHeroHeader(
    String name,
    String position,
    EmployeeDetailResponse? data,
  ) {
    final accent = widget.accentColor;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent,
            Color.lerp(accent, Colors.indigo.shade900, 0.35)!,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30.w,
            top: -20.h,
            child: Container(
              width: 160.w,
              height: 160.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            left: -40.w,
            bottom: 10.h,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 22.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + name row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Large avatar
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.35),
                              Colors.white.withOpacity(0.12),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 20.r,
                              offset: Offset(0, 8.h),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _initials(name),
                            style: GoogleFonts.inter(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (position.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.work_outline_rounded,
                                    size: 12.w,
                                    color: Colors.white.withOpacity(0.75),
                                  ),
                                  SizedBox(width: 4.w),
                                  Flexible(
                                    child: Text(
                                      position,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (data != null) ...[
                    SizedBox(height: 18.h),
                    // Badge row
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        if (data.isPrimary)
                          _HeroBadge(
                            label: 'Primary',
                            icon: Icons.star_rounded,
                            color: const Color(0xFFFBBF24),
                          ),
                        if (data.employeeCode.isNotEmpty)
                          _HeroBadge(
                            label: data.employeeCode,
                            icon: Icons.badge_outlined,
                          ),
                        if (data.accessCategory.isNotEmpty)
                          _HeroBadge(
                            label: data.accessCategory,
                            icon: Icons.shield_outlined,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody(EmployeeDetailProvider provider) {
    if (provider.isLoading) return _buildLoader();
    if (provider.error != null) return _buildError(provider);
    if (!provider.hasData) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: _buildContent(provider.data!),
      ),
    );
  }

  Widget _buildContent(EmployeeDetailResponse data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Contact card ─────────────────────────────────────────────────────
        Container(
          margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.12),
                blurRadius: 20.r,
                offset: Offset(0, 8.h),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card header strip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.06),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 15.w,
                        color: widget.accentColor,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Contact Information',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(18.w),
                child: Column(
                  children: [
                    _ContactRow(
                      icon: Icons.mail_outline_rounded,
                      label: 'Email',
                      value: data.email.isNotEmpty ? data.email : '—',
                      accent: widget.accentColor,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Divider(height: 1, color: const Color(0xFFF0F0F5)),
                    ),
                    _ContactRow(
                      icon: Icons.badge_outlined,
                      label: 'Employee Code',
                      value: data.employeeCode.isNotEmpty ? data.employeeCode : '—',
                      accent: widget.accentColor,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Divider(height: 1, color: const Color(0xFFF0F0F5)),
                    ),
                    _ContactRow(
                      icon: Icons.shield_outlined,
                      label: 'Access Category',
                      value: data.accessCategory.isNotEmpty ? data.accessCategory : '—',
                      accent: widget.accentColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Task Overview card ─────────────────────────────────────────────
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.05),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.bar_chart_rounded, size: 14.w, color: widget.accentColor),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Task Overview',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${data.taskSummary.totalTasks} Total',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: widget.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Stats grid
                Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _InlineStatTile(
                              label: 'Completed',
                              value: '${data.taskSummary.completedTasks}',
                              color: const Color(0xFF10B981),
                              icon: Icons.check_circle_outline_rounded,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _InlineStatTile(
                              label: 'In Progress',
                              value: '${data.taskSummary.inProgressTasks}',
                              color: const Color(0xFFF59E0B),
                              icon: Icons.timelapse_rounded,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            child: _InlineStatTile(
                              label: 'Pending',
                              value: '${data.taskSummary.pendingTasks}',
                              color: const Color(0xFF3B82F6),
                              icon: Icons.pending_actions_rounded,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _InlineStatTile(
                              label: 'Overdue',
                              value: '${data.taskSummary.overdueTasks}',
                              color: const Color(0xFFEF4444),
                              icon: Icons.warning_amber_rounded,
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

        // ── Progress card ─────────────────────────────────────────────────
        if (data.taskSummary.totalTasks > 0) ...[
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _buildProgressCard(data.taskSummary),
          ),
        ],

        // ── Tasks list ────────────────────────────────────────────────────
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionLabel(
                title: 'Assigned Tasks',
                icon: Icons.task_alt_rounded,
                accent: widget.accentColor,
              ),
              if (data.tasks.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${data.tasks.length}',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: widget.accentColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        if (data.tasks.isEmpty)
          _buildEmptyTasks()
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: data.tasks
                  .map((task) => _TaskCard(task: task, accent: widget.accentColor))
                  .toList(),
            ),
          ),
      ],
    );
  }


  // ── Progress Card ──────────────────────────────────────────────────────────

  Widget _buildProgressCard(EmployeeTaskSummary summary) {
    final total = summary.totalTasks;
    final completedPct = summary.completedTasks / total;
    final inProgressPct = summary.inProgressTasks / total;
    final overduePct = summary.overdueTasks / total;
    final pendingPct = (math.max(
            0,
            total -
                summary.completedTasks -
                summary.inProgressTasks -
                summary.overdueTasks)) /
        total;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Overview',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  summary.totalTasks > 0
                      ? '${((summary.completedTasks / summary.totalTasks) * 100).round()}% Done'
                      : '0% Done',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // Segmented bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: SizedBox(
              height: 12.h,
              child: Row(
                children: [
                  if (completedPct > 0)
                    Expanded(
                      flex: (completedPct * 100).round(),
                      child: Container(color: const Color(0xFF10B981)),
                    ),
                  if (inProgressPct > 0)
                    Expanded(
                      flex: (inProgressPct * 100).round(),
                      child: Container(color: const Color(0xFFF59E0B)),
                    ),
                  if (overduePct > 0)
                    Expanded(
                      flex: (overduePct * 100).round(),
                      child: Container(color: const Color(0xFFEF4444)),
                    ),
                  if (pendingPct > 0)
                    Expanded(
                      flex: (pendingPct * 100).round().clamp(1, 100),
                      child: Container(color: const Color(0xFFE2E8F0)),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 16.w,
            runSpacing: 8.h,
            children: [
              _Legend(color: const Color(0xFF10B981), label: 'Completed'),
              _Legend(color: const Color(0xFFF59E0B), label: 'In Progress'),
              _Legend(color: const Color(0xFFEF4444), label: 'Overdue'),
              _Legend(
                color: const Color(0xFFE2E8F0),
                label: 'Pending',
                textColor: AppColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTasks() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: widget.accentColor.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_outlined,
                size: 36.w,
                color: widget.accentColor.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'No tasks assigned yet',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Tasks will appear here once assigned',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return Padding(
      padding: EdgeInsets.only(top: 100.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40.w,
            height: 40.w,
            child: CircularProgressIndicator(
              color: widget.accentColor,
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Loading profile…',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(EmployeeDetailProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 80.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(22.w),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 38.w,
              color: const Color(0xFFEF4444),
            ),
          ),
          SizedBox(height: 22.h),
          Text(
            'Unable to load profile',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          SizedBox(height: 28.h),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.accentColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
            onPressed: () => provider.refresh(
              departmentId: widget.departmentId,
              userId: widget.userId,
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              'Try Again',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero badge
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;

  const _HeroBadge({required this.label, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11.w, color: color ?? Colors.white),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;

  const _SectionLabel({
    required this.title,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 14.w, color: accent),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contact row
// ─────────────────────────────────────────────────────────────────────────────

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(child: Icon(icon, size: 16.w, color: accent)),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat chip (horizontal scroll)
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Inline Stat Tile (used in the 2-column grid inside the Task Overview card)
// ─────────────────────────────────────────────────────────────────────────────

class _InlineStatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _InlineStatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 14.w, color: color),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: color.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat chip (horizontal scroll)
// ─────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      margin: EdgeInsets.only(right: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 13.w, color: color),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress legend
// ─────────────────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final Color? textColor;

  const _Legend({required this.color, required this.label, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: textColor ?? AppColors.textMain,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task Card
// ─────────────────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final EmployeeTask task;
  final Color accent;

  const _TaskCard({required this.task, required this.accent});

  Color get _statusColor {
    switch (task.status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'in_progress':
      case 'in progress':
        return const Color(0xFFF59E0B);
      case 'overdue':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Color get _priorityColor {
    switch (task.priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return AppColors.textMuted;
    }
  }

  IconData get _statusIcon {
    switch (task.status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'in_progress':
      case 'in progress':
        return Icons.timelapse_rounded;
      case 'overdue':
        return Icons.warning_amber_rounded;
      default:
        return Icons.pending_actions_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withOpacity(0.08),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // Colored left accent + content
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent bar
                Container(
                  width: 4.w,
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(18.r),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: icon + title + priority badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: _statusColor.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                _statusIcon,
                                size: 15.w,
                                color: _statusColor,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title.isNotEmpty ? task.title : '—',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textMain,
                                      height: 1.3,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    task.taskCode.isNotEmpty
                                        ? task.taskCode
                                        : task.taskType,
                                    style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            _PriorityBadge(
                              label: task.priority,
                              color: _priorityColor,
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        // Divider
                        Container(
                          height: 1,
                          color: const Color(0xFFF1F5F9),
                        ),
                        SizedBox(height: 10.h),
                        // Bottom meta row
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: _statusColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_statusIcon,
                                      size: 10.w, color: _statusColor),
                                  SizedBox(width: 3.w),
                                  Text(
                                    task.status.replaceAll('_', ' '),
                                    style: GoogleFonts.inter(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w600,
                                      color: _statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (task.dueDate.isNotEmpty) ...[
                              Icon(Icons.calendar_today_outlined,
                                  size: 11.w, color: AppColors.textMuted),
                              SizedBox(width: 4.w),
                              Text(
                                _formatDate(task.dueDate),
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (task.assignedBy.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(Icons.person_outline_rounded,
                                  size: 11.w, color: AppColors.textMuted),
                              SizedBox(width: 4.w),
                              Text(
                                'By ${task.assignedBy}',
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
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

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

class _PriorityBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _PriorityBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 8.sp,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
