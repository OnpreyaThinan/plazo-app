import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'app_colors.dart';
import 'models.dart';
import 'navigation_wrapper.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PlazoApp());
}

class PlazoApp extends StatefulWidget {
  const PlazoApp({super.key});

  @override
  State<PlazoApp> createState() => _PlazoAppState();
}

class _PlazoAppState extends State<PlazoApp> {
  final _authService = AuthService();
  String _language = 'en';
  bool _darkMode = false;

  void _changeLanguage(String language) {
    setState(() => _language = language);
  }

  void _toggleDarkMode(bool value) {
    setState(() => _darkMode = value);
  }

  UserProfile _createUserProfile(User firebaseUser) {
    final providerPhotoUrl = firebaseUser.providerData
        .map((p) => p.photoURL)
        .whereType<String>()
        .cast<String?>()
        .firstWhere((url) => url != null && url.isNotEmpty, orElse: () => null);

    final rawAvatarUrl = firebaseUser.photoURL ??
        providerPhotoUrl ??
        "https://api.dicebear.com/7.x/avataaars/svg?seed=${firebaseUser.displayName ?? firebaseUser.email}";

    String avatarUrl = rawAvatarUrl;
    if (rawAvatarUrl.startsWith('http')) {
      final uri = Uri.parse(rawAvatarUrl);
      avatarUrl = uri
          .replace(
            queryParameters: {
              ...uri.queryParameters,
              'v': firebaseUser.uid,
            },
          )
          .toString();
    }

    return UserProfile(
      name: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
      email: firebaseUser.email ?? '',
      avatarUrl: avatarUrl,
    );
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
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850],
          hintStyle: const TextStyle(color: Colors.grey),
          labelStyle: const TextStyle(color: Colors.white),
        ),
      );
    }
    return baseTheme.copyWith(
      appBarTheme: const AppBarTheme(elevation: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plazo',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(false),
      darkTheme: _buildTheme(true),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder<User?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          }

          User? firebaseUser = snapshot.data;

          if (firebaseUser != null) {
            // User is logged in
            UserProfile currentUser = _createUserProfile(firebaseUser);
            return MainNavigation(
              key: ValueKey(firebaseUser.uid),
              user: currentUser,
              language: _language,
              onLanguageChange: _changeLanguage,
              darkMode: _darkMode,
              onDarkModeChange: _toggleDarkMode,
              onLogout: () async {
                await _authService.signOut();
              },
            );
          } else {
            // User is not logged in
            return LoginScreen(
              onLogin: (name, email) {
                // This is called after successful login
                // The StreamBuilder will rebuild when Firebase auth state changes
              },
            );
          }
        },
      ),
    );
  }
}