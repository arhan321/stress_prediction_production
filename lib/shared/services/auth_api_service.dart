import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApiService {
  static const String baseUrl = AppConstants.baseUrl;

  // Persistent storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _loginTimestampKey = 'login_timestamp';

  // Token expiry duration (7 days)
  static const Duration _tokenExpiry = Duration(days: 7);

  // Mock token for development - replace with real authentication
  static String? _authToken;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // Set auth token (for mock purposes)
  static void setAuthToken(String token) {
    _authToken = token;
  }

  // Mock login for development
  static Future<Map<String, dynamic>> mockLogin() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Set mock token
    _authToken = 'mock-jwt-token-for-development';

    return {
      'success': true,
      'token': _authToken,
      'user': {
        'id': 1,
        'username': 'demo_user',
        'email': 'demo@acme.inc',
        'full_name': 'Demo User',
        'role': 'employee',
      }
    };
  }

  // Save user session to persistent storage
  static Future<void> saveUserSession({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, json.encode(userData));
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setInt(
          _loginTimestampKey, DateTime.now().millisecondsSinceEpoch);

      print('✅ User session saved to persistent storage');
    } catch (e) {
      print('❌ Error saving user session: $e');
    }
  }

  // Load user session from persistent storage
  static Future<Map<String, dynamic>?> loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      if (!isLoggedIn) {
        print('📱 No saved login session found');
        return null;
      }

      final token = prefs.getString(_tokenKey);
      final userDataString = prefs.getString(_userKey);
      final loginTimestamp = prefs.getInt(_loginTimestampKey);

      if (token == null || userDataString == null || loginTimestamp == null) {
        print('⚠️ Incomplete session data, clearing storage');
        await clearUserSession();
        return null;
      }

      // Check if token is expired
      final loginTime = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
      final now = DateTime.now();
      final timeDifference = now.difference(loginTime);

      if (timeDifference > _tokenExpiry) {
        print('⏰ Session expired, clearing storage');
        await clearUserSession();
        return null;
      }

      final userData = json.decode(userDataString) as Map<String, dynamic>;
      userData['token'] = token;

      print('✅ Loaded user session from persistent storage');
      print(
          '👤 User: ${userData['username']} (expires in ${_tokenExpiry - timeDifference})');

      return userData;
    } catch (e) {
      print('❌ Error loading user session: $e');
      await clearUserSession();
      return null;
    }
  }

  // Clear user session from persistent storage
  static Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_loginTimestampKey);

      print('🗑️ User session cleared from persistent storage');
    } catch (e) {
      print('❌ Error clearing user session: $e');
    }
  }

  // Check if user has valid saved session
  static Future<bool> hasValidSession() async {
    final session = await loadUserSession();
    return session != null;
  }

  // Update session timestamp (extend session)
  static Future<void> extendSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      if (isLoggedIn) {
        await prefs.setInt(
            _loginTimestampKey, DateTime.now().millisecondsSinceEpoch);
        print('🔄 Session extended');
      }
    } catch (e) {
      print('❌ Error extending session: $e');
    }
  }

  // Register new user
  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? department,
    String? position,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
          'department': department,
          'position': position,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> loginUser({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username_or_email': usernameOrEmail,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Save session to persistent storage on successful login
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;

        await saveUserSession(
          token: token,
          userData: userData,
        );

        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'token': token,
          'session_token': data['session_token'],
          'user': userData,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Change password
  static Future<Map<String, dynamic>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password changed successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update profile
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? fullName,
    String? department,
    String? position,
    String? phoneNumber,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      if (fullName != null && fullName.isNotEmpty) {
        updateData['full_name'] = fullName;
      }
      if (department != null) {
        updateData['department'] = department;
      }
      if (position != null) {
        updateData['position'] = position;
      }
      if (phoneNumber != null) {
        updateData['phone_number'] = phoneNumber;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/user/update-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Profile updated successfully',
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Logout user
  static Future<Map<String, dynamic>> logoutUser({
    required String token,
    String? sessionToken,
  }) async {
    try {
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      if (sessionToken != null) {
        headers['Session-Token'] = sessionToken;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/logout'),
        headers: headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Clear session from persistent storage on successful logout
        await clearUserSession();

        return {
          'success': true,
          'message': data['message'] ?? 'Logout successful',
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Logout failed',
        };
      }
    } catch (e) {
      // Clear session anyway if there's a network error during logout
      await clearUserSession();

      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Upload dataset
  static Future<Map<String, dynamic>> uploadDataset({
    required String token,
    String? filePath, // Optional for web compatibility
    List<int>? fileBytes, // For web platform
    required String fileName,
    String? datasetName,
    String? description,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/upload-dataset'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add file - handle both path and bytes
      if (fileBytes != null) {
        // For web platform - use bytes
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ));
      } else if (filePath != null) {
        // For mobile/desktop - use path
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
      } else {
        return {
          'success': false,
          'message': 'No file data provided',
        };
      }

      // Add form fields
      if (datasetName != null && datasetName.isNotEmpty) {
        request.fields['dataset_name'] = datasetName;
      }
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Dataset uploaded successfully',
          'dataset': data['dataset'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to upload dataset',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get datasets list
  static Future<Map<String, dynamic>> getDatasets({String? token}) async {
    print(
        '🔄 AuthApiService.getDatasets called with token: ${token != null ? 'present' : 'null'}');

    try {
      final headers = {'Content-Type': 'application/json'};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        print('🔐 Authorization header added');
      }

      print('📡 Making GET request to: $baseUrl/api/datasets');

      final response = await http
          .get(
        Uri.parse('$baseUrl/api/datasets'),
        headers: headers,
      )
          .timeout(
        const Duration(seconds: 15), // Increase timeout
        onTimeout: () {
          print('❌ Request timeout after 15 seconds');
          throw Exception('Request timeout - server may not be running');
        },
      );

      print('📊 Response status: ${response.statusCode}');
      print('📋 Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        print('✅ Datasets fetched successfully');
        return {
          'success': true,
          'datasets': data['datasets'],
          'summary': data['summary'],
        };
      } else {
        print('❌ Server returned error: ${response.statusCode}');
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get datasets',
        };
      }
    } catch (e) {
      print('❌ Network error in getDatasets: ${e.toString()}');

      // Provide more specific error messages
      String errorMessage;
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed to establish a new connection')) {
        errorMessage =
            'Server is not running. Please start the backend server.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Server may be slow or not responding.';
      } else {
        errorMessage = 'Network error: ${e.toString()}';
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  // Analyze dataset
  static Future<Map<String, dynamic>> analyzeDataset({
    required String token,
    required int datasetId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/analyze-dataset/$datasetId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Analysis completed successfully',
          'analysis': data,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to analyze dataset',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Analyze dataset with enhanced ML models
  static Future<Map<String, dynamic>> analyzeDatasetEnhanced({
    required String token,
    required int datasetId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/enhanced-analysis/$datasetId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Enhanced analysis completed successfully',
          'analysis': data,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to perform enhanced analysis',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Perform enhanced analysis (alias for analyzeDatasetEnhanced)
  static Future<Map<String, dynamic>> performEnhancedAnalysis({
    required String token,
    required int datasetId,
  }) async {
    try {
      print(
          '🤖 Starting Enhanced Deep Learning Analysis for dataset $datasetId...');

      final response = await http.post(
        Uri.parse('$baseUrl/api/enhanced-analysis/$datasetId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🧠 Deep Learning API Response Status: ${response.statusCode}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print('✅ Deep Learning Analysis Successful');
        print(
            '📊 Recommendations count: ${responseData['recommendations']?.length ?? 0}');
        print('🎯 Analysis type: ${responseData['analysis_type']}');

        // Log neural network performance
        final summary = responseData['summary'];
        if (summary != null) {
          print('🧠 Neural Network Results:');
          print('   • Overall Stress: ${summary['overall_stress_level']}%');
          print(
              '   • Confidence Score: ${(summary['confidence_score'] * 100).toStringAsFixed(1)}%');
          print('   • Stress Category: ${summary['stress_category']}');
          print('   • Total Employees: ${summary['total_employees']}');
        }

        // Log implementation steps generation
        final recommendations = responseData['recommendations'] as List?;
        if (recommendations != null) {
          int totalSteps = 0;
          for (var rec in recommendations) {
            final steps = rec['implementation_steps'] as List?;
            if (steps != null) totalSteps += steps.length;
          }
          print('📋 Dynamic Implementation Steps Generated: $totalSteps total');
        }

        return responseData;
      } else {
        print('❌ Deep Learning Analysis Failed: ${response.statusCode}');
        print('📝 Error details: ${responseData['error']}');
        return {
          'success': false,
          'message': responseData['error'] ?? 'Deep learning analysis failed',
        };
      }
    } catch (e) {
      print('💥 Deep Learning Analysis Exception: ${e.toString()}');
      return {
        'success': false,
        'message':
            'Network error during deep learning analysis: ${e.toString()}',
      };
    }
  }

  // Delete dataset
  static Future<Map<String, dynamic>> deleteDataset({
    required String token,
    required int datasetId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/dataset/$datasetId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Dataset deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to delete dataset',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Test server connection
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Download dataset template
  static Future<Map<String, dynamic>> downloadTemplate() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/download-template'),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.bodyBytes, // Raw file data
          'filename': _extractFilenameFromResponse(response),
          'message': 'Template downloaded successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to download template',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static String _extractFilenameFromResponse(http.Response response) {
    // Try to extract filename from Content-Disposition header
    final contentDisposition = response.headers['content-disposition'];
    if (contentDisposition != null &&
        contentDisposition.contains('filename=')) {
      final filenameMatch =
          RegExp(r'filename="?([^"]+)"?').firstMatch(contentDisposition);
      if (filenameMatch != null) {
        return filenameMatch.group(1) ?? 'stress_dataset_template.csv';
      }
    }

    // Default filename with timestamp
    final timestamp =
        DateTime.now().toIso8601String().split('T')[0].replaceAll('-', '');
    return 'stress_dataset_template_$timestamp.csv';
  }

  // Get dynamic recommendations for a specific dataset
  static Future<Map<String, dynamic>> getDatasetRecommendations({
    required String token,
    required int datasetId,
  }) async {
    print('🔄 Getting dynamic recommendations for dataset $datasetId...');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dataset/$datasetId/recommendations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('❌ Recommendations request timeout after 15 seconds');
          throw Exception('Request timeout while fetching recommendations');
        },
      );

      print('📊 Recommendations response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);

          print('✅ Dynamic recommendations retrieved successfully');
          print(
              '💡 Recommendations count: ${responseData['recommendations']?.length ?? 0}');

          return {
            'success': true,
            'dataset_id': responseData['dataset_id'],
            'dataset_name': responseData['dataset_name'],
            'recommendations': responseData['recommendations'],
            'analysis_summary': responseData['analysis_summary'],
            'generated_at': responseData['generated_at'],
            'message': 'Dynamic recommendations retrieved successfully',
          };
        } catch (jsonError) {
          print(
              '❌ JSON parsing error for recommendations: ${jsonError.toString()}');

          return {
            'success': false,
            'message': 'Server returned invalid recommendation data format.',
            'technical_error': jsonError.toString(),
          };
        }
      } else {
        print('❌ Server returned error: ${response.statusCode}');

        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message':
                errorData['error'] ?? 'Failed to get dataset recommendations',
          };
        } catch (e) {
          return {
            'success': false,
            'message':
                'Server error: ${response.statusCode}. Please try again.',
          };
        }
      }
    } catch (e) {
      print('❌ Network error in getDatasetRecommendations: ${e.toString()}');

      String errorMessage;
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed to establish a new connection')) {
        errorMessage =
            'Cannot connect to server. Please check your connection and ensure the backend is running.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout while generating recommendations.';
      } else {
        errorMessage = 'Network error: ${e.toString()}';
      }

      return {
        'success': false,
        'message': errorMessage,
        'technical_error': e.toString(),
      };
    }
  }

  // Get basic analysis for a specific dataset
  static Future<Map<String, dynamic>> getDatasetBasicAnalysis({
    required String token,
    required int datasetId,
  }) async {
    print('🔄 Getting basic analysis for dataset $datasetId...');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dataset/$datasetId/basic-analysis'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(
            seconds: 30), // Extended timeout for deep learning processing
        onTimeout: () {
          print('❌ Analysis request timeout after 30 seconds');
          throw Exception(
              'Analisis membutuhkan waktu lebih lama - server sedang memproses data besar');
        },
      );

      print('📊 Analysis response status: ${response.statusCode}');
      print('📋 Analysis response length: ${response.body.length} characters');

      if (response.statusCode == 200) {
        try {
          // Check for common JSON parsing issues before attempting to decode
          final responseBody = response.body;

          // Check for NaN values in the response string
          if (responseBody.contains('NaN') || responseBody.contains('null')) {
            print(
                '⚠️  Response contains NaN or null values, attempting to clean...');
            // Try to clean the response
            final cleanedBody = responseBody
                .replaceAll('NaN', '0.0')
                .replaceAll('"null"', 'null')
                .replaceAll(': null,', ': 0.0,')
                .replaceAll(': null}', ': 0.0}');

            print('🔧 Cleaned response, attempting to parse...');
            final responseData = json.decode(cleanedBody);

            return {
              'success': true,
              'dataset_info': responseData['dataset_info'],
              'analysis': responseData['analysis'],
              'has_enhanced_analysis': responseData['has_enhanced_analysis'],
              'last_analysis_date': responseData['last_analysis_date'],
              'message': 'Dataset analysis retrieved successfully (cleaned)',
            };
          } else {
            // Normal parsing
            final responseData = json.decode(responseBody);

            print('✅ Analysis data retrieved successfully');

            return {
              'success': true,
              'dataset_info': responseData['dataset_info'],
              'analysis': responseData['analysis'],
              'has_enhanced_analysis': responseData['has_enhanced_analysis'],
              'last_analysis_date': responseData['last_analysis_date'],
              'message': 'Dataset analysis retrieved successfully',
            };
          }
        } catch (jsonError) {
          print('❌ JSON parsing error: ${jsonError.toString()}');
          print(
              '📋 Raw response (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

          return {
            'success': false,
            'message':
                'Server returned invalid data format. Please try refreshing or contact support.',
            'technical_error': jsonError.toString(),
          };
        }
      } else {
        print('❌ Server returned error: ${response.statusCode}');

        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['error'] ?? 'Failed to get dataset analysis',
          };
        } catch (e) {
          return {
            'success': false,
            'message':
                'Server error: ${response.statusCode}. Please try again.',
          };
        }
      }
    } catch (e) {
      print('❌ Network error in getDatasetBasicAnalysis: ${e.toString()}');

      // Provide more specific error messages
      String errorMessage;
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed to establish a new connection')) {
        errorMessage =
            'Cannot connect to server. Please check your connection and ensure the backend is running.';
      } else if (e.toString().contains('timeout')) {
        errorMessage =
            'Analisis membutuhkan waktu lebih lama. Server sedang memproses dataset Anda.';
      } else if (e.toString().contains('FormatException') ||
          e.toString().contains('JSON')) {
        errorMessage =
            'Server mengembalikan data tidak valid. Coba upload dataset baru atau hubungi dukungan.';
      } else {
        errorMessage = 'Error jaringan: ${e.toString()}';
      }

      return {
        'success': false,
        'message': errorMessage,
        'technical_error': e.toString(),
      };
    }
  }

  // Get employees from specific dataset
  static Future<Map<String, dynamic>> getDatasetEmployees(int datasetId) async {
    print('🔄 Getting employees from dataset $datasetId...');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dataset/$datasetId/employees'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('❌ Request timeout after 15 seconds');
          throw Exception('Request timeout - server may be slow');
        },
      );

      print('📊 Employees response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(
            '✅ Successfully loaded ${data['total_employees']} employees from ${data['dataset_name']}');
        return data;
      } else {
        print('❌ Failed to load employees: ${response.statusCode}');
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error loading employees: ${e.toString()}');

      // Return mock data for development if API fails
      print('🔄 Falling back to mock data...');
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'dataset_id': datasetId,
        'dataset_name': 'Mock Dataset',
        'employees': [
          {
            'employee_id': 'EMP001',
            'name': 'Employee EMP001',
            'department': 'IT',
            'position': 'Software Developer',
            'age': 28,
            'workload': 7.5,
            'work_life_balance': 6.2,
            'team_conflict': 3.8,
            'management_support': 8.1,
            'work_environment': 7.9,
            'stress_level': 65.3
          },
          {
            'employee_id': 'EMP002',
            'name': 'Employee EMP002',
            'department': 'HR',
            'position': 'HR Specialist',
            'age': 32,
            'workload': 6.8,
            'work_life_balance': 7.1,
            'team_conflict': 2.5,
            'management_support': 8.9,
            'work_environment': 8.2,
            'stress_level': 45.7
          },
          {
            'employee_id': 'EMP003',
            'name': 'Employee EMP003',
            'department': 'Finance',
            'position': 'Financial Analyst',
            'age': 29,
            'workload': 8.2,
            'work_life_balance': 5.8,
            'team_conflict': 4.1,
            'management_support': 7.3,
            'work_environment': 6.9,
            'stress_level': 72.1
          },
        ],
        'total_employees': 3,
        'departments': ['IT', 'HR', 'Finance'],
      };
    }
  }

  // Analyze individual employee
  static Future<Map<String, dynamic>> analyzeEmployee(
      int datasetId, String employeeId) async {
    print('🔄 Analyzing employee $employeeId from dataset $datasetId...');

    try {
      final response = await http
          .post(
        Uri.parse(
            '$baseUrl/api/dataset/$datasetId/employee/$employeeId/analyze'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({}),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('❌ Analysis timeout after 30 seconds');
          throw Exception(
              'Analysis timeout - complex analysis taking too long');
        },
      );

      print('📊 Analysis response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(
            '✅ Successfully analyzed employee ${data['employee_info']['name']}');
        print('📈 Stress Level: ${data['stress_analysis']['stress_level']}%');
        print('🎯 Risk Factors: ${data['risk_factors'].length}');
        return data;
      } else {
        print('❌ Failed to analyze employee: ${response.statusCode}');
        throw Exception('Failed to analyze employee: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error analyzing employee: ${e.toString()}');

      // Return mock analysis for development if API fails
      print('🔄 Falling back to mock analysis...');
      await Future.delayed(const Duration(seconds: 2));
      return {
        'success': true,
        'dataset_id': datasetId,
        'dataset_name': 'Mock Dataset',
        'employee_info': {
          'employee_id': employeeId,
          'name': 'Employee $employeeId',
          'department': 'IT',
          'position': 'Staff',
          'age': 30,
          'workload': 7.5,
          'work_life_balance': 6.2,
          'team_conflict': 3.8,
          'management_support': 8.1,
          'work_environment': 7.9,
          'actual_stress_level': 65.3
        },
        'stress_analysis': {
          'stress_level': 65.3,
          'stress_category': 'Medium',
          'stress_color': 'orange',
          'prediction_confidence': 87.5,
          'department_average': 62.1,
          'compared_to_department': 'Di atas rata-rata'
        },
        'risk_factors': [
          {
            'factor': 'Beban Kerja',
            'value': 7.5,
            'impact': 'Tinggi',
            'recommendation': 'Redistributions tugas dan optimalisasi workflow'
          },
          {
            'factor': 'Ketegangan dan Kesimbangan Kerja',
            'value': 6.2,
            'impact': 'Medium',
            'recommendation': 'Berikan pelatihan time management'
          },
          {
            'factor': 'Konflik Tim',
            'value': 3.8,
            'impact': 'Rendah',
            'recommendation': 'Pertahankan harmoni tim yang baik'
          },
          {
            'factor': 'Dukungan Manajemen',
            'value': 8.1,
            'impact': 'Rendah',
            'recommendation': 'Pertahankan dukungan manajemen yang baik'
          },
          {
            'factor': 'Lingkungan Kerja',
            'value': 7.9,
            'impact': 'Rendah',
            'recommendation': 'Pertahankan lingkungan kerja yang kondusif'
          },
        ],
        'similar_profiles': [
          {
            'employee_id': 'EMP004',
            'department': 'IT',
            'stress_level': 67.2,
            'similarity': 89.2
          },
          {
            'employee_id': 'EMP005',
            'department': 'IT',
            'stress_level': 63.8,
            'similarity': 84.7
          },
        ],
        'analysis_timestamp': DateTime.now().toIso8601String(),
        'recommendations_summary':
            'Berdasarkan analisis, karyawan ini memiliki tingkat stres medium dengan skor 65.3%. Fokus utama intervensi pada faktor dengan dampak tinggi.'
      };
    }
  }
}
