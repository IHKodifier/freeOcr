import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Apple-inspired Material 3 ColorScheme design tokens for freeOCR.me
/// Adheres strictly to product-specs/05-style-guide.md
class AppTheme {
  AppTheme._();

  // --- Light Mode Color Tokens ---
  static const Color lightPrimary = Color(0xFF4F46E5); // Electric Indigo
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFEEF2FF);
  static const Color lightOnPrimaryContainer = Color(0xFF312E81);

  static const Color lightSecondary = Color(0xFF3B82F6); // Cyber Blue
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFDBEAFE);

  static const Color lightTertiary = Color(0xFF10B981); // Emerald Green

  static const Color lightSurface = Color(0xFFF8FAFC); // Slate Light
  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightSurfaceContainer = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerHigh = Color.fromRGBO(255, 255, 255, 0.75);

  static const Color lightOutline = Color(0xFFE2E8F0);
  static const Color lightOutlineVariant = Color(0xFFCBD5E1);

  static const Color lightError = Color(0xFFEF4444); // Rose Red

  // --- Dark Mode Color Tokens ---
  static const Color darkPrimary = Color(0xFF818CF8); // Light Indigo
  static const Color darkOnPrimary = Color(0xFF0F172A);
  static const Color darkPrimaryContainer = Color(0xFF312E81);
  static const Color darkOnPrimaryContainer = Color(0xFFE0E7FF);

  static const Color darkSecondary = Color(0xFF60A5FA); // Cyber Blue Dark
  static const Color darkOnSecondary = Color(0xFF0F172A);
  static const Color darkSecondaryContainer = Color(0xFF1E3A8A);

  static const Color darkTertiary = Color(0xFF34D399); // Emerald Green Dark

  static const Color darkSurface = Color(0xFF0F172A); // Slate Dark
  static const Color darkOnSurface = Color(0xFFF8FAFC);
  static const Color darkSurfaceContainer = Color(0xFF1E293B); // Slate Card
  static const Color darkSurfaceContainerHigh = Color.fromRGBO(30, 41, 59, 0.75);

  static const Color darkOutline = Color(0xFF334155);
  static const Color darkOutlineVariant = Color(0xFF475569);

  static const Color darkError = Color(0xFFF87171);

  // --- Color Schemes ---
  static final ColorScheme lightColorScheme = const ColorScheme.light(
    primary: lightPrimary,
    onPrimary: lightOnPrimary,
    primaryContainer: lightPrimaryContainer,
    onPrimaryContainer: lightOnPrimaryContainer,
    secondary: lightSecondary,
    onSecondary: lightOnSecondary,
    secondaryContainer: lightSecondaryContainer,
    tertiary: lightTertiary,
    surface: lightSurface,
    onSurface: lightOnSurface,
    surfaceContainer: lightSurfaceContainer,
    surfaceContainerHigh: lightSurfaceContainerHigh,
    outline: lightOutline,
    outlineVariant: lightOutlineVariant,
    error: lightError,
  );

  static final ColorScheme darkColorScheme = const ColorScheme.dark(
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    primaryContainer: darkPrimaryContainer,
    onPrimaryContainer: darkOnPrimaryContainer,
    secondary: darkSecondary,
    onSecondary: darkOnSecondary,
    secondaryContainer: darkSecondaryContainer,
    tertiary: darkTertiary,
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceContainer: darkSurfaceContainer,
    surfaceContainerHigh: darkSurfaceContainerHigh,
    outline: darkOutline,
    outlineVariant: darkOutlineVariant,
    error: darkError,
  );

  // --- Typography ---
  static TextTheme _buildTextTheme(TextTheme base, Color textColor) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        height: 1.1,
        color: textColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
        color: textColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: textColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: textColor,
      ),
    );
  }

  /// TextStyle helper for code and OCR text side-by-side preview
  static TextStyle codePreviewTextStyle({Color? color}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.6,
      color: color,
    );
  }

  // --- ThemeData Builders ---
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: lightSurface,
      textTheme: _buildTextTheme(base.textTheme, lightOnSurface),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightOutlineVariant, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: darkSurface,
      textTheme: _buildTextTheme(base.textTheme, darkOnSurface),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkOutlineVariant, width: 1.5),
        ),
      ),
    );
  }
}
