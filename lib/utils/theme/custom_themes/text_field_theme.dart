import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';

/// -- Light & Dark Text Form Field Themes
class FTextFormFieldTheme {
  FTextFormFieldTheme._();  // To avoid creating instances

  /// -- Light Theme
  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,
    // constraints: const BoxConstraints.expand(height: 14.inputFieldHeight),
    labelStyle: const TextStyle().copyWith(fontSize: 14, color: Colors.black),
    hintStyle: const TextStyle().copyWith(fontSize: 14, color: Colors.black),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: const TextStyle().copyWith(color: Colors.black.withOpacity(0.8)),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: Colors.grey),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: Colors.grey),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: Colors.black12),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: Colors.red),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 2, color: Colors.orange),
    ),
  );

  /// -- Dark Theme
  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,
    // constraints: const BoxConstraints.expand(height: 14.inputFieldHeight),
    labelStyle: const TextStyle().copyWith(fontSize: 14, color: Colors.white),
    hintStyle: const TextStyle().copyWith(fontSize: 14, color: Colors.white),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: const TextStyle().copyWith(color: Colors.white.withOpacity(0.8)),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: Colors.grey),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: Colors.grey),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: Colors.white),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: Colors.red),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 2, color: Colors.orange),
    ),
  );

  /// -- Admin Light Theme
  static InputDecorationTheme adminLightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: FColors.adminLightSurface.withOpacity(0.6),
    suffixIconColor: FColors.adminLightSurface.withOpacity(0.6),
    labelStyle: TextStyle().copyWith(fontSize: 14, color: FColors.adminLightSurface),
    hintStyle: TextStyle().copyWith(fontSize: 14, color: FColors.adminLightSurface.withOpacity(0.6)),
    errorStyle: TextStyle().copyWith(fontStyle: FontStyle.normal, color: FColors.adminLightError),
    floatingLabelStyle: TextStyle().copyWith(color: FColors.adminLightPrimary),
    border: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 1, color: FColors.adminLightBorder),
    ),
    enabledBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 1, color: FColors.adminLightBorder),
    ),
    focusedBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 2, color: FColors.adminLightPrimary),
    ),
    errorBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 1, color: FColors.adminLightError),
    ),
    focusedErrorBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 2, color: FColors.adminLightError),
    ),
    fillColor: FColors.adminLightSurface,
    filled: true,
  );

  /// -- Admin Dark Theme
  static InputDecorationTheme adminDarkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: FColors.adminDarkSurface.withOpacity(0.6),
    suffixIconColor: FColors.adminDarkSurface.withOpacity(0.6),
    labelStyle: TextStyle().copyWith(fontSize: 14, color: FColors.adminDarkSurface),
    hintStyle: TextStyle().copyWith(fontSize: 14, color: FColors.adminDarkSurface.withOpacity(0.6)),
    errorStyle: TextStyle().copyWith(fontStyle: FontStyle.normal, color: FColors.adminDarkError),
    floatingLabelStyle: TextStyle().copyWith(color: FColors.adminDarkPrimary),
    border: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 1, color: FColors.adminDarkBorder),
    ),
    enabledBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 1, color: FColors.adminDarkBorder),
    ),
    focusedBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 2, color: FColors.adminDarkPrimary),
    ),
    errorBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 1, color: FColors.adminDarkError),
    ),
    focusedErrorBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 2, color: FColors.adminDarkError),
    ),
    fillColor: FColors.adminDarkSurface,
    filled: true,
  );
}