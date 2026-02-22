import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'admin/core/theme/admin_theme.dart';
import 'admin/shared/providers/admin_state_provider.dart';
import 'admin/features/auth/presentation/admin_auth_wrapper.dart';
import 'core/theme/custom_scroll_behavior.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminStateProvider()),
      ],
      child: MaterialApp(
        title: 'Stress Analysis - Admin Panel',
        debugShowCheckedModeBanner: false,
        scrollBehavior: const NoScrollbarBehavior(),
        theme: AdminTheme.lightTheme,
        home: const AdminAuthWrapper(),
      ),
    );
  }
} 