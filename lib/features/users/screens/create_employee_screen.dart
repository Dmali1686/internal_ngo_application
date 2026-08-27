import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../models/create_user_request.dart';
import '../models/department_model.dart';
import '../models/position_model.dart';
import '../models/user_assignment_request.dart';
import '../services/user_api_service.dart';

// ---------------------------------------------------------------------------
// Access Category UUIDs — seeded constants, no extra API call needed
// ---------------------------------------------------------------------------
const _kAccessCategories = [
  _AccessCat(label: 'Super Admin', id: 'b4fc7beb-8d38-440e-b9e6-88e0e01cd4c6', code: 'SUP001'),
  _AccessCat(label: 'Dept Admin',  id: '1b8fc8a0-bcfd-4857-9854-1e48285dd4ba', code: 'ADM001'),
  _AccessCat(label: 'Employee',    id: '2c140a47-c9db-4bbb-b4db-45c87a848467', code: 'EMP001'),
];

class _AccessCat {
  final String label;
  final String id;
  final String code;
  const _AccessCat({required this.label, required this.id, required this.code});
}

/// Super Admin screen to create a new employee.
///
/// Flow:
///   1. On init: parallel GET /departments + GET /positions
///   2. User fills form (personal + assignment)
///   3. On submit: POST /users → POST /users/{id}/assignments
class CreateEmployeeScreen extends StatefulWidget {
  const CreateEmployeeScreen({super.key});

  @override
  State<CreateEmployeeScreen> createState() => _CreateEmployeeScreenState();
}

