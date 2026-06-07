import 'package:flutter/material.dart';

/// CFPV Elevation (Shadow) Tokens
/// Source: DESIGN.md §11.4
class CFPVElevation {
  CFPVElevation._();

  /// Cards, modals
  static const List<BoxShadow> card = [
    BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 0.5,
      color: Color.fromRGBO(0, 0, 0, 0.14),
    ),
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 1,
      color: Color.fromRGBO(0, 0, 0, 0.24),
    ),
  ];

  /// Global navigation (tab bar, app bar)
  static const List<BoxShadow> nav = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 3,
      color: Color.fromRGBO(0, 0, 0, 0.1),
    ),
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 2,
      color: Color.fromRGBO(0, 0, 0, 0.06),
    ),
    BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 2,
      color: Color.fromRGBO(0, 0, 0, 0.07),
    ),
  ];

  /// Frap CTA base shadow (on press: fades)
  static const BoxShadow frapBase = BoxShadow(
    offset: Offset(0, 0),
    blurRadius: 6,
    color: Color.fromRGBO(0, 0, 0, 0.24),
  );

  /// Frap CTA ambient shadow
  static const BoxShadow frapAmbient = BoxShadow(
    offset: Offset(0, 8),
    blurRadius: 12,
    color: Color.fromRGBO(0, 0, 0, 0.14),
  );
}
