import 'package:flutter/material.dart';

/// -- Light & Dark Chip Themes
class FChipTheme {
  FChipTheme._();  // To avoid creating instances

  /// -- Light Theme
  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: Colors.grey.withOpacity(0.4),
    labelStyle: const TextStyle(color: Colors.black),
    selectedColor: Colors.green,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    checkmarkColor: Colors.white,
  );

  /// -- Dark Theme
  static ChipThemeData darkChipTheme = const ChipThemeData(
    disabledColor: Colors.grey,
    labelStyle: TextStyle(color: Colors.white),
    selectedColor: Colors.green,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    checkmarkColor: Colors.white,
  );

  /// -- Admin Light Theme
  static ChipThemeData adminLightChipTheme = ChipThemeData(
    disabledColor: Colors.grey.withOpacity(0.3),
    labelStyle: const TextStyle(color: Colors.black87),
    selectedColor: Colors.indigo,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
    checkmarkColor: Colors.white,
    backgroundColor: Colors.grey[200],
  );

  /// -- Admin Dark Theme
  static const ChipThemeData adminDarkChipTheme = ChipThemeData(
    disabledColor: Colors.grey,
    labelStyle: TextStyle(color: Colors.white70),
    selectedColor: Color(0xFF6C72FF),
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
    checkmarkColor: Colors.white,
    backgroundColor: Color(0xFF37446B), // secondary background
  );
}