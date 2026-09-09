import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_storage_service.dart';

/// Premium splash screen for MH14 Animal Hospital.
///
/// Features:
/// - Subtle paw-print patterned background
/// - Logo with fully rounded edges in a white card with soft shadow
/// - Poppins font for app title, Inter for tagline
/// - Responsive sizing via [ScreenUtil] (no overflow on any device)
/// - Staggered fade-in + scale animations
/// - Heart icon with pulsing animation at the bottom
/// - Auto-navigates to /welcome after 5 seconds
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _heartController;

  late final Animation<double> _logoFadeIn;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFadeIn;
  late final Animation<double> _heartPulse;

  @override
  void initState() {
    super.initState();
    AppLogger.lifecycle('SplashScreen', 'initState');
    debugPrint('[DEBUG][SplashScreen] initState called');

    // ── Logo animation (fade + scale) ─────────────────────────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoFadeIn = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    // ── Text animation (staggered fade) ───────────────────────
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textFadeIn = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    // ── Heart pulse animation (infinite loop) ─────────────────
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _heartPulse = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );

    // Start the animation sequence
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    debugPrint('[DEBUG][SplashScreen] Starting animation sequence...');
    AppLogger.info('SplashScreen', 'Starting animation sequence...');

    // Phase 1: Logo fades in immediately
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    debugPrint('[DEBUG][SplashScreen] Phase 1: Logo fade-in starting');
    _logoController.forward();

    // Phase 2: Text fades in shortly after logo
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    debugPrint('[DEBUG][SplashScreen] Phase 2: Text fade-in starting');
    _textController.forward();

    // Phase 3: Heart starts pulsing
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    debugPrint('[DEBUG][SplashScreen] Phase 3: Heart pulse starting');
    _heartController.repeat(reverse: true);

    // Phase 4: Hold the splash for a full 5 seconds total before navigating
    await Future.delayed(const Duration(milliseconds: 3800));
    if (!mounted) return;

    // Check if the user is already authenticated (token persisted from last session).
    final authStorage = AuthStorageService();
    if (authStorage.isAuthenticated) {
      // User has a valid token — skip welcome/login and go straight to their dashboard.
      debugPrint('[DEBUG][SplashScreen] Phase 4: User already authenticated — navigating to /dashboard-transition');
      AppLogger.info('SplashScreen', 'Splash complete — user authenticated, navigating to dashboard');
      AppLogger.navigation('/dashboard-transition');
      context.go('/dashboard-transition');
    } else {
      debugPrint('[DEBUG][SplashScreen] Phase 4: No auth token — navigating to /welcome');
      AppLogger.info('SplashScreen', 'Splash complete — navigating to /welcome');
      AppLogger.navigation('/welcome');
      context.go('/welcome');
    }
  }

  @override
  void dispose() {
    AppLogger.lifecycle('SplashScreen', 'dispose');
    debugPrint('[DEBUG][SplashScreen] dispose called');
    _logoController.dispose();
    _textController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.lifecycle('SplashScreen', 'build');
    debugPrint('[DEBUG][SplashScreen] build called');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // ── Background with paw-print pattern ─────────────────
          Positioned.fill(child: CustomPaint(painter: _PawPatternPainter())),

          // ── Main content (responsive via ScreenUtil) ──────────
          SafeArea(
            child: SizedBox.expand(
              child: Column(
                children: [
                  // Top spacer — pushes content toward center
                  SizedBox(height: 200.h),

                  // ── Logo card ───────────────────────────────────
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoFadeIn,
                      child: _buildLogoCard(),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // ── App name (Poppins — bold & distinctive) ─────
                  FadeTransition(
                    opacity: _textFadeIn,
                    child: Text(
                      AppStrings.appTitle,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // ── Tagline (Inter — clean & readable) ──────────
                  FadeTransition(
                    opacity: _textFadeIn,
                    child: Text(
                      AppStrings.appTagline,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                  // Flexible spacer — fills remaining space
                  const Spacer(),

                  // ── Heart loading animation ─────────────────────
                  FadeTransition(
                    opacity: _textFadeIn,
                    child: _buildHeartLoader(),
                  ),

                  SizedBox(height: 48.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// White rounded card containing the logo image.
  ///
  /// The logo has fully rounded edges (borderRadius: 32.r) and
  /// the image is clipped to match. Responsive sizing via ScreenUtil.
  Widget _buildLogoCard() {
    debugPrint('[DEBUG][SplashScreen] Building logo card');
    final cardSize = 130.w;
    final radius = 32.r;

    return Container(
      width: cardSize,
      height: cardSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30.r,
            spreadRadius: 2.r,
            offset: Offset(0, 10.h),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: ClipRRect(
            // Inner rounded corners for the logo image itself
            borderRadius: BorderRadius.circular(24.r),
            child: Image.asset(
              'assets/images/mh14_logo.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('[ERROR][SplashScreen] Failed to load logo: $error');
                // Fallback: show icon if image fails
                return Icon(
                  Icons.pets,
                  size: 64.w,
                  color: AppColors.primaryGreen,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Heart icon with circular border and pulsing animation.
  Widget _buildHeartLoader() {
    return ScaleTransition(
      scale: _heartPulse,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            width: 2.w,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.favorite_outline_rounded,
            size: 20.w,
            color: AppColors.primaryGreen.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

/// Custom painter that draws a subtle repeating paw-print pattern.
class _PawPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.025)
      ..style = PaintingStyle.fill;

    const spacing = 60.0;
    const pawSize = 6.0;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        // Offset every other row for a more natural pattern
        final offsetX = (y ~/ spacing) % 2 == 0 ? 0.0 : spacing / 2;
        final cx = x + offsetX;

        // Main pad (larger circle)
        canvas.drawCircle(Offset(cx, y + pawSize * 1.5), pawSize * 1.2, paint);

        // Toe pads (4 smaller circles)
        canvas.drawCircle(
          Offset(cx - pawSize, y - pawSize * 0.3),
          pawSize * 0.6,
          paint,
        );
        canvas.drawCircle(
          Offset(cx + pawSize, y - pawSize * 0.3),
          pawSize * 0.6,
          paint,
        );
        canvas.drawCircle(
          Offset(cx - pawSize * 0.4, y - pawSize * 1.2),
          pawSize * 0.55,
          paint,
        );
        canvas.drawCircle(
          Offset(cx + pawSize * 0.4, y - pawSize * 1.2),
          pawSize * 0.55,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
