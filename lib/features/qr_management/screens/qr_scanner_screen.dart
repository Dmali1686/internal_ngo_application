import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Simulated Camera Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAG3ZZqQdr1ecmuK-O5Vle9F_eLMQiggUo_jEuWGGZM9Bfmy3aMT7OU5HgnC6zy6e4YpjaBthYa3LR3VClyLN4kqBYYP6Mhs6JW9Mn2Oi5fIzHheZKpqdvZvvaKRQmnU2v6LKx3GD4wLh9cPZdsH1ItPyJCOYAX7_LL3VEdI4xOMxiPWHSQ2EHnWaffeyxjXYzeJO6U3SZCROJLA3kDbn-u5CQmAlzQjnixwyqHYwcW98wwk3Ubx5VPLg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Viewfinder
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => context.push('/patient-detail'),
                  child: Container(
                    width: 320.w,
                    height: 320.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.5),
                        width: 2.w,
                      ),
                      color: Colors.black12,
                    ),
                    child: Stack(
                      children: [
                        // Animated Scanning Line
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Positioned(
                              top: _animation.value * (320.w - 4),
                              left: 0.w,
                              right: 0.w,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green,
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        // Corner Brackets
                        _buildCorner(top: 0.h, left: 0.w, angle: 0),
                        _buildCorner(top: 0.h, right: 0.w, angle: 90),
                        _buildCorner(bottom: 0.h, right: 0.w, angle: 180),
                        _buildCorner(bottom: 0.h, left: 0.w, angle: 270),

                        // Center icon hint
                        Center(
                          child: Icon(
                            Icons.qr_code_2,
                            size: 64.w,
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    'Scan Animal QR to View History\n(Tap the box to simulate scan)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Flash & Gallery Controls
          Positioned(
            bottom: 48.h,
            left: 0.w,
            right: 0.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: _isFlashOn ? Icons.flashlight_on : Icons.flashlight_off,
                  isActive: _isFlashOn,
                  onTap: () => setState(() => _isFlashOn = !_isFlashOn),
                ),
                SizedBox(width: 32.w),
                _buildControlButton(
                  icon: Icons.image_outlined,
                  isActive: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double angle,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: angle * 3.14159 / 180,
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.green, width: 4.w),
              left: BorderSide(color: Colors.green, width: 4.w),
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r)),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.green.withOpacity(0.5) : Colors.white24,
          border: Border.all(color: isActive ? Colors.green : Colors.white30),
        ),
        child: Icon(icon, color: Colors.white, size: 28.w),
      ),
    );
  }
}
