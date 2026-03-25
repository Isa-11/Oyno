import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF111111);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color accent = Color(0xFFCCFF00);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF777777);
  static const Color darkChip = Color(0xFF2A2A2A);
  static const Color surface = Color(0xFF252525);
  static const Color divider = Color(0xFF2E2E2E);
  static const Color onlineGreen = Color(0xFF4CAF50);
  static const Color confirmGreen = Color(0xFF00C853);
  static const Color waitGray = Color(0xFF555555);
  static const Color dangerRed = Color(0xFFFF3B30);
}

class AppTextStyles {
  static TextStyle get headingXL => GoogleFonts.oswald(
        color: AppColors.textPrimary,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
      );

  static TextStyle get headingLG => GoogleFonts.oswald(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      );

  static TextStyle get headingMD => GoogleFonts.oswald(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      );

  static TextStyle get headingAccent => GoogleFonts.oswald(
        color: AppColors.accent,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      );

  static TextStyle get bodyMD => GoogleFonts.oswald(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      );

  static TextStyle get bodySM => GoogleFonts.oswald(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
      );

  static TextStyle get labelBold => GoogleFonts.oswald(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      );

  static TextStyle get accentBold => GoogleFonts.oswald(
        color: AppColors.accent,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      );
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.accent,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.cardBackground,
        ),
        fontFamily: GoogleFonts.oswald().fontFamily,
        textTheme: GoogleFonts.oswaldTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.cardBackground,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );
}
