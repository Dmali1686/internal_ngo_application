import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/widgets/text_to_speech_player.dart';
import '../../../features/patient_registration/services/patient_api_service.dart';
import '../../../features/patient_registration/models/patient_registration_model.dart';

class AnimalOverviewScreen extends StatefulWidget {
  const AnimalOverviewScreen({super.key});

  @override
  State<AnimalOverviewScreen> createState() => _AnimalOverviewScreenState();
}

class _AnimalOverviewScreenState extends State<AnimalOverviewScreen> {
  final PatientApiService _apiService = PatientApiService();

  PatientModel? _patient;
  List<TreatmentModel> _treatments = [];
  bool _isLoading = true;
  bool _treatmentsLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_patient == null) {
      _loadPatient();
    }
  }

  Future<void> _loadPatient() async {
    final extra = GoRouterState.of(context).extra;
    Map<String, dynamic>? initialMap;
    if (extra is Map<String, dynamic>) {
      initialMap = extra;
    }

    setState(() => _isLoading = true);

    final patientId = initialMap?['id']?.toString();

    if (patientId != null && patientId.isNotEmpty) {
      final res = await _apiService.getPatientById(patientId);
      if (res.success && res.data != null) {
        Map<String, dynamic>? src;
        final raw = res.data;
        if (raw is Map<String, dynamic>) {
          final inner = raw['data'];
          src = (inner is Map<String, dynamic>) ? inner : raw;
        }
        if (src != null && mounted) {
          setState(() {
            _patient = PatientModel.fromJson(src!);
            _isLoading = false;
          });
          _loadTreatments(patientId);
          return;
        }
      }
    }

    // Fallback: use the passed map directly
    if (initialMap != null && mounted) {
      setState(() {
        _patient = PatientModel.fromJson(initialMap!);
        _isLoading = false;
      });
      if (patientId != null) _loadTreatments(patientId);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTreatments(String patientId) async {
    setState(() => _treatmentsLoading = true);
    final res = await _apiService.getTreatmentHistory(patientId);
    if (res.success && res.data != null && mounted) {
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
        _treatmentsLoading = false;
      });
    } else {
      if (mounted) setState(() => _treatmentsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Patient Profile'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_patient == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Patient Profile'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: Text('Patient data not available')),
      );
    }

    final p = _patient!;
    final displayName = p.animalName?.isNotEmpty == true
        ? p.animalName!
        : p.animalType;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          displayName,
          style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
            children: [
              _buildPatientHeader(p, displayName),
              SizedBox(height: 16.h),
              _buildExpansionTile(
                title: 'Basic Details',
                icon: Icons.pets,
                initiallyExpanded: true,
                content: _buildBasicInfo(p),
              ),
              SizedBox(height: 12.h),
              _buildExpansionTile(
                title: 'Rescue Information',
                icon: Icons.volunteer_activism,
                content: _buildRescueInfo(p),
              ),
              if (_treatments.isNotEmpty || _treatmentsLoading) ...[
                SizedBox(height: 12.h),
                _buildExpansionTile(
                  title: 'Treatment History (${_treatments.length})',
                  icon: Icons.medical_services,
                  content: _buildTreatmentSummary(),
                ),
              ],
              if (p.symptoms != null && p.symptoms!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                _buildExpansionTile(
                  title: 'Initial Assessment',
                  icon: Icons.assignment,
                  content: _buildInitialAssessment(p),
                ),
              ],
            ],
          ),

          // Sticky Bottom Actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        onPressed: () => _shareQrCode(context, p),
                        icon: const Icon(Icons.qr_code_2, size: 18),
                        label: const Text('QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[50],
                          foregroundColor: Colors.green[700],
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push(
                          '/treatment-history',
                          extra: {'patient_id': p.id, 'patient_name': displayName},
                        ),
                        icon: const Icon(Icons.medical_services, size: 18),
                        label: const Text('Treatments'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareQrCode(BuildContext context, PatientModel p) async {
    final hasQr = p.qrPayload != null && p.qrPayload!.isNotEmpty;
    if (!hasQr) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR Code payload is not available for this patient.')),
      );
      return;
    }

    try {
      // Show loading indicator in snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating QR Code...'), duration: Duration(seconds: 1)),
      );

      final qrValidationResult = QrValidator.validate(
        data: p.qrPayload!,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode;
        final painter = QrPainter.withQr(
          qr: qrCode!,
          color: const Color(0xFF000000),
          emptyColor: const Color(0xFFFFFFFF),
          gapless: true,
        );

        final picData = await painter.toImageData(2048, format: ui.ImageByteFormat.png);
        if (picData != null) {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/${p.caseId}_QR.png');
          await file.writeAsBytes(picData.buffer.asUint8List());

          if (context.mounted) {
            final box = context.findRenderObject() as RenderBox?;
            await Share.shareXFiles(
              [XFile(file.path)],
              text: 'QR Code for Patient ${p.caseId}',
              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to generate QR Code.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildPatientHeader(PatientModel p, String displayName) {
    Color statusColor;
    switch (p.status.toUpperCase()) {
      case 'ADMITTED':
        statusColor = Colors.orange;
        break;
      case 'RELEASED':
        statusColor = Colors.green;
        break;
      case 'TREATMENT':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40.r,
                backgroundColor: Colors.green[50],
                child: Text(
                  (p.animalType.isNotEmpty ? p.animalType[0] : '?'),
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.tag, size: 14.sp, color: Colors.grey[500]),
                        SizedBox(width: 4.w),
                        Text(
                          p.caseId,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        p.status,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (p.cageNumber != null) ...[
            SizedBox(height: 16.h),
            const Divider(),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.meeting_room, size: 16.sp, color: Colors.grey[500]),
                SizedBox(width: 8.w),
                Text(
                  'Cage: ${p.cageNumber}',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBasicInfo(PatientModel p) {
    return Column(
      children: [
        _row4(
          'Type', p.animalType,
          'Age', p.age ?? 'Unknown',
          'Weight', p.weight != null ? '${p.weight} kg' : 'N/A',
          'Gender', p.gender ?? 'Unknown',
        ),
        SizedBox(height: 12.h),
        _row4(
          'Color', p.color ?? 'N/A',
          'Sterilized', p.isSterilized == true ? 'Yes' : 'No',
          '', '',
          '', '',
        ),
      ],
    );
  }

  Widget _row4(String l1, String v1, String l2, String v2, String l3,
      String v3, String l4, String v4) {
    return Row(
      children: [
        if (l1.isNotEmpty) Expanded(child: _dataPoint(l1, v1)),
        if (l2.isNotEmpty) Expanded(child: _dataPoint(l2, v2)),
        if (l3.isNotEmpty) Expanded(child: _dataPoint(l3, v3)),
        if (l4.isNotEmpty) Expanded(child: _dataPoint(l4, v4)),
      ],
    );
  }

  Widget _dataPoint(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey[600], fontSize: 11.sp)),
          SizedBox(height: 2.h),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13.sp)),
        ],
      ),
    );
  }

  Widget _buildRescueInfo(PatientModel p) {
    return Column(
      children: [
        if (p.admissionDate != null)
          _iconRow(Icons.calendar_today, 'Admitted',
              _formatDate(p.admissionDate!)),
        if (p.animalAddress != null) ...[
          SizedBox(height: 12.h),
          _iconRow(Icons.location_on, 'Found At', p.animalAddress!),
        ],
        if (p.landmark != null) ...[
          SizedBox(height: 12.h),
          _iconRow(Icons.place, 'Landmark', p.landmark!),
        ],
        if (p.reporterName != null) ...[
          SizedBox(height: 12.h),
          _iconRow(Icons.person, 'Reporter', p.reporterName!),
        ],
        if (p.reporterMobile != null) ...[
          SizedBox(height: 12.h),
          _iconRow(Icons.phone, 'Reporter Mobile', p.reporterMobile!),
        ],
        if (p.transportedBy != null) ...[
          SizedBox(height: 12.h),
          _iconRow(Icons.local_shipping, 'Transported By', p.transportedBy!),
        ],
      ],
    );
  }

  Widget _buildInitialAssessment(PatientModel p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (p.symptoms != null && p.symptoms!.isNotEmpty) ...[
          Text('Symptoms',
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 4.h),
          Text(p.symptoms!,
              style: TextStyle(fontSize: 14.sp, height: 1.5)),
          TextToSpeechPlayer(text: p.symptoms!),
          SizedBox(height: 12.h),
        ],
        if (p.diagnosis != null && p.diagnosis!.isNotEmpty) ...[
          Text('Diagnosis',
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 4.h),
          Text(p.diagnosis!,
              style: TextStyle(fontSize: 14.sp, height: 1.5)),
        ],
        if (p.tests != null && p.tests!.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Text('Tests Ordered',
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 4.h),
          Text(p.tests!, style: TextStyle(fontSize: 14.sp)),
        ],
      ],
    );
  }

  Widget _buildTreatmentSummary() {
    if (_treatmentsLoading) {
      return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ));
    }
    return Column(
      children: _treatments.take(3).map((t) {
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(Icons.medical_services, color: Colors.green[700], size: 20.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.diagnosis,
                        style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    if (t.treatmentDate != null)
                      Text(_formatDate(t.treatmentDate!),
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.grey[600])),
                    if (t.medicines.isNotEmpty)
                      Text('${t.medicines.length} medicine(s)',
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.green[700])),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _iconRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey[500]),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11.sp, color: Colors.grey[500])),
              Text(value,
                  style: TextStyle(
                      fontSize: 14.sp, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required IconData icon,
    required Widget content,
    bool initiallyExpanded = false,
  }) {
    return Card(
      elevation: 0,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Icon(icon, color: Colors.green[700]),
          title: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          children: [
            Padding(padding: EdgeInsets.all(16.w), child: content)
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
