import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/paw_pattern_painter.dart';
import '../services/auth_api_service.dart';

/// Premium login screen for MH14 Animal Hospital.
///
/// Features:
/// - Same paw-print background as Splash screen
/// - Top logo with app name
/// - Central card with Email & Password inputs only
/// - Distinct typography (Montserrat for headings, Lato for labels)
/// - Responsive sizing via [ScreenUtil]
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthApiService();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedRole = 'Employee'; // Default role
  
  final List<String> _roles = ['Employee', 'Admin', 'Super Admin'];

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    // ignore: unused_local_variable
    final unused = message; // Keep for future use
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20.r,
                  offset: Offset(0, 10.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primaryGreen,
                    size: 32.w,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Login Failed',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      'Try Again',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogin() async {
    // ignore: unused_local_variable
    final authService = _authService; // Keep for future use
    setState(() {
      _isLoading = true;
    });
    AppLogger.action('LoginScreen', 'Login bypassed for testing UI screens');
    
    // Simulate loading for UI
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      context.go('/dashboard-transition');
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.lifecycle('LoginScreen', 'build');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Same as splash screen
      body: Stack(
        children: [
          // ── Background Pattern ────────────────────────────────────
          Positioned.fill(child: CustomPaint(painter: PawPatternPainter())),

          // ── Main Content ──────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top Header
                    _buildHeader(),

                    SizedBox(height: 32.h),

                    // ── Login Card ────────────────────────────────────
                    _buildLoginCard(),

                    SizedBox(height: 32.h),

                    // ── Bottom Footer ─────────────────────────────────
                    _buildFooter(),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Logo and App Title at the top
  Widget _buildHeader() {
    return Column(
      children: [
        // Small logo
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.asset(
            AppAssets.mh14Logo,
            width: 54.w,
            height: 54.w,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.pets,
                size: 32.w,
                color: AppColors.primaryGreen,
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        // App Name
        Text(
          AppStrings.appTitle,
          style: GoogleFonts.nunitoSans(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryGreen,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  /// White card containing the form
  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          Center(
            child: Text(
              AppStrings.loginHeading,
              style: GoogleFonts.nunitoSans(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(height: 8.h),

          // Subtitle
          Center(
            child: Text(
              AppStrings.loginSubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
          SizedBox(height: 32.h),

          // Role Selection
          _buildTextFieldLabel('Login Role'),
          SizedBox(height: 8.h),
          _buildRoleDropdown(),
          SizedBox(height: 20.h),

          // Identifier Field (Email/Mobile or Username)
          _buildTextFieldLabel(_selectedRole == 'Super Admin' ? 'Email or Mobile *' : 'Username *'),
          SizedBox(height: 8.h),
          _buildTextField(
            controller: _identifierController,
            hint: _selectedRole == 'Super Admin' ? 'e.g. admin@mh14.org or 9876543210' : 'e.g. jdoe123',
            keyboardType: _selectedRole == 'Super Admin' ? TextInputType.emailAddress : TextInputType.text,
          ),
          SizedBox(height: 20.h),

          // Password Field
          _buildTextFieldLabel(AppStrings.passwordLabel),
          SizedBox(height: 8.h),
          _buildTextField(
            controller: _passwordController,
            hint: AppStrings.passwordHint,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey.shade500,
                size: 20.w,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          SizedBox(height: 32.h),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 24.w,
                      width: 24.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.loginButtonLabel,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.arrow_forward_rounded, size: 20.w),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return InputDecorator(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 2.w),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade600),
          style: GoogleFonts.nunitoSans(fontSize: 15.sp, color: AppColors.textMain),
          isExpanded: true,
          items: _roles.map((role) {
            return DropdownMenuItem<String>(
              value: role,
              child: Text(role),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedRole = value;
                _identifierController.clear();
              });
            }
          },
        ),
      ),
    );
  }

  /// Helper for text field labels
  Widget _buildTextFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.nunitoSans(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textMain,
      ),
    );
  }

  /// Helper for text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.nunitoSans(fontSize: 15.sp, color: AppColors.textMain),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunitoSans(
          fontSize: 15.sp,
          color: Colors.grey.shade400,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppColors.primaryGreen,
            width: 2.w,
          ),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  /// Privacy Policy and Terms & Conditions links
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFooterLink(AppStrings.privacyPolicy),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            '•',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16.sp),
          ),
        ),
        _buildFooterLink(AppStrings.termsConditions),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {
        AppLogger.action('LoginScreen', '$text link pressed');
      },
      child: Text(
        text,
        style: GoogleFonts.nunitoSans(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
