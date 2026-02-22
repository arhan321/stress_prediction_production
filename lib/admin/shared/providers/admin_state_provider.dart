import 'package:flutter/material.dart';
import '../services/admin_api_service.dart';
import '../services/admin_auth_persistence_service.dart';

class AdminStateProvider with ChangeNotifier {
  final AdminApiService _apiService = AdminApiService();
  final AdminAuthPersistenceService _persistenceService = AdminAuthPersistenceService();
  
  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _currentUser;
  String? _errorMessage;
  int _currentPageIndex = 0;
  bool _isInitialized = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  int get currentPageIndex => _currentPageIndex;
  bool get isInitialized => _isInitialized;

  // Authentication methods
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.login(email, password);
      
      if (result['success']) {
        final data = result['data'];
        _currentUser = data['user'];
        _isAuthenticated = true;
        
        // Save authentication data to persistent storage (always remember for admin)
        await _persistenceService.saveAuthData(
          token: data['token'],
          refreshToken: data['refresh_token'],
          userData: data['user'],
          sessionToken: data['session_token'],
          rememberMe: true, // Always remember admin sessions
          expiresIn: data['expires_in'],
        );
        
        _setLoading(false);
        return true;
      } else {
        _setError(result['error']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    await _persistenceService.clearAuthData();
    _isAuthenticated = false;
    _currentUser = null;
    _currentPageIndex = 0;
    _clearError();
    notifyListeners();
  }

  // Navigation methods
  void setCurrentPageIndex(int index) {
    _currentPageIndex = index;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Check if user has admin role
  bool get isAdmin => _currentUser?['role'] == 'admin';

  // Get user display name
  String get userDisplayName => _currentUser?['full_name'] ?? 'Unknown User';

  // Get user initials for avatar
  String get userInitials {
    final fullName = _currentUser?['full_name'] ?? 'Unknown User';
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }

  // Initialize authentication state from persistent storage
  Future<void> initializeAuth() async {
    if (_isInitialized) return;
    
    _setLoading(true);
    
    try {
      // Check if there's stored authentication data
      final hasStoredAuth = await _persistenceService.hasStoredAuth();
      
      if (hasStoredAuth) {
        final isValid = await _persistenceService.isSessionValid();
        
        if (isValid) {
          // Try to restore session
          final userData = await _persistenceService.getUserData();
          final token = await _persistenceService.getAuthToken();
          
          if (userData != null && token != null) {
            _apiService.setAuthToken(token);
            _currentUser = userData;
            _isAuthenticated = true;
          }
        } else {
          // Try to refresh token if session expired
          final refreshToken = await _persistenceService.getRefreshToken();
          if (refreshToken != null) {
            final refreshResult = await _apiService.refreshToken(refreshToken);
            
            if (refreshResult['success']) {
              final data = refreshResult['data'];
              _currentUser = data['user'];
              _isAuthenticated = true;
              
              // Update stored token
              await _persistenceService.updateAuthToken(data['token']);
              await _persistenceService.updateUserData(data['user']);
            } else {
              // Refresh failed, clear stored data
              await _persistenceService.clearAuthData();
            }
          } else {
            // No refresh token, clear stored data
            await _persistenceService.clearAuthData();
          }
        }
      }
      
      _isInitialized = true;
      _setLoading(false);
    } catch (e) {
      // Error occurred, clear stored data and continue
      await _persistenceService.clearAuthData();
      _isInitialized = true;
      _setLoading(false);
    }
  }
  
  // Check if user has persistent session
  Future<bool> hasPersistentSession() async {
    return await _persistenceService.hasStoredAuth() && 
           await _persistenceService.isSessionValid();
  }
  
  // Get API service for other components
  AdminApiService get apiService => _apiService;
} 