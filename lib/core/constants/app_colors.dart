import 'package:flutter/material.dart';

/// Bonovela palette — taken from the logo (hot pink "B", plum wordmark,
/// blush background).
class AppColors {
  static const Color primary = Color(0xFFEC2A82); // logo pink
  static const Color primaryLight = Color(0xFFFF6FAE);
  static const Color plum = Color(0xFF5C1458); // logo wordmark
  static const Color plumLight = Color(0xFF9B2F86);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F5F8);
  static const Color blush = Color(0xFFFFECF3); // header tint
  static const Color blushDeep = Color(0xFFFFD9E8);

  static const Color textPrimary = Color(0xFF1E1A22);
  static const Color textSecondary = Color(0xFF6E6A75);
  static const Color textHint = Color(0xFFA7A3AD);
  static const Color divider = Color(0xFFEFEDF1);

  static const Color tag = plumLight;
  static const Color star = Color(0xFFFF9F1C);
  static const Color gold = Color(0xFFFFB020);
  static const Color success = Color(0xFF2EB67D);
  static const Color error = Color(0xFFE5484D);

  /// Pill buttons (READ, TOP UP, Check in …).
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [primaryLight, primary],
  );

  /// Soft blush wash behind the top of the tab screens.
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [blush, background],
  );

  /// Placeholder cover palettes, used until real cover art comes from the API.
  static const List<List<Color>> coverPalettes = [
    [Color(0xFF5C1458), Color(0xFFEC2A82)],
    [Color(0xFF1F1B3A), Color(0xFF6B4FA0)],
    [Color(0xFF3B0A1E), Color(0xFFB3204D)],
    [Color(0xFF0F2A3D), Color(0xFF3D7EA6)],
    [Color(0xFF2B1A0E), Color(0xFFB0723A)],
    [Color(0xFF14261C), Color(0xFF3F8A5E)],
    [Color(0xFF2A0F2E), Color(0xFFC04FB0)],
    [Color(0xFF231F20), Color(0xFF8A7F86)],
  ];
}
