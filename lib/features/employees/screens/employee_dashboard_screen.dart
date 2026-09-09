import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../admin/models/employee_model.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<EmployeeModel> _employees = [];
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fetchData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    _loadMockData();
  }

  void _loadMockData() {
    if (!mounted) return;
    setState(() {
      _employees = [
        EmployeeModel(id: '1', name: 'Dr. Priya Sharma', email: 'priya@mh14.org', phone: '9876543210', role: 'doctor', status: 'active'),
        EmployeeModel(id: '2', name: 'Ravi Desai', email: 'ravi@mh14.org', phone: '9876543211', role: 'nurse', status: 'active'),
        EmployeeModel(id: '3', name: 'Anita Kulkarni', email: 'anita@mh14.org', phone: '9876543212', role: 'caretaker', status: 'inactive'),
        EmployeeModel(id: '4', name: 'Suresh Patil', email: 'suresh@mh14.org', phone: '9876543213', role: 'driver', status: 'active'),
        EmployeeModel(id: '5', name: 'Meera Joshi', email: 'meera@mh14.org', phone: '9876543214', role: 'nurse', status: 'active'),
      ];
      _isLoading = false;
    });
    _animController.forward();
  }

  // Role → accent color
  static const Map<String, Color> _roleColors = {
    'doctor': Color(0xFF6366F1),
    'nurse': Color(0xFFEC4899),
    'caretaker': Color(0xFF14B8A6),
    'driver': Color(0xFFF97316),
    'receptionist': Color(0xFF8B5CF6),
  };

  static const Map<String, IconData> _roleIcons = {
    'doctor': Icons.medical_information_rounded,
    'nurse': Icons.local_hospital_rounded,
    'caretaker': Icons.pets_rounded,
    'driver': Icons.directions_car_rounded,
    'receptionist': Icons.record_voice_over_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final activeCount = _employees.where((e) => e.isActive).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : RefreshIndicator(
              onRefresh: _fetchData,
              color: AppColors.primaryGreen,
              child: CustomScrollView(
                slivers: [
                  _buildSliverHeader(activeCount),
                  SliverToBoxAdapter(child: _buildQuickActions()),
                  SliverToBoxAdapter(child: _buildSectionTitle('Recent Staff', showViewAll: true, onViewAll: () => context.push('/employee-list'))),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildStaffCard(_employees[index]),
                      childCount: _employees.take(4).length,
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryGreen,
        elevation: 4,
        child: Icon(Icons.person_add_rounded, color: Colors.white, size: 24.w),
      ),
    );
  }

  // ── Gradient Sliver Header ────────────────────────────────────────────────

  Widget _buildSliverHeader(int activeCount) {
    final totalCount = _employees.length;
    final inactiveCount = totalCount - activeCount;

    return SliverAppBar(
      expandedHeight: 220.h,
      pinned: true,
      floating: false,
      backgroundColor: const Color(0xFF1E293B),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.w),
        onPressed: () => context.pop(),
      ),
      title: Text('Employee Dashboard', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white)),
      actions: [
        IconButton(icon: Icon(Icons.notifications_outlined, color: Colors.white, size: 22.w), onPressed: () {}),
        SizedBox(width: 8.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFF14B8A6)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 64.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Staff Overview', style: GoogleFonts.nunitoSans(fontSize: 13.sp, color: Colors.white.withValues(alpha: 0.7))),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(child: _buildStatChip('Total', totalCount.toString(), Icons.people_rounded, Colors.white)),
                      SizedBox(width: 10.w),
                      Expanded(child: _buildStatChip('Active', activeCount.toString(), Icons.check_circle_rounded, const Color(0xFF34A853))),
                      SizedBox(width: 10.w),
                      Expanded(child: _buildStatChip('Inactive', inactiveCount.toString(), Icons.cancel_rounded, Colors.red.shade300)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18.w),
          SizedBox(height: 4.h),
          Text(value, style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(label, style: GoogleFonts.nunitoSans(fontSize: 10.sp, color: Colors.white.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitleInline('Quick Actions'),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(child: _buildActionCard('Staff List', Icons.format_list_bulleted_rounded, const Color(0xFF1E293B), const Color(0xFF0F766E), '/employee-list')),
              SizedBox(width: 10.w),
              Expanded(child: _buildActionCard('Attendance', Icons.fingerprint_rounded, const Color(0xFF6366F1), const Color(0xFF4338CA), '/attendance')),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(child: _buildActionCard('Tasks', Icons.task_alt_rounded, const Color(0xFFF97316), const Color(0xFFEA580C), '/assigned-tasks')),
              SizedBox(width: 10.w),
              Expanded(child: _buildActionCard('Performance', Icons.trending_up_rounded, const Color(0xFFEC4899), const Color(0xFFDB2777), '/performance')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color from, Color to, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [from, to]),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(color: from.withValues(alpha: 0.35), blurRadius: 10, offset: Offset(0, 4.h)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22.w),
            SizedBox(width: 10.w),
            Text(title, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // ── Section Title ─────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, {bool showViewAll = false, VoidCallback? onViewAll}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textMain)),
          if (showViewAll)
            GestureDetector(
              onTap: onViewAll,
              child: Text('View All', style: GoogleFonts.nunitoSans(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitleInline(String title) {
    return Text(title, style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textMain));
  }

  // ── Staff Card ────────────────────────────────────────────────────────────

  Widget _buildStaffCard(EmployeeModel employee) {
    final isActive = employee.isActive;
    final statusColor = isActive ? AppColors.primaryGreen : Colors.red;
    final roleColor = _roleColors[employee.role] ?? AppColors.primaryGreen;
    final roleIcon = _roleIcons[employee.role] ?? Icons.person_rounded;
    final initials = employee.name.trim().split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').take(2).join();

    return GestureDetector(
      onTap: () => context.push('/employee-profile', extra: employee),
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: Offset(0, 3.h))],
        ),
        child: Row(
          children: [
            // Avatar with gradient
            Stack(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [roleColor.withValues(alpha: 0.8), roleColor],
                    ),
                  ),
                  child: Center(child: Text(initials, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white))),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                    child: Icon(roleIcon, size: 10.w, color: roleColor),
                  ),
                ),
              ],
            ),
            SizedBox(width: 14.w),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(employee.name, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textMain), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)),
                        child: Text(employee.roleLabel, style: GoogleFonts.nunitoSans(fontSize: 10.sp, fontWeight: FontWeight.w700, color: roleColor)),
                      ),
                      SizedBox(width: 6.w),
                      Icon(Icons.phone_rounded, size: 11.w, color: AppColors.textMuted),
                      SizedBox(width: 3.w),
                      Text(employee.phone, style: GoogleFonts.nunitoSans(fontSize: 10.sp, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            // Status dot + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20.r)),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: GoogleFonts.nunitoSans(fontSize: 10.sp, fontWeight: FontWeight.w700, color: statusColor),
                  ),
                ),
                SizedBox(height: 6.h),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 18.w),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
