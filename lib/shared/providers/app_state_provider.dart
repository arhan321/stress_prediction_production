import 'package:flutter/material.dart';
import '../services/auth_api_service.dart';

class AppStateProvider with ChangeNotifier {
  // Navigation state
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
  
  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // User authentication state
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  
  bool _isCheckingSession = true; // Add loading state for session check
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;
  
  void setAuthenticated(bool authenticated) {
    _isAuthenticated = authenticated;
    notifyListeners();
  }
  
  void setUser(Map<String, dynamic> user) {
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
  }
  
  // Current dataset information
  String? _currentDatasetName;
  String? get currentDatasetName => _currentDatasetName;
  
  int _datasetSize = 0;
  int get datasetSize => _datasetSize;
  
  void setCurrentDataset(String? name, int size) {
    _currentDatasetName = name;
    _datasetSize = size;
    notifyListeners();
  }
  
  // Analysis state
  bool _isAnalyzing = false;
  bool get isAnalyzing => _isAnalyzing;
  
  double _analysisProgress = 0.0;
  double get analysisProgress => _analysisProgress;
  
  void setAnalysisState(bool analyzing, {double progress = 0.0}) {
    _isAnalyzing = analyzing;
    _analysisProgress = progress;
    notifyListeners();
  }
  
  // Current analysis results
  double _currentStressLevel = 0.0;
  double get currentStressLevel => _currentStressLevel;
  
  Map<String, double> _factorImportance = {};
  Map<String, double> get factorImportance => _factorImportance;
  
  void setAnalysisResults(double stressLevel, Map<String, double> factors) {
    _currentStressLevel = stressLevel;
    _factorImportance = Map.from(factors);
    notifyListeners();
  }
  
  // App theme and settings
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
  
  // Error handling
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Initialize app state and check for saved session
  Future<void> initializeApp() async {
    _isCheckingSession = true;
    notifyListeners();

    try {
      print('🔄 Checking for saved user session...');
      final savedSession = await AuthApiService.loadUserSession();
      
      if (savedSession != null) {
        print('✅ Found saved session, auto-login successful');
        _isAuthenticated = true;
        _currentUser = savedSession;
        _errorMessage = null;
        
        // Extend session since user is actively using the app
        await AuthApiService.extendSession();
      } else {
        print('📱 No saved session found, user needs to login');
        _isAuthenticated = false;
        _currentUser = null;
      }
    } catch (e) {
      print('❌ Error during session check: $e');
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = 'Session check failed';
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  // Login method
  Future<bool> login(String usernameOrEmail, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthApiService.loginUser(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );

      if (result['success'] == true) {
        _isAuthenticated = true;
        _currentUser = {
          'token': result['token'],
          'session_token': result['session_token'],
          ...result['user'],
        };
        _errorMessage = null;
        
        print('✅ Login successful, session saved automatically');
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    print('🔄 Starting logout process...');

    try {
      if (_currentUser != null && _currentUser!['token'] != null) {
        // Attempt to logout from server
        print('📡 Attempting server logout...');
        await AuthApiService.logoutUser(
          token: _currentUser!['token'],
          sessionToken: _currentUser!['session_token'],
        );
        print('✅ Server logout successful');
      }
    } catch (e) {
      print('⚠️ Server logout failed, but clearing local session: $e');
      // Continue with local cleanup even if server logout fails
    } finally {
      // Always clear local state regardless of server response
      print('🗑️ Clearing local app state...');
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = null;
      _currentStressLevel = 0.0;
      _factorImportance.clear();
      _currentIndex = 0; // Reset navigation to home tab
      _isLoading = false; // Ensure loading state is cleared
      
      // Clear persistent storage
      try {
        await AuthApiService.clearUserSession();
        print('✅ Persistent storage cleared');
      } catch (storageError) {
        print('⚠️ Error clearing storage: $storageError');
      }
      
      print('🏁 Logout completed, all data cleared');
      notifyListeners();
    }
  }

  // Check session validity
  Future<bool> validateSession() async {
    if (!_isAuthenticated || _currentUser == null) {
      return false;
    }

    try {
      final isValid = await AuthApiService.hasValidSession();
      if (!isValid) {
        print('⏰ Session expired, logging out...');
        await logout();
        return false;
      }
      
      // Extend session if still valid
      await AuthApiService.extendSession();
      return true;
    } catch (e) {
      print('❌ Session validation failed: $e');
      await logout();
      return false;
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (!_isAuthenticated || _currentUser == null || _currentUser!['token'] == null) {
      return;
    }

    try {
      final result = await AuthApiService.getUserProfile(_currentUser!['token']);
      if (result['success'] == true) {
        _currentUser = {
          ..._currentUser!,
          ...result['user'],
        };
        notifyListeners();
      }
    } catch (e) {
      print('❌ Failed to refresh user data: $e');
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? department,
    String? position,
    String? phoneNumber,
  }) async {
    if (!_isAuthenticated || _currentUser == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await AuthApiService.updateProfile(
        token: _currentUser!['token'],
        fullName: fullName,
        department: department,
        position: position,
        phoneNumber: phoneNumber,
      );

      if (result['success'] == true) {
        // Update local user data
        _currentUser = {
          ..._currentUser!,
          ...result['user'],
        };
        
        // Update persistent storage with new user data
        await AuthApiService.saveUserSession(
          token: _currentUser!['token'],
          userData: _currentUser!,
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Update failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool get isCheckingSession => _isCheckingSession;
} 