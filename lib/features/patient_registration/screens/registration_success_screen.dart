import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

              // ── Case ID badge ─────────────────────────────────────────
              _CaseIdBadge(caseId: caseId),
              SizedBox(height: 28.h),

              // ── QR Code ───────────────────────────────────────────────
              _QrCodeCard(qrPayload: qrPayload, caseId: caseId),
              SizedBox(height: 32.h),

              // ── Actions ───────────────────────────────────────────────
              if (patientId != null) ...[
                ElevatedButton.icon(
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
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Patient Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006E1C),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    textStyle: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],
              OutlinedButton.icon(
                onPressed: () {
                  context.read<RegistrationProvider>().reset();
                  context.go('/new-registration');
                },
                icon: const Icon(Icons.add),
                label: const Text('Register Another Animal'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF006E1C),
                  side: const BorderSide(color: Color(0xFF006E1C)),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  textStyle: GoogleFonts.nunitoSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
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

// ── Case ID badge ─────────────────────────────────────────────────────────────

class _CaseIdBadge extends StatelessWidget {
  final String caseId;
  const _CaseIdBadge({required this.caseId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF006E1C).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
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
                  caseId,
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
              Clipboard.setData(ClipboardData(text: caseId));
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
    );
  }
}

// ── QR Code Card ──────────────────────────────────────────────────────────────

class _QrCodeCard extends StatelessWidget {
  final String? qrPayload;
  final String caseId;
  const _QrCodeCard({required this.qrPayload, required this.caseId});

  @override
  Widget build(BuildContext context) {
    final hasQr = qrPayload != null && qrPayload!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
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
          if (hasQr)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: QrImageView(
                data: qrPayload!,
                version: QrVersions.auto,
                size: 200.w,
                backgroundColor: Colors.white,
              ),
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
                qrPayload!,
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
