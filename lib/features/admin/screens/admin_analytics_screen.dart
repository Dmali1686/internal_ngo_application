import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../models/analytics_model.dart';
import '../models/employee_model.dart';
import '../services/admin_api_service.dart';

/// Super Admin — Analytics Dashboard.
///
/// Displays:
///  - Task KPI summary cards (Total / Completed / Pending / Overdue)
///  - Circular completion ring with percentage
///  - Role distribution horizontal bar chart
///  - Employee performance table
///  - Time period selector (Today / Week / Month)
class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final AdminApiService _api = AdminApiService();

  AdminAnalyticsModel? _data;
  bool _isLoading = true;
  String _period = 'week'; // today | week | month

  late final AnimationController _ringController;
  late final Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();
    AppLogger.lifecycle('AdminAnalyticsScreen', 'initState');
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _ringAnimation = CurvedAnimation(parent: _ringController, curve: Curves.easeOut);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data
  // ---------------------------------------------------------------------------

  Future<void> _loadAnalytics() async {
    AppLogger.info('AdminAnalyticsScreen', 'Loading analytics for period: $_period');
    setState(() => _isLoading = true);

    try {
      final response = await _api.getAnalytics(period: _period);
      if (response.success && response.data is Map<String, dynamic>) {
        setState(() => _data = AdminAnalyticsModel.fromJson(response.data as Map<String, dynamic>));
        AppLogger.info('AdminAnalyticsScreen', '✅ Analytics loaded');
      } else {
        // Fallback to mock data
        setState(() => _data = AdminAnalyticsModel.fallback());
        AppLogger.info('AdminAnalyticsScreen', '⚠️ Using fallback analytics data');
      }
    } catch (e, st) {
      AppLogger.error('AdminAnalyticsScreen', 'Error loading analytics: $e\n$st');
      setState(() => _data = AdminAnalyticsModel.fallback());
    } finally {
      setState(() => _isLoading = false);
      _ringController.forward(from: 0.0);
    }
  }

  void _onPeriodChanged(String period) {
    AppLogger.action('AdminAnalyticsScreen', 'Period changed to: $period');
    setState(() => _period = period);
    _loadAnalytics();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    AppLogger.lifecycle('AdminAnalyticsScreen', 'build');
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          if (_isLoading)
            SliverFillRemaining(child: _buildLoadingState())
          else if (_data != null) ...[
            SliverToBoxAdapter(child: _buildPeriodSelector()),
            SliverToBoxAdapter(child: _buildKpiCards()),
            SliverToBoxAdapter(child: _buildCompletionRing()),
            SliverToBoxAdapter(child: _buildRoleDistributionChart()),
            SliverToBoxAdapter(child: _buildEmployeePerformanceTable()),
            SliverToBoxAdapter(child: SizedBox(height: 32.h)),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sliver app bar header
  // ---------------------------------------------------------------------------

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 160.h,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1E293B),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.w),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 22.w),
          onPressed: _loadAnalytics,
          tooltip: 'Refresh',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFF6366F1)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.analytics_rounded, color: Colors.white, size: 22.w),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Analytics', style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('Operational Overview', style: GoogleFonts.nunitoSans(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.7))),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  if (_data != null)
                    Text(
                      '${_data!.totalEmployees} employees · ${_data!.activeEmployees} active',
                      style: GoogleFonts.nunitoSans(fontSize: 13.sp, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Period selector
  // ---------------------------------------------------------------------------

  Widget _buildPeriodSelector() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            _buildPeriodTab('today', 'Today'),
            _buildPeriodTab('week', 'This Week'),
            _buildPeriodTab('month', 'This Month'),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(String value, String label) {
    final isSelected = _period == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onPeriodChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
            borderRadius: BorderRadius.circular(9.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // KPI cards
  // ---------------------------------------------------------------------------

  Widget _buildKpiCards() {
    final d = _data!;
    final kpis = [
      _KpiItem('Total Tasks', d.totalTasks.toString(), Icons.assignment_rounded, const Color(0xFF6366F1), 'All assigned'),
      _KpiItem('Completed', d.completedTasks.toString(), Icons.check_circle_rounded, AppColors.primaryGreen, '${(d.completionRate * 100).toStringAsFixed(0)}% done'),
      _KpiItem('Pending', d.pendingTasks.toString(), Icons.pending_rounded, AppColors.warningOrange, 'In progress'),
      _KpiItem('Overdue', d.overdueTasks.toString(), Icons.warning_rounded, AppColors.warningRed, 'Needs attention'),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 1.8,
        ),
        itemCount: kpis.length,
        itemBuilder: (_, i) => _buildKpiCard(kpis[i]),
      ),
    );
  }

  Widget _buildKpiCard(_KpiItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: Offset(0, 3.h))],
      ),
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(item.icon, size: 20.w, color: item.color),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.value, style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w800, color: AppColors.textMain, height: 1.1)),
                Text(item.label, style: GoogleFonts.nunitoSans(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                Text(item.sub, style: GoogleFonts.nunitoSans(fontSize: 9.sp, color: item.color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Completion ring
  // ---------------------------------------------------------------------------

  Widget _buildCompletionRing() {
    final d = _data!;
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F766E)],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          // Ring
          AnimatedBuilder(
            animation: _ringAnimation,
            builder: (context, _) {
              return SizedBox(
                width: 110.w,
                height: 110.w,
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: _ringAnimation.value * d.completionRate,
                    completedColor: AppColors.primaryGreen,
                    trackColor: Colors.white.withValues(alpha: 0.15),
                    strokeWidth: 10.w,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(_ringAnimation.value * d.completionRate * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        Text('Done', style: GoogleFonts.nunitoSans(fontSize: 10.sp, color: Colors.white.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 24.w),
          // Legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Task Completion', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                SizedBox(height: 4.h),
                Text('Overview for selected period', style: GoogleFonts.nunitoSans(fontSize: 11.sp, color: Colors.white.withValues(alpha: 0.65))),
                SizedBox(height: 14.h),
                _buildLegendRow('Completed', d.completedTasks, AppColors.primaryGreen),
                SizedBox(height: 8.h),
                _buildLegendRow('Pending', d.pendingTasks, AppColors.warningOrange),
                SizedBox(height: 8.h),
                _buildLegendRow('Overdue', d.overdueTasks, AppColors.warningRed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String label, int count, Color color) {
    return Row(
      children: [
        Container(width: 10.w, height: 10.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 8.w),
        Text(label, style: GoogleFonts.nunitoSans(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.8))),
        const Spacer(),
        Text('$count', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Role distribution horizontal bar chart
  // ---------------------------------------------------------------------------

  static const Map<String, Color> _roleBarColors = {
    'doctor': Color(0xFF6366F1),
    'nurse': Color(0xFFEC4899),
    'caretaker': Color(0xFF14B8A6),
    'driver': Color(0xFFF97316),
    'receptionist': Color(0xFF8B5CF6),
  };

  Widget _buildRoleDistributionChart() {
    final d = _data!;
    final total = d.roleDistribution.values.fold(0, (a, b) => a + b);

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: Offset(0, 3.h))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: const Color(0xFF6366F1), size: 20.w),
              SizedBox(width: 8.w),
              Text('Role Distribution', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const Spacer(),
              Text('$total total', style: GoogleFonts.nunitoSans(fontSize: 11.sp, color: AppColors.textMuted)),
            ],
          ),
          SizedBox(height: 16.h),
          ...d.roleDistribution.entries.map((entry) {
            final color = _roleBarColors[entry.key] ?? AppColors.primaryGreen;
            final pct = total == 0 ? 0.0 : entry.value / total;
            final label = EmployeeModel(id: '', name: '', email: '', phone: '', role: entry.key, status: '').roleLabel;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(label, style: GoogleFonts.nunitoSans(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                      ),
                      Text('${entry.value}  ${(pct * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.nunitoSans(fontSize: 11.sp, color: AppColors.textMuted)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: pct),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 8.h,
                          backgroundColor: color.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation(color),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Employee performance table
  // ---------------------------------------------------------------------------

  Widget _buildEmployeePerformanceTable() {
    final stats = _data!.employeeStats;
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: Offset(0, 3.h))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 0),
            child: Row(
              children: [
                Icon(Icons.leaderboard_rounded, color: AppColors.primaryGreen, size: 20.w),
                SizedBox(width: 8.w),
                Text('Employee Performance', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // Table header
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.backgroundLightGray,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Employee', style: GoogleFonts.nunitoSans(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted))),
                Expanded(child: Text('Assigned', textAlign: TextAlign.center, style: GoogleFonts.nunitoSans(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted))),
                Expanded(child: Text('Done', textAlign: TextAlign.center, style: GoogleFonts.nunitoSans(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted))),
                Expanded(child: Text('Rate', textAlign: TextAlign.center, style: GoogleFonts.nunitoSans(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted))),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          // Rows
          ...stats.map((stat) => _buildPerformanceRow(stat)),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow(EmployeeStatModel stat) {
    final pct = stat.completionRate;
    final color = pct >= 0.75 ? AppColors.primaryGreen : pct >= 0.5 ? AppColors.warningOrange : AppColors.warningRed;
    final roleColor = _roleBarColors[stat.role] ?? AppColors.primaryGreen;

    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 2.h, 12.w, 2.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14.r,
                  backgroundColor: roleColor.withValues(alpha: 0.15),
                  child: Text(
                    stat.name.isNotEmpty ? stat.name[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w700, color: roleColor),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    stat.name,
                    style: GoogleFonts.nunitoSans(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textMain),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Text('${stat.assigned}', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.textMain))),
          Expanded(child: Text('${stat.completed}', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.primaryGreen))),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6.r)),
              alignment: Alignment.center,
              child: Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w800, color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading state
  // ---------------------------------------------------------------------------

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 3.w),
          SizedBox(height: 16.h),
          Text('Loading analytics...', style: GoogleFonts.nunitoSans(fontSize: 14.sp, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// KPI item data holder
// ---------------------------------------------------------------------------

class _KpiItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String sub;

  const _KpiItem(this.label, this.value, this.icon, this.color, this.sub);
}

// ---------------------------------------------------------------------------
// Custom ring painter
// ---------------------------------------------------------------------------

class _RingPainter extends CustomPainter {
  final double progress;   // 0.0 – 1.0
  final Color completedColor;
  final Color trackColor;
  final double strokeWidth;

  const _RingPainter({
    required this.progress,
    required this.completedColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    const fullSweep = 2 * math.pi;

    // Track (background ring)
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        fullSweep * progress,
        false,
        Paint()
          ..color = completedColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
