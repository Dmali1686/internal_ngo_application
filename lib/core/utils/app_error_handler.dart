import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../services/auth_storage_service.dart';
import 'package:go_router/go_router.dart';

/// Central error handling utility for the entire app.
///
/// Use [AppErrorHandler.translate] to convert any raw error (API exceptions,
/// PostgreSQL constraint messages, network errors, etc.) into a clean,
/// user-friendly string.
///
/// Use [AppErrorHandler.showError] / [AppErrorHandler.showSuccess] to display
/// consistently styled snackbars, or [AppErrorHandler.showErrorDialog] for
/// modal dialogs.
class AppErrorHandler {
  AppErrorHandler._();

  // ---------------------------------------------------------------------------
  // Error translation
  // ---------------------------------------------------------------------------

  /// Converts a raw exception / error string into a friendly user-facing message.
  static String translate(Object error) {
    final raw = error.toString();
    final msg = raw.toLowerCase();

    // ── PostgreSQL unique constraint violations (23505) ─────────────────────
    if (msg.contains('users_email_key') ||
        (msg.contains('duplicate') && msg.contains('email'))) {
      return 'This email address is already registered.\nPlease use a different email.';
    }
    if (msg.contains('users_username_key') ||
        (msg.contains('duplicate') && msg.contains('username'))) {
      return 'This username is already taken.\nPlease choose a different username.';
    }
    if (msg.contains('users_mobile_key') ||
        (msg.contains('duplicate') && msg.contains('mobile')) ||
        (msg.contains('duplicate') && msg.contains('phone'))) {
      return 'This mobile number is already in use.\nPlease enter a different number.';
    }
    if (msg.contains('23505') || msg.contains('duplicate key')) {
      return 'A record with these details already exists.\nPlease check your inputs and try again.';
    }

    // ── Foreign key / referential integrity (23503) ─────────────────────────
    if (msg.contains('23503') || msg.contains('foreign key')) {
      return 'Invalid selection detected.\nPlease refresh the page and try again.';
    }

    // ── Not-null / check constraint (23502, 23514) ──────────────────────────
    if (msg.contains('23502') || msg.contains('not-null')) {
      return 'Some required fields are missing.\nPlease fill in all required fields.';
    }
    if (msg.contains('23514') || msg.contains('check constraint')) {
      return 'One or more values are invalid.\nPlease review your inputs.';
    }

    // ── HTTP status codes ────────────────────────────────────────────────────
    if (msg.contains('unauthorised') ||
        msg.contains('unauthorized') ||
        msg.contains('401')) {
      return 'Your session has expired. Please log in again.';
    }
    if (msg.contains('forbidden') || msg.contains('403')) {
      return 'You don\'t have permission to perform this action.';
    }
    if (msg.contains('not found') || msg.contains('404')) {
      return 'The requested resource was not found.';
    }
    if (msg.contains('badrequest') ||
        msg.contains('bad request') ||
        msg.contains('400')) {
      // Try to strip wrapper noise and return the inner message
      final clean = raw
          .replaceAll(RegExp(r'BadRequestException[:\s]*', caseSensitive: false), '')
          .replaceAll(RegExp(r'ApiException\(\d+\)[:\s]*', caseSensitive: false), '')
          .replaceAll(RegExp(r'^pq:\s*', caseSensitive: false), '')
          .trim();
      if (clean.isNotEmpty && clean.length < 200) return clean;
      return 'Invalid request. Please check your inputs and try again.';
    }
    if (msg.contains('500') ||
        msg.contains('server') ||
        msg.contains('internal')) {
      return 'Server error. Please try again in a moment.';
    }

    // ── Network / connectivity ───────────────────────────────────────────────
    if (msg.contains('socketexception') ||
        msg.contains('networkexception') ||
        msg.contains('connection refused') ||
        msg.contains('no route to host') ||
        msg.contains('network error')) {
      return 'No internet connection.\nPlease check your network and try again.';
    }
    if (msg.contains('timeout') || msg.contains('timed out')) {
      return 'The request timed out.\nPlease check your connection and try again.';
    }

    // ── Generic cleanup ──────────────────────────────────────────────────────
    // Strip common noisy prefixes before falling back
    final cleaned = raw
        .replaceAll(RegExp(r'^Exception:\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^pq:\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'ApiException\(\d+\)[:\s]*', caseSensitive: false), '')
        .replaceAll(RegExp(r'BadRequestException[:\s]*', caseSensitive: false), '')
        .trim();

    if (cleaned.isEmpty) return 'Something went wrong. Please try again.';
    // Truncate overly long messages
    if (cleaned.length > 180) return 'Something went wrong. Please try again.';
    return cleaned;
  }

  // ---------------------------------------------------------------------------
  // Snackbar helpers
  // ---------------------------------------------------------------------------

  /// Shows a styled **error** snackbar.
  static void showError(BuildContext context, Object error) {
    if (!context.mounted) return;
    final message = translate(error);

    if (message == 'Your session has expired. Please log in again.') {
      _showSessionExpiredDialog(context, message);
      return;
    }

    _showSnackBar(
      context,
      message: message,
      isError: true,
    );
  }

  /// Shows a styled **error** snackbar with a custom pre-translated message.
  static void showErrorMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    
    if (message == 'Your session has expired. Please log in again.') {
      _showSessionExpiredDialog(context, message);
      return;
    }

    _showSnackBar(context, message: message, isError: true);
  }

  /// Shows a styled **success** snackbar.
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    _showSnackBar(context, message: message, isError: false);
  }

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required bool isError,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20.w,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isError
              ? const Color(0xFFDC2626)
              : const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          duration: Duration(seconds: isError ? 4 : 3),
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Dialog helper
  // ---------------------------------------------------------------------------

  /// Shows a modal error dialog with a friendly translated message.
  static Future<void> showErrorDialog(
    BuildContext context,
    Object error, {
    String? title,
    VoidCallback? onDismiss,
  }) async {
    if (!context.mounted) return;
    final message = translate(error);
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
        contentPadding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
        actionsPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_rounded,
                color: const Color(0xFFDC2626),
                size: 22.w,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              title ?? 'Something went wrong',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: AppColors.textMuted,
            height: 1.55,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDismiss?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a strict modal dialog when the session expires.
  static void _showSessionExpiredDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
        contentPadding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
        actionsPadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_clock_rounded,
                color: const Color(0xFFDC2626),
                size: 22.w,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'Session Expired',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: AppColors.textMuted,
            height: 1.55,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                AuthStorageService().clear();
                Navigator.pop(dialogContext); // Close dialog
                context.go('/login'); // Navigate to login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Log In Again',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
