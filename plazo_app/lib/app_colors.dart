import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF9BD1B3);  // Mint green
  static const Color accentBlue = Color(0xFFAFD9E4);  // Soft blue
  static const Color accentPink = Color(0xFFFFB3C1);  // Soft pink
  static const Color navy = Color(0xFF5D8C7B);  // Soft green dark
  static const Color textMain = Color(0xFF2F4858);
  static const Color bgInput = Color(0xFFF0F8F0);  // Very light green
  static const Color border = Color(0xFFE8F5E9);
  static const Color glassWhite = Color(0xCCFFFFFF);
  
  // Detail/Edit Screen background
  static const Color bgDetailLight = Color(0xFFF5FBF7);  // Light mint background
  
  // Avatar
  static const Color avatarOrange = Color(0xFFFFCE9F);  // Soft orange
  
  // Dark mode
  static const Color darkBg = Color(0xFF1A1A1A);
  
  // Helper method for theme-aware colors
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : textMain;
  }
  
  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[400]!
        : Colors.grey;
  }
  
  static Color getCardBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]!
        : Colors.white;
  }
  
  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[200]!;
  }
  
  static Color getInputBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[850]!
        : bgInput;
  }
}

