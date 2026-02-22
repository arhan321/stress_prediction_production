import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../auth/presentation/auth_screen.dart';
import '../../home/presentation/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    await _animationController.forward();

    // Initialize app and check for saved session
    await _initializeApp();
  }

  Future<void> _initializeApp() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    // Initialize the app state (checks for saved session)
    await appState.initializeApp();

    // Wait minimum splash time for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      // Navigate based on authentication state
      if (appState.isAuthenticated) {
        // User has valid saved session, go to main app
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigation(),
          ),
        );
      } else {
        // No valid session, go to auth screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AuthScreen(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.backgroundColor,
                      AppTheme.primaryColor.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Company Logo/Icon
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            // child: const Icon(
                            //   Icons.analytics_outlined,
                            //   size: 60,
                            //   color: Colors.white,
                            // ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                'asset/images/LWS.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Company Name
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          AppConstants.companyName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // App Title
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          AppConstants.appName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 64),

                      // Loading Animation
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: AppTheme.primaryColor,
                          size: 40,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Loading Text with dynamic status
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          appState.isCheckingSession
                              ? 'Memeriksa sesi tersimpan...'
                              : 'Memuat aplikasi...',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textLight,
                                  ),
                        ),
                      ),

                      // Show additional status if user found
                      if (appState.isAuthenticated &&
                          appState.currentUser != null) ...[
                        const SizedBox(height: 8),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            '✅ Selamat datang kembali, ${appState.currentUser!['username'] ?? 'User'}!',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
