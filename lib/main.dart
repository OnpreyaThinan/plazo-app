import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'app_colors.dart';
import 'app_strings.dart';
import 'content/privacy_policy_content.dart';
import 'models.dart';
import 'navigation_wrapper.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'widgets/privacy_policy_dialog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  if (!(const bool.fromEnvironment('flutter.test'))) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
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
  bool _privacyConsentAccepted = false;
  bool _privacyNoticeShown = false;
  bool _isReady = false;
  int _mainNavigationIndex = 0;

  String _t(String key) => AppStrings.get(key, _language);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final language = await StorageService.loadLanguage();
    final darkMode = await StorageService.loadDarkMode();
    final privacyConsentAccepted = await StorageService.loadPrivacyConsent();
    if (!mounted) return;
    setState(() {
      _language = language;
      _darkMode = darkMode;
      _privacyConsentAccepted = privacyConsentAccepted;
      _isReady = true;
    });
  }

  Future<void> _acceptPrivacyConsent() async {
    await StorageService.savePrivacyConsentRecord(
      accepted: true,
      policyVersion: PrivacyPolicyContent.currentVersion,
    );
    if (!mounted) return;
    setState(() => _privacyConsentAccepted = true);
  }

  Future<void> _showPrivacyNoticeDialog(BuildContext context) async {
    final isThai = _language == 'th';

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(isThai ? 'ประกาศความเป็นส่วนตัว' : 'Privacy Notice'),
        content: Text(
          isThai
              ? 'Plazo ใช้ข้อมูลที่จำเป็นต่อการให้บริการ เช่น บัญชีผู้ใช้และข้อมูลที่คุณบันทึกไว้ในแอป คุณสามารถดูนโยบายความเป็นส่วนตัวและจัดการข้อมูลได้จากหน้า Settings\n\nหากไม่ยอมรับ คุณจะยังไม่สามารถใช้งานแอปต่อได้'
              : 'Plazo uses data required to provide core features, such as your account and items you save in the app. You can review the privacy policy and manage your data from Settings.\n\nIf you decline, app usage remains blocked until consent is accepted.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              showAppPrivacyPolicyDialog(
                context: dialogContext,
                language: _language,
              );
            },
            child: Text(_t('viewPrivacyPolicy')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(isThai ? 'ไม่ยอมรับ' : 'Decline'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(isThai ? 'ยอมรับ' : 'Accept'),
          ),
        ],
      ),
    );

    if (accepted == true) {
      await _acceptPrivacyConsent();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isThai
                ? 'จำเป็นต้องยอมรับนโยบายความเป็นส่วนตัวก่อนใช้งานแอป'
                : 'You need to accept the privacy notice before using the app.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _privacyNoticeShown = false;
      });
    }
  }

  void _changeLanguage(String language) {
    setState(() => _language = language);
    StorageService.saveLanguage(language);
  }

  void _toggleDarkMode(bool value) {
    setState(() => _darkMode = value);
    StorageService.saveDarkMode(value);
  }

  void _handleMainNavigationIndexChanged(int index) {
    if (_mainNavigationIndex == index) {
      return;
    }
    setState(() => _mainNavigationIndex = index);
  }

  UserProfile _createUserProfile(User firebaseUser) {
    final providerPhotoUrl = firebaseUser.providerData
        .map((p) => p.photoURL)
        .whereType<String>()
        .cast<String?>()
        .firstWhere((url) => url != null && url.isNotEmpty, orElse: () => null);

    final rawAvatarUrl = firebaseUser.photoURL ??
        providerPhotoUrl ??
      "https://api.dicebear.com/7.x/avataaars/svg?seed=${firebaseUser.uid}";

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
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.grey[900],
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
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
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(elevation: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Plazo',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(false),
      darkTheme: _buildTheme(true),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(_language),
      home: StreamBuilder<User?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (!_privacyConsentAccepted && !_privacyNoticeShown) {
            _privacyNoticeShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _showPrivacyNoticeDialog(context);
            });
          }

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
              initialIndex: _mainNavigationIndex,
              onIndexChanged: _handleMainNavigationIndexChanged,
              onLogout: () async {
                await _authService.signOut();
              },
            );
          } else {
            // User is not logged in
            return LoginScreen(
              language: _language,
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
