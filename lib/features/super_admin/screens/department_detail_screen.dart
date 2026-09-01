import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../org/models/department_org_model.dart';
import '../../org/providers/department_org_provider.dart';
import '../../org/providers/employee_detail_provider.dart';
import '../../org/screens/department_org_screen.dart';
import '../../org/screens/employee_detail_screen.dart';
import '../../tasks/providers/task_provider.dart';
import '../../tasks/screens/create_task_screen.dart';
import '../../tasks/screens/task_details_screen.dart';
import '../../users/models/user_model.dart';
import '../../users/services/user_api_service.dart';
import '../models/super_admin_models.dart';
import '../providers/super_admin_provider.dart';


/// Screen 2 — Department Detail
///
/// Shows department-level analytics, team members list (HOD first, from API),
/// and an active tasks overview with a progress bar.
class DepartmentDetailScreen extends StatefulWidget {
  final DepartmentModel department;

  const DepartmentDetailScreen({super.key, required this.department});

  @override
  State<DepartmentDetailScreen> createState() => _DepartmentDetailScreenState();
}

class _DepartmentDetailScreenState extends State<DepartmentDetailScreen> {
  late final DepartmentOrgProvider _orgProvider;
  final UserApiService _userApiService = UserApiService();

  List<UserModel> _allUsers = [];
  bool _isLoadingUsers = false;

  static final Map<String, IconData> _icons = {
    'medical': Icons.medical_services_rounded,
    'transport': Icons.local_shipping_rounded,
    'food': Icons.restaurant_rounded,
    'social_media': Icons.campaign_rounded,
    'fundraising': Icons.volunteer_activism_rounded,
    'operations': Icons.settings_rounded,
  };

  static final Map<String, Color> _colors = {
    'medical': Color(0xFF2563EB),
    'transport': Color(0xFF10B981),
    'food': Color(0xFFF59E0B),
    'social_media': Color(0xFF8B5CF6),
    'fundraising': Color(0xFFEF4444),
    'operations': Color(0xFF06B6D4),
  };

