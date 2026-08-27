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
  List<EmployeeModel> _allEmployees = [];
  List<EmployeeModel> _filtered = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate network

    if (!mounted) return;
    final mockData = [
      EmployeeModel(id: '1', name: 'Dr. Priya Sharma', email: 'priya@mh14.org', phone: '9876543210', role: 'doctor', status: 'active'),
      EmployeeModel(id: '2', name: 'Ravi Desai', email: 'ravi@mh14.org', phone: '9876543211', role: 'nurse', status: 'active'),
      EmployeeModel(id: '3', name: 'Anita Kulkarni', email: 'anita@mh14.org', phone: '9876543212', role: 'caretaker', status: 'inactive'),
      EmployeeModel(id: '4', name: 'Suresh Patil', email: 'suresh@mh14.org', phone: '9876543213', role: 'driver', status: 'active'),
      EmployeeModel(id: '5', name: 'Meera Joshi', email: 'meera@mh14.org', phone: '9876543214', role: 'nurse', status: 'active'),
    ];

    setState(() {
      _allEmployees = mockData;
      _filtered = mockData;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _allEmployees.where((e) {
        return e.name.toLowerCase().contains(query) || e.roleLabel.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Staff List', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 18.sp)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.w),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchData,
                    color: AppColors.primaryGreen,
                    child: _filtered.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.all(16.w),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              return _buildEmployeeCard(_filtered[index]);
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.nunitoSans(fontSize: 14.sp, color: AppColors.textMain),
        decoration: InputDecoration(
          hintText: 'Search staff...',
          hintStyle: GoogleFonts.nunitoSans(fontSize: 14.sp, color: AppColors.textMuted),
          prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20.w),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48.w, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            'No staff found',
            style: GoogleFonts.nunitoSans(color: Colors.grey.shade600, fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(EmployeeModel employee) {
    final isActive = employee.isActive;
    final statusColor = isActive ? AppColors.primaryGreen : Colors.red;

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.grey.shade200),
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
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
      ),
    );
  }
}
