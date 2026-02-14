
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masr_spaces_app/theme/tokens.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTokens.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppTokens.primary,
        secondary: AppTokens.neutral,
        surface: AppTokens.surface,
        error: AppTokens.danger,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppTokens.bg,
      textTheme: _textTheme(false),
      appBarTheme: AppBarTheme(
        backgroundColor: AppTokens.bg,
        foregroundColor: AppTokens.text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppTokens.text,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppTokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rCard),
          side: const BorderSide(color: AppTokens.border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppTokens.surface,
        selectedColor: AppTokens.neutral,
        side: const BorderSide(color: AppTokens.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rPill),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTokens.text,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        helperStyle: GoogleFonts.inter(fontSize: 12, color: AppTokens.text2),
        errorStyle: GoogleFonts.inter(fontSize: 12, color: AppTokens.danger),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rInput),
          borderSide: const BorderSide(color: AppTokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rInput),
          borderSide: const BorderSide(color: AppTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rInput),
          borderSide: const BorderSide(color: AppTokens.primary, width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.rInput),
          ),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTokens.primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppTokens.neutral,
        secondary: AppTokens.accent,
        surface: AppTokens.surfaceDark,
        error: AppTokens.danger,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppTokens.bgDark,
      textTheme: _textTheme(true),
      appBarTheme: AppBarTheme(
        backgroundColor: AppTokens.bgDark,
        foregroundColor: AppTokens.textDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppTokens.textDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppTokens.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rCard),
          side: const BorderSide(color: AppTokens.borderDark),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppTokens.surfaceDark,
        selectedColor: AppTokens.primary.withOpacity(0.22),
        side: const BorderSide(color: AppTokens.borderDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rPill),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTokens.textDark,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        helperStyle: GoogleFonts.inter(fontSize: 12, color: AppTokens.text2Dark),
        errorStyle: GoogleFonts.inter(fontSize: 12, color: AppTokens.danger),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rInput),
          borderSide: const BorderSide(color: AppTokens.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rInput),
          borderSide: const BorderSide(color: AppTokens.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rInput),
          borderSide: const BorderSide(color: AppTokens.neutral, width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.rInput),
          ),
        ),
      ),
    );
  }

  static TextTheme _textTheme(bool dark) {
    final fg = dark ? AppTokens.textDark : AppTokens.text;
    final fg2 = dark ? AppTokens.text2Dark : AppTokens.text2;

    return TextTheme(
      headlineSmall: GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        height: 1.05,
        color: fg,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        height: 1.1,
        color: fg,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1.1,
        color: fg,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: fg,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: fg2,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: fg,
      ),
    );
  }
}
