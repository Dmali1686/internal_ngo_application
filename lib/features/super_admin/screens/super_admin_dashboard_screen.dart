import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../models/super_admin_models.dart';
import '../providers/super_admin_provider.dart';
import '../../tasks/screens/admin_all_tasks_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'department_detail_screen.dart';
import 'create_employee_screen.dart';

/// Screen 1 — Super Admin Management Dashboard
class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch real departments when the dashboard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SuperAdminProvider>().loadDepartments();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuperAdminProvider>();
    final stats = provider.stats;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          // Tab 0 — Home Dashboard (background image + stats + dept grid)
          Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/backgound.png',
                  fit: BoxFit.cover,
                ),
              ),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    _buildStatsCard(stats),
                    _buildDepartmentsGrid(context, provider.departments),
                    SizedBox(height: 120.h),
                  ],
                ),
              ),
              Positioned(
                bottom: 20.h,
                left: 0,
                right: 0,
                child: _buildViewAllAnimalsCard(context),
              ),
            ],
          ),
          // Tab 1 — Create Employee
          const CreateEmployeeScreen(),
          // Tab 2 — All Tasks (SUP001 global view)
          const AdminAllTasksScreen(),
          // Tab 3 — Profile (reuse existing screen)
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.only(
        top: 60.h,
        left: 20.w,
        right: 20.w,
        bottom: 20.h,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Text padded right so it never overlaps the dog image
          Padding(
            padding: EdgeInsets.only(right: 150.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification + avatar row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Stack(
                      children: [
                        Icon(Icons.notifications_none, size: 28.w),
                        Positioned(
                          right: 2.w,
                          top: 2.h,
                          child: Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 15.w),
                    // Local fallback avatar (no network call)
                    CircleAvatar(
                      radius: 18.r,
                      backgroundColor: AppColors.primaryGreen,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20.w,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 22.h),
                Text(
                  'NGO',
                  style: GoogleFonts.poppins(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                    height: 1.0,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Super Admin',
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text(
                      'Management Dashboard ',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Icon(
                      Icons.waving_hand_rounded,
                      color: AppColors.primaryGreen,
                      size: 15.w,
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
          // Dog decorative image
          Positioned(
            right: 0.w,
            bottom: 0.h,
            child: Image.asset(
              'assets/images/dog_transparent.png',
              width: 140.w,
              height: 140.h,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => SizedBox(width: 140.w),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats card (floating white card same as StatCards widget) ──────────────
  Widget _buildStatsCard(SuperAdminStats stats) {
    final items = [
      _StatItem(
        title: 'Total\nEmployees',
        value: '${stats.totalEmployees}',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF2563EB),
      ),
      _StatItem(
        title: 'Total\nDepartments',
        value: '${stats.totalDepartments}',
        icon: Icons.account_tree_rounded,
        color: const Color(0xFF34A853),
      ),
      _StatItem(
        title: 'Active\nTasks',
        value: '${stats.activeTasks}',
        icon: Icons.task_alt_rounded,
        color: const Color(0xFFF59E0B),
      ),
      _StatItem(
        title: 'Completed\nTasks',
        value: '${stats.completedTasks}',
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Transform.translate(
        offset: Offset(0, -20.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
          child: Row(
            children: items.map((s) {
              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: s.color.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(s.icon, color: s.color, size: 24.w),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      s.value,
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      s.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ── View All Animals Card ──────────────────────────────────────────────────
  Widget _buildViewAllAnimalsCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F3EA),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.pets,
                  color: Colors.green[700],
                  size: 28.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'View all registered animals',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Search, filter & manage all animals',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to view all animals screen
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.nunitoSans(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_forward, color: AppColors.primaryGreen, size: 16.w),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ── Departments grid (Tab 0 home content) ──────────────────────────────────
  Widget _buildDepartmentsGrid(
      BuildContext context, List<DepartmentModel> departments) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Departments',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _currentNavIndex = 1),
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: AppColors.primaryGreen, size: 20.w),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14.w,
              mainAxisSpacing: 14.h,
              childAspectRatio: 0.78,  // tall enough for all content
            ),
            itemCount: departments.length,
            itemBuilder: (context, i) => _DepartmentCard(
              department: departments[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DepartmentDetailScreen(department: departments[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Departments tab (Tab 1 — full list) ────────────────────────────────────
  /*
  Widget _buildDepartmentsTab(
      BuildContext context, List<DepartmentModel> departments) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
            child: Text(
              'All Departments',
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
              physics: const BouncingScrollPhysics(),
              itemCount: departments.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, i) => _DepartmentListTile(
                department: departments[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DepartmentDetailScreen(department: departments[i]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  */

  // ── Bottom nav ─────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      _NavItem(icon: Icons.home, label: 'Dashboard'),
      _NavItem(icon: Icons.person_add_alt_1_rounded, label: 'Add User'),
      _NavItem(icon: Icons.task_alt_rounded, label: 'Tasks'),
      _NavItem(icon: Icons.person_outline, label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _currentNavIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _currentNavIndex = i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[i].icon,
                      color: selected ? const Color(0xFF2E8B57) : Colors.grey,
                      size: 24.w,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      items[i].label,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color:
                            selected ? const Color(0xFF2E8B57) : Colors.grey,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Department Card — 2-col grid, centered icon + text (ModulesGrid style)
// ─────────────────────────────────────────────────────────────────────────────

class _DepartmentCard extends StatefulWidget {
  final DepartmentModel department;
  final VoidCallback onTap;
  const _DepartmentCard({required this.department, required this.onTap});

  @override
  State<_DepartmentCard> createState() => _DepartmentCardState();
}

class _DepartmentCardState extends State<_DepartmentCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const Map<String, IconData> _icons = {
    'medical': Icons.medical_services_rounded,
    'transport': Icons.local_shipping_rounded,
    'food': Icons.restaurant_rounded,
    'social_media': Icons.campaign_rounded,
    'fundraising': Icons.volunteer_activism_rounded,
    'operations': Icons.settings_rounded,
  };

  static const Map<String, Color> _colors = {
    'medical': Color(0xFF2563EB),
    'transport': Color(0xFF10B981),
    'food': Color(0xFFF59E0B),
    'social_media': Color(0xFF8B5CF6),
    'fundraising': Color(0xFFEF4444),
    'operations': Color(0xFF06B6D4),
  };

  @override
  Widget build(BuildContext context) {
    final dept = widget.department;
    final icon = _icons[dept.iconKey] ?? Icons.business_rounded;
    final color = _colors[dept.iconKey] ?? AppColors.primaryGreen;

    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon container — use .w for width, .h for height
              Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, size: 28.sp, color: color),
              ),
              SizedBox(height: 8.h),
              Text(
                dept.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                '${dept.totalEmployees} Employees',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                '${dept.activeTasks} Active Tasks',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${dept.completionPct}% Done',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Department List Tile — used in Tab 1 (All Departments list)
// ─────────────────────────────────────────────────────────────────────────────
/*
class _DepartmentListTile extends StatelessWidget {
  final DepartmentModel department;
  final VoidCallback onTap;
  const _DepartmentListTile({required this.department, required this.onTap});

  static const Map<String, IconData> _icons = {
    'medical': Icons.medical_services_rounded,
    'transport': Icons.local_shipping_rounded,
    'food': Icons.restaurant_rounded,
    'social_media': Icons.campaign_rounded,
    'fundraising': Icons.volunteer_activism_rounded,
    'operations': Icons.settings_rounded,
  };

  static const Map<String, Color> _colors = {
    'medical': Color(0xFF2563EB),
    'transport': Color(0xFF10B981),
    'food': Color(0xFFF59E0B),
    'social_media': Color(0xFF8B5CF6),
    'fundraising': Color(0xFFEF4444),
    'operations': Color(0xFF06B6D4),
  };

  @override
  Widget build(BuildContext context) {
    final icon = _icons[department.iconKey] ?? Icons.business_rounded;
    final color = _colors[department.iconKey] ?? AppColors.primaryGreen;
    final pct = department.completionPct;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        padding: EdgeInsets.all(14.w),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: color, size: 26.w),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        department.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            '${department.totalEmployees} Employees',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 12.sp,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            '  •  ',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                          Text(
                            '${department.activeTasks} Active',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '$pct%',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(Icons.chevron_right, color: Colors.grey, size: 20.w),
              ],
            ),
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 5.h,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

// ─────────────────────────────────────────────────────────────────────────────
// Data holders
// ─────────────────────────────────────────────────────────────────────────────

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
