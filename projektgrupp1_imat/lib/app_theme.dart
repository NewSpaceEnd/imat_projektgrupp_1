import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFE9E9EA);
  static const Color panel = Color(0xFFD7D7D8);
  static const Color panelSoft = Color(0xFFEFEFEF);
  static const Color border = Color(0xFFBDBDBE);
  static const Color textPrimary = Color(0xFF323236);
  static const Color accent = Color(0xFF5A3CC9);
  static const Color topBar = Color(0xFF0D0D0F);

  static ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.light,
  );

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.oswaldTextTheme().copyWith(
        bodyMedium: GoogleFonts.sourceSans3(
          fontSize: 18,
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodySmall: GoogleFonts.sourceSans3(
          fontSize: 14,
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
