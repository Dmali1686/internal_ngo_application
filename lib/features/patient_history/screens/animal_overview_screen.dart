import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/text_to_speech_player.dart';
import '../../../features/patient_registration/services/patient_api_service.dart';
import '../../../features/patient_registration/models/patient_registration_model.dart';

class AnimalOverviewScreen extends StatefulWidget {
  const AnimalOverviewScreen({super.key});

  @override
  State<AnimalOverviewScreen> createState() => _AnimalOverviewScreenState();
}

class _AnimalOverviewScreenState extends State<AnimalOverviewScreen>
    with SingleTickerProviderStateMixin {
  final PatientApiService _apiService = PatientApiService();

  PatientModel? _patient;
  List<TreatmentModel> _treatments = [];
  bool _isLoading = true;
  bool _treatmentsLoading = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Map<String, Color> _statusColors = {
    'ADMITTED': Color(0xFF2563EB),
    'UNDER_TREATMENT': Color(0xFFF59E0B),
    'READY_FOR_RELEASE': Color(0xFF10B981),
    'RELEASED': Color(0xFF6366F1),
    'ADOPTED': Color(0xFF34A853),
    'DECEASED': Color(0xFF9CA3AF),
  };
  static const Map<String, String> _statusLabels = {
    'ADMITTED': 'Admitted',
    'UNDER_TREATMENT': 'Under Treatment',
    'READY_FOR_RELEASE': 'Ready for Release',
    'RELEASED': 'Released',
    'ADOPTED': 'Adopted',
    'DECEASED': 'Deceased',
  };

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_patient == null) {
      _loadPatient();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
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
      try {
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
            _animCtrl.forward();
            _loadTreatments(patientId);
            return;
          }
        }
      } catch (e) {
        debugPrint('Error loading patient: $e');
      }
    }

    if (initialMap != null && mounted) {
      setState(() {
        _patient = PatientModel.fromJson(initialMap!);
        _isLoading = false;
      });
      _animCtrl.forward();
      if (patientId != null) _loadTreatments(patientId);
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTreatments(String patientId) async {
    setState(() => _treatmentsLoading = true);
    try {
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
        return;
      }
    } catch (e) {
      debugPrint('Error loading treatments: $e');
    }
    
    if (mounted) setState(() => _treatmentsLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLightGray,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1B6B3A), Color(0xFFF4F6F8)],
              stops: [0.0, 0.35],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    if (_patient == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLightGray,
        appBar: AppBar(
          title: const Text('Patient Profile'),
          backgroundColor: const Color(0xFF2E8B57),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: Text('Patient data not available')),
      );
    }

    final p = _patient!;
    final displayName = (p.animalName != null && p.animalName!.isNotEmpty)
        ? p.animalName!
        : p.animalType;
    final statusLabel = _statusLabels[p.status.toUpperCase()] ?? p.status;

    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Gradient Header ────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 270.h,
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFF2E8B57),
                leading: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: IconButton(
                        icon: const Icon(Icons.qr_code_2, color: Colors.white),
                        onPressed: () => _showQrPopup(context, p),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1B6B3A),
                          Color(0xFF2E8B57),
                          Color(0xFF34A853),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 20.h),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2.5.w),
                                  ),
                                  child: CircleAvatar(
                                    radius: 40.r,
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    child: Text(
                                      p.animalType.isNotEmpty
                                          ? p.animalType[0].toUpperCase()
                                          : '?',
                                      style: GoogleFonts.poppins(
                                        fontSize: 30.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
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
                                        style: GoogleFonts.poppins(
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        '${p.animalType}  •  ${p.gender ?? 'Unknown'}  •  ${p.age ?? 'Unknown Age'}',
                                        style: GoogleFonts.nunitoSans(
                                          fontSize: 13.sp,
                                          color: Colors.white.withOpacity(0.85),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20.r),
                                          border: Border.all(color: Colors.white38),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.healing,
                                                size: 13, color: Colors.white),
                                            SizedBox(width: 4.w),
                                            Text(
                                              statusLabel,
                                              style: GoogleFonts.nunitoSans(
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              children: [
                                _chip(Icons.tag,
                                    p.caseId.isEmpty ? 'No Case ID' : p.caseId),
                                SizedBox(width: 10.w),
                                _chip(Icons.meeting_room, p.cageNumber ?? 'Unassigned'),
                                SizedBox(width: 10.w),
                                _chip(Icons.calendar_today,
                                    _getDaysAdmitted(p.admissionDate)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 140.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Animal Info Grid
                          _sectionTitle('Animal Information'),
                          SizedBox(height: 10.h),
                          _infoGrid([
                            _gridTile(Icons.pets, 'Type', p.animalType, const Color(0xFF34A853)),
                            _gridTile(Icons.palette, 'Color', p.color ?? 'N/A', const Color(0xFFEC4899)),
                            _gridTile(Icons.cake, 'Age', p.age ?? 'Unknown', const Color(0xFFF59E0B)),
                            _gridTile(Icons.monitor_weight, 'Weight',
                                p.weight != null ? '${p.weight} kg' : 'N/A', const Color(0xFF3B82F6)),
                            _gridTile(Icons.wc, 'Gender', p.gender ?? 'Unknown', const Color(0xFF8B5CF6)),
                            _gridTile(Icons.medical_services, 'Sterilized',
                                p.isSterilized == true ? 'Yes' : 'No',
                                p.isSterilized == true
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444)),
                          ]),
                          SizedBox(height: 20.h),

                          // Rescue Info
                          _sectionTitle('Rescue Information'),
                          SizedBox(height: 10.h),
                          _rescueCard(p),
                          SizedBox(height: 20.h),

                          // Medical Assessment
                          if ((p.symptoms != null && p.symptoms!.isNotEmpty) ||
                              (p.diagnosis != null && p.diagnosis!.isNotEmpty) ||
                              (p.tests != null && p.tests!.isNotEmpty)) ...[
                            _sectionTitle('Medical Assessment'),
                            SizedBox(height: 10.h),
                            _medCard(p),
                            SizedBox(height: 20.h),
                          ],

                          // Treatment History
                          if (_treatments.isNotEmpty || _treatmentsLoading) ...[
                            _sectionTitle('Treatment History'),
                            SizedBox(height: 10.h),
                            if (_treatmentsLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF34A853)),
                                ),
                              )
                            else
                              ..._treatments.take(3).map(_treatmentCard),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom Buttons ─────────────────────────────────────────────
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
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: () => _showQrPopup(context, _patient!),
                        icon: Icon(Icons.qr_code_2,
                            size: 18.sp, color: AppColors.primaryGreen),
                        label: Text('QR',
                            style: GoogleFonts.nunitoSans(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryGreen)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: AppColors.primaryGreen, width: 1.5),
                          padding: EdgeInsets.symmetric(vertical: 13.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push(
                          '/treatment-history',
                          extra: {
                            'patient_id': _patient!.id,
                            'patient_name': displayName
                          },
                        ),
                        icon: Icon(Icons.medical_services,
                            size: 18.sp, color: Colors.white),
                        label: Text('Treatments',
                            style: GoogleFonts.nunitoSans(
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: EdgeInsets.symmetric(vertical: 13.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r)),
                          elevation: 0,
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

  // ─── QR Popup ────────────────────────────────────────────────────────────

  void _showQrPopup(BuildContext context, PatientModel p) {
    final qrData = p.qrPayload;
    final hasQr = qrData != null && qrData.isNotEmpty;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34A853).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.qr_code_2,
                        color: Color(0xFF2E8B57), size: 24),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient QR Code',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                          ),
                        ),
                        Text(
                          p.caseId,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // QR Code widget
              if (hasQr)
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: const Color(0xFF2E8B57).withOpacity(0.25),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF34A853).withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 220.w,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF1B6B3A),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF2E8B57),
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.all(32.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.qr_code_2, size: 60.sp, color: Colors.grey[400]),
                      SizedBox(height: 12.h),
                      Text('QR code not available',
                          style: GoogleFonts.nunitoSans(color: Colors.grey[500])),
                    ],
                  ),
                ),

              if (hasQr) ...[
                SizedBox(height: 16.h),
                Text(
                  p.animalName?.isNotEmpty == true ? p.animalName! : p.animalType,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Scan to access patient record',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _shareQrCode(ctx, p),
                    icon: const Icon(Icons.share_rounded,
                        color: Colors.white, size: 18),
                    label: Text('Share QR Code',
                        style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w700, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareQrCode(BuildContext context, PatientModel p) async {
    if (p.qrPayload == null || p.qrPayload!.isEmpty) return;
    try {
      final qrValidationResult = QrValidator.validate(
        data: p.qrPayload!,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode;
        final painter = QrPainter.withQr(
          qr: qrCode!,
          color: const Color(0xFF2E8B57),
          emptyColor: const Color(0xFFFFFFFF),
          gapless: true,
        );
        final picData =
            await painter.toImageData(2048, format: ui.ImageByteFormat.png);
        if (picData != null) {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/${p.caseId}_QR.png');
          await file.writeAsBytes(picData.buffer.asUint8List());
          if (context.mounted) {
            final box = context.findRenderObject() as RenderBox?;
            await Share.shareXFiles(
              [XFile(file.path)],
              text: 'QR Code for Patient ${p.caseId}',
              sharePositionOrigin: box != null
                  ? box.localToGlobal(Offset.zero) & box.size
                  : Rect.zero,
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing QR: $e')),
        );
      }
    }
  }

  // ─── Widget Helpers ───────────────────────────────────────────────────────

  String _getDaysAdmitted(String? admissionDate) {
    if (admissionDate == null || admissionDate.isEmpty) return 'Day 1';
    try {
      final date = DateTime.parse(admissionDate);
      final diff = DateTime.now().difference(date).inDays;
      return 'Day ${diff + 1}';
    } catch (_) {
      return 'Day 1';
    }
  }

  Widget _chip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13.sp, color: Colors.white70),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 11.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain,
      ),
    );
  }

  Widget _infoGrid(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.1,
        mainAxisSpacing: 14.h,
        crossAxisSpacing: 8.w,
        children: tiles,
      ),
    );
  }

  Widget _gridTile(IconData icon, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, size: 11.sp, color: color),
            SizedBox(width: 3.w),
            Text(label,
                style: GoogleFonts.nunitoSans(
                    fontSize: 10.sp, color: AppColors.textMuted)),
          ],
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          style: GoogleFonts.nunitoSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _rescueCard(PatientModel p) {
    final rows = <Widget>[];
    bool isFirst = true;

    void addRow(IconData icon, String label, String value) {
      rows.add(_rescueRow(icon, label, value, isFirst: isFirst));
      isFirst = false;
    }

    if (p.admissionDate != null)
      addRow(Icons.calendar_today, 'Admission Date', _formatDate(p.admissionDate!));
    if (p.animalAddress != null)
      addRow(Icons.location_on, 'Found At', p.animalAddress!);
    if (p.landmark != null) addRow(Icons.place, 'Landmark', p.landmark!);
    if (p.reporterName != null)
      addRow(Icons.person, 'Reporter Name', p.reporterName!);
    if (p.reporterMobile != null)
      addRow(Icons.phone, 'Reporter Mobile', p.reporterMobile!);
    if (p.transportedBy != null)
      addRow(Icons.local_shipping, 'Transported By', p.transportedBy!);

    if (rows.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Text('No rescue info available',
            style: GoogleFonts.nunitoSans(color: AppColors.textMuted)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: rows),
    );
  }

  Widget _rescueRow(IconData icon, String label, String value,
      {bool isFirst = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: Border(
          top: isFirst
              ? BorderSide.none
              : BorderSide(color: Colors.grey[100]!, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 16.sp, color: AppColors.primaryGreen),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.nunitoSans(
                        fontSize: 11.sp, color: AppColors.textMuted)),
                SizedBox(height: 2.h),
                Text(value,
                    style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _medCard(PatientModel p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (p.symptoms != null && p.symptoms!.isNotEmpty) ...[
            _medLabel('Symptoms'),
            SizedBox(height: 6.h),
            Text(p.symptoms!,
                style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp, height: 1.5, color: AppColors.textMain)),
            TextToSpeechPlayer(text: p.symptoms!),
            SizedBox(height: 14.h),
          ],
          if (p.diagnosis != null && p.diagnosis!.isNotEmpty) ...[
            _medLabel('Diagnosis'),
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFF34A853).withOpacity(0.07),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: const Color(0xFF34A853).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: Color(0xFF34A853), size: 18),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(p.diagnosis!,
                        style: GoogleFonts.nunitoSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B6B3A))),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
          ],
          if (p.tests != null && p.tests!.isNotEmpty) ...[
            _medLabel('Tests Ordered'),
            SizedBox(height: 6.h),
            Text(p.tests!,
                style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp, height: 1.5, color: AppColors.textMain)),
          ],
        ],
      ),
    );
  }

  Widget _medLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.nunitoSans(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryGreen,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _treatmentCard(TreatmentModel t) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Icon(Icons.medical_services,
                color: Color(0xFF3B82F6), size: 20),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.diagnosis,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 14.sp)),
                if (t.treatmentDate != null) ...[
                  SizedBox(height: 2.h),
                  Text(_formatDate(t.treatmentDate!),
                      style: GoogleFonts.nunitoSans(
                          fontSize: 12.sp, color: AppColors.textMuted)),
                ],
                if (t.medicines.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text('${t.medicines.length} medicine(s)',
                      style: GoogleFonts.nunitoSans(
                          fontSize: 12.sp,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600)),
                ],
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
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }
}
