import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../super_admin/providers/super_admin_provider.dart';
import '../../org/models/department_org_model.dart';
import '../../org/services/org_api_service.dart';
import '../../../core/utils/app_error_handler.dart';
import '../providers/task_provider.dart';

class CreateTaskScreen extends StatefulWidget {
  final String? initialDepartmentId;

  const CreateTaskScreen({super.key, this.initialDepartmentId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedDepartmentId;
  String? _selectedAssigneeId;
  String _selectedPriority = 'NORMAL';
  DateTime? _selectedDueDate;
  
  final List<String> _priorities = ['NORMAL', 'IMPORTANT', 'URGENT'];
  bool _isSubmitting = false;

  final OrgApiService _orgApiService = OrgApiService();
  List<OrgEmployee> _availableEmployees = [];
  bool _isLoadingEmployees = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDepartmentId != null) {
      _selectedDepartmentId = widget.initialDepartmentId;
      _fetchEmployees(_selectedDepartmentId!);
    }
  }

  Future<void> _fetchEmployees(String departmentId) async {
    setState(() {
      _isLoadingEmployees = true;
      _availableEmployees = [];
      _selectedAssigneeId = null;
    });

    try {
      final res = await _orgApiService.getDepartmentOrganization(departmentId);
      if (mounted) {
        setState(() {
          // Deduplicate employees by userId to prevent Dropdown duplicate value errors
          final seen = <String>{};
          _availableEmployees = res.allMembers.where((e) {
            if (e.userId.isEmpty || seen.contains(e.userId)) return false;
            seen.add(e.userId);
            return true;
          }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        AppErrorHandler.showError(context, 'Failed to load employees: ${AppErrorHandler.translate(e)}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingEmployees = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDepartmentId == null || _selectedAssigneeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a department and assignee.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final provider = context.read<TaskProvider>();
    final success = await provider.createTask(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _selectedPriority,
      departmentId: _selectedDepartmentId!,
      assignedToId: _selectedAssigneeId!,
      dueDate: _selectedDueDate?.toUtc().toIso8601String(),
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to create task'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final superAdminProvider = context.watch<SuperAdminProvider>();
    final departments = superAdminProvider.departments;

    return Scaffold(
      backgroundColor: AppColors.backgroundSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Create Task',
          style: GoogleFonts.inter(
            color: AppColors.textMain,
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Task Title'),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'Enter task title',
                      validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Description'),
                    _buildTextField(
                      controller: _descriptionController,
                      hint: 'Enter detailed description',
                      maxLines: 4,
                      validator: (val) => val == null || val.isEmpty ? 'Description is required' : null,
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Department'),
                    _buildDropdown<String>(
                      value: _selectedDepartmentId,
                      items: departments.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                      hint: 'Select Department',
                      // Disable if initialDepartmentId is provided
                      onChanged: widget.initialDepartmentId != null
                          ? null
                          : (val) {
                              if (val != null && val != _selectedDepartmentId) {
                                setState(() {
                                  _selectedDepartmentId = val;
                                });
                                _fetchEmployees(val);
                              }
                            },
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Assign To'),
                    _buildDropdown<String>(
                      value: _selectedAssigneeId,
                      items: _availableEmployees
                          .map((e) => DropdownMenuItem(value: e.userId, child: Text(e.fullName)))
                          .toList(),
                      hint: _isLoadingEmployees 
                          ? 'Loading...' 
                          : _selectedDepartmentId == null 
                              ? 'Select Department First' 
                              : 'Select Employee',
                      onChanged: _selectedDepartmentId == null || _isLoadingEmployees
                          ? null
                          : (val) {
                              setState(() => _selectedAssigneeId = val);
                            },
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Priority'),
                    _buildDropdown<String>(
                      value: _selectedPriority,
                      items: _priorities.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      hint: 'Select Priority',
                      onChanged: (val) {
                        setState(() => _selectedPriority = val!);
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Due Date (Optional)'),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2050),
                        );
                        if (picked != null) {
                          setState(() => _selectedDueDate = picked);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDueDate == null
                                  ? 'Select Due Date'
                                  : '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}',
                              style: GoogleFonts.inter(
                                color: _selectedDueDate == null ? AppColors.textMuted : AppColors.textMain,
                                fontSize: 14.sp,
                              ),
                            ),
                            Icon(Icons.calendar_today_rounded, color: AppColors.textMuted, size: 20.w),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        onPressed: _submitTask,
                        child: Text(
                          'Create Task',
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textMain,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14.sp),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required String hint,
    required void Function(T?)? onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: onChanged == null ? Color(0xFFE2E8F0).withValues(alpha: 0.3) : Colors.white,
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}
