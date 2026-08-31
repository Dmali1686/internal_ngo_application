import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/registration_provider.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve data passed via GoRouter extra
    final extra = GoRouterState.of(context).extra;
    String caseId = 'N/A';
    String? qrPayload;
    String? patientId;

    if (extra is Map<String, dynamic>) {
      caseId = extra['case_id']?.toString() ?? 'N/A';
      qrPayload = extra['qr_payload']?.toString();
      patientId = extra['patient_id']?.toString();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20.h),

              // ── Success animation header ───────────────────────────────
              _SuccessHeader(),
              SizedBox(height: 28.h),

              // Case ID and QR code are now combined below

              // ── QR Code ───────────────────────────────────────────────
              _QrCodeCard(
                qrPayload: qrPayload,
                caseId: caseId,
                animalName: context.read<RegistrationProvider>().animalNameController.text.isNotEmpty 
                    ? context.read<RegistrationProvider>().animalNameController.text 
                    : context.read<RegistrationProvider>().animalType,
              ),
              SizedBox(height: 32.h),

              // ── Actions ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (patientId != null) ...[
                    _buildSmallAction(
                      icon: Icons.visibility_rounded,
                      label: 'Profile',
                      color: const Color(0xFF006E1C),
                      onPressed: () {
                        context.read<RegistrationProvider>().reset();
                        context.go(
                          '/animal-overview',
                          extra: {
                            'id': patientId,
                            'case_id': caseId,
                            'qr_payload': qrPayload,
                            'animal_name': null,
                            'animal_type': null,
                            'status': 'ADMITTED',
                          },
                        );
                      },
                    ),
                    _buildSmallAction(
                      icon: Icons.share_rounded,
                      label: 'Share',
                      color: const Color(0xFFE65100),
                      onPressed: () {
                        final provider = context.read<RegistrationProvider>();
                        context.push(
                          '/share-to-public',
                          extra: {
                            'patient_id': patientId,
                            'case_id': caseId,
                            'qr_payload': qrPayload,
                            'animal_type': provider.animalType,
                            'breed': provider.breedController.text,
                            'color': provider.colorController.text,
                            'gender': provider.gender,
                            'age': provider.age,
                            'rescue_location':
                                '${provider.addressController.text}, ${provider.cityController.text}',
                            'condition': provider.symptomsController.text,
                            'urgency': provider.priority,
                            'photos': provider.reporterPhotos,
                          },
                        );
                      },
                    ),
                  ],
                  _buildSmallAction(
                    icon: Icons.add_rounded,
                    label: 'New',
                    color: const Color(0xFF006E1C),
                    isOutlined: true,
                    onPressed: () {
                      context.read<RegistrationProvider>().reset();
                      context.go('/new-registration');
                    },
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              TextButton(
                onPressed: () {
                  context.read<RegistrationProvider>().reset();
                  context.go('/dashboard-transition');
                },
                child: Text(
                  'Back to Dashboard',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSmallAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isOutlined ? Colors.transparent : color.withOpacity(0.1),
              border: isOutlined ? Border.all(color: color, width: 1.5) : null,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(icon, color: color, size: 28.w),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

// ── Success animated header ───────────────────────────────────────────────────

class _SuccessHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF006E1C),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF006E1C).withOpacity(0.3),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 56.w,
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          'Registration Successful!',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunitoSans(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF003C0B),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'The animal has been admitted and a unique\nCase ID has been generated.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// (Case ID badge is now merged into QR Code Card)

// ── QR Code Card ──────────────────────────────────────────────────────────────

class _QrCodeCard extends StatefulWidget {
  final String? qrPayload;
  final String caseId;
  final String animalName;
  const _QrCodeCard({required this.qrPayload, required this.caseId, required this.animalName});

  @override
  State<_QrCodeCard> createState() => _QrCodeCardState();
}

class _QrCodeCardState extends State<_QrCodeCard> {
  final GlobalKey _qrKey = GlobalKey();

  Future<void> _shareQrCode() async {
    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      
      final buffer = byteData.buffer;
      
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_${widget.caseId}.png').create();
      await file.writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      
      await Share.shareXFiles([XFile(file.path)], text: 'Patient QR Code for ${widget.animalName} (${widget.caseId})');
    } catch (e) {
      debugPrint('Error sharing QR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasQr = widget.qrPayload != null && widget.qrPayload!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Merged Case ID Section
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF006E1C).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.tag_rounded,
                  color: const Color(0xFF006E1C),
                  size: 22.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CASE ID',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.caseId,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF006E1C),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.caseId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Case ID copied!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: Icon(
                  Icons.copy_rounded,
                  color: Colors.grey[400],
                  size: 20.w,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: Colors.grey.shade200, thickness: 1),
          SizedBox(height: 16.h),
          
          // QR Code Section
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_2_rounded,
                color: const Color(0xFF006E1C),
                size: 22.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'Patient QR Code',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B1C1C),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          RepaintBoundary(
            key: _qrKey,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(32.r),
              ),
              child: Column(
                children: [
                  if (hasQr)
                    QrImageView(
                      data: widget.qrPayload!,
                      version: QrVersions.auto,
                      size: 200.w,
                      backgroundColor: const Color(0xFFFAFAFA),
                    )
                  else
                    Container(
                      width: 200.w,
                      height: 200.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_2, size: 60.w, color: Colors.grey[400]),
                          SizedBox(height: 8.h),
                          Text(
                            'QR not available',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 12.h),
                  Text(
                    widget.animalName.toUpperCase(),
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B1C1C),
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.caseId,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF006E1C),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _shareQrCode,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download / Share QR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006E1C),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
              textStyle: GoogleFonts.nunitoSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Scan this QR code to access the\npatient record instantly.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 13.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          if (hasQr) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                widget.qrPayload!,
                style: GoogleFonts.nunitoSans(
                  fontSize: 10.sp,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
