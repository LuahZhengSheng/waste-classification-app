import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';

class FCardTheme {
  FCardTheme._();

  /// -- Admin Light Theme
  static CardTheme adminLightCardTheme = CardTheme(
    color: FColors.adminLightAccent,
    shadowColor: FColors.adminLightBorder,
    surfaceTintColor: FColors.adminLightSurface,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: FColors.adminLightBorder, width: 1),
    ),
    margin: const EdgeInsets.all(8),
  );

  /// -- Admin Dark Theme
  static CardTheme adminDarkCardTheme = CardTheme(
    color: FColors.adminDarkAccent,
    shadowColor: FColors.adminDarkBorder,
    surfaceTintColor: FColors.adminDarkSurface,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: FColors.adminDarkBorder, width: 1),
    ),
    margin: const EdgeInsets.all(8),
  );
}