  @override
  void initState() {
    super.initState();
    _orgProvider = DepartmentOrgProvider();
    _orgProvider.load(widget.department.id);
    _loadAllUsers();
    
    // Fetch tasks for this department
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchDepartmentTasks(widget.department.id);
    });
  }

  Future<void> _loadAllUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      // Super Admin can fetch all users
      final users = await _userApiService.getAllUsers();
      if (mounted) setState(() => _allUsers = users);
    } catch (_) {
      // If unauthorized (Admin), fallback to fetching unassigned users
      try {
        final unassigned = await _userApiService.getUnassignedUsers();
        if (mounted) setState(() => _allUsers = unassigned);
      } catch (_) {}
    } finally {
      if (mounted) setState(() => _isLoadingUsers = false);
    }
  }

  @override
  void dispose() {
    _orgProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuperAdminProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final departmentTasks = taskProvider.getTasksForDepartment(widget.department.id);
    final color = _colors[widget.department.iconKey] ?? AppColors.primaryBlue;
    final icon = _icons[widget.department.iconKey] ?? Icons.business_rounded;

    return Scaffold(
      backgroundColor: AppColors.backgroundSurface,
      floatingActionButton: !provider.isEmployee ? FloatingActionButton.extended(
        backgroundColor: color,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateTaskScreen(initialDepartmentId: widget.department.id),
            ),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Create Task', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
      ) : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ───────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            pinned: true,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16.w,
                  color: AppColors.textMain,
                ),
              ),
            ),
            title: Text(
              widget.department.name,
              style: GoogleFonts.inter(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            centerTitle: true,
            actions: [
              Container(
                margin: EdgeInsets.all(10.w),
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.settings_outlined,
                  size: 18.w,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          // ── Analytics Banner ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: _buildAnalyticsBanner(color, icon),
            ),
          ),

          // ── Team Members header ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Team Members',
                    style: GoogleFonts.inter(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: _orgProvider,
                            child: DepartmentOrgScreen(
                              departmentId: widget.department.id,
                              departmentName: widget.department.name,
                              accentColor: color,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'View All',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Team Members — API-driven (HOD first, then members) ───────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ListenableBuilder(
                listenable: _orgProvider,
                builder: (context, _) => _buildTeamSection(color, provider),
              ),
            ),
          ),

          // ── Active Tasks Overview ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: _buildTasksOverview(context, color, departmentTasks),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }

  // ── Team Section (inline, API-driven) ────────────────────────────────────

  Widget _buildTeamSection(Color accent, SuperAdminProvider provider) {
    // Loading state
    if (_orgProvider.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 28.h),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 28.w,
                height: 28.w,
                child: CircularProgressIndicator(
                  color: accent,
                  strokeWidth: 2.5,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Loading team…',
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

    // Error state
    if (_orgProvider.error != null) {
      return Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.dangerRed.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.dangerRed.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: AppColors.dangerRed, size: 20.w),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                _orgProvider.error!,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.dangerRed,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _orgProvider.refresh(widget.department.id),
              child: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dangerRed,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // No data yet
    if (!_orgProvider.hasData) return const SizedBox.shrink();

    final data = _orgProvider.data!;
    final hod = data.hod;
    final uniqueMembers = <String, OrgEmployee>{};
    for (var emp in data.employees) {
      if (emp.userId != hod?.userId) {
        uniqueMembers[emp.userId] = emp;
      }
    }
    final members = uniqueMembers.values.toList();
    
    // Use the GET /api/v1/users API to find unassigned employees
    // Filter out users who are already in this department.
    final unassignedFromApi = _allUsers
        .where((u) => u.isActive && !u.isInDepartment(widget.department.id))
        .toList();

    // Deduplicate by user id just in case
    final seen = <String>{};
    final unassigned = unassignedFromApi
        .where((u) => seen.add(u.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── HOD highlighted card ─────────────────────────────────────────
        if (hod != null) ..._buildHodSection(hod, accent),

        // ── Member cards ─────────────────────────────────────────────────
        ...members.asMap().entries.map((e) {
          return _buildOrgMemberCard(e.value, e.key, accent, isHod: false);
        }),

        // ── Empty state ───────────────────────────────────────────────────
        if (hod == null && members.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Center(
              child: Text(
                'No team members found.',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),

        // ── Unassigned Employees (from real API) ─────────────────────────
        if (_isLoadingUsers)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Center(
              child: SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: accent),
              ),
            ),
          )
        else if (unassigned.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.person_add_alt_1_rounded, size: 14.sp, color: AppColors.textMuted),
              SizedBox(width: 6.w),
              Text(
                'Available to Assign Task',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ...unassigned.asMap().entries.map((e) {
            return _buildUnassignedUserCard(e.value, e.key, accent);
          }),
        ],

        SizedBox(height: 8.h),
      ],
    );
  }

  List<Widget> _buildHodSection(OrgEmployee hod, Color accent) {
    return [
      // HOD label
      Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.12),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded,
                    size: 11.w, color: const Color(0xFFF59E0B)),
                SizedBox(width: 4.w),
                Text(
                  'Head of Department',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF59E0B),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      SizedBox(height: 10.h),

      // HOD card
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => EmployeeDetailProvider(),
                child: EmployeeDetailScreen(
                  departmentId: widget.department.id,
                  userId: hod.userId,
                  accentColor: accent,
                  employeeName: hod.fullName,
                ),
              ),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: accent.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.10),
              blurRadius: 14.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with crown badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withOpacity(0.65)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.30),
                        blurRadius: 8.r,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      hod.initials,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -5.h,
                  right: -3.w,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(Icons.star_rounded,
                        size: 9.w, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hod.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    hod.positionName,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Icon(Icons.mail_outline_rounded,
                          size: 11.w, color: AppColors.textMuted),
                      SizedBox(width: 3.w),
                      Flexible(
                        child: Text(
                          hod.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (hod.tags.isNotEmpty) ...[  
                    SizedBox(height: 6.h),
                    _buildTagRow(hod.tags, accent),
                  ],
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'HOD',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    ),

      // Section separator
      if (true) ...[  
        Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Text(
            'All Members',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
        ),
      ],
    ];
  }

  Widget _buildOrgMemberCard(
    OrgEmployee employee,
    int index,
    Color accent, {
    required bool isHod,
  }) {
    const bgPalette = [
      Color(0xFFDDEAFF),
      Color(0xFFDCFCE7),
      Color(0xFFFEF3C7),
      Color(0xFFFCE7F3),
      Color(0xFFEDE9FE),
      Color(0xFFFFEDD5),
    ];
    const fgPalette = [
      Color(0xFF2563EB),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEC4899),
      Color(0xFF8B5CF6),
      Color(0xFFF97316),
    ];

    final bg = bgPalette[index % bgPalette.length];
    final fg = fgPalette[index % fgPalette.length];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => EmployeeDetailProvider(),
              child: EmployeeDetailScreen(
                departmentId: widget.department.id,
                userId: employee.userId,
                accentColor: accent,
                employeeName: employee.fullName,
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Initials avatar
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                employee.initials,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Name + position
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  employee.positionName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                if (employee.tags.isNotEmpty) ...[  
                  SizedBox(height: 5.h),
                  _buildTagRow(employee.tags, accent, compact: true),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Employee code + chevron
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (employee.employeeCode.isNotEmpty)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(7.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    employee.employeeCode,
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              SizedBox(height: 4.h),
              Icon(Icons.chevron_right_rounded,
                  size: 18.w, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    ),
  );
}


  /// Card for a user who is NOT yet in this department.
  /// Tapping opens CreateTaskScreen with this user pre-filled as the assignee.
  Widget _buildUnassignedUserCard(UserModel user, int index, Color accent) {
    final initials = user.initials;
    final primaryPosition = user.assignments.isNotEmpty
        ? user.assignments.first.positionName
        : 'Employee';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateTaskScreen(
              initialDepartmentId: widget.department.id,
              initialAssigneeId: user.id,
              initialAssigneeName: user.fullName,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: accent.withOpacity(0.15),
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Name + position
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    primaryPosition,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Assign task button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment_ind_rounded, size: 14.sp, color: accent),
                  SizedBox(width: 4.w),
                  Text(
                    'Assign Task',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: accent,
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

  Widget _buildTagRow(List<String> tags, Color accent,
      {bool compact = false}) {
    final shown = compact ? tags.take(2).toList() : tags;
    return Wrap(
      spacing: 4.w,
      runSpacing: 3.h,
      children: [
        ...shown.map(
          (tag) => Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              tag,
              style: GoogleFonts.inter(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),
        ),
        if (compact && tags.length > 2)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '+${tags.length - 2}',
              style: GoogleFonts.inter(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
      ],
    );
  }

  // ── Analytics Banner Card ────────────────────────────────────────────────
  Widget _buildAnalyticsBanner(Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.75)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.30),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + name + subtitle
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: Colors.white, size: 22.w),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.department.name,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Manage healthcare & rescue operations',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // 4-stat row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BannerStat(
                  label: 'Total\nEmployees',
                  value: _orgProvider.hasData
                      ? '${_orgProvider.data!.totalEmployees}'
                      : '${widget.department.totalEmployees}'),
              _BannerDivider(),
              _BannerStat(
                  label: 'Tasks\nAssigned', value: '${widget.department.totalTasks}'),
              _BannerDivider(),
              _BannerStat(
                  label: 'Completed', value: '${widget.department.completedTasks}'),
              _BannerDivider(),
              _BannerStat(label: 'Pending', value: '${widget.department.pendingTasks}'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Active Tasks Overview Card ───────────────────────────────────────────
  Widget _buildTasksOverview(BuildContext context, Color color, List<dynamic> departmentTasks) {
    // If API tasks exist, use them. Otherwise fallback to mock department counts
    final hasRealTasks = departmentTasks.isNotEmpty;
    
    final completed = hasRealTasks ? departmentTasks.where((t) => t.status == 'COMPLETED').length : widget.department.completedTasks;
    final pending = hasRealTasks ? departmentTasks.where((t) => t.status != 'COMPLETED' && t.status != 'CANCELLED').length : widget.department.pendingTasks;
    final total = hasRealTasks ? departmentTasks.length : widget.department.totalTasks;
    
    final completedPct = total == 0 ? 0.0 : completed / total;
    final pendingPct = total == 0 ? 0.0 : pending / total;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Tasks Overview',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to TasksDashboard or list view
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _TaskStat(label: 'Total Tasks', value: '$total', color: AppColors.textMain),
              SizedBox(width: 24.w),
              _TaskStat(label: 'Completed', value: '$completed', color: AppColors.successGreen),
              SizedBox(width: 24.w),
              _TaskStat(label: 'Pending', value: '$pending', color: AppColors.dangerRed),
            ],
          ),
          SizedBox(height: 14.h),
          // Stacked progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: SizedBox(
              height: 8.h,
              child: Row(
                children: [
                  Flexible(
                    flex: (completedPct * 100).round(),
                    child: Container(color: AppColors.successGreen),
                  ),
                  Flexible(
                    flex: (pendingPct * 100).round(),
                    child: Container(color: AppColors.dangerRed),
                  ),
                  Flexible(
                    flex: 100 -
                        (completedPct * 100).round() -
                        (pendingPct * 100).round(),
                    child: Container(color: Colors.grey.shade200),
                  ),
                ],
              ),
            ),
          ),
          if (hasRealTasks) ...[
            SizedBox(height: 24.h),
            Text(
              'Recent Tasks',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 12.h),
            ...departmentTasks.take(5).map((task) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetailsScreen(task: task),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: task.status == 'COMPLETED'
                              ? AppColors.successGreen.withOpacity(0.1)
                              : task.status == 'IN_PROGRESS'
                                  ? AppColors.primaryBlue.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          task.status == 'COMPLETED'
                              ? Icons.check_rounded
                              : task.status == 'IN_PROGRESS'
                                  ? Icons.sync_rounded
                                  : Icons.pending_actions_rounded,
                          size: 16.sp,
                          color: task.status == 'COMPLETED'
                              ? AppColors.successGreen
                              : task.status == 'IN_PROGRESS'
                                  ? AppColors.primaryBlue
                                  : Colors.orange,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMain,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'To: ${task.assignedTo?.name ?? 'Unassigned'}',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18.w),
                    ],
                  ),
                ),
              );
            }).toList(),
          ]
        ],
      ),
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// Banner Stat + Divider helpers
// ─────────────────────────────────────────────────────────────────────────────

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  const _BannerStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            color: Colors.white.withOpacity(0.75),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _BannerDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36.h,
      color: Colors.white.withOpacity(0.25),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task stat helper
// ─────────────────────────────────────────────────────────────────────────────

class _TaskStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _TaskStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
