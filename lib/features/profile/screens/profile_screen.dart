import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../auth/services/auth_api_service.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const Color _darkGreen = Color(0xFF166534);
  static const Color _teal = Color(0xFF0F766E);

  final AuthApiService _authService = AuthApiService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _fetchProfile();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    try {
      AppLogger.info('ProfileScreen', 'Fetching profile API...');
      final response = await _authService.getProfile();
      if (response.success && response.data is Map<String, dynamic>) {
        setState(() {
          _profileData = response.data as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.errorMessage ?? 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String get _name =>
      _isLoading ? 'Loading...' : (_profileData?['name'] ?? 'Unknown User');
  String get _role =>
      _isLoading ? '...' : (_profileData?['role'] ?? 'Staff');
  String get _userType =>
      _isLoading ? '...' : (_profileData?['user_type'] ?? 'Staff');
  String get _empId =>
      _isLoading
          ? 'EMP-...'
          : (_profileData?['employee_code'] ?? 'EMP-${_profileData?['id']?.toString().split('-').first ?? '0000'}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            _buildSliverHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    _buildStatsRow(),
                    SizedBox(height: 20.h),
                    _buildProgressSection(),
                    SizedBox(height: 20.h),
                    _buildSectionLabel('Quick Access'),
                    SizedBox(height: 14.h),
                    _buildQuickAccess(),
                    SizedBox(height: 20.h),
                    _buildSectionLabel('Account'),
                    SizedBox(height: 14.h),
                    _buildAccountActions(),
                    SizedBox(height: 20.h),
                    _buildAchievementBanner(),
                    SizedBox(height: 28.h),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 190.h,
      pinned: true,
      elevation: 0,
      backgroundColor: _darkGreen,
      automaticallyImplyLeading: false,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              onPressed: () {},
            ),
            Positioned(
              right: 8.w,
              top: 8.w,
              child: Container(
                width: 14.w,
                height: 14.w,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Center(
                  child: Text('5',
                      style: TextStyle(
                          color: Colors.white, fontSize: 7.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {},
        ),
        SizedBox(width: 8.w),
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
                  colors: [Color(0xFF14532D), Color(0xFF0F766E)],
                ),
              ),
            ),
            Positioned(
              right: -40.w,
              top: -30.h,
              child: Container(
                width: 180.w,
                height: 180.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              left: -50.w,
              bottom: 10.h,
              child: Container(
                width: 140.w,
                height: 140.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 24.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 36.r,
                      backgroundImage: const NetworkImage(
                        'https://randomuser.me/api/portraits/men/32.jpg',
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _name,
                                style: GoogleFonts.poppins(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Icon(Icons.verified_rounded,
                                color: const Color(0xFF4ADE80), size: 18.sp),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.pets,
                                color: Colors.white.withValues(alpha: 0.7), size: 13.sp),
                            SizedBox(width: 5.w),
                            Text(
                              _role,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 13.sp,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Icon(Icons.location_on_outlined,
                                color: Colors.white.withValues(alpha: 0.6), size: 13.sp),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                'East Side Clinic',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 13.sp,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 6.h,
                          children: [
                            _headerPill(_empId, Icons.badge_outlined, solid: true),
                            _headerPill(_userType, Icons.medical_services_outlined),
                            _headerPill('Active', Icons.circle,
                                iconColor: const Color(0xFF4ADE80)),
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

  Widget _headerPill(String label, IconData icon,
      {bool solid = false, Color? iconColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: solid ? Colors.white : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: solid ? null : Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 200.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12.sp,
              color: solid ? _darkGreen : (iconColor ?? Colors.white),
            ),
            SizedBox(width: 5.w),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: solid ? _darkGreen : Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      ['18', 'Tasks'],
      ['12', 'Done'],
      ['96%', 'Attend.'],
      ['4.9', 'Rating'],
    ];
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14532D), Color(0xFF0F766E)],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: List.generate(stats.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Container(
              width: 1,
              height: 40.h,
              color: Colors.white.withValues(alpha: 0.15),
            );
          }
          final s = stats[i ~/ 2];
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s[0],
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  s[1],
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                "Today's Progress",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'This Month',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.keyboard_arrow_down,
                        size: 16.w, color: AppColors.textMuted),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90.w,
                    height: 90.w,
                    child: CircularProgressIndicator(
                      value: 0.68,
                      strokeWidth: 8.w,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(_darkGreen),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '68%',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      Text(
                        'Done',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 10.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: SizedBox(
                  height: 110.h,
                  child: CustomPaint(
                    size: Size(double.infinity, 110.h),
                    painter: _ProgressLineChartPainter(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain,
      ),
    );
  }

  Widget _buildQuickAccess() {
    final items = [
      [Icons.assignment_outlined, 'My Tasks', _darkGreen],
      [Icons.calendar_today_outlined, 'Attendance', const Color(0xFF3B82F6)],
      [Icons.bar_chart_rounded, 'Reports', const Color(0xFFF97316)],
      [Icons.people_outline, 'My Team', _teal],
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) {
        final icon = item[0] as IconData;
        final label = item[1] as String;
        final color = item[2] as Color;
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54.w,
                height: 54.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: color.withValues(alpha: 0.15)),
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccountActions() {
    final actions = [
      [Icons.person_outline_rounded, 'Edit Profile'],
      [Icons.lock_outline_rounded, 'Change Password'],
      [Icons.notifications_outlined, 'Notifications'],
      [Icons.help_outline_rounded, 'Help & Support'],
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(actions.length, (i) {
          final a = actions[i];
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: _darkGreen.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(a[0] as IconData, color: _darkGreen, size: 20.sp),
                ),
                title: Text(
                  a[1] as String,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                trailing:
                    Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20.sp),
                onTap: () {},
              ),
              if (i < actions.length - 1)
                Divider(height: 1, indent: 60.w, color: Colors.grey.shade100),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAchievementBanner() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF14532D).withValues(alpha: 0.08),
            const Color(0xFF0F766E).withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _darkGreen.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Text('🏆', style: TextStyle(fontSize: 34.sp)),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Great Going!',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'You completed 12 tasks this week. Keep it up!',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: _darkGreen,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'View',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _authService.logout();
          context.go('/login');
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.white),
        label: Text(
          'Logout',
          style: GoogleFonts.nunitoSans(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class _ProgressLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const chartLeft = 28.0;
    final chartBottom = size.height - 18;
    final chartRight = size.width;
    const chartTop = 0.0;
    final chartHeight = chartBottom - chartTop;
    final chartWidth = chartRight - chartLeft;

    final yLabels = ['100%', '75%', '50%', '25%', '0%'];
    for (int i = 0; i < yLabels.length; i++) {
      final y = chartTop + (chartHeight / 4) * i;
      final tp = TextPainter(
        text: TextSpan(
          text: yLabels[i],
          style: GoogleFonts.nunitoSans(fontSize: 8, color: Colors.grey),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
      canvas.drawLine(
          Offset(chartLeft, y),
          Offset(chartRight, y),
          Paint()
            ..color = Colors.grey.withValues(alpha: 0.1)
            ..strokeWidth = 0.5);
    }

    final xLabels = ['06 May', '12 May', '18 May', '24 May'];
    for (int i = 0; i < xLabels.length; i++) {
      final x = chartLeft + (chartWidth / (xLabels.length - 1)) * i;
      final tp = TextPainter(
        text: TextSpan(
          text: xLabels[i],
          style: GoogleFonts.nunitoSans(fontSize: 8, color: Colors.grey),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartBottom + 3));
    }

    final dataPoints = [0.30, 0.55, 0.60, 0.50, 0.90];
    final points = <Offset>[];
    for (int i = 0; i < dataPoints.length; i++) {
      final x = chartLeft + (chartWidth / (dataPoints.length - 1)) * i;
      final y = chartBottom - (chartHeight * dataPoints[i]);
      points.add(Offset(x, y));
    }

    final fillPath = Path()..moveTo(points.first.dx, chartBottom);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, chartBottom);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF166534).withValues(alpha: 0.18),
            const Color(0xFF166534).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTRB(chartLeft, chartTop, chartRight, chartBottom)),
    );

    final linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFF166534)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    for (final p in points) {
      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      canvas.drawCircle(p, 3.5, Paint()..color = const Color(0xFF166534));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
