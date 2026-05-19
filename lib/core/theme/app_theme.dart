import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF00E676);
  static const Color accentGreen = Color(0xFF06C755);
  static const Color textPrimary = Color(0xFF1D1D1F);
  static const Color textSecondary = Color(0xFF3C4A42);
  static const Color background = Color(0xFFF4FBF4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFEF4444);
  static const Color textHint = Color(0xFFBBCABF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentGreen,
        surface: background,
        onSurface: textPrimary,
        error: error,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.publicSansTextTheme().copyWith(
        displayLarge: GoogleFonts.robotoMono(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.24,
        ),
        bodyLarge: GoogleFonts.publicSans(fontSize: 16, color: textPrimary),
        bodyMedium: GoogleFonts.publicSans(fontSize: 14, color: textSecondary),
        labelLarge: GoogleFonts.publicSans(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 0.6,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        hintStyle: GoogleFonts.publicSans(
          color: const Color(0xFFBBCABF),
          fontSize: 16,
        ),
      ),
    );
  }
}
