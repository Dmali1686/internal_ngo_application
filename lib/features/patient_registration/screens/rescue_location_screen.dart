import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/registration_provider.dart';

class RescueLocationScreen extends StatefulWidget {
  const RescueLocationScreen({super.key});

  @override
  State<RescueLocationScreen> createState() => _RescueLocationScreenState();
}

class _RescueLocationScreenState extends State<RescueLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _landmarkController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      context.read<RegistrationProvider>().updateRescueLocation(
        address: _addressController.text,
        city: _cityController.text,
        landmark: _landmarkController.text.isEmpty
            ? null
            : _landmarkController.text,
      );
      context.push('/animal-information');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Rescue Location'),
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
              'Step 2 of 6',
              style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Where was the animal found?',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32.h),
            _buildTextField(
              controller: _addressController,
              label: 'Street Address',
              icon: Icons.location_on_outlined,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 20.h),
            _buildTextField(
              controller: _cityController,
              label: 'City / Area',
              icon: Icons.location_city_outlined,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 20.h),
            _buildTextField(
              controller: _landmarkController,
              label: 'Nearby Landmark (Optional)',
              icon: Icons.flag_outlined,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
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
