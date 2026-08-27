import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class CreateEmployeeScreen extends StatefulWidget {
  const CreateEmployeeScreen({super.key});

  @override
  State<CreateEmployeeScreen> createState() => _CreateEmployeeScreenState();
}

class _CreateEmployeeScreenState extends State<CreateEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  // User fields
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Assignment fields
  String? _selectedDeptId;
  String? _selectedPositionId;
  String? _selectedAccessCategoryId;
  bool _isPrimary = true;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // In a real app, you would make the API call here.
      // 1. POST /api/v1/users
      // 2. POST /api/v1/users/{id}/assignments
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee creation submitted successfully!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildSectionHeader('User Details', Icons.person_add_alt_1_rounded),
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
                      validator: (v) => v!.isEmpty ? 'Required' : null,
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
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    
                    SizedBox(height: 24.h),
                    _buildSectionHeader('Role Assignment', Icons.assignment_ind_outlined),
                    SizedBox(height: 16.h),
                    
                    // Mock Dropdowns for assignment
                    _buildMockDropdown(
                      label: 'Department',
                      value: _selectedDeptId,
                      icon: Icons.account_tree_outlined,
                      items: ['dept_medical', 'dept_transport', 'dept_food'],
                      onChanged: (v) => setState(() => _selectedDeptId = v),
                    ),
                    SizedBox(height: 12.h),
                    _buildMockDropdown(
                      label: 'Position',
                      value: _selectedPositionId,
                      icon: Icons.badge_outlined,
                      items: ['pos_doctor', 'pos_driver', 'pos_manager', 'pos_staff'],
                      onChanged: (v) => setState(() => _selectedPositionId = v),
                    ),
                    SizedBox(height: 12.h),
                    _buildMockDropdown(
                      label: 'Access Category',
                      value: _selectedAccessCategoryId,
                      icon: Icons.security_outlined,
                      items: ['cat_hod', 'cat_staff', 'cat_volunteer'],
                      onChanged: (v) => setState(() => _selectedAccessCategoryId = v),
                    ),
                    SizedBox(height: 12.h),
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
                          value: _isPrimary,
                          activeColor: AppColors.primaryGreen,
                          onChanged: (v) => setState(() => _isPrimary = v),
                        ),
                      ],
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
                        onPressed: _submit,
                        child: Text(
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
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  Widget _buildMockDropdown({
    required String label,
    required String? value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      validator: (v) => v == null ? 'Required' : null,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 24.w),
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
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: GoogleFonts.nunitoSans(
              fontSize: 15.sp,
              color: AppColors.textMain,
            ),
          ),
        );
      }).toList(),
    );
  }
}
