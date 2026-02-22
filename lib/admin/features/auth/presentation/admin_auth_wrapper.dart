import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/admin_state_provider.dart';
import '../../../features/dashboard/presentation/admin_main_screen.dart';
import 'admin_auth_screen.dart';

class AdminAuthWrapper extends StatefulWidget {
  const AdminAuthWrapper({super.key});

  @override
  State<AdminAuthWrapper> createState() => _AdminAuthWrapperState();
}

class _AdminAuthWrapperState extends State<AdminAuthWrapper> {
  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final adminState = Provider.of<AdminStateProvider>(context, listen: false);
    await adminState.initializeAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminStateProvider>(
      builder: (context, adminState, child) {
        // Show loading while initializing
        if (!adminState.isInitialized) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Admin Logo/Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Loading indicator
                  const CircularProgressIndicator(
                    color: Color(0xFF2563EB),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Memeriksa sesi admin...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Navigate based on authentication state
        if (adminState.isAuthenticated) {
          return const AdminMainScreen();
        } else {
          return const AdminAuthScreen();
        }
      },
    );
  }
} 