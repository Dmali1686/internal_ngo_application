import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringController;
  late final Animation<double> _ringAnim;

  static const _performers = [
    {'name': 'Dr. Priya Sharma', 'role': 'Doctor', 'score': 98, 'tasks': 32, 'done': 31},
    {'name': 'Ravi Desai', 'role': 'Nurse', 'score': 95, 'tasks': 26, 'done': 25},
    {'name': 'Suresh Patil', 'role': 'Driver', 'score': 91, 'tasks': 20, 'done': 18},
    {'name': 'Meera Joshi', 'role': 'Nurse', 'score': 87, 'tasks': 22, 'done': 19},
    {'name': 'Arun Nair', 'role': 'Receptionist', 'score': 82, 'tasks': 15, 'done': 12},
  ];

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
    _ringController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _ringAnim = CurvedAnimation(parent: _ringController, curve: Curves.easeOut);
    _ringController.forward();
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      body: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180.h,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.w),
              onPressed: () => context.pop(),
            ),
            title: Text('Performance', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E293B), Color(0xFFEC4899)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Organizational Overview', style: GoogleFonts.nunitoSans(fontSize: 13.sp, color: Colors.white.withValues(alpha: 0.7))),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            _buildHeaderChip('5', 'Staff', Icons.people_rounded),
                            SizedBox(width: 10.w),
                            _buildHeaderChip('115', 'Total Tasks', Icons.task_rounded),
                            SizedBox(width: 10.w),
                            _buildHeaderChip('85%', 'Avg. Score', Icons.trending_up_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Org Ring Card ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E293B), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  // Ring
                  AnimatedBuilder(
                    animation: _ringAnim,
                    builder: (context, _) {
                      return SizedBox(
                        width: 100.w,
                        height: 100.w,
                        child: CustomPaint(
                          painter: _RingPainter(progress: _ringAnim.value * 0.85, color: AppColors.primaryGreen, strokeWidth: 9.w),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${(_ringAnim.value * 85).toStringAsFixed(0)}%', style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Colors.white)),
                                Text('Overall', style: GoogleFonts.nunitoSans(fontSize: 9.sp, color: Colors.white.withValues(alpha: 0.7))),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Org Performance', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                        SizedBox(height: 12.h),
                        _buildLegendDot('Task Completion', '92%', AppColors.primaryGreen),
                        SizedBox(height: 6.h),
                        _buildLegendDot('On-time Rate', '88%', AppColors.warningOrange),
                        SizedBox(height: 6.h),
                        _buildLegendDot('Attendance', '79%', const Color(0xFF6366F1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Key Metrics ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Key Metrics', style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard('Task Completion', '92%', Icons.task_alt_rounded, AppColors.primaryGreen)),
                      SizedBox(width: 10.w),
                      Expanded(child: _buildMetricCard('On-time Rate', '88%', Icons.timer_rounded, const Color(0xFF6366F1))),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard('Attendance', '79%', Icons.fingerprint_rounded, const Color(0xFFEC4899))),
                      SizedBox(width: 10.w),
                      Expanded(child: _buildMetricCard('Satisfaction', '4.5 / 5', Icons.star_rounded, AppColors.warningOrange)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Leaderboard ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
              child: Text('Top Performers', style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textMain)),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final p = _performers[index];
                final rank = index + 1;
                final roleColor = _roleColors[p['role']] ?? AppColors.primaryGreen;
                final score = p['score'] as int;
                final name = p['name'] as String;
                final initials = name.trim().split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').take(2).join();

                Color rankColor;
                if (rank == 1) {
                  rankColor = Colors.amber;
                } else if (rank == 2) {
                  rankColor = Colors.grey.shade400;
                } else if (rank == 3) {
                  rankColor = const Color(0xFFCD7F32);
                } else {
                  rankColor = AppColors.textMuted;
                }

                return Container(
                  margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: rank == 1 ? Colors.amber.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(color: (rank == 1 ? Colors.amber : Colors.black).withValues(alpha: 0.04), blurRadius: 10, offset: Offset(0, 3.h)),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Rank badge
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(color: rankColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: Center(
                          child: rank <= 3
                              ? Icon(Icons.emoji_events_rounded, size: 16.w, color: rankColor)
                              : Text('$rank', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w800, color: rankColor)),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      // Avatar
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [roleColor.withValues(alpha: 0.7), roleColor]),
                        ),
                        child: Center(child: Text(initials, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white))),
                      ),
                      SizedBox(width: 12.w),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textMain), maxLines: 1, overflow: TextOverflow.ellipsis),
                            SizedBox(height: 3.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5.r)),
                                  child: Text(p['role'] as String, style: GoogleFonts.nunitoSans(fontSize: 9.sp, fontWeight: FontWeight.w700, color: roleColor)),
                                ),
                                SizedBox(width: 6.w),
                                Text('${p['done']}/${p['tasks']} tasks', style: GoogleFonts.nunitoSans(fontSize: 10.sp, color: AppColors.textMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Score
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: score >= 90 ? AppColors.primaryGreen.withValues(alpha: 0.1) : AppColors.warningOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              '$score%',
                              style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w800, color: score >= 90 ? AppColors.primaryGreen : AppColors.warningOrange),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              childCount: _performers.length,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }

  Widget _buildHeaderChip(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
        child: Column(
          children: [
            Icon(icon, size: 14.w, color: Colors.white.withValues(alpha: 0.8)),
            SizedBox(height: 3.h),
            Text(value, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(label, style: GoogleFonts.nunitoSans(fontSize: 9.sp, color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(String label, String value, Color color) {
    return Row(
      children: [
        Container(width: 8.w, height: 8.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 8.w),
        Expanded(child: Text(label, style: GoogleFonts.nunitoSans(fontSize: 11.sp, color: Colors.white.withValues(alpha: 0.8)))),
        Text(value, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white)),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: Offset(0, 3.h))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
            child: Icon(icon, color: color, size: 20.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w800, color: AppColors.textMain)),
                Text(title, style: GoogleFonts.nunitoSans(fontSize: 10.sp, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Ring Painter ────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  const _RingPainter({required this.progress, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawCircle(center, radius, Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
