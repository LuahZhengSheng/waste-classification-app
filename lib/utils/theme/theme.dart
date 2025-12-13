import 'package:flutter/material.dart';
import 'package:fyp/utils/theme/custom_themes/appbar_theme.dart';
import 'package:fyp/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:fyp/utils/theme/custom_themes/checkbox_theme.dart';
import 'package:fyp/utils/theme/custom_themes/chip_theme.dart';
import 'package:fyp/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:fyp/utils/theme/custom_themes/outlined_button_theme.dart';
import 'package:fyp/utils/theme/custom_themes/text_field_theme.dart';
import 'package:fyp/utils/theme/custom_themes/text_theme.dart';

import '../constants/colors.dart';

/// -- Light & Dark App Themes
class FAppTheme {
  FAppTheme._();

  /// -- Light Theme
  static ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      brightness: Brightness.light,
      primaryColor: FColors.primary,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: FAppBarTheme.lightAppBarTheme,
      textTheme: FTextTheme.lightTextTheme,
      chipTheme: FChipTheme.lightChipTheme,
      checkboxTheme: FCheckboxTheme.lightCheckboxTheme,
      bottomSheetTheme: FBottomSheetTheme.lightBottomSheetTheme,
      inputDecorationTheme: FTextFormFieldTheme.lightInputDecorationTheme,
      elevatedButtonTheme: FElevatedButtonTheme.lightElevatedButtonTheme,
      outlinedButtonTheme: FOutlinedButtonTheme.lightOutlinedButtonTheme
  );

  /// -- Dark Theme
  static ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      brightness: Brightness.dark,
      primaryColor: FColors.primary,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: FAppBarTheme.darkAppBarTheme,
      textTheme: FTextTheme.darkTextTheme,
      chipTheme: FChipTheme.darkChipTheme,
      checkboxTheme: FCheckboxTheme.darkCheckboxTheme,
      bottomSheetTheme: FBottomSheetTheme.darkBottomSheetTheme,
      inputDecorationTheme: FTextFormFieldTheme.darkInputDecorationTheme,
      elevatedButtonTheme: FElevatedButtonTheme.darkElevatedButtonTheme,
      outlinedButtonTheme: FOutlinedButtonTheme.darkOutlinedButtonTheme
  );

  /// -- Admin Light Theme
  static ThemeData adminLightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: Colors.indigo,
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: FAppBarTheme.adminLightAppBarTheme,
    textTheme: FTextTheme.lightTextTheme,
    chipTheme: FChipTheme.adminLightChipTheme,
    checkboxTheme: FCheckboxTheme.adminLightCheckboxTheme,
    bottomSheetTheme: FBottomSheetTheme.lightBottomSheetTheme,
    inputDecorationTheme: FTextFormFieldTheme.lightInputDecorationTheme,
    elevatedButtonTheme: FElevatedButtonTheme.adminLightElevatedButtonTheme,
    outlinedButtonTheme: FOutlinedButtonTheme.adminLightOutlinedButtonTheme,
  );

  /// -- Admin Dark Theme
  static ThemeData adminDarkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: Color(0xFF6C72FF),
    scaffoldBackgroundColor: Color(0xFF101935),
    appBarTheme: FAppBarTheme.adminDarkAppBarTheme,
    textTheme: FTextTheme.darkTextTheme,
    chipTheme: FChipTheme.adminDarkChipTheme,
    checkboxTheme: FCheckboxTheme.adminDarkCheckboxTheme,
    bottomSheetTheme: FBottomSheetTheme.darkBottomSheetTheme,
    inputDecorationTheme: FTextFormFieldTheme.adminDarkInputDecorationTheme,
    elevatedButtonTheme: FElevatedButtonTheme.adminDarkElevatedButtonTheme,
    outlinedButtonTheme: FOutlinedButtonTheme.adminDarkOutlinedButtonTheme,
  );
}
