import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'spacing.dart';
import 'radius.dart';

/// CFPV App Theme
/// Constructs Material ThemeData from design tokens.
class CFPVTheme {
  CFPVTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: CFPVColors.greenAccent,
      secondary: CFPVColors.starbucksGreen,
      surface: CFPVColors.neutralWarm,
      error: CFPVColors.red,
      onPrimary: CFPVColors.white,
      onSecondary: CFPVColors.white,
      onSurface: CFPVColors.textBlack,
      onError: CFPVColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: CFPVColors.neutralWarm,

      // ── AppBar ───────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: CFPVColors.white,
        foregroundColor: CFPVColors.textBlack,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: CFPVTypography.h1,
        iconTheme: IconThemeData(color: CFPVColors.greenAccent),
      ),

      // ── Bottom Navigation ────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: CFPVColors.white,
        selectedItemColor: CFPVColors.greenAccent,
        unselectedItemColor: CFPVColors.textBlackSoft,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ── Elevated Button ─────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CFPVColors.greenAccent,
          foregroundColor: CFPVColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: CFPVSpacing.space3,
            vertical: CFPVSpacing.space2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CFPVRadius.button),
          ),
          textStyle: CFPVTypography.buttonLabel,
        ),
      ),

      // ── Outlined Button ─────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CFPVColors.greenAccent,
          side: const BorderSide(color: CFPVColors.greenAccent),
          padding: const EdgeInsets.symmetric(
            horizontal: CFPVSpacing.space3,
            vertical: CFPVSpacing.space2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CFPVRadius.button),
          ),
          textStyle: CFPVTypography.buttonLabel,
        ),
      ),

      // ── Text Button ─────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CFPVColors.greenAccent,
          textStyle: CFPVTypography.buttonSmall,
        ),
      ),

      // ── Input Decoration ────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CFPVColors.white,
        contentPadding: const EdgeInsets.all(CFPVSpacing.space3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CFPVRadius.input),
          borderSide: const BorderSide(color: CFPVColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CFPVRadius.input),
          borderSide: const BorderSide(color: CFPVColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CFPVRadius.input),
          borderSide: const BorderSide(color: CFPVColors.greenAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CFPVRadius.input),
          borderSide: const BorderSide(color: CFPVColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CFPVRadius.input),
          borderSide: const BorderSide(color: CFPVColors.red, width: 2),
        ),
        labelStyle: CFPVTypography.small.copyWith(color: CFPVColors.textBlackSoft),
        hintStyle: CFPVTypography.body.copyWith(color: CFPVColors.textBlackSoft),
        errorStyle: CFPVTypography.small.copyWith(color: CFPVColors.red),
      ),

      // ── Card ────────────────────────────────────
      cardTheme: CardThemeData(
        color: CFPVColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CFPVRadius.card),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Divider ─────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: CFPVColors.hairline,
        thickness: 1,
        space: 0,
      ),

      // ── Text ────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: CFPVTypography.display,
        headlineLarge: CFPVTypography.jumbo,
        headlineMedium: CFPVTypography.heroLarge,
        headlineSmall: CFPVTypography.h1,
        titleLarge: CFPVTypography.h2,
        bodyLarge: CFPVTypography.bodyLarge,
        bodyMedium: CFPVTypography.body,
        bodySmall: CFPVTypography.small,
        labelLarge: CFPVTypography.buttonLabel,
        labelSmall: CFPVTypography.micro,
      ),

      // ── Bottom Sheet ────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CFPVColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(CFPVRadius.card),
          ),
        ),
      ),
    );
  }
}
