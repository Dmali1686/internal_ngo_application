import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/patient_api_service.dart';
import '../../../../core/theme/app_colors.dart';

class EditPatientScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const EditPatientScreen({super.key, required this.patient});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final PatientApiService _apiService = PatientApiService();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;

  String? _selectedGender;
  String? _selectedPriority;
  bool _isSterilized = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.patient['animal_name']?.toString() ?? '',
    );
    _ageController = TextEditingController(
      text: widget.patient['age']?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.patient['weight']?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.patient['description']?.toString() ?? '',
    );
    _addressController = TextEditingController(
      text: widget.patient['address']?.toString() ?? '',
    );

    _selectedGender = widget.patient['gender']?.toString();
    if (_selectedGender != 'Male' &&
        _selectedGender != 'Female' &&
        _selectedGender != 'Unknown' &&
        _selectedGender != 'male' &&
        _selectedGender != 'female' &&
        _selectedGender != 'unknown') {
      _selectedGender = 'Unknown';
    } else if (_selectedGender != null) {
      _selectedGender =
          _selectedGender![0].toUpperCase() +
          _selectedGender!.substring(1).toLowerCase();
    }

    _selectedPriority = widget.patient['rescue_priority']
        ?.toString()
        .toLowerCase();
    if (_selectedPriority != 'low' &&
        _selectedPriority != 'medium' &&
        _selectedPriority != 'high') {
      _selectedPriority = 'low';
    }

    _isSterilized = widget.patient['is_sterilized'] == true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdates() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final double? weight = double.tryParse(_weightController.text);

      final updates = {
        "animal_name": _nameController.text.trim(),
        "age": _ageController.text.trim(),
        if (weight != null) "weight": weight,
        "description": _descriptionController.text.trim(),
        "address": _addressController.text.trim(),
        "gender": _selectedGender,
        "rescue_priority": _selectedPriority,
        "is_sterilized": _isSterilized,
      };

      print('========== EDIT PATIENT PATCH REQUEST ==========');
      print('Patient ID: ${widget.patient['id']}');
      print('Payload: $updates');
      print('================================================');

      final response = await _apiService.updatePatient(
        patientId: widget.patient['id'].toString(),
        updates: updates,
      );

      print('========== EDIT PATIENT API RESPONSE ==========');
      print('Success: ${response.success}');
      print('Error Message: ${response.errorMessage}');
      print('Data: ${response.data}');
      print('===============================================');

      if (mounted) {
        setState(() => _isLoading = false);
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Patient updated successfully',
                style: GoogleFonts.nunitoSans(),
              ),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          context.pop(true); // Return true to signal a refresh is needed
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.errorMessage ?? 'Update failed',
                style: GoogleFonts.nunitoSans(),
              ),
              backgroundColor: AppColors.warningRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.nunitoSans()),
            backgroundColor: AppColors.warningRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      appBar: AppBar(
        title: Text(
          'Edit Patient',
          style: GoogleFonts.nunitoSans(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textMain,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Basic Details'),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      'Animal Name',
                      _nameController,
                      required: true,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Age', _ageController)),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTextField(
                            'Weight (kg)',
                            _weightController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            'Gender',
                            _selectedGender,
                            ['Male', 'Female', 'Unknown'],
                            (val) => setState(() => _selectedGender = val),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildDropdown(
                            'Priority',
                            _selectedPriority,
                            ['low', 'medium', 'high'],
                            (val) => setState(() => _selectedPriority = val),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          'Is Sterilized?',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMain,
                          ),
                        ),
                        value: _isSterilized,
                        onChanged: (val) => setState(() => _isSterilized = val),
                        activeColor: AppColors.primaryGreen,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                    ),

                    SizedBox(height: 32.h),
                    _buildSectionTitle('Additional Info'),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      'Address / Location',
                      _addressController,
                      icon: Icons.location_on_outlined,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      'Description / Notes',
                      _descriptionController,
                      maxLines: 3,
                      icon: Icons.notes_outlined,
                    ),

                    SizedBox(height: 40.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitUpdates,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save Changes',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textMain,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.nunitoSans(fontSize: 15.sp, color: AppColors.textMain),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunitoSans(
          color: AppColors.textMuted,
          fontSize: 14.sp,
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.textMuted, size: 20.sp)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppColors.primaryGreen,
            width: 1.5.w,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
      style: GoogleFonts.nunitoSans(fontSize: 15.sp, color: AppColors.textMain),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunitoSans(
          color: AppColors.textMuted,
          fontSize: 14.sp,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppColors.primaryGreen,
            width: 1.5.w,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item.toUpperCase() == item
                ? item
                : (item[0].toUpperCase() + item.substring(1)),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
