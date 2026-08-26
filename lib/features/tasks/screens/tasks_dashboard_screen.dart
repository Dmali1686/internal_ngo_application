import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class TasksDashboardScreen extends StatefulWidget {
  const TasksDashboardScreen({super.key});

  @override
  State<TasksDashboardScreen> createState() => _TasksDashboardScreenState();
}

class _TasksDashboardScreenState extends State<TasksDashboardScreen> {
  int _selectedFilter = 0;
  static const Color _primary = Color(0xFF1E293B);
  static const Color _accent = Color(0xFF0F766E);

  final List<String> _filters = [
    'All', 'High Priority', 'Emergency', 'Today', 'Overdue',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildWelcomeCard()),
            SliverToBoxAdapter(child: _buildStatsRow()),
            SliverToBoxAdapter(child: _buildFilters()),
            SliverToBoxAdapter(child: _buildSectionHeader()),
            SliverToBoxAdapter(child: _buildTaskTimeline()),
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }

  // ─── Header ───

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _accent, width: 2.w),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://randomuser.me/api/portraits/men/32.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NGO Tasks',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                    ),
                  ),
                  Text(
                    'East Side Clinic',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.analytics_outlined, color: _accent, size: 22.sp),
          ),
        ],
      ),
    );
  }

  // ─── Welcome Card ───

  Widget _buildWelcomeCard() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F766E)],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning,',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  'Dr. Rahul 👋',
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFFBBF24), size: 14),
                          SizedBox(width: 4.w),
                          Text(
                            '6 critical tasks pending',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFBBF24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          // Circular progress
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 72.w,
                height: 72.w,
                child: CircularProgressIndicator(
                  value: 0.78,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF2DD4BF),
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '78%',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '14/18',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 9.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Stats Row ───

  Widget _buildStatsRow() {
    final stats = [
      ['18', 'Total', Icons.list_alt_rounded, const Color(0xFF3B82F6)],
      ['06', 'Pending', Icons.pending_actions_rounded, const Color(0xFFF59E0B)],
      ['04', 'Active', Icons.autorenew_rounded, const Color(0xFF8B5CF6)],
      ['08', 'Done', Icons.task_alt_rounded, const Color(0xFF10B981)],
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Row(
        children: stats.map((s) {
          final color = s[3] as Color;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  right: s == stats.last ? 0 : 10.w),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(s[2] as IconData, color: color, size: 16.sp),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    s[0] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                    ),
                  ),
                  Text(
                    s[1] as String,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 10.sp,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Filters ───

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: SizedBox(
        height: 36.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: _filters.length,
          itemBuilder: (context, index) {
            final selected = _selectedFilter == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? _primary : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: selected
                        ? _primary
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: _primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  _filters[index],
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Section Header ───

  Widget _buildSectionHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 4.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.schedule_rounded, size: 16.sp, color: _primary),
          ),
          SizedBox(width: 10.w),
          Text(
            "Today's Schedule",
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Task Timeline ───

  Widget _buildTaskTimeline() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        children: [
          _buildTimeBlock(
            time: '09:00 AM',
            tag: 'MORNING ROUNDS',
            tasks: [
              _buildTaskCard(
                name: 'Bella',
                id: 'ANM-1024 • ICU',
                condition: 'Tick Fever',
                action: 'Medicine Due',
                timeStr: '10:30 AM',
                progress: 0.33,
                tagLabel: 'High Priority',
                tagColor: const Color(0xFFF59E0B),
                tagBg: const Color(0xFFFFFBEB),
                imgUrl:
                    'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&q=80&w=100&h=100',
              ),
              _buildTaskCard(
                name: 'Max',
                id: 'ANM-0982 • Ward B',
                condition: 'Post-Op Recovery',
                action: 'Surgical Checkup',
                timeStr: '09:45 AM',
                progress: 0.0,
                tagLabel: 'Routine',
                tagColor: const Color(0xFF3B82F6),
                tagBg: const Color(0xFFEFF6FF),
                imgUrl:
                    'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&q=80&w=100&h=100',
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _buildTimeBlock(
            time: '12:00 PM',
            tag: 'MIDDAY TREATMENTS',
            tasks: [
              _buildTaskCard(
                name: 'Luna',
                id: 'ANM-1105 • Emergency',
                condition: 'Severe Dehydration',
                action: 'IV Fluid Adjustment',
                timeStr: '12:15 PM',
                progress: 0.0,
                tagLabel: 'Urgent',
                tagColor: const Color(0xFFEF4444),
                tagBg: const Color(0xFFFEF2F2),
                imgUrl:
                    'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&q=80&w=100&h=100',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBlock({
    required String time,
    required String tag,
    required List<Widget> tasks,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 3.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: _accent,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...tasks.map((t) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: t,
            )),
      ],
    );
  }

  Widget _buildTaskCard({
    required String name,
    required String id,
    required String condition,
    required String action,
    required String timeStr,
    required double progress,
    required String tagLabel,
    required Color tagColor,
    required Color tagBg,
    required String imgUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: tagColor.withValues(alpha: 0.2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Column(
          children: [
            // Top accent bar
            Container(
              height: 3.5.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [tagColor, tagColor.withValues(alpha: 0.4)],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.network(
                          imgUrl,
                          width: 48.w,
                          height: 48.w,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48.w,
                            height: 48.w,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.pets, color: Colors.grey),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: _primary,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: tagBg,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                        color: tagColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    tagLabel,
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                      color: tagColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              id,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 11.sp,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Text(
                              condition,
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: tagColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.medical_services_outlined,
                              size: 14.sp, color: AppColors.textMuted),
                          SizedBox(width: 5.w),
                          Text(
                            action,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: _primary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 13.sp, color: AppColors.textMuted),
                          SizedBox(width: 4.w),
                          Text(
                            timeStr,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 11.sp,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (progress > 0) ...[
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5.h,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(tagColor),
                      ),
                    ),
                  ],
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 9.h),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_primary, _accent],
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Start Task',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.all(9.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.info_outline_rounded,
                            size: 18.sp, color: AppColors.textMuted),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.all(9.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.check_circle_outline_rounded,
                            size: 18.sp, color: const Color(0xFF16A34A)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
