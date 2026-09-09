import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/patient_registration/services/patient_api_service.dart';
import '../../../features/patient_registration/models/patient_registration_model.dart';

class TreatmentHistoryScreen extends StatefulWidget {
  const TreatmentHistoryScreen({super.key});

  @override
  State<TreatmentHistoryScreen> createState() => _TreatmentHistoryScreenState();
}

class _TreatmentHistoryScreenState extends State<TreatmentHistoryScreen> {
  final PatientApiService _apiService = PatientApiService();

  List<TreatmentModel> _treatments = [];
  bool _isLoading = true;
  String? _error;
  String? _patientId;
  String? _patientName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_patientId == null) {
      _init();
    }
  }

  void _init() {
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic>) {
      _patientId = extra['patient_id']?.toString();
      _patientName = extra['patient_name']?.toString();
    } else if (extra is String) {
      _patientId = extra;
    }

    if (_patientId != null) {
      _fetchTreatments();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'No patient ID provided.';
      });
    }
  }

  Future<void> _fetchTreatments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final res = await _apiService.getTreatmentHistory(_patientId!);
    if (!mounted) return;

    if (res.success) {
      List<dynamic> list = [];
      final raw = res.data;
      if (raw is Map<String, dynamic>) {
        final inner = raw['data'];
        list = (inner is List) ? inner : [];
      } else if (raw is List) {
        list = raw;
      }

      setState(() {
        _treatments = list
            .map((t) => TreatmentModel.fromJson(t as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = res.errorMessage ?? 'Failed to load treatment history.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _patientName != null
              ? '${_patientName!}\'s Treatments'
              : 'Treatment History',
          style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTreatments,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.w, color: Colors.red[300]),
              SizedBox(height: 16.h),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(color: Colors.grey[600]),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: _fetchTreatments,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_treatments.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.medical_services_outlined,
                  size: 64.w, color: Colors.grey[300]),
              SizedBox(height: 16.h),
              Text(
                'No treatment records yet.',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Treatment records will appear here\nonce added by a doctor.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 13.sp,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchTreatments,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _treatments.length,
        itemBuilder: (ctx, index) => _buildTreatmentCard(
          _treatments[index],
          isFirst: index == 0,
        ),
      ),
    );
  }

  Widget _buildTreatmentCard(TreatmentModel t, {bool isFirst = false}) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: isFirst
              ? const Color(0xFF006E1C).withOpacity(0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isFirst
                        ? const Color(0xFF006E1C).withOpacity(0.1)
                        : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medical_services,
                    color: isFirst
                        ? const Color(0xFF006E1C)
                        : Colors.grey[600],
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFirst)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF006E1C),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'LATEST',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 10.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      SizedBox(height: isFirst ? 4.h : 0),
                      if (t.treatmentDate != null)
                        Text(
                          _formatDate(t.treatmentDate!),
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12.sp,
                            color: isFirst
                                ? const Color(0xFF006E1C)
                                : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Diagnosis
            Text(
              'Diagnosis',
              style: GoogleFonts.nunitoSans(
                fontSize: 11.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              t.diagnosis,
              style: GoogleFonts.nunitoSans(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B1C1C),
              ),
            ),

            // Medicines
            if (t.medicines.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Text(
                'Prescribed Medicines',
                style: GoogleFonts.nunitoSans(
                  fontSize: 11.sp,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8.h),
              ...t.medicines.map((m) => _buildMedicineRow(m)),
            ] else ...[
              SizedBox(height: 8.h),
              Text(
                'No medicines prescribed.',
                style: GoogleFonts.nunitoSans(
                  fontSize: 13.sp,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineRow(MedicineModel m) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.medication, color: Colors.green[800], size: 18.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.medicineName,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${m.dosage} • ${m.frequency} • ${m.duration}',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}
