import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/registration_provider.dart';

class AnimalInformationScreen extends StatefulWidget {
  const AnimalInformationScreen({super.key});

  @override
  State<AnimalInformationScreen> createState() =>
      _AnimalInformationScreenState();
}

class _AnimalInformationScreenState extends State<AnimalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _animalType = 'Dog';
  String _gender = 'Unknown';
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _colorController = TextEditingController();

  @override
  void dispose() {
    _breedController.dispose();
    _ageController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      context.read<RegistrationProvider>().updateAnimalInformation(
        type: _animalType,
        breed: _breedController.text,
        age: _ageController.text,
        gender: _gender,
        color: _colorController.text,
      );
      context.push('/medical-assessment');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Animal Information'),
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
              'Step 3 of 6',
              style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tell us about the animal',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32.h),
            DropdownButtonFormField<String>(
              value: _animalType,
              items: [
                'Dog',
                'Cat',
                'Bird',
                'Livestock',
                'Other',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _animalType = v!),
              decoration: _inputDecoration('Animal Type', Icons.pets),
            ),
            SizedBox(height: 20.h),
            _buildTextField(
              controller: _breedController,
              label: 'Breed (if known)',
              icon: Icons.category_outlined,
            ),
            SizedBox(height: 20.h),
            _buildTextField(
              controller: _ageController,
              label: 'Approximate Age',
              icon: Icons.cake_outlined,
            ),
            SizedBox(height: 20.h),
            DropdownButtonFormField<String>(
              value: _gender,
              items: [
                'Male',
                'Female',
                'Unknown',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _gender = v!),
              decoration: _inputDecoration(
                'Gender',
                Icons.transgender_outlined,
              ),
            ),
            SizedBox(height: 20.h),
            _buildTextField(
              controller: _colorController,
              label: 'Color / Markings',
              icon: Icons.palette_outlined,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
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
      decoration: _inputDecoration(label, icon),
    );
  }
}
