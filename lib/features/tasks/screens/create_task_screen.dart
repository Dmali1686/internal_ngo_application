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
import '../../../core/services/voice_service.dart';

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
  TextEditingController? _activeListeningController;
  
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
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Background Gradient Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280.h,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E293B), Color(0xFF0F766E)],
                ),
              ),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        'Create New Task',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Main Form Content
                Expanded(
                  child: _isSubmitting
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 40.h),
                          child: Container(
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title section
                                  _buildSectionHeader('Task Details', Icons.description_outlined),
                                  SizedBox(height: 20.h),
                                  _buildLabel('Task Title', Icons.title_rounded),
                                  _buildTextField(
                                    controller: _titleController,
                                    hint: 'e.g. Morning checkup for Bella',
                                    enableVoice: true,
                                    validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
                                  ),
                                  SizedBox(height: 20.h),
                                  _buildLabel('Description', Icons.notes_rounded),
                                  _buildTextField(
                                    controller: _descriptionController,
                                    hint: 'Enter detailed instructions or notes',
                                    maxLines: 4,
                                    enableVoice: true,
                                    validator: (val) => val == null || val.isEmpty ? 'Description is required' : null,
                                  ),
                                  SizedBox(height: 32.h),
                                  
                                  // Assignment section
                                  _buildSectionHeader('Assignment', Icons.people_alt_outlined),
                                  SizedBox(height: 20.h),
                                  _buildLabel('Department', Icons.business_rounded),
                                  _buildDropdown<String>(
                                    value: _selectedDepartmentId,
                                    items: departments.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                                    hint: 'Select Department',
                                    onChanged: widget.initialDepartmentId != null ? null : (val) {
                                      if (val != null && val != _selectedDepartmentId) {
                                        setState(() => _selectedDepartmentId = val);
                                        _fetchEmployees(val);
                                      }
                                    },
                                  ),
                                  SizedBox(height: 20.h),
                                  _buildLabel('Assign To', Icons.person_rounded),
                                  _buildDropdown<String>(
                                    value: _selectedAssigneeId,
                                    items: _availableEmployees.map((e) => DropdownMenuItem(value: e.userId, child: Text(e.fullName))).toList(),
                                    hint: _isLoadingEmployees ? 'Loading...' : _selectedDepartmentId == null ? 'Select Department First' : 'Select Employee',
                                    onChanged: _selectedDepartmentId == null || _isLoadingEmployees ? null : (val) => setState(() => _selectedAssigneeId = val),
                                  ),
                                  SizedBox(height: 32.h),
                                  
                                  // Logistics section
                                  _buildSectionHeader('Logistics', Icons.event_available_outlined),
                                  SizedBox(height: 20.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildLabel('Priority', Icons.flag_rounded),
                                            _buildDropdown<String>(
                                              value: _selectedPriority,
                                              items: _priorities.map((p) => DropdownMenuItem(
                                                value: p,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      p == 'URGENT' ? Icons.error_rounded : p == 'IMPORTANT' ? Icons.warning_rounded : Icons.info_rounded,
                                                      size: 16.sp,
                                                      color: p == 'URGENT' ? Colors.red : p == 'IMPORTANT' ? Colors.orange : Colors.blue,
                                                    ),
                                                    SizedBox(width: 8.w),
                                                    Flexible(
                                                      child: Text(
                                                        p, 
                                                        style: GoogleFonts.inter(fontSize: 13.sp),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )).toList(),
                                              hint: 'Select',
                                              onChanged: (val) => setState(() => _selectedPriority = val!),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildLabel('Due Date', Icons.calendar_today_rounded),
                                            GestureDetector(
                                              onTap: () async {
                                                final picked = await showDatePicker(
                                                  context: context,
                                                  initialDate: _selectedDueDate ?? DateTime.now(),
                                                  firstDate: DateTime.now(),
                                                  lastDate: DateTime(2050),
                                                  builder: (context, child) {
                                                    return Theme(
                                                      data: Theme.of(context).copyWith(
                                                        colorScheme: const ColorScheme.light(
                                                          primary: Color(0xFF0F766E),
                                                        ),
                                                      ),
                                                      child: child!,
                                                    );
                                                  },
                                                );
                                                if (picked != null) {
                                                  setState(() => _selectedDueDate = picked);
                                                }
                                              },
                                              child: Container(
                                                height: 52.h,
                                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF8FAFC),
                                                  borderRadius: BorderRadius.circular(12.r),
                                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      _selectedDueDate == null
                                                          ? 'Optional'
                                                          : '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}',
                                                      style: GoogleFonts.inter(
                                                        color: _selectedDueDate == null ? AppColors.textMuted : AppColors.textMain,
                                                        fontSize: 13.sp,
                                                        fontWeight: _selectedDueDate == null ? FontWeight.normal : FontWeight.w600,
                                                      ),
                                                    ),
                                                    Icon(Icons.calendar_month_rounded, color: const Color(0xFF0F766E), size: 18.w),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 40.h),
                                  
                                  // Create Button
                                  Container(
                                    width: double.infinity,
                                    height: 56.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.r),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0F766E).withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _submitTask,
                                        borderRadius: BorderRadius.circular(16.r),
                                        child: Center(
                                          child: Text(
                                            'Create Task',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFF0F766E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 18.sp, color: const Color(0xFF0F766E)),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: const Color(0xFF64748B)),
          SizedBox(width: 6.w),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool enableVoice = false,
  }) {
    return Consumer<VoiceService>(
      builder: (context, voiceService, _) {
        final bool isThisListening =
            voiceService.isListening && _activeListeningController == controller;

        return TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textMain,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14.sp),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            suffixIcon: enableVoice
                ? IconButton(
                    icon: Icon(
                      isThisListening ? Icons.mic : Icons.mic_none,
                      color: isThisListening ? const Color(0xFF0F766E) : AppColors.textMuted,
                    ),
                    onPressed: () {
                      if (voiceService.isListening) {
                        voiceService.stopListening();
                        if (mounted) {
                          setState(() => _activeListeningController = null);
                        }
                      } else {
                        if (mounted) {
                          setState(() => _activeListeningController = controller);
                        }
                        voiceService.startListening(
                          onResultFinalized: (text) {
                            if (text.isNotEmpty) {
                              controller.text = text;
                            }
                            if (mounted) {
                              setState(() => _activeListeningController = null);
                            }
                          },
                          onResultPartial: (text) {
                            if (text.isNotEmpty) {
                              controller.text = text;
                            }
                          },
                        );
                      }
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        );
      },
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
      isExpanded: true,
      icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF64748B)),
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        color: AppColors.textMain,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: onChanged == null ? const Color(0xFFE2E8F0).withValues(alpha: 0.3) : const Color(0xFFF8FAFC),
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
        ),
      ),
    );
  }
}
