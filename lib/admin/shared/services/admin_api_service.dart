import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminApiService {
  static const String _baseUrl = 'http://localhost:5000/api';
  String? _authToken;

  // Singleton pattern
  static final AdminApiService _instance = AdminApiService._internal();
  factory AdminApiService() => _instance;
  AdminApiService._internal();

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username_or_email': email,
          'password': password,
          'remember_me': true, // Always remember admin sessions
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['user']['role'] == 'admin') {
          _authToken = data['token'];
          return {'success': true, 'data': data};
        } else {
          return {'success': false, 'error': 'Access denied: Admin role required'};
        }
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<void> logout() async {
    _authToken = null;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Token refresh failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/dashboard/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to fetch dashboard stats'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getRecentActivity() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/dashboard/activity'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to fetch recent activity'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Employees
  Future<Map<String, dynamic>> getEmployees({
    String? search,
    String? department,
    String? stressLevel,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (department != null && department != 'Semua') 'department': department,
        if (stressLevel != null && stressLevel != 'Semua') 'stress_level': stressLevel,
      };

      final uri = Uri.parse('$_baseUrl/employees').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to fetch employees'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getEmployeeStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/employees/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to fetch employee stats'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> deleteEmployee(int employeeId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/employees/$employeeId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Employee deleted successfully'};
      } else {
        return {'success': false, 'error': 'Failed to delete employee'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Datasets - Enhanced with admin endpoints
  Future<Map<String, dynamic>> getDatasets({
    int page = 1,
    int limit = 20,
    String search = '',
    String? status,
    String userId = '',
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (search.isNotEmpty) 'search': search,
        if (status != null && status != 'Semua') 'status': status.toLowerCase(),
        if (userId.isNotEmpty) 'user_id': userId,
      };

      final uri = Uri.parse('$_baseUrl/admin/datasets').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to fetch datasets'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getDatasetStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/datasets/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to fetch dataset stats'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> runAnalysis(int datasetId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/datasets/$datasetId/analyze'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to run analysis'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> deleteDataset(int datasetId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/datasets/$datasetId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Dataset deleted successfully'};
      } else {
        return {'success': false, 'error': 'Failed to delete dataset'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Analytics
  Future<Map<String, dynamic>> getAnalyticsData({
    String? period = '30',
    String? department,
  }) async {
    try {
      final queryParams = <String, String>{
        'period': period ?? '30',
        if (department != null && department != 'Semua Departemen') 'department': department,
      };

      final uri = Uri.parse('$_baseUrl/analytics').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to fetch analytics data'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getInsights() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/analytics/insights'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to fetch insights'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getRecommendations() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/analytics/recommendations'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to fetch recommendations'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Users Management - Enhanced with filtering and pagination
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 20,
    String search = '',
    String role = '',
    String department = '',
    bool activeOnly = true,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'active_only': activeOnly.toString(),
        if (search.isNotEmpty) 'search': search,
        if (role.isNotEmpty) 'role': role,
        if (department.isNotEmpty) 'department': department,
      };

      final uri = Uri.parse('$_baseUrl/admin/users').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to fetch users'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getUserDatasets(
    int userId, {
    int page = 1,
    int limit = 10,
    String status = '',
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (status.isNotEmpty) 'status': status,
      };

      final uri = Uri.parse('$_baseUrl/admin/users/$userId/datasets').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to fetch user datasets'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/users'),
        headers: _headers,
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to create user'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/users/$userId/edit'),
        headers: _headers,
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to update user'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> toggleUserStatus(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/users/$userId/toggle-status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to toggle user status'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> resetUserPassword(int userId, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/users/$userId/reset-password'),
        headers: _headers,
        body: jsonEncode({'new_password': newPassword}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to reset password'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }



  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/change-password'),
        headers: _headers,
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password changed successfully'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to change password'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // System Logs
  Future<Map<String, dynamic>> getSystemLogs({int page = 1, int limit = 50}) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$_baseUrl/admin/logs').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to fetch system logs'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }
} 