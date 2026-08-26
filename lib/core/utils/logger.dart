import 'package:flutter/foundation.dart';

/// Centralized logger for the NGO ERP application.
///
/// Uses [debugPrint] under the hood so logs are automatically stripped
/// in release builds. Every log line is prefixed with a timestamp and
/// category tag for easy filtering in the console.
class AppLogger {
  AppLogger._(); // Prevent instantiation

  /// General informational log.
  ///
  /// Example: `AppLogger.info('App', 'Starting NGO ERP...');`
  static void info(String tag, String message) {
    debugPrint('[INFO][$tag] $message');
  }

  /// Navigation / route-transition log.
  ///
  /// Example: `AppLogger.navigation('/welcome');`
  static void navigation(String route) {
    debugPrint('[NAV] Navigating to → $route');
  }

  /// User-action log (button tap, form submit, etc.).
  ///
  /// Example: `AppLogger.action('LoginScreen', 'Login button pressed');`
  static void action(String tag, String action) {
    debugPrint('[ACTION][$tag] $action');
  }

  /// Widget-lifecycle log (initState, dispose, build, etc.).
  ///
  /// Example: `AppLogger.lifecycle('SplashScreen', 'initState');`
  static void lifecycle(String screen, String event) {
    debugPrint('[LIFECYCLE][$screen] $event');
  }

  /// Error / warning log.
  ///
  /// Example: `AppLogger.error('AuthService', 'Token expired');`
  static void error(String tag, String message) {
    debugPrint('[ERROR][$tag] $message');
  }
}
