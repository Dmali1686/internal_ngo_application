import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../admin/models/employee_model.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  final List<EmployeeModel> _allEmployees = [
    EmployeeModel(id: '1', name: 'Dr. Priya Sharma', email: 'priya@mh14.org', phone: '9876543210', role: 'doctor', status: 'active'),
    EmployeeModel(id: '2', name: 'Ravi Desai', email: 'ravi@mh14.org', phone: '9876543211', role: 'nurse', status: 'active'),
    EmployeeModel(id: '3', name: 'Anita Kulkarni', email: 'anita@mh14.org', phone: '9876543212', role: 'caretaker', status: 'inactive'),
    EmployeeModel(id: '4', name: 'Suresh Patil', email: 'suresh@mh14.org', phone: '9876543213', role: 'driver', status: 'active'),
    EmployeeModel(id: '5', name: 'Meera Joshi', email: 'meera@mh14.org', phone: '9876543214', role: 'nurse', status: 'active'),
    EmployeeModel(id: '6', name: 'Arun Nair', email: 'arun@mh14.org', phone: '9876543215', role: 'receptionist', status: 'active'),
    EmployeeModel(id: '7', name: 'Dr. Kavita Singh', email: 'kavita@mh14.org', phone: '9876543216', role: 'doctor', status: 'active'),
    EmployeeModel(id: '8', name: 'Deepak More', email: 'deepak@mh14.org', phone: '9876543217', role: 'caretaker', status: 'inactive'),
  ];

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

  List<EmployeeModel> get _filtered {
    final query = _searchController.text.toLowerCase();
    final roleKey = _selectedFilter == 'All' ? '' : _selectedFilter.toLowerCase();
    return _allEmployees.where((e) {
      final matchSearch = query.isEmpty || e.name.toLowerCase().contains(query) || e.email.toLowerCase().contains(query);
      final matchRole = roleKey.isEmpty || e.role == roleKey;
      return matchSearch && matchRole;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildFilterChips()),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
              child: Text('${_filtered.length} staff members', style: GoogleFonts.nunitoSans(fontSize: 12.sp, color: AppColors.textMuted)),
            ),
          ),
          if (_filtered.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildEmployeeCard(_filtered[index]),
                childCount: _filtered.length,
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF1E293B),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.w),
        onPressed: () => context.pop(),
      ),
      title: Text('Staff Directory', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.nunitoSans(fontSize: 14.sp, color: AppColors.textMain),
        decoration: InputDecoration(
          hintText: 'Search by name or email...',
          hintStyle: GoogleFonts.nunitoSans(fontSize: 14.sp, color: AppColors.textMuted),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20.w),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5.w)),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Doctor', 'Nurse', 'Caretaker', 'Driver', 'Receptionist'];
    final chipColors = <String, Color>{
      'All': AppColors.primaryGreen,
      'Doctor': const Color(0xFF6366F1),
      'Nurse': const Color(0xFFEC4899),
      'Caretaker': const Color(0xFF14B8A6),
      'Driver': const Color(0xFFF97316),
      'Receptionist': const Color(0xFF8B5CF6),
    };

    return SizedBox(
      height: 48.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: filters.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final label = filters[index];
          final isSelected = _selectedFilter == label;
          final color = chipColors[label] ?? AppColors.primaryGreen;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: isSelected ? color : Colors.grey.withValues(alpha: 0.2)),
                boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: Offset(0, 3.h))] : [],
              ),
              child: Text(label, style: GoogleFonts.nunitoSans(fontSize: 12.sp, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textMuted)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmployeeCard(EmployeeModel employee) {
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
            Stack(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [roleColor.withValues(alpha: 0.8), roleColor]),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(employee.name, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textMain), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 3.h),
                  Text(employee.email, style: GoogleFonts.nunitoSans(fontSize: 11.sp, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)),
                    child: Text(employee.roleLabel, style: GoogleFonts.nunitoSans(fontSize: 10.sp, fontWeight: FontWeight.w700, color: roleColor)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 8.w, height: 8.w,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
                SizedBox(height: 4.h),
                Text(isActive ? 'Active' : 'Inactive', style: GoogleFonts.nunitoSans(fontSize: 10.sp, fontWeight: FontWeight.w700, color: statusColor)),
                SizedBox(height: 6.h),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 18.w),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 56.w, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text('No staff found', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          SizedBox(height: 6.h),
          Text('Try a different search or filter', style: GoogleFonts.nunitoSans(fontSize: 13.sp, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
