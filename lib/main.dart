import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_strings.dart';
import 'models.dart';
import 'navigation_wrapper.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const PlazoApp());
}

class PlazoApp extends StatefulWidget {
  const PlazoApp({super.key});

  @override
  State<PlazoApp> createState() => _PlazoAppState();
}

class _PlazoAppState extends State<PlazoApp> {
  UserProfile? _currentUser;
  String _language = 'en';
  bool _darkMode = false;

  void _changeLanguage(String language) {
    setState(() => _language = language);
  }

  void _toggleDarkMode(bool value) {
    setState(() => _darkMode = value);
  }

  ThemeData _buildTheme(bool isDark) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : Colors.white,
    );

    if (isDark) {
      return baseTheme.copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkBg,
          elevation: 0,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      );
    }
    return baseTheme;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plazo',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(false),
      darkTheme: _buildTheme(true),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: _currentUser == null
          ? LoginScreen(
              onLogin: (name, email) => setState(() {
                _currentUser = UserProfile(
                  name: name,
                  email: email,
                  avatarUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=$name",
                );
              }),
            )
          : MainNavigation(
              user: _currentUser!,
              language: _language,
              onLanguageChange: _changeLanguage,
              darkMode: _darkMode,
              onDarkModeChange: _toggleDarkMode,
              onLogout: () => setState(() => _currentUser = null),
            ),
    );
  }
}
