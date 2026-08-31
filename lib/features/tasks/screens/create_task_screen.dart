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
import '../providers/task_form_provider.dart';
import '../services/task_voice_assistant.dart';
import '../../../core/services/voice_service.dart';
import '../../../core/widgets/global_voice_button.dart';

class CreateTaskScreen extends StatefulWidget {
  final String? initialDepartmentId;
  final String? initialAssigneeId;
  final String? initialAssigneeName;

  const CreateTaskScreen({
    super.key,
    this.initialDepartmentId,
    this.initialAssigneeId,
    this.initialAssigneeName,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TaskFormProvider _formProvider;
  late final TaskVoiceAssistant _voiceAssistant;

  final List<String> _priorities = ['NORMAL', 'IMPORTANT', 'URGENT'];
  bool _isSubmitting = false;

  final OrgApiService _orgApiService = OrgApiService();
  List<OrgEmployee> _availableEmployees = [];
  bool _isLoadingEmployees = false;

  @override
  void initState() {
    super.initState();
    _formProvider = TaskFormProvider();
    _formProvider.addListener(() {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final voiceService = context.read<VoiceService>();
      _voiceAssistant = TaskVoiceAssistant(voiceService, _formProvider);
    });
    
    if (widget.initialDepartmentId != null) {
      _formProvider.setDepartmentId(widget.initialDepartmentId);
      _fetchEmployees(widget.initialDepartmentId!);
    }
    // Pre-fill assignee if provided (e.g., tapped from unassigned list)
    if (widget.initialAssigneeId != null) {
      _formProvider.setAssigneeId(widget.initialAssigneeId);
    }
  }

  Future<void> _fetchEmployees(String departmentId) async {
    setState(() {
      _isLoadingEmployees = true;
      _availableEmployees = [];
      _formProvider.setAssigneeId(null);
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
          
          // If we tapped an unassigned user, they won't be in the department's team.
          // Inject them so the DropdownButton doesn't crash on a missing value.
          if (widget.initialAssigneeId != null && 
              departmentId == widget.initialDepartmentId &&
              !seen.contains(widget.initialAssigneeId)) {
            _availableEmployees.add(
              OrgEmployee(
                userId: widget.initialAssigneeId!,
                fullName: widget.initialAssigneeName ?? 'Unknown User',
                email: '',
                employeeCode: '',
                positionName: 'Unassigned',
                tags: const [],
              ),
            );
          }
          
          // Restore the initial assignee selection after fetching
          if (widget.initialAssigneeId != null && departmentId == widget.initialDepartmentId) {
            _formProvider.setAssigneeId(widget.initialAssigneeId);
          }
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
    // Abort any running voice session so the assistant stops when navigating away
    _voiceAssistant.abort();
    _formProvider.dispose();
    super.dispose();
  }

  Future<void> _submitTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_formProvider.selectedDepartmentId == null || _formProvider.selectedAssigneeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a department and assignee.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final provider = context.read<TaskProvider>();
    final success = await provider.createTask(
      title: _formProvider.titleController.text.trim(),
      description: _formProvider.descriptionController.text.trim(),
      priority: _formProvider.selectedPriority,
      departmentId: _formProvider.selectedDepartmentId!,
      assignedToId: _formProvider.selectedAssigneeId!,
      dueDate: _formProvider.selectedDueDate?.toUtc().toIso8601String(),
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

    return GlobalVoiceButton(
      child: Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Header Background
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'New Task',
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Consumer<VoiceService>(
                        builder: (context, voiceService, _) {
                          return IconButton(
                            icon: Icon(
                              voiceService.isVoiceModeActive ? Icons.mic : Icons.mic_none,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                            onPressed: () {
                              if (voiceService.isVoiceModeActive) {
                                voiceService.abortVoice();
                              } else {
                                _voiceAssistant.startVoiceFlow();
                              }
                            },
                          );
                        },
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
                                    controller: _formProvider.titleController,
                                    focusNode: _formProvider.titleFocus,
                                    hint: 'e.g. Morning checkup for Bella',
                                    validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
                                    isActiveVoiceField: _formProvider.activeVoiceField == 'title',
                                  ),
                                  SizedBox(height: 20.h),
                                  _buildLabel('Description', Icons.notes_rounded),
                                  _buildTextField(
                                    controller: _formProvider.descriptionController,
                                    focusNode: _formProvider.descriptionFocus,
                                    hint: 'Enter detailed instructions or notes',
                                    maxLines: 4,
                                    validator: (val) => val == null || val.isEmpty ? 'Description is required' : null,
                                    isActiveVoiceField: _formProvider.activeVoiceField == 'description',
                                  ),
                                  SizedBox(height: 32.h),
                                  
                                  // Assignment section
                                  _buildSectionHeader('Assignment', Icons.people_alt_outlined),
                                  SizedBox(height: 20.h),
                                  _buildLabel('Department', Icons.business_rounded),
                                  _buildDropdown<String>(
                                    value: _formProvider.selectedDepartmentId,
                                    items: departments.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                                    hint: 'Select Department',
                                    onChanged: widget.initialDepartmentId != null ? null : (val) {
                                      if (val != null && val != _formProvider.selectedDepartmentId) {
                                        setState(() => _formProvider.setDepartmentId(val));
                                        _fetchEmployees(val);
                                      }
                                    },
                                    isActiveVoiceField: _formProvider.activeVoiceField == 'department',
                                  ),
                                  SizedBox(height: 20.h),
                                  _buildLabel('Assign To', Icons.person_rounded),
                                  _buildDropdown<String>(
                                    value: _formProvider.selectedAssigneeId,
                                    items: _availableEmployees.map((e) => DropdownMenuItem(value: e.userId, child: Text(e.fullName))).toList(),
                                    hint: _isLoadingEmployees ? 'Loading...' : _formProvider.selectedDepartmentId == null ? 'Select Department First' : 'Select Employee',
                                    onChanged: _formProvider.selectedDepartmentId == null || _isLoadingEmployees ? null : (val) => setState(() => _formProvider.setAssigneeId(val)),
                                    isActiveVoiceField: _formProvider.activeVoiceField == 'assignee',
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
                                              value: _formProvider.selectedPriority,
                                              isActiveVoiceField: _formProvider.activeVoiceField == 'priority',
                                              onChanged: (val) {
                                                if (val != null) setState(() => _formProvider.setPriority(val));
                                              },
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
                                                  initialDate: _formProvider.selectedDueDate ?? DateTime.now(),
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
                                                  setState(() => _formProvider.setDueDate(picked));
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
                                                      _formProvider.selectedDueDate == null
                                                          ? 'Optional'
                                                          : '${_formProvider.selectedDueDate!.day}/${_formProvider.selectedDueDate!.month}/${_formProvider.selectedDueDate!.year}',
                                                      style: GoogleFonts.inter(
                                                        color: _formProvider.selectedDueDate == null ? AppColors.textMuted : AppColors.textMain,
                                                        fontSize: 13.sp,
                                                        fontWeight: _formProvider.selectedDueDate == null ? FontWeight.normal : FontWeight.w600,
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
    FocusNode? focusNode,
    bool enableVoice = false,
    bool isActiveVoiceField = false,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
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
        border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: isActiveVoiceField ? const Color(0xFF0F766E) : const Color(0xFFE2E8F0), width: isActiveVoiceField ? 2.0 : 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: isActiveVoiceField ? const Color(0xFF0F766E) : const Color(0xFFE2E8F0), width: isActiveVoiceField ? 2.0 : 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFF0F766E), width: 2.0),
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
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required String hint,
    required void Function(T?)? onChanged,
    bool isActiveVoiceField = false,
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
          borderSide: BorderSide(color: isActiveVoiceField ? const Color(0xFF0F766E) : const Color(0xFFE2E8F0), width: isActiveVoiceField ? 2.0 : 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: isActiveVoiceField ? const Color(0xFF0F766E) : const Color(0xFFE2E8F0), width: isActiveVoiceField ? 2.0 : 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF0F766E), width: 2.0),
        ),
      ),
    );
  }
}
