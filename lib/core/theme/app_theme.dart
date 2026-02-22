import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors (Clean white theme with black outlines)
  static const Color primaryColor = Color(0xFF2563EB); // Clean blue accent
  static const Color primaryVariant = Color(0xFF1E40AF);
  static const Color secondaryColor = Color(0xFF059669); // Green for success
  static const Color backgroundColor = Color(0xFFFFFFFF); // Pure white background
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color warningColor = Color(0xFFF59E0B);
  
  // Text Colors (Strong contrast for readability)
  static const Color textPrimary = Color(0xFF000000); // Pure black text
  static const Color textSecondary = Color(0xFF374151); // Dark gray
  static const Color textLight = Color(0xFF6B7280); // Medium gray
  
  // Stress Level Colors (Subtle but clear)
  static const Color stressLow = Color(0xFF059669);    // Green
  static const Color stressModerate = Color(0xFFF59E0B); // Orange
  static const Color stressHigh = Color(0xFFDC2626);    // Red
  
  // Card and Background Colors (Clean white with soft gray borders)
  static const Color cardColor = Color(0xFFFFFFFF); // Pure white cards
  static const Color dividerColor = Color(0xFFE5E7EB); // Soft gray dividers
  static const Color borderColor = Color(0xFFD1D5DB); // Soft gray borders for smooth outline
  
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: MaterialColor(
        primaryColor.value,
        <int, Color>{
          50: primaryColor.withOpacity(0.1),
          100: primaryColor.withOpacity(0.2),
          200: primaryColor.withOpacity(0.3),
          300: primaryColor.withOpacity(0.4),
          400: primaryColor.withOpacity(0.5),
          500: primaryColor,
          600: primaryColor.withOpacity(0.7),
          700: primaryColor.withOpacity(0.8),
          800: primaryColor.withOpacity(0.9),
          900: primaryColor.withOpacity(1.0),
        },
      ),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      dividerColor: dividerColor,
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 1,
        shadowColor: Color(0x10000000), // Very subtle shadow
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      
      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Scrollbar Theme - Hide scrollbar visual but keep functionality
      scrollbarTheme: const ScrollbarThemeData(
        thumbVisibility: MaterialStatePropertyAll(false), // Hide thumb
        trackVisibility: MaterialStatePropertyAll(false), // Hide track
        interactive: false, // Disable interaction
        thickness: MaterialStatePropertyAll(0.0), // Set thickness to 0
        radius: Radius.circular(0), // Remove radius
        crossAxisMargin: 0.0, // Remove margin
        mainAxisMargin: 0.0, // Remove margin
      ),
      
      // Card Theme (White cards with soft gray borders and subtle shadow)
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: borderColor, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(
          color: textLight,
          fontSize: 14,
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: textLight,
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),
      
      // Progress Indicator Theme  
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: Color(0xFFF3F4F6), // Very light smooth gray for track
        circularTrackColor: Color(0xFFF3F4F6), // Very light smooth gray for track
      ),
    );
  }
  
  // Utility methods for progress colors based on percentage
  static Color getProgressColor(double percentage) {
    if (percentage <= 30) {
      return const Color(0xFF059669); // Green
    } else if (percentage <= 60) {
      return const Color(0xFFF59E0B); // Orange
    } else {
      return const Color(0xFFDC2626); // Red
    }
  }

  // Utility methods for stress level colors (kept for backward compatibility)
  static Color getStressLevelColor(double stressLevel) {
    return getProgressColor(stressLevel);
  }
  
  static String getStressCategory(double stressLevel) {
    if (stressLevel <= 30) return 'Rendah';
    if (stressLevel <= 60) return 'Medium';
    return 'Tinggi';
  }
} 