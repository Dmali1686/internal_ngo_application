import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/registration_provider.dart';

class MedicalAssessmentScreen extends StatefulWidget {
  const MedicalAssessmentScreen({super.key});

  @override
  State<MedicalAssessmentScreen> createState() =>
      _MedicalAssessmentScreenState();
}

class _MedicalAssessmentScreenState extends State<MedicalAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _conditionController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _testsController = TextEditingController();
  String _urgencyLevel = 'Normal';

  @override
  void dispose() {
    _conditionController.dispose();
    _diagnosisController.dispose();
    _testsController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      context.read<RegistrationProvider>().updateMedicalAssessment(
        condition: _conditionController.text,
        diagnosis: _diagnosisController.text,
        tests: _testsController.text,
        urgency: _urgencyLevel,
      );
      context.push('/transport-details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Medical Assessment'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(24.w),
          children: [
            Text(
              'Step 4 of 6',
              style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Initial Medical Assessment',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32.h),
            _buildTextField(
              controller: _conditionController,
              label: 'General Condition',
              icon: Icons.monitor_heart_outlined,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              maxLines: 2,
            ),
            SizedBox(height: 20.h),
            _buildTextField(
              controller: _diagnosisController,
              label: 'Diagnosis (Optional)',
              icon: Icons.healing_outlined,
              maxLines: 3,
            ),
            SizedBox(height: 20.h),
            _buildTextField(
              controller: _testsController,
              label: 'Required Tests (Optional)',
              icon: Icons.science_outlined,
              maxLines: 2,
            ),
            SizedBox(height: 20.h),
            Text(
              'Urgency Level',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildUrgencyChip('Normal', Colors.green),
                SizedBox(width: 8.w),
                _buildUrgencyChip('Urgent', Colors.orange),
                SizedBox(width: 8.w),
                _buildUrgencyChip('Critical', Colors.red),
              ],
            ),
            SizedBox(height: 48.h),
            ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                textStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Next Step'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgencyChip(String label, MaterialColor color) {
    final isSelected = _urgencyLevel == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _urgencyLevel = label),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? color[100] : Colors.grey[100],
            border: Border.all(
              color: isSelected ? color[700]! : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color[900] : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? (maxLines * 8.0) : 0),
          child: Icon(icon, color: Colors.grey[600]),
        ),
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.green[700]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
