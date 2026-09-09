import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TreatmentDashboardScreen extends StatelessWidget {
  const TreatmentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/dashboard-transition');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Treatment Cycle'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Stat Cards
          Row(
            children: [
              Expanded(child: _buildStatCard('Active', '24', Colors.green)),
              SizedBox(width: 16.w),
              Expanded(child: _buildStatCard('Critical', '3', Colors.red)),
            ],
          ),
          SizedBox(height: 24.h),

          Text(
            'Active Treatments',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),

          // List of Patients in Treatment
          _buildPatientTreatmentCard(
            context,
            name: 'Bella',
            id: '#PT-2938',
            diagnosis: 'Tick Fever',
            day: 'Day 3 of 21',
            statusColor: Colors.blue,
            image:
                'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=200&q=80',
          ),
          SizedBox(height: 12.h),
          _buildPatientTreatmentCard(
            context,
            name: 'Max',
            id: '#PT-2939',
            diagnosis: 'Fracture Repair',
            day: 'Day 10 of 45',
            statusColor: Colors.orange,
            image:
                'https://images.unsplash.com/photo-1537151608804-ea9d17d0570b?auto=format&fit=crop&w=200&q=80',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/treatment-plan'),
        backgroundColor: Colors.green[700],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Assign Treatment',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),);
  }

  Widget _buildStatCard(String title, String count, MaterialColor color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color[700],
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            count,
            style: TextStyle(
              color: color[900],
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientTreatmentCard(
    BuildContext context, {
    required String name,
    required String id,
    required String diagnosis,
    required String day,
    required MaterialColor statusColor,
    required String image,
  }) {
    return GestureDetector(
      onTap: () => context.push('/treatment-timeline'),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 30.r, backgroundImage: NetworkImage(image)),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        id,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    diagnosis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor[50],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: statusColor[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
