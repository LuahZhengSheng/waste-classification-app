import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';

/// -- Light & Dark Elevated Button Themes
class FOutlinedButtonTheme {
  FOutlinedButtonTheme._();  // To avoid creating instances

  /// -- Light Theme (Customer)
  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.grey),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        textStyle: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      )
  );

  /// -- Dark Theme (Customer)
  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.grey),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        textStyle: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      )
  );

  /// -- Admin Light Theme
  static final adminLightOutlinedButtonTheme = OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        foregroundColor: FColors.adminLightSurface,
        backgroundColor: Colors.transparent,
        side: BorderSide(color: FColors.adminLightBorder),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: TextStyle(
            fontSize: 14,
            color: FColors.adminLightSurface,
            fontWeight: FontWeight.w600
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      )
  );

  /// -- Admin Dark Theme
  static final adminDarkOutlinedButtonTheme = OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        foregroundColor: FColors.adminDarkSurface,
        backgroundColor: Colors.transparent,
        side: BorderSide(color: FColors.adminDarkBorder),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: TextStyle(
            fontSize: 14,
            color: FColors.adminDarkSurface,
            fontWeight: FontWeight.w600
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      )
  );
}