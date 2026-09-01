import 'package:shared_preferences/shared_preferences.dart';

/// Simple in-memory auth token storage with SharedPreferences persistence.
///
/// Stores tokens in memory for fast access, and backs them up
/// to SharedPreferences for persistence across app restarts.
class AuthStorageService {
  static final AuthStorageService _instance = AuthStorageService._internal();

  factory AuthStorageService() => _instance;

  AuthStorageService._internal();

  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  String? _departmentId;
  bool _isDoctor = false;
  String? _role; // persisted role: 'Super Admin', 'Admin', 'Employee'

  /// The current access token (JWT).
  String? get accessToken => _accessToken;

  /// The current refresh token.
  String? get refreshToken => _refreshToken;

  /// The current user ID.
  String? get userId => _userId;

  /// The current user's department ID.
  String? get departmentId => _departmentId;

  /// True if the currently logged in user is identified as a doctor.
  bool get isDoctor => _isDoctor;

  /// The persisted role: 'Super Admin', 'Admin', or 'Employee'.
  String? get role => _role;

  /// Whether the user is currently authenticated.
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  /// Initialize from SharedPreferences at app startup.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('auth_access_token');
    _refreshToken = prefs.getString('auth_refresh_token');
    _userId = prefs.getString('auth_user_id');
    _departmentId = prefs.getString('auth_department_id');
    _isDoctor = prefs.getBool('auth_is_doctor') ?? false;
    _role = prefs.getString('auth_role'); // restore role on restart
  }

  void setIsDoctor(bool val) {
    _isDoctor = val;
    _saveToPrefs();
  }

  void setDepartmentId(String id) {
    _departmentId = id;
    _saveToPrefs();
  }

  /// Persist the user role after successful login.
  void saveRole(String role) {
    _role = role;
    _saveToPrefs();
  }

  /// Store tokens after successful login or token refresh.
  void saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    if (userId != null) {
      _userId = userId;
    }
    _saveToPrefs();
  }

  /// Update only the access token (e.g., after a refresh).
  void updateAccessToken(String accessToken) {
    _accessToken = accessToken;
    _saveToPrefs();
  }

  /// Clear all stored auth data (logout).
  void clear() {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _departmentId = null;
    _isDoctor = false;
    _role = null;
    _saveToPrefs();
  }

  /// Persist current state to SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_accessToken != null) {
      await prefs.setString('auth_access_token', _accessToken!);
    } else {
      await prefs.remove('auth_access_token');
    }
    
    if (_refreshToken != null) {
      await prefs.setString('auth_refresh_token', _refreshToken!);
    } else {
      await prefs.remove('auth_refresh_token');
    }
    
    if (_userId != null) {
      await prefs.setString('auth_user_id', _userId!);
    } else {
      await prefs.remove('auth_user_id');
    }
    
    if (_departmentId != null) {
      await prefs.setString('auth_department_id', _departmentId!);
    } else {
      await prefs.remove('auth_department_id');
    }

    if (_role != null) {
      await prefs.setString('auth_role', _role!);
    } else {
      await prefs.remove('auth_role');
    }
    
    await prefs.setBool('auth_is_doctor', _isDoctor);
  }
}
