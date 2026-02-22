import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/services/auth_api_service.dart';
import '../../auth/presentation/auth_screen.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.profil),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            _buildUserProfileCard(),
            
            const SizedBox(height: 24),
            
            // Password Change Section
            _buildPasswordChangeSection(),
            
            const SizedBox(height: 24),
            
            // Logout Button
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    final user = context.watch<AppStateProvider>().currentUser;
    
    // Get initials from full name
    String getInitials(String? fullName) {
      if (fullName == null || fullName.isEmpty) return 'U';
      final names = fullName.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else {
        return fullName[0].toUpperCase();
      }
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // User Avatar
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  getInitials(user?['full_name']),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?['full_name'] ?? 'User',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?['email'] ?? 'No Email',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (user?['role'] != null)
                    Text(
                      '${user!['role'].toString().toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (user?['department'] != null)
                    Text(
                      user!['department'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordChangeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubah Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Current Password
            const Text(
              'Password Saat Ini',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _currentPasswordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Masukkan password saat ini',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // New Password
            const Text(
              'Password Baru',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _newPasswordController,
              obscureText: !_isNewPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Masukkan password baru',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Confirm Password
            const Text(
              'Konfirmasi Password',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Konfirmasi password baru',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Update Password Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _updatePassword,
                child: const Text('Ubah Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.errorColor,
          foregroundColor: Colors.white,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout),
            SizedBox(width: 8),
            Text('Keluar'),
          ],
        ),
      ),
    );
  }

  void _updatePassword() {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Semua field harus diisi');
      return;
    }
    
    if (newPassword != confirmPassword) {
      _showMessage('Password baru dan konfirmasi tidak sama');
      return;
    }
    
    if (newPassword.length < 8) {
      _showMessage('Password minimal 8 karakter');
      return;
    }
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Mengubah password...'),
          ],
        ),
      ),
    );
    
    // Call real password change API
    final user = context.read<AppStateProvider>().currentUser;
    final token = user?['token'];
    
    if (token == null) {
      Navigator.pop(context); // Close loading dialog
      _showMessage('Session expired. Please login again.');
      return;
    }
    
    AuthApiService.changePassword(
      token: token,
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    ).then((result) {
      Navigator.pop(context); // Close loading dialog
      
      if (result['success'] == true) {
        _showMessage('✅ ${result['message']}', isSuccess: true);
        
        // Clear fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        _showMessage('❌ ${result['message']}', isError: true);
      }
    }).catchError((error) {
      Navigator.pop(context); // Close loading dialog
      _showMessage('❌ Terjadi kesalahan: $error', isError: true);
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation dialog first
                _performLogout(); // Call separate logout method
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout() async {
    // Show loading dialog
    bool loadingClosed = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Sedang logout...'),
          ],
        ),
      ),
    );

    // Set up emergency timeout as final fallback
    Timer(Duration(seconds: 5), () {
      if (!loadingClosed && mounted) {
        print('🚨 Emergency logout timeout triggered');
        Navigator.of(context).pop(); // Force close loading
        loadingClosed = true;
        _emergencyLogout();
      }
    });

    try {
      // Main logout process with shorter timeout
      await Future.any([
        _executeLogout(),
        Future.delayed(Duration(seconds: 2)),
      ]);
      
      // If successful, close loading and navigate
      if (mounted && !loadingClosed) {
        Navigator.of(context).pop(); // Close loading
        loadingClosed = true;
        _navigateToLogin();
      }
    } catch (e) {
      print('⚠️ Logout process error: $e');
      if (mounted && !loadingClosed) {
        Navigator.of(context).pop(); // Close loading
        loadingClosed = true;
        _emergencyLogout();
      }
    }
  }

  Future<void> _executeLogout() async {
    try {
      // Clear app state first (this is instant)
      await context.read<AppStateProvider>().logout();
    } catch (e) {
      // If normal logout fails, force clear critical state
      print('❌ Normal logout failed: $e');
      context.read<AppStateProvider>().setAuthenticated(false);
      throw e;
    }
  }

  void _emergencyLogout() {
    print('🚨 Executing emergency logout');
    
    // Force clear authentication state
    context.read<AppStateProvider>().setAuthenticated(false);
    
    // Navigate to login immediately
    _navigateToLogin();
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  void _showMessage(String message, {bool isSuccess = false, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isSuccess ? Colors.green : isError ? Colors.red : null,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 