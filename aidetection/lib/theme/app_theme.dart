import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Colors ──
  static const bg       = Color(0xFF0A0A0B);
  static const bg2      = Color(0xFF111113);
  static const bg3      = Color(0xFF18181C);
  static const bg4      = Color(0xFF202026);
  static const line     = Color(0x12FFFFFF);
  static const line2    = Color(0x1FFFFFFF);
  static const textPrimary   = Color(0xFFF0EDE8);
  static const textSecondary = Color(0xFF9A9691);
  static const textMuted     = Color(0xFF5C5A57);
  static const accent   = Color(0xFFE8C547);
  static const accent2  = Color(0xFFF5D76E);
  static const aiColor  = Color(0xFFF0614A);
  static const aiLight  = Color(0xFFFF8F7E);
  static const humanColor  = Color(0xFF4ADE98);
  static const humanLight  = Color(0xFF86EFB8);

  // ── Text Styles ──
  static TextStyle get serif => GoogleFonts.instrumentSerif(
    color: textPrimary,
    fontStyle: FontStyle.italic,
  );

  static TextStyle get mono => GoogleFonts.dmMono(
    color: textPrimary,
  );

  static TextStyle get sans => GoogleFonts.syne(
    color: textPrimary,
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      surface: bg2,
      primary: accent,
      secondary: humanColor,
      error: aiColor,
    ),
    textTheme: GoogleFonts.syneTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.instrumentSerif(
        color: textPrimary,
        fontSize: 22,
        fontStyle: FontStyle.italic,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bg3,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: accent.withOpacity(0.4), width: 1.5),
      ),
      hintStyle: GoogleFonts.syne(color: textMuted, fontSize: 14),
      contentPadding: const EdgeInsets.all(20),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: bg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.syne(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    dividerColor: line,
  );
}
