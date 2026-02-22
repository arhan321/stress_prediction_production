import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/custom_scroll_behavior.dart';
import 'core/constants/app_constants.dart';
import 'shared/providers/app_state_provider.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const StressPredictionApp());
}

class StressPredictionApp extends StatelessWidget {
  const StressPredictionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        // Apply custom scroll behavior to hide scrollbars throughout the app
        scrollBehavior: const NoScrollbarBehavior(),
        theme: AppTheme.lightTheme.copyWith(
          // Ensure icons are properly themed
          iconTheme: const IconThemeData(
            color: Color(0xFF374151),
            size: 24,
          ),
          // Explicitly configure primary icon theme
          primaryIconTheme: const IconThemeData(
            color: Color(0xFF2563EB),
            size: 24,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
