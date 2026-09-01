import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../features/patient_registration/services/patient_api_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  final PatientApiService _apiService = PatientApiService();
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  bool _isProcessing = false;
  bool _torchOn = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _lineController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  // ── Extract case_id from the qr_payload URL ───────────────────────────────
  // qr_payload format: http://10.58.16.90:8080/patient/MH14-2026-000001
  String? _extractCaseId(String rawValue) {
    // Try to parse as URL and get the last path segment
    try {
      final uri = Uri.parse(rawValue.trim());
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        final last = segments.last;
        // Case IDs match pattern like MH14-2026-000001
        if (RegExp(r'^[A-Z0-9]+-\d{4}-\d+$').hasMatch(last)) {
          return last;
        }
      }
    } catch (_) {}

    // Fallback: extract via regex directly from string
    final match = RegExp(r'([A-Z0-9]+-\d{4}-\d+)').firstMatch(rawValue);
    return match?.group(1);
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _lastError = null;
    });

    // Pause the camera while processing
    await _cameraController.stop();

    // Show loading overlay
    if (!mounted) return;

    final caseId = _extractCaseId(rawValue);

    if (caseId == null) {
      setState(() {
        _isProcessing = false;
        _lastError = 'Invalid QR code.\nNo patient Case ID found in:\n$rawValue';
      });
      await _cameraController.start();
      return;
    }

    // Fetch patient by case ID
    _showLoadingDialog(caseId);
    
    dynamic res;
    String? errorMessage;
    try {
      res = await _apiService.getPatientByCaseId(caseId);
    } catch (e) {
      errorMessage = e.toString();
      // Clean up exception prefix if any
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // dismiss loading

    if (res != null && res.success && res.data != null) {
      // Parse response
      Map<String, dynamic>? patientMap;
      final raw = res.data;
      if (raw is Map<String, dynamic>) {
        final inner = raw['data'];
        patientMap = (inner is Map<String, dynamic>) ? inner : raw;
      }

      if (patientMap != null) {
        // Debug: log all keys so we can verify the id field name
        print('========== QR SCAN: patientMap keys ==========');
        print(patientMap.keys.toList());
        print('id: ${patientMap['id']}  patient_id: ${patientMap['patient_id']}');
        print('case_id: ${patientMap['case_id']}  animal_name: ${patientMap['animal_name']}');
        print('================================================');
        // Navigate to patient detail — replace current route
        context.pushReplacement('/patient-detail', extra: patientMap);
        return;
      }
    }

    // Error: show message and resume camera
    setState(() {
      _isProcessing = false;
      _lastError =
          'Patient not found for Case ID: $caseId\n${errorMessage ?? res?.errorMessage ?? ''}';
    });
    await _cameraController.start();
  }

  void _showLoadingDialog(String caseId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF006E1C)),
            SizedBox(height: 16.h),
            Text(
              'Loading patient...',
              style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.h),
            Text(
              caseId,
              style: GoogleFonts.nunitoSans(
                color: const Color(0xFF006E1C),
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        title: Text(
          'Scan Patient QR',
          style: GoogleFonts.nunitoSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: IconButton(
                icon: Icon(
                  _torchOn ? Icons.flashlight_on : Icons.flashlight_off,
                  color: _torchOn ? Colors.yellow : Colors.white,
                ),
                onPressed: () {
                  _cameraController.toggleTorch();
                  setState(() => _torchOn = !_torchOn);
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Real camera view ─────────────────────────────────────────────
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
          ),

          // ── Dark overlay with cutout ──────────────────────────────────────
          _ScanOverlay(lineAnimation: _lineAnimation),

          // ── Bottom info + error area ──────────────────────────────────────
          Positioned(
            bottom: 60.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_lastError != null)
                  _ErrorBanner(
                    message: _lastError!,
                    onRetry: () {
                      setState(() {
                        _lastError = null;
                        _isProcessing = false;
                      });
                      _cameraController.start();
                    },
                  )
                else
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 32.w),
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      'Point the camera at a patient QR code\nto instantly view their profile',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunitoSans(
                        color: Colors.white,
                        fontSize: 14.sp,
                        height: 1.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Processing indicator ──────────────────────────────────────────
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black38,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF006E1C)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Overlay with transparent cutout ──────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  final Animation<double> lineAnimation;
  const _ScanOverlay({required this.lineAnimation});

  @override
  Widget build(BuildContext context) {
    final boxSize = 280.w;
    return Stack(
      children: [
        // Dark overlay
        ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.black54,
            BlendMode.srcOut,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: boxSize,
                  height: boxSize,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Corners + scan line
        Center(
          child: SizedBox(
            width: boxSize,
            height: boxSize,
            child: Stack(
              children: [
                // Scan line
                AnimatedBuilder(
                  animation: lineAnimation,
                  builder: (_, __) => Positioned(
                    top: lineAnimation.value * (boxSize - 4),
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2.5,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xFF00E676),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF00E676),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 4 corners
                _buildCorner(top: 0, left: 0, rotate: 0),
                _buildCorner(top: 0, right: 0, rotate: 90),
                _buildCorner(bottom: 0, right: 0, rotate: 180),
                _buildCorner(bottom: 0, left: 0, rotate: 270),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double rotate,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: rotate * 3.14159265 / 180,
        child: SizedBox(
          width: 36.w,
          height: 36.w,
          child: CustomPaint(painter: _CornerPainter()),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E676)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const r = 10.0;
    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: const Radius.circular(r))
      ..lineTo(size.width * 0.6, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.shade400),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 28.w),
          SizedBox(height: 8.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              color: Colors.white,
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Scan Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red.shade900,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
