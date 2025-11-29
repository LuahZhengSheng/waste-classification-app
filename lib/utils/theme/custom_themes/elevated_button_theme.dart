import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';

/// -- Light & Dark Elevated Button Themes
class FElevatedButtonTheme {
  FElevatedButtonTheme._();  // To avoid creating instances

  /// -- Light Theme (Customer)
  static final ElevatedButtonThemeData lightElevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        disabledForegroundColor: Colors.grey,
        disabledBackgroundColor: Colors.grey,
        side: const BorderSide(color: Colors.transparent),
        padding: const EdgeInsets.symmetric(vertical: 18),
        textStyle: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      )
  );

  /// -- Dark Theme (Customer)
  static final ElevatedButtonThemeData darkElevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        disabledForegroundColor: Colors.grey,
        disabledBackgroundColor: Colors.grey,
        side: const BorderSide(color: Colors.transparent),
        padding: const EdgeInsets.symmetric(vertical: 18),
        textStyle: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      )
  );

  /// -- Admin Light Theme
  static final ElevatedButtonThemeData adminLightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: FColors.adminLightText,
      backgroundColor: FColors.adminLightPrimary,
      disabledForegroundColor: FColors.adminLightError,
      disabledBackgroundColor: FColors.adminLightError,
      side: BorderSide(color: FColors.adminLightPrimary),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: FColors.adminLightText
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  /// -- Admin Dark Theme
  static final ElevatedButtonThemeData adminDarkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: FColors.adminDarkText,
      backgroundColor: FColors.adminDarkPrimary,
      disabledForegroundColor: FColors.adminDarkError,
      disabledBackgroundColor: FColors.adminDarkError,
      side: BorderSide(color: FColors.adminDarkPrimary),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: FColors.adminDarkText
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}