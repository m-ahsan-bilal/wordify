import 'package:flutter/material.dart';
// Google Fonts import removed - using system fonts for better performance and offline support

/// Safely get Google Fonts with fallback to system font
/// This prevents crashes when network is unavailable
/// Uses timeout to prevent blocking
TextStyle safeGoogleFonts({
  required String fontFamily,
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
}) {
  // For splash screen and critical paths, use system font directly
  // to avoid any network delays or blocking
  return TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
  );
  
  // Uncomment below if you want to try Google Fonts (may block on slow/no network)
  /*
  try {
    // Try to use Google Fonts with timeout
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
  */
}

