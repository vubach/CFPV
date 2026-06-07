import 'package:flutter/material.dart';

/// CFPV Color Palette
/// Source: DESIGN.md §11.1
class CFPVColors {
  CFPVColors._();

  // ── Green System ──────────────────────────────────────────
  static const Color starbucksGreen = Color(0xFF006241); // H1, brand headings
  static const Color greenAccent = Color(0xFF00754A); // CTAs, Frap button
  static const Color houseGreen = Color(0xFF1E3932); // Feature bands, footer
  static const Color greenUplift = Color(0xFF2B5148); // Decorative accents
  static const Color greenLight = Color(0xFFD4E9E2); // Form valid tint

  // ── Warm Neutral System ──────────────────────────────────
  static const Color neutralWarm = Color(0xFFF2F0EB); // Page canvas
  static const Color ceramic = Color(0xFFEDEBE9); // Zone separators
  static const Color neutralCool = Color(0xFFF9F9F9); // Dropdown bg
  static const Color white = Color(0xFFFFFFFF); // Card bg, modals
  static const Color black = Color(0xFF000000); // Auth bar CTA

  // ── Text Colors ──────────────────────────────────────────
  static const Color textBlack = Color.fromRGBO(0, 0, 0, 0.87);
  static const Color textBlackSoft = Color.fromRGBO(0, 0, 0, 0.58);
  static const Color textWhite = Color.fromRGBO(255, 255, 255, 1);
  static const Color textWhiteSoft = Color.fromRGBO(255, 255, 255, 0.70);
  static const Color rewardsGreen = Color(0xFF33433D);

  // ── Accent Colors ────────────────────────────────────────
  static const Color gold = Color(0xFFCBA258); // Rewards only
  static const Color goldLight = Color(0xFFDFC49D); // Rewards bg
  static const Color red = Color(0xFFC82014); // Error / destructive
  static const Color yellow = Color(0xFFFBBC05); // Warning (legacy)

  // ── Borders ──────────────────────────────────────────────
  static const Color inputBorder = Color(0xFFD6DBDE);
  static const Color hairline = Color(0xFFE7E7E7);
}
