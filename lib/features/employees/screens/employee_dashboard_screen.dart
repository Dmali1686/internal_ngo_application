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

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  bool _isLoading = true;
  List<EmployeeModel> _employees = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    // Simulate network delay
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
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Employee Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 18.sp)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.w),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: CircleAvatar(
              radius: 16.r,
              backgroundImage: const NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuD4X8v89VRtlb3VS5i1TxxwRn1QLNGK4jGkTgrcDF5VnK3Z5Jw_maTE0-r621TXfOlmYNQqnM02Ds6NUstjD6NrFx8W8dwT3oIZbMbgawE0IBR0ILnHOytlRGoRgJ0L37HUIblDfldgEDKlzqz-AZ97PdDHTHXLNEZjRXnv_pfka5dMAOkg_jcYtPyyJgtpQeLj3h3nqS_msnJlOS94WvSEIM5rzv0CvtbbABgkfIsrKmTum6JtcCia3g',
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : RefreshIndicator(
              onRefresh: _fetchData,
              color: AppColors.primaryGreen,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(),
                    SizedBox(height: 24.h),
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildQuickActions(context),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Staff',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/employee-list'),
                          child: Text('View All', style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _buildRecentStaff(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final activeCount = _employees.where((e) => e.isActive).length;
    final totalCount = _employees.length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Staff',
            totalCount.toString(),
            Icons.people_alt,
            AppColors.primaryGreen.withValues(alpha: 0.1),
            AppColors.primaryGreen,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildSummaryCard(
            'On Duty',
            activeCount.toString(),
            Icons.check_circle,
            Colors.blue[50]!,
            Colors.blue[700]!,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String count,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28.w),
          SizedBox(height: 12.h),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.nunitoSans(fontSize: 14.sp, color: Colors.black87, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 2.5,
      children: [
        _buildActionBtn(
          context,
          'Staff List',
          Icons.format_list_bulleted,
          AppColors.primaryGreen,
          Colors.white,
          '/employee-list',
        ),
        _buildActionBtn(
          context,
          'Attendance',
          Icons.co_present,
          Colors.white,
          Colors.black87,
          '/attendance',
        ),
        _buildActionBtn(
          context,
          'Tasks',
          Icons.task_alt,
          Colors.white,
          Colors.black87,
          '/assigned-tasks',
        ),
        _buildActionBtn(
          context,
          'Performance',
          Icons.trending_up,
          Colors.white,
          Colors.black87,
          '/performance',
        ),
      ],
    );
  }

  Widget _buildActionBtn(
    BuildContext context,
    String title,
    IconData icon,
    Color bgColor,
    Color textColor,
    String route,
  ) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
          border: bgColor == Colors.white
              ? Border.all(color: Colors.grey[300]!)
              : null,
          boxShadow: bgColor == Colors.white
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20.w),
            SizedBox(width: 8.w),
            Text(
              title,
              style: GoogleFonts.nunitoSans(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentStaff() {
    if (_employees.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Text(
            'No staff found.',
            style: GoogleFonts.nunitoSans(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Column(
      children: _employees.take(5).map((employee) {
        final isActive = employee.isActive;
        final statusColor = isActive ? AppColors.primaryGreen : Colors.red;

        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: ListTile(
            onTap: () => context.push('/employee-profile', extra: employee),
            contentPadding: EdgeInsets.all(12.w),
            leading: CircleAvatar(
              radius: 24.r,
              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
              child: Text(
                employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    employee.name,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15.sp, color: AppColors.textMain),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: GoogleFonts.nunitoSans(
                      color: statusColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                '${employee.roleLabel} • ${employee.phone}',
                style: GoogleFonts.nunitoSans(fontSize: 13.sp, color: AppColors.textMuted),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
