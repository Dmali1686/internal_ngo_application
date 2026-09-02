import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/registration_provider.dart';
import '../models/patient_registration_model.dart';
import '../services/patient_api_service.dart';

class ReviewRegistrationScreen extends StatefulWidget {
  const ReviewRegistrationScreen({super.key});

  @override
  State<ReviewRegistrationScreen> createState() => _ReviewRegistrationScreenState();
}

class _ReviewRegistrationScreenState extends State<ReviewRegistrationScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();
    final data = provider.data;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Review Registration'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Text(
            'Step 6 of 6',
            style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please review the details',
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24.h),
          _buildReviewCard('Reporter Details', Icons.person, {
            'Name': data['reporterName'] ?? '',
            'Phone': data['reporterPhone'] ?? '',
            if (data['reporterId'] != null) 'ID': data['reporterId']!,
          }),
          SizedBox(height: 12.h),
          _buildReviewCard('Rescue Location', Icons.location_on, {
            'Address': data['address'] ?? '',
            'City': data['city'] ?? '',
            if (data['landmark'] != null) 'Landmark': data['landmark']!,
          }),
          SizedBox(height: 12.h),
          _buildReviewCard('Animal Information', Icons.pets, {
            'Type': data['animalType'] ?? '',
            'Breed': data['breed'] ?? '',
            'Age': data['age'] ?? '',
            'Gender': data['gender'] ?? '',
            'Color': data['color'] ?? '',
          }),
          SizedBox(height: 12.h),
          _buildReviewCard('Medical Assessment', Icons.monitor_heart, {
            'Symptoms/Condition': data['condition'] ?? '',
            if (data['diagnosis'] != null && data['diagnosis']!.isNotEmpty) 'Diagnosis': data['diagnosis']!,
            if (data['tests'] != null && data['tests']!.isNotEmpty) 'Tests': data['tests']!,
            'Urgency': data['urgency'] ?? '',
          }),
          SizedBox(height: 12.h),
          _buildReviewCard('Transport & Admission', Icons.directions_car, {
            'Method': data['transportMethod'] ?? '',
            if (data['transporterContact'] != null && data['transporterContact']!.isNotEmpty) 'Contact': data['transporterContact']!,
            if (data['cageNumber'] != null && data['cageNumber']!.isNotEmpty) 'Assigned Cage': data['cageNumber']!,
          }),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _submitRegistration(context, provider),
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
            child: _isLoading 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Submit Registration'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    String title,
    IconData icon,
    Map<String, String> data,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green[700], size: 24.w),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(height: 24.h),
            ...data.entries.map((e) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100.w,
                      child: Text(
                        e.key,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        e.value.isEmpty ? 'Not provided' : e.value,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRegistration(BuildContext context, RegistrationProvider provider) async {
    setState(() => _isLoading = true);

    final data = provider.data;
    double? weightParsed;
    if (provider.weightController.text.isNotEmpty) {
      weightParsed = double.tryParse(provider.weightController.text);
    }

    String mappedGender = 'UNKNOWN';
    final g = data['gender']?.toString().toUpperCase() ?? '';
    if (g == 'MALE' || g == 'FEMALE') {
      mappedGender = g;
    }

    final request = PatientRegistrationRequest(
      reporterName: data['reporterName'],
      reporterMobile: data['reporterPhone'],
      animalAddress: data['address'],
      landmark: data['landmark'],
      animalType: data['animalType'],
      animalName: provider.animalNameController.text.isNotEmpty ? provider.animalNameController.text : null,
      color: data['color'],
      gender: mappedGender,
      age: data['age'],
      weight: weightParsed,
      isSterilized: provider.isSterilized,
      symptoms: data['condition'],
      diagnosis: data['diagnosis'],
      tests: data['tests'],
      transportedBy: data['transportMethod'],
      transporterContact: data['transporterContact'],
      cageNumber: data['cageNumber'],
    );

    try {
      final apiService = PatientApiService();
      final response = await apiService.registerPatient(request: request);

      if (response.success && mounted) {
        context.push('/registration-success');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.errorMessage ?? 'Failed to register patient'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
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
