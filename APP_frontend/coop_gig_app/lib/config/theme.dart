import 'package:flutter/material.dart';

class AppColors {
  // Figma Exact Palette
  static const Color forestGreen = Color(0xFF22483E);       // Primary Deep Forest Green
  static const Color forestGreenDark = Color(0xFF17332B);   // Hero Card Dark Green
  static const Color forestGreenLight = Color(0xFFE8F3ED);  // Selected Service Background
  static const Color forestGreenSubtle = Color(0xFFD6EAE0); // Accent mint

  // Standard aliases so all screens compile seamlessly with Figma palette
  static const Color primaryLight = forestGreen;
  static const Color primaryDark = Color(0xFF3D6B5D);
  static const Color backgroundLight = Color(0xFFFAF7EE);
  static const Color backgroundDark = Color(0xFF0F1C18);

  // Soft Organic Pastel Wash (Figma background gradient)
  static const Color bgCream = Color(0xFFFAF7EE);          // Warm cream top
  static const Color bgMid = Color(0xFFEFF5EE);            // Transition
  static const Color bgSage = Color(0xFFDCECE2);           // Pastel mint/sage bottom

  // Dark Mode equivalents
  static const Color bgDarkTop = Color(0xFF0F1C18);
  static const Color bgDarkMid = Color(0xFF13231E);
  static const Color bgDarkBottom = Color(0xFF172D26);

  // Cards & Surfaces
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF182D26);

  static const Color borderLight = Color(0xFFE2EBE5);
  static const Color borderDark = Color(0xFF233F36);

  // Typography
  static const Color textPrimaryLight = Color(0xFF13221C); // Deep Charcoal
  static const Color textPrimaryDark = Color(0xFFF0F5F2);

  static const Color textSecondaryLight = Color(0xFF6B7E76); // Muted Sage Grey
  static const Color textSecondaryDark = Color(0xFFA2B5AD);

  // Functional Accents
  static const Color coralPin = Color(0xFFDC5B4D); // Terracotta Red Pin 📍
  static const Color verified = Color(0xFF22483E); // Forest Green
  static const Color pending = Color(0xFFE69A28);  // Warm Gold Bell / Amber
  static const Color error = Color(0xFFE04F43);

  // Background Gradient decoration helper
  static const LinearGradient sageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgCream, bgMid, bgSage],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient darkSageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgDarkTop, bgDarkMid, bgDarkBottom],
    stops: [0.0, 0.45, 1.0],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.forestGreen,
      scaffoldBackgroundColor: Colors.transparent, // Uses AppColors.sageGradient container
      colorScheme: const ColorScheme.light(
        primary: AppColors.forestGreen,
        onPrimary: Colors.white,
        secondary: AppColors.forestGreen,
        onSecondary: Colors.white,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.error,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.forestGreen,
          side: const BorderSide(color: AppColors.borderLight, width: 1.2),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.forestGreen, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 14),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.forestGreenSubtle,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.forestGreenSubtle,
        onPrimary: AppColors.forestGreenDark,
        secondary: AppColors.forestGreenSubtle,
        onSecondary: Colors.white,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestGreenSubtle,
          foregroundColor: AppColors.forestGreenDark,
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
