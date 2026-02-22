import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthPersistenceService {
  static const String _keyAuthToken = 'admin_auth_token';
  static const String _keyRefreshToken = 'admin_refresh_token';
  static const String _keyUserData = 'admin_user_data';
  static const String _keyRememberMe = 'admin_remember_me';
  static const String _keyExpiresAt = 'admin_expires_at';
  static const String _keySessionToken = 'admin_session_token';

  // Singleton pattern
  static final AdminAuthPersistenceService _instance = AdminAuthPersistenceService._internal();
  factory AdminAuthPersistenceService() => _instance;
  AdminAuthPersistenceService._internal();

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save authentication data to persistent storage
  Future<void> saveAuthData({
    required String token,
    String? refreshToken,
    required Map<String, dynamic> userData,
    String? sessionToken,
    bool rememberMe = false,
    int? expiresIn,
  }) async {
    await init();
    
    await _prefs!.setString(_keyAuthToken, token);
    await _prefs!.setString(_keyUserData, jsonEncode(userData));
    await _prefs!.setBool(_keyRememberMe, rememberMe);
    
    if (sessionToken != null) {
      await _prefs!.setString(_keySessionToken, sessionToken);
    }
    
    if (refreshToken != null) {
      await _prefs!.setString(_keyRefreshToken, refreshToken);
    }
    
    if (expiresIn != null) {
      final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
      await _prefs!.setString(_keyExpiresAt, expiresAt.toIso8601String());
    }
  }

  /// Get stored authentication token
  Future<String?> getAuthToken() async {
    await init();
    return _prefs!.getString(_keyAuthToken);
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    await init();
    return _prefs!.getString(_keyRefreshToken);
  }

  /// Get stored user data
  Future<Map<String, dynamic>?> getUserData() async {
    await init();
    final userData = _prefs!.getString(_keyUserData);
    if (userData != null) {
      try {
        return jsonDecode(userData) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Get stored session token
  Future<String?> getSessionToken() async {
    await init();
    return _prefs!.getString(_keySessionToken);
  }

  /// Check if remember me was enabled
  Future<bool> getRememberMe() async {
    await init();
    return _prefs!.getBool(_keyRememberMe) ?? false;
  }

  /// Check if stored session is still valid
  Future<bool> isSessionValid() async {
    await init();
    
    final token = await getAuthToken();
    final rememberMe = await getRememberMe();
    
    if (token == null) return false;
    
    // If remember me is enabled, check expiration
    if (rememberMe) {
      final expiresAtString = _prefs!.getString(_keyExpiresAt);
      if (expiresAtString != null) {
        try {
          final expiresAt = DateTime.parse(expiresAtString);
          return DateTime.now().isBefore(expiresAt);
        } catch (e) {
          return false;
        }
      }
    }
    
    // For non-persistent sessions, assume valid if token exists
    return true;
  }

  /// Check if user has stored authentication data
  Future<bool> hasStoredAuth() async {
    await init();
    final token = await getAuthToken();
    final userData = await getUserData();
    return token != null && userData != null;
  }

  /// Clear all stored authentication data
  Future<void> clearAuthData() async {
    await init();
    
    await _prefs!.remove(_keyAuthToken);
    await _prefs!.remove(_keyRefreshToken);
    await _prefs!.remove(_keyUserData);
    await _prefs!.remove(_keyRememberMe);
    await _prefs!.remove(_keyExpiresAt);
    await _prefs!.remove(_keySessionToken);
  }

  /// Update stored auth token (for token refresh)
  Future<void> updateAuthToken(String newToken) async {
    await init();
    await _prefs!.setString(_keyAuthToken, newToken);
  }

  /// Update stored user data
  Future<void> updateUserData(Map<String, dynamic> userData) async {
    await init();
    await _prefs!.setString(_keyUserData, jsonEncode(userData));
  }

  /// Get all stored auth data for debugging
  Future<Map<String, dynamic>> getDebugData() async {
    await init();
    
    return {
      'hasAuthToken': await getAuthToken() != null,
      'hasRefreshToken': await getRefreshToken() != null,
      'hasUserData': await getUserData() != null,
      'rememberMe': await getRememberMe(),
      'isSessionValid': await isSessionValid(),
      'expiresAt': _prefs!.getString(_keyExpiresAt),
    };
  }
} 