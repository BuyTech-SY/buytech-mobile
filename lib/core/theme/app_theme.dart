import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        surface: AppColors.lightSurface,
      ),
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme).copyWith(
        titleLarge: GoogleFonts.cairo(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
        titleMedium: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
        bodyLarge: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
        bodyMedium: GoogleFonts.cairo(fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardTheme(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
    );
  }

  // Dark Theme (Blinq Signature Dark Style)
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        surface: AppColors.darkSurface,
      ),
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme).copyWith(
        titleLarge: GoogleFonts.cairo(fontWeight: FontWeight.w900, color: Colors.white),
        titleMedium: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: Colors.white),
        bodyLarge: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: const Color(0xFFE2E8F0)),
        bodyMedium: GoogleFonts.cairo(fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
    );
  }
}
