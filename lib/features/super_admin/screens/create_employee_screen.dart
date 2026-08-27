import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/user_creation_models.dart';
import '../services/user_api_service.dart';

class _AssignmentState {
  String? departmentId;
  String? positionId;
  String? accessCategoryId;
  bool isPrimary = false;
}

class CreateEmployeeScreen extends StatefulWidget {
  const CreateEmployeeScreen({super.key});

  @override
  State<CreateEmployeeScreen> createState() => _CreateEmployeeScreenState();
}

class _CreateEmployeeScreenState extends State<CreateEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = UserApiService();
  
  bool _isLoading = false;
  bool _isLoadingData = true;

  // Data lists for dropdowns
  List<DepartmentItem> _departments = [];
  List<PositionItem> _positions = [];
  List<AccessCategoryItem> _accessCategories = [];

  // User fields
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Assignment fields
  final List<_AssignmentState> _assignments = [_AssignmentState()];

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final depts = await _apiService.fetchDepartments();
      final pos = await _apiService.fetchPositions();
      final cats = await _apiService.fetchAccessCategories();

      if (mounted) {
        setState(() {
          _departments = depts;
          _positions = pos;
          _accessCategories = cats;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dropdown data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    print('--- CreateEmployeeScreen _submit clicked ---');
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final req = UserCreationRequest(
          fullName: _fullNameCtrl.text,
          username: _usernameCtrl.text,
          email: _emailCtrl.text,
          mobile: _mobileCtrl.text,
          password: _passwordCtrl.text,
        );

        final userId = await _apiService.createUser(req);

        if (userId.isNotEmpty) {
          final assignmentReq = UserAssignmentRequest(
            assignments: _assignments
                .map((a) => AssignmentItem(
                      departmentId: a.departmentId!,
                      positionId: a.positionId!,
                      accessCategoryId: a.accessCategoryId!,
                      isPrimary: a.isPrimary,
                    ))
                .toList(),
          );
          await _apiService.assignRoles(userId, assignmentReq);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Employee creation & assignment successful!'),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
            // Clear form
            _fullNameCtrl.clear();
            _usernameCtrl.clear();
            _emailCtrl.clear();
            _mobileCtrl.clear();
            _passwordCtrl.clear();
            setState(() {
              _assignments.clear();
              _assignments.add(_AssignmentState());
            });
          }
        } else {
          throw Exception('Failed to get User ID after creation.');
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 28.sp),
                  SizedBox(width: 8.w),
                  Text('Error', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
              content: Text(
                e.toString().replaceAll('Exception: ', '').replaceAll('ApiException(400): ', ''),
                style: GoogleFonts.nunitoSans(fontSize: 15.sp, color: AppColors.textMain),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('OK', style: GoogleFonts.poppins(color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
            child: Text(
              'Create Employee',
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                        'User Details', Icons.person_add_alt_1_rounded),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _fullNameCtrl,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 12.h),
                    _buildTextField(
                      controller: _usernameCtrl,
                      label: 'Username',
                      icon: Icons.alternate_email_rounded,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 12.h),
                    _buildTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildTextField(
                      controller: _mobileCtrl,
                      label: 'Mobile',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 12.h),
                    _buildTextField(
                      controller: _passwordCtrl,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),
                    _buildSectionHeader(
                        'Role Assignments', Icons.assignment_ind_outlined),
                    SizedBox(height: 16.h),
                    ..._buildAssignmentsList(),
                    SizedBox(height: 12.h),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _assignments.add(_AssignmentState());
                          });
                        },
                        icon: const Icon(Icons.add,
                            color: AppColors.primaryGreen),
                        label: Text(
                          'Add Another Role',
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Create & Assign Employee',
                                style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAssignmentsList() {
    List<Widget> widgets = [];
    for (int i = 0; i < _assignments.length; i++) {
      final assignment = _assignments[i];
      
      // Filter positions based on selected department
      final availablePositions = assignment.departmentId == null 
          ? <PositionItem>[] 
          : _positions.where((p) => p.departmentId == assignment.departmentId).toList();

      widgets.add(
        Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assignment ${i + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                  if (_assignments.length > 1)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _assignments.removeAt(i);
                        });
                      },
                      child: Icon(Icons.remove_circle_outline,
                          color: Colors.red, size: 20.w),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              
              // Department Dropdown
              _buildDropdown(
                label: 'Department',
                value: assignment.departmentId,
                icon: Icons.account_tree_outlined,
                items: _departments.map((d) => DropdownMenuItem(
                  value: d.id,
                  child: Text(d.name, style: GoogleFonts.nunitoSans(fontSize: 15.sp, color: AppColors.textMain)),
                )).toList(),
                onChanged: (v) => setState(() {
                  assignment.departmentId = v;
                  assignment.positionId = null; // reset position if department changes
                }),
              ),
              SizedBox(height: 12.h),
              
              // Position Dropdown
              _buildDropdown(
                label: 'Position',
                value: assignment.positionId,
                icon: Icons.badge_outlined,
                items: availablePositions.map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Text(p.name, style: GoogleFonts.nunitoSans(fontSize: 15.sp, color: AppColors.textMain)),
                )).toList(),
                onChanged: (v) => setState(() => assignment.positionId = v),
              ),
              SizedBox(height: 12.h),
              
              // Access Category Dropdown
              _buildDropdown(
                label: 'Access Category',
                value: assignment.accessCategoryId,
                icon: Icons.security_outlined,
                items: _accessCategories.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name, style: GoogleFonts.nunitoSans(fontSize: 15.sp, color: AppColors.textMain)),
                )).toList(),
                onChanged: (v) => setState(() => assignment.accessCategoryId = v),
              ),
              SizedBox(height: 12.h),
              
              // Primary Assignment Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Primary Assignment',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                  Switch(
                    value: assignment.isPrimary,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (v) {
                      setState(() {
                        // If turning on, optionally turn off others
                        if (v) {
                          for (var a in _assignments) {
                            a.isPrimary = false;
                          }
                        }
                        assignment.isPrimary = v;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 22.w),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.nunitoSans(
        fontSize: 15.sp,
        color: AppColors.textMain,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunitoSans(
          fontSize: 14.sp,
          color: AppColors.textMuted,
        ),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20.w),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      validator: (v) => v == null ? 'Required' : null,
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: Colors.grey, size: 24.w),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunitoSans(
          fontSize: 14.sp,
          color: AppColors.textMuted,
        ),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20.w),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      items: items,
    );
  }
}
