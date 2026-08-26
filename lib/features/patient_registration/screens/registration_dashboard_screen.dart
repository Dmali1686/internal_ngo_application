import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../services/patient_api_service.dart';

class RegistrationDashboardScreen extends StatefulWidget {
  const RegistrationDashboardScreen({super.key});

  @override
  State<RegistrationDashboardScreen> createState() =>
      _RegistrationDashboardScreenState();
}

class _RegistrationDashboardScreenState
    extends State<RegistrationDashboardScreen> {
  final PatientApiService _apiService = PatientApiService();

  bool _isLoading = true;
  int _admissionsToday = 0;
  int _emergencyToday = 0;
  List<dynamic> _recentPatients = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _apiService.getAdmissionsToday(),
        _apiService.getEmergencyToday(),
        _apiService.listPatients(),
      ]);

      final admissionsRes = results[0];
      final emergencyRes = results[1];
      final patientsRes = results[2];

      print('========== DASHBOARD API LOGS ==========');
      print('Admissions API Response: ${admissionsRes.data}');
      print('Emergency API Response: ${emergencyRes.data}');

      if (patientsRes.data != null) {
        final list = patientsRes.data as List;
        print('Patients API Response: Fetched ${list.length} patients');
        if (list.isNotEmpty) {
          print('First patient: ${list.first}');
        }
      } else {
        print('Patients API Response: null or error');
      }
      print('========================================');

      int parsedAdmissions = 0;
      if (admissionsRes.success && admissionsRes.data != null) {
        parsedAdmissions = admissionsRes.data['count'] ?? 0;
      }

      int parsedEmergency = 0;
      if (emergencyRes.success && emergencyRes.data != null) {
        parsedEmergency = emergencyRes.data['count'] ?? 0;
      }

      List<dynamic> parsedPatients = [];
      if (patientsRes.success && patientsRes.data != null) {
        parsedPatients = List<dynamic>.from(patientsRes.data);
      }

      if (mounted) {
        setState(() {
          _admissionsToday = parsedAdmissions;
          _emergencyToday = parsedEmergency;
          _recentPatients = parsedPatients;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Patient Registration'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: CircleAvatar(
              radius: 16.r,
              backgroundImage: const NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuD4X8v89VRtlb3VS5i1TxxwRn1QLNGK4jGkTgrcDF5VnK3Z5Jw_maTE0-r621TXfOlmYNQqnM02Ds6NUstjD6NrFx8W8dwT3oIZbMbgawE0IBR0ILnHOytlRGoRgJ0L37HUIblDfldgEDKlzqz-AZ97PdDHTHXLNEZjRXnv_pfka5dMAOkg_jcYtPyyJgtpQeLj3h3nqS_msnJlOS94WvSEIM5rzv0CvtbbABgkfIsrKmTum6JtcCia3g',
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(),
                    SizedBox(height: 24.h),
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildQuickActions(context),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Admissions',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _buildRecentAdmissions(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/new-registration'),
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Today\'s Admissions',
            _admissionsToday.toString(),
            Icons.pets,
            Colors.green[50]!,
            Colors.green[700]!,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildSummaryCard(
            'Emergency',
            _emergencyToday.toString(),
            Icons.warning_amber_rounded,
            Colors.red[50]!,
            Colors.red[700]!,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String count,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28.w),
          SizedBox(height: 12.h),
          Text(
            count,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 2.5,
      children: [
        _buildActionBtn(
          context,
          'New Reg.',
          Icons.add_circle,
          Colors.green[700]!,
          Colors.white,
          '/new-registration',
        ),
        _buildActionBtn(
          context,
          'Scan QR',
          Icons.qr_code_scanner,
          Colors.white,
          Colors.black87,
          '/qr-scanner',
        ),
      ],
    );
  }

  Widget _buildActionBtn(
    BuildContext context,
    String title,
    IconData icon,
    Color bgColor,
    Color textColor,
    String route,
  ) {
    return InkWell(
      onTap: () => context.push(route),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
          border: bgColor == Colors.white
              ? Border.all(color: Colors.grey[300]!)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20.w),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAdmissions() {
    if (_recentPatients.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Text(
            'No recent admissions found.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Column(
      children: _recentPatients.take(5).map((patient) {
        final name = patient['animal_name'] ?? 'Unknown';
        final status = patient['status'] ?? 'pending';
        // You might need a helper to format details nicely depending on the backend payload
        final details =
            'Age: ${patient['age'] ?? 'Unknown'} • Gender: ${patient['gender'] ?? 'Unknown'}';

        MaterialColor statusColor;
        switch (status.toString().toLowerCase()) {
          case 'pending':
          case 'admitted':
            statusColor = Colors.orange;
            break;
          case 'treatment':
          case 'icu':
            statusColor = Colors.red;
            break;
          case 'recovered':
          case 'released':
            statusColor = Colors.green;
            break;
          default:
            statusColor = Colors.blue;
        }

        return _buildPatientCard(
          name: name,
          details: details,
          status: status.toString().toUpperCase(),
          statusColor: statusColor,
          patientMap: patient,
        );
      }).toList(),
    );
  }

  Widget _buildPatientCard({
    required String name,
    required String details,
    required String status,
    required MaterialColor statusColor,
    required Map<String, dynamic> patientMap,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        onTap: () async {
          final shouldRefresh = await context.push(
            '/edit-patient',
            extra: patientMap,
          );
          if (shouldRefresh == true) {
            _fetchDashboardData();
          }
        },
        contentPadding: EdgeInsets.all(12.w),
        leading: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: const Icon(Icons.pets, color: Colors.grey),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: statusColor[50],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor[700],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            details,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}
