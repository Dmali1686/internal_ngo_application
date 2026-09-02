import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/registration_provider.dart';

class TransportDetailsScreen extends StatefulWidget {
  const TransportDetailsScreen({super.key});

  @override
  State<TransportDetailsScreen> createState() => _TransportDetailsScreenState();
}

class _TransportDetailsScreenState extends State<TransportDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _transportMethod = 'Ambulance';
  final _transporterContactController = TextEditingController();
  final _cageNumberController = TextEditingController();

  @override
  void dispose() {
    _transporterContactController.dispose();
    _cageNumberController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      context.read<RegistrationProvider>().updateTransportDetails(
        method: _transportMethod,
        contact: _transporterContactController.text,
        cage: _cageNumberController.text,
      );
      context.push('/review-registration');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Transport Details'),
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
              'Step 5 of 6',
              style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'How will the animal arrive?',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32.h),
            _buildTransportCard(
              title: 'NGO Ambulance',
              subtitle: 'Dispatch an ambulance to the location',
              icon: Icons.local_hospital_outlined,
              value: 'Ambulance',
            ),
            SizedBox(height: 16.h),
            _buildTransportCard(
              title: 'Walk-in / Citizen Drop-off',
              subtitle: 'The reporter will bring the animal to the hospital',
              icon: Icons.directions_walk_outlined,
              value: 'Walk-in',
            ),
            SizedBox(height: 16.h),
            _buildTransportCard(
              title: 'Volunteer Transport',
              subtitle: 'A registered volunteer is handling transport',
              icon: Icons.volunteer_activism_outlined,
              value: 'Volunteer',
            ),
            SizedBox(height: 24.h),
            TextFormField(
              controller: _transporterContactController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Transporter Contact Number (Optional)',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _cageNumberController,
              decoration: InputDecoration(
                labelText: 'Assign Cage Number (Optional)',
                prefixIcon: const Icon(Icons.meeting_room_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
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

  Widget _buildTransportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _transportMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _transportMethod = value),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[50] : Colors.grey[50],
          border: Border.all(
            color: isSelected ? Colors.green[700]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32.w,
              color: isSelected ? Colors.green[700] : Colors.grey[600],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.green[900] : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: Colors.green[700]),
          ],
        ),
      ),
    );
  }
}
