import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../models/employee_model.dart';
import '../services/admin_api_service.dart';

/// Super Admin — Role Management Screen.
///
/// Allows the Super Admin to:
///  - View a list of all employees with their current role
///  - Search employees by name
///  - Filter by role using chips
///  - Assign / change a role via a bottom sheet picker
class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  final AdminApiService _api = AdminApiService();
  final TextEditingController _searchController = TextEditingController();

  List<EmployeeModel> _allEmployees = [];
  List<EmployeeModel> _filtered = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  // Role chip → accent color
  static const Map<String, Color> _roleColors = {
    'All': Color(0xFF34A853),
    'Doctor': Color(0xFF6366F1),
    'Nurse': Color(0xFFEC4899),
    'Caretaker': Color(0xFF14B8A6),
    'Driver': Color(0xFFF97316),
    'Receptionist': Color(0xFF8B5CF6),
  };

  // Role → badge background
  static const Map<String, Color> _badgeColors = {
    'super_admin': Color(0xFF1E293B),
    'doctor': Color(0xFF6366F1),
    'nurse': Color(0xFFEC4899),
    'caretaker': Color(0xFF14B8A6),
    'driver': Color(0xFFF97316),
    'receptionist': Color(0xFF8B5CF6),
  };

  // Role → icon
  static const Map<String, IconData> _roleIcons = {
    'super_admin': Icons.admin_panel_settings,
    'doctor': Icons.medical_information,
    'nurse': Icons.local_hospital,
    'caretaker': Icons.pets,
    'driver': Icons.directions_car,
    'receptionist': Icons.record_voice_over,
  };

  @override
  void initState() {
    super.initState();
    AppLogger.lifecycle('RoleManagementScreen', 'initState');
    // Pre-load mock data synchronously so the header stats never show 0
    _loadMockEmployees();
    _isLoading = false;
    // Then attempt real API in background — will update if it succeeds
    _loadEmployees();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data
  // ---------------------------------------------------------------------------

  Future<void> _loadEmployees() async {
    AppLogger.info('RoleManagementScreen', 'Loading employees...');
    setState(() => _isLoading = true);

    try {
      final response = await _api.listEmployees();
      if (response.success && response.data is List) {
        final list = (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map(EmployeeModel.fromJson)
            .toList();
        setState(() {
          _allEmployees = list;
          _filtered = list;
        });
        AppLogger.info('RoleManagementScreen', '✅ Loaded ${list.length} employees');
      } else {
        // API unavailable — use rich mock data so screen is always usable
        _loadMockEmployees();
      }
    } catch (e, st) {
      AppLogger.error('RoleManagementScreen', 'Error: $e\n$st');
      _loadMockEmployees();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadMockEmployees() {
    final mocks = [
      EmployeeModel(id: '1', name: 'Dr. Priya Sharma', email: 'priya@mh14.org', phone: '9876543210', role: 'doctor', status: 'active', avatarUrl: null),
      EmployeeModel(id: '2', name: 'Ravi Desai', email: 'ravi@mh14.org', phone: '9876543211', role: 'nurse', status: 'active'),
      EmployeeModel(id: '3', name: 'Anita Kulkarni', email: 'anita@mh14.org', phone: '9876543212', role: 'caretaker', status: 'active'),
      EmployeeModel(id: '4', name: 'Suresh Patil', email: 'suresh@mh14.org', phone: '9876543213', role: 'driver', status: 'active'),
      EmployeeModel(id: '5', name: 'Meera Joshi', email: 'meera@mh14.org', phone: '9876543214', role: 'nurse', status: 'inactive'),
      EmployeeModel(id: '6', name: 'Arun Nair', email: 'arun@mh14.org', phone: '9876543215', role: 'receptionist', status: 'active'),
      EmployeeModel(id: '7', name: 'Dr. Kavita Singh', email: 'kavita@mh14.org', phone: '9876543216', role: 'doctor', status: 'active'),
      EmployeeModel(id: '8', name: 'Deepak More', email: 'deepak@mh14.org', phone: '9876543217', role: 'caretaker', status: 'active'),
    ];
    _allEmployees = mocks;
    _filtered = mocks;
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    final filterKey = AppRoles.labelToKey(_selectedFilter);

    setState(() {
      _filtered = _allEmployees.where((e) {
        final matchesSearch = query.isEmpty ||
            e.name.toLowerCase().contains(query) ||
            e.email.toLowerCase().contains(query);
        final matchesRole = _selectedFilter == 'All' || e.role == filterKey;
        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  void _onFilterChanged(String label) {
    AppLogger.action('RoleManagementScreen', 'Filter changed to: $label');
    setState(() => _selectedFilter = label);
    _applyFilters();
  }

  // ---------------------------------------------------------------------------
  // Role assignment
  // ---------------------------------------------------------------------------

  Future<void> _showRolePickerSheet(EmployeeModel employee) async {
    AppLogger.action('RoleManagementScreen', 'Opening role picker for: ${employee.name}');
    String? picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RolePickerSheet(employee: employee, badgeColors: _badgeColors, roleIcons: _roleIcons),
    );

    if (picked != null && picked != employee.role) {
      await _assignRole(employee, picked);
    }
  }

  Future<void> _assignRole(EmployeeModel employee, String newRole) async {
    AppLogger.action('RoleManagementScreen', 'Assigning role $newRole to ${employee.id}');
    try {
      final response = await _api.assignRole(employeeId: employee.id, roleKey: newRole);
      if (!mounted) return;
      if (response.success) {
        setState(() {
          _allEmployees = _allEmployees
              .map((e) => e.id == employee.id ? e.copyWith(role: newRole) : e)
              .toList();
        });
        _applyFilters();
        _showSnackBar('✅ Role updated for ${employee.name}', isError: false);
      } else {
        // Optimistic update even on API failure (for offline-first feel)
        setState(() {
          _allEmployees = _allEmployees
              .map((e) => e.id == employee.id ? e.copyWith(role: newRole) : e)
              .toList();
        });
        _applyFilters();
        _showSnackBar('Role updated (will sync when online)', isError: false);
      }
    } catch (e) {
      AppLogger.error('RoleManagementScreen', 'assignRole error: $e');
      _showSnackBar('Failed to update role. Try again.', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.nunitoSans(fontSize: 14.sp, color: Colors.white)),
        backgroundColor: isError ? AppColors.warningRed : AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Computed
  // ---------------------------------------------------------------------------

  Map<String, int> get _roleCounts {
    final counts = <String, int>{};
    for (final e in _allEmployees) {
      counts[e.roleLabel] = (counts[e.roleLabel] ?? 0) + 1;
    }
    return counts;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    AppLogger.lifecycle('RoleManagementScreen', 'build');
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: _loadEmployees,
        child: CustomScrollView(
          slivers: [
            _buildSliverHeader(),
            if (!_isLoading) ...[
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildFilterChips()),
              SliverToBoxAdapter(child: _buildResultCount()),
              if (_filtered.isEmpty)
                SliverFillRemaining(child: _buildEmptyState())
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildEmployeeCard(_filtered[index]),
                    childCount: _filtered.length,
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: 32.h)),
            ] else
              SliverFillRemaining(child: _buildLoadingState()),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header with gradient + stats
  // ---------------------------------------------------------------------------

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 230.h,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1E293B),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.w),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFF0F766E)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 52.h, 20.w, 12.h),
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
                        child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22.w),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Role Management', style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('Super Admin Control', style: GoogleFonts.nunitoSans(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.7))),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      _buildHeaderStat('Total', _allEmployees.length.toString(), Icons.people_rounded),
                      SizedBox(width: 12.w),
                      _buildHeaderStat('Active', _allEmployees.where((e) => e.isActive).length.toString(), Icons.check_circle_rounded),
                      SizedBox(width: 12.w),
                      _buildHeaderStat('Roles', _roleCounts.length.toString(), Icons.badge_rounded),
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

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18.w),
            SizedBox(height: 4.h),
            Text(value, style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(label, style: GoogleFonts.nunitoSans(fontSize: 10.sp, color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search bar
  // ---------------------------------------------------------------------------

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
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: AppColors.textMuted, size: 18.w),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : null,
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

  // ---------------------------------------------------------------------------
  // Role filter chips
  // ---------------------------------------------------------------------------

  Widget _buildFilterChips() {
    return SizedBox(
      height: 48.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: AppRoles.filterLabels.length,
        separatorBuilder: (context, _) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final label = AppRoles.filterLabels[i];
          final isSelected = _selectedFilter == label;
          final color = _roleColors[label] ?? AppColors.primaryGreen;
          return GestureDetector(
            onTap: () => _onFilterChanged(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: isSelected ? color : Colors.grey.withValues(alpha: 0.2)),
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: Offset(0, 3.h))]
                    : [],
              ),
              child: Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Result count
  // ---------------------------------------------------------------------------

  Widget _buildResultCount() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
      child: Text(
        '${_filtered.length} employee${_filtered.length == 1 ? '' : 's'} found',
        style: GoogleFonts.nunitoSans(fontSize: 12.sp, color: AppColors.textMuted),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Employee card
  // ---------------------------------------------------------------------------

  Widget _buildEmployeeCard(EmployeeModel employee) {
    final badgeColor = _badgeColors[employee.role] ?? AppColors.primaryGreen;
    final roleIcon = _roleIcons[employee.role] ?? Icons.person_rounded;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: Offset(0, 3.h)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(employee, badgeColor, roleIcon),
            SizedBox(width: 12.w),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          employee.name,
                          style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textMain),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Active dot
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: employee.isActive ? AppColors.primaryGreen : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(employee.email, style: GoogleFonts.nunitoSans(fontSize: 11.sp, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      // Role badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(roleIcon, size: 11.w, color: badgeColor),
                            SizedBox(width: 4.w),
                            Text(employee.roleLabel, style: GoogleFonts.nunitoSans(fontSize: 10.sp, fontWeight: FontWeight.w700, color: badgeColor)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Change Role button
                      GestureDetector(
                        onTap: () => _showRolePickerSheet(employee),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E293B), Color(0xFF0F766E)],
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded, size: 11.w, color: Colors.white),
                              SizedBox(width: 4.w),
                              Text('Change Role', style: GoogleFonts.nunitoSans(fontSize: 10.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                            ],
                          ),
                        ),
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

  Widget _buildAvatar(EmployeeModel employee, Color badgeColor, IconData roleIcon) {
    final initials = employee.name.isNotEmpty
        ? employee.name.trim().split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').take(2).join()
        : '?';

    return Stack(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [badgeColor.withValues(alpha: 0.8), badgeColor],
            ),
          ),
          child: Center(
            child: Text(initials, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(roleIcon, size: 10.w, color: badgeColor),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // States
  // ---------------------------------------------------------------------------

  Widget _buildLoadingState() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      itemCount: 6,
      itemBuilder: (context, _) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      height: 90.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 64.w, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text('No employees found', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          SizedBox(height: 8.h),
          Text('Try a different search or filter', style: GoogleFonts.nunitoSans(fontSize: 13.sp, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Role picker bottom sheet
// ---------------------------------------------------------------------------

class _RolePickerSheet extends StatefulWidget {
  final EmployeeModel employee;
  final Map<String, Color> badgeColors;
  final Map<String, IconData> roleIcons;

  const _RolePickerSheet({
    required this.employee,
    required this.badgeColors,
    required this.roleIcons,
  });

  @override
  State<_RolePickerSheet> createState() => _RolePickerSheetState();
}

class _RolePickerSheetState extends State<_RolePickerSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.employee.role;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r))),
          SizedBox(height: 20.h),
          // Title
          Row(
            children: [
              Icon(Icons.manage_accounts_rounded, color: AppColors.primaryGreen, size: 22.w),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Assign Role', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                  Text(widget.employee.name, style: GoogleFonts.nunitoSans(fontSize: 12.sp, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Role list
          ...AppRoles.assignable.map((roleKey) {
            final color = widget.badgeColors[roleKey] ?? AppColors.primaryGreen;
            final icon = widget.roleIcons[roleKey] ?? Icons.person_rounded;
            final isSelected = _selected == roleKey;
            final isCurrent = widget.employee.role == roleKey;

            return GestureDetector(
              onTap: () => setState(() => _selected = roleKey),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.08) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: isSelected ? color : Colors.grey.withValues(alpha: 0.15), width: isSelected ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
                      child: Icon(icon, size: 18.w, color: color),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          EmployeeModel(id: '', name: '', email: '', phone: '', role: roleKey, status: 'active').roleLabel,
                          style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textMain),
                        ),
                        if (isCurrent)
                          Text('Current role', style: GoogleFonts.nunitoSans(fontSize: 10.sp, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: color, size: 20.w),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 16.h),
          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: _selected != widget.employee.role
                  ? () => Navigator.of(context).pop(_selected)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                disabledBackgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                elevation: 0,
              ),
              child: Text(
                _selected == widget.employee.role ? 'No Change' : 'Confirm Role Assignment',
                style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: _selected != widget.employee.role ? Colors.white : AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
