import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/registration_provider.dart';

class ReviewRegistrationScreen extends StatelessWidget {
  const ReviewRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<RegistrationProvider>().data;

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
            'Condition': data['condition'] ?? '',
            'Injuries': data['injuries'] ?? '',
            'Urgency': data['urgency'] ?? '',
          }),
          SizedBox(height: 12.h),
          _buildReviewCard('Transport Details', Icons.directions_car, {
            'Method': data['transportMethod'] ?? '',
          }),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: () {
              // Simulate API call
              context.push('/registration-success');
            },
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
            child: const Text('Submit Registration'),
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
}