class _CreateEmployeeScreenState extends State<CreateEmployeeScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _service = UserApiService();

  // ── Text controllers ───────────────────────────────────────────────────────
  final _fullNameCtrl   = TextEditingController();
  final _usernameCtrl   = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _mobileCtrl     = TextEditingController();
  final _passwordCtrl   = TextEditingController();

  bool _obscurePassword = true;

  // ── Dropdown data ──────────────────────────────────────────────────────────
  List<DepartmentModel> _departments   = [];
  List<PositionModel>   _allPositions  = [];
  List<PositionModel>   _filteredPositions = [];

  DepartmentModel?  _selectedDept;
  PositionModel?    _selectedPosition;
  _AccessCat        _selectedAccess = _kAccessCategories.last; // default: Employee

  // ── State ──────────────────────────────────────────────────────────────────
  bool _loadingMeta  = true;
  bool _submitting   = false;
  String? _metaError;

  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _headerAnim;
  late final Animation<double>   _headerFade;

  @override
  void initState() {
    super.initState();
    AppLogger.lifecycle('CreateEmployeeScreen', 'initState');

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerAnim.forward();

    _loadMeta();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadMeta() async {
    AppLogger.info('CreateEmployeeScreen', 'Loading departments + positions...');
    setState(() {
      _loadingMeta = true;
      _metaError   = null;
    });

    final results = await Future.wait([
      _service.getDepartments(),
      _service.getPositions(),
    ]);

    final deptRes = results[0] as dynamic;
    final posRes  = results[1] as dynamic;

    if (!mounted) return;

    if (deptRes.success && posRes.success) {
      setState(() {
        _departments  = deptRes.data as List<DepartmentModel>;
        _allPositions = posRes.data as List<PositionModel>;
        _loadingMeta  = false;
      });
      AppLogger.info('CreateEmployeeScreen',
          'Meta loaded: ${_departments.length} depts, ${_allPositions.length} positions');
    } else {
      final err = deptRes.errorMessage ?? posRes.errorMessage ?? 'Failed to load data';
      AppLogger.error('CreateEmployeeScreen', 'Meta load error: $err');
      setState(() {
        _metaError   = err;
        _loadingMeta = false;
      });
    }
  }

  void _onDeptChanged(DepartmentModel? dept) {
    setState(() {
      _selectedDept     = dept;
      _selectedPosition = null;
      _filteredPositions = dept == null
          ? []
          : _allPositions.where((p) => p.departmentId == dept.id).toList();
    });
    AppLogger.info('CreateEmployeeScreen',
        'Dept changed → ${dept?.name}, ${_filteredPositions.length} positions available');
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    AppLogger.action('CreateEmployeeScreen', 'Submit pressed');
    setState(() => _submitting = true);

    final userReq = CreateUserRequest(
      fullName: _fullNameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      mobile:   _mobileCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    final assignReq = UserAssignmentRequest(
      accessCategoryId: _selectedAccess.id,
      departmentId:     _selectedDept?.id,
      positionId:       _selectedPosition?.id,
      isPrimary:        true,
    );

    final result = await _service.createEmployeeWithAssignment(
      user:       userReq,
      assignment: assignReq,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.success) {
      AppLogger.action('CreateEmployeeScreen', 'Employee created: ${result.data}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Employee created successfully!',
            style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      );
      Navigator.of(context).pop();
    } else {
      AppLogger.error('CreateEmployeeScreen', 'Failed: ${result.errorMessage}');
      _showErrorDialog(result.errorMessage ?? 'Something went wrong');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Icon(Icons.error_rounded, color: Colors.red.shade400, size: 24.w),
            SizedBox(width: 8.w),
            Text('Error', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18.sp)),
          ],
        ),
        content: Text(message, style: GoogleFonts.nunitoSans(fontSize: 14.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.nunitoSans(color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          if (_loadingMeta)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_metaError != null)
            SliverFillRemaining(child: _buildMetaError())
          else
            SliverToBoxAdapter(child: _buildForm()),
        ],
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 160.h,
      pinned: true,
      floating: false,
      backgroundColor: const Color(0xFF1E293B),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.w),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: _headerFade,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E293B), Color(0xFF0F766E)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 48.h, 20.w, 16.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 26.w),
                    ),
                    SizedBox(width: 14.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add Employee',
                          style: GoogleFonts.poppins(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Super Admin · Create new profile',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 13.sp,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64.w, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              'Could not load departments / positions',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
            SizedBox(height: 8.h),
            Text(_metaError!, textAlign: TextAlign.center, style: GoogleFonts.nunitoSans(fontSize: 13.sp, color: Colors.grey.shade500)),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _loadMeta,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: Personal Details ──────────────────────────────────
            _buildSectionHeader('Personal Details', Icons.person_rounded),
            SizedBox(height: 14.h),
            _buildCard([
              _buildField(_fullNameCtrl,  'Full Name',    'e.g. Ramesh Patil',   Icons.badge_rounded,       required: true),
              _buildField(_usernameCtrl,  'Username',     'e.g. ramesh123',      Icons.alternate_email,     required: true),
              _buildField(_emailCtrl,     'Email',        'e.g. ram@mh14.org',   Icons.email_outlined,      required: true, keyboard: TextInputType.emailAddress, validator: _emailValidator),
              _buildField(_mobileCtrl,    'Mobile',       '10-digit number',     Icons.phone_rounded,       required: true, keyboard: TextInputType.phone,  validator: _mobileValidator),
              _buildPasswordField(),
            ]),

            SizedBox(height: 24.h),

            // ── Section 2: Job Assignment ────────────────────────────────────
            _buildSectionHeader('Job Assignment', Icons.work_rounded),
            SizedBox(height: 14.h),
            _buildCard([
              _buildDeptDropdown(),
              _buildPositionDropdown(),
              _buildAccessDropdown(),
            ]),

            SizedBox(height: 32.h),

            // ── Submit Button ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: _submitting
                    ? SizedBox(height: 22.w, width: 22.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 22.w),
                          SizedBox(width: 10.w),
                          Text('Create Employee', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper widgets
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 18.w, color: AppColors.primaryGreen),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12.r, offset: Offset(0, 4.h))],
      ),
      child: Column(
        children: children.map((w) {
          final idx = children.indexOf(w);
          return Column(
            children: [
              Padding(padding: EdgeInsets.all(16.w), child: w),
              if (idx < children.length - 1) Divider(height: 1, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon, {
    bool required = false,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      style: GoogleFonts.nunitoSans(fontSize: 15.sp, color: const Color(0xFF1E293B)),
      validator: validator ?? (required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20.w, color: Colors.grey.shade500),
        labelStyle: GoogleFonts.nunitoSans(fontSize: 13.sp, color: Colors.grey.shade600),
        hintStyle: GoogleFonts.nunitoSans(fontSize: 14.sp, color: Colors.grey.shade400),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      style: GoogleFonts.nunitoSans(fontSize: 15.sp, color: const Color(0xFF1E293B)),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required';
        if (v.length < 6) return 'Minimum 6 characters';
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Min. 6 characters',
        prefixIcon: Icon(Icons.lock_rounded, size: 20.w, color: Colors.grey.shade500),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20.w, color: Colors.grey.shade500),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        labelStyle: GoogleFonts.nunitoSans(fontSize: 13.sp, color: Colors.grey.shade600),
        hintStyle: GoogleFonts.nunitoSans(fontSize: 14.sp, color: Colors.grey.shade400),
        border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none, focusedErrorBorder: InputBorder.none,
      ),
    );
  }

  Widget _buildDeptDropdown() {
    return _buildDropdownRow<DepartmentModel>(
      label: 'Department',
      icon: Icons.domain_rounded,
      value: _selectedDept,
      hint: 'Select department',
      items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d.name, style: GoogleFonts.nunitoSans(fontSize: 14.sp)))).toList(),
      onChanged: _onDeptChanged,
      validator: (v) => v == null ? 'Please select a department' : null,
    );
  }

  Widget _buildPositionDropdown() {
    return _buildDropdownRow<PositionModel>(
      label: 'Position',
      icon: Icons.work_outline_rounded,
      value: _selectedPosition,
      hint: _selectedDept == null ? 'Select dept first' : 'Select position',
      items: _filteredPositions.map((p) => DropdownMenuItem(
        value: p,
        child: Row(
          children: [
            Text(p.name, style: GoogleFonts.nunitoSans(fontSize: 14.sp)),
            if (p.isHod) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4.r)),
                child: Text('HOD', style: GoogleFonts.nunitoSans(fontSize: 10.sp, color: const Color(0xFFD97706), fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      )).toList(),
      onChanged: _selectedDept == null ? null : (p) => setState(() => _selectedPosition = p),
      validator: null, // optional
    );
  }

  Widget _buildAccessDropdown() {
    return _buildDropdownRow<_AccessCat>(
      label: 'Access Role',
      icon: Icons.verified_user_rounded,
      value: _selectedAccess,
      hint: 'Select role',
      items: _kAccessCategories.map((c) => DropdownMenuItem(
        value: c,
        child: Text('${c.label} (${c.code})', style: GoogleFonts.nunitoSans(fontSize: 14.sp)),
      )).toList(),
      onChanged: (c) => setState(() => _selectedAccess = c ?? _selectedAccess),
      validator: null,
    );
  }

  Widget _buildDropdownRow<T>({
    required String label,
    required IconData icon,
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    required String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      // ignore: deprecated_member_use
      initialValue: value,
      validator: validator,
      isExpanded: true,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500, size: 20.w),
      style: GoogleFonts.nunitoSans(fontSize: 14.sp, color: const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20.w, color: Colors.grey.shade500),
        labelStyle: GoogleFonts.nunitoSans(fontSize: 13.sp, color: Colors.grey.shade600),
        border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none, focusedErrorBorder: InputBorder.none,
      ),
      hint: Text(hint, style: GoogleFonts.nunitoSans(fontSize: 14.sp, color: Colors.grey.shade400)),
      items: items,
      onChanged: onChanged,
    );
  }

  // ---------------------------------------------------------------------------
  // Validators
  // ---------------------------------------------------------------------------

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final emailReg = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!emailReg.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _mobileValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Mobile is required';
    if (v.trim().length != 10) return 'Enter a 10-digit mobile number';
    if (!RegExp(r'^\d+$').hasMatch(v.trim())) return 'Only digits allowed';
    return null;
  }
}
