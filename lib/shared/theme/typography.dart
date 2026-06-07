import 'package:flutter/material.dart';
import 'colors.dart';

/// CFPV Typography Tokens
/// Source: DESIGN.md §11.2
class CFPVTypography {
  CFPVTypography._();

  static const TextStyle display = TextStyle(
    fontSize: 80,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.16,
  );

  static const TextStyle jumbo = TextStyle(
    fontSize: 58,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.16,
  );

  static const TextStyle heroLarge = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.16,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: -0.16,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.16,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w400,
    height: 1.75,
    letterSpacing: -0.16,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.01,
  );

  static const TextStyle small = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.01,
  );

  static const TextStyle smallBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: -0.01,
  );

  static const TextStyle micro = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.01,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.01,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.01,
  );

  /// Convenience getters for themed text styles
  static TextStyle get h1Green => h1.copyWith(color: CFPVColors.starbucksGreen);
  static TextStyle get bodySoft => body.copyWith(color: CFPVColors.textBlackSoft);
  static TextStyle get h1White => h1.copyWith(color: CFPVColors.white);
  static TextStyle get bodyWhite => body.copyWith(color: CFPVColors.textWhite);
  static TextStyle get bodyWhiteSoft => body.copyWith(color: CFPVColors.textWhiteSoft);
}
