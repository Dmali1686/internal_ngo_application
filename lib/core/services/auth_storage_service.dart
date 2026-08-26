/// Simple in-memory auth token storage.
///
/// Currently stores tokens in memory. Can be extended to use
/// SharedPreferences or FlutterSecureStorage for persistence
/// across app restarts.
class AuthStorageService {
  static final AuthStorageService _instance = AuthStorageService._internal();

  factory AuthStorageService() => _instance;

  AuthStorageService._internal();

  String? _accessToken;
  String? _refreshToken;
  String? _userId;

  /// The current access token (JWT).
  String? get accessToken => _accessToken;

  /// The current refresh token.
  String? get refreshToken => _refreshToken;

  /// The current user ID.
  String? get userId => _userId;

  /// Whether the user is currently authenticated.
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

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
  }

  /// Update only the access token (e.g., after a refresh).
  void updateAccessToken(String accessToken) {
    _accessToken = accessToken;
  }

  /// Clear all stored auth data (logout).
  void clear() {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
  }
}
