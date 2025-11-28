import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Safely get Google Fonts with fallback to system font
/// This prevents crashes when network is unavailable
TextStyle safeGoogleFonts({
  required String fontFamily,
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
}) {
  try {
    // Try to use Google Fonts
    switch (fontFamily.toLowerCase()) {
      case 'inter':
        return GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
          decoration: decoration,
        );
      default:
        return TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
          decoration: decoration,
        );
    }
  } catch (e) {
    // Fallback to system font if Google Fonts fails
    debugPrint('Google Fonts error (using fallback): $e');
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }
}

