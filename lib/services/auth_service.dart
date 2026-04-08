import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'security_service.dart';
import 'storage_service.dart';

class AuthService {
  static const Duration _requestTimeout = Duration(seconds: 15);
  static const int _maxRetryAttempts = 2;
  final _securityService = SecurityService();

  GoogleSignIn? get _googleSignInOrNull => kIsWeb ? null : GoogleSignIn();

  FirebaseAuth? get _authOrNull {
    if (Firebase.apps.isEmpty) {
      return null;
    }
    return FirebaseAuth.instance;
  }

  bool _isRetryableFirebaseError(FirebaseAuthException e) {
    return e.code == 'network-request-failed' ||
        e.code == 'too-many-requests' ||
        e.code == 'internal-error';
  }

  FirebaseAuthException _toUiSafeAuthException(Object error) {
    if (error is FirebaseAuthException) {
      return error;
    }

    if (error is TimeoutException) {
      return FirebaseAuthException(
        code: 'timeout',
        message: 'Request timed out. Please try again.',
      );
    }

    return _defaultFailure();
  }

  FirebaseAuthException _defaultFailure() {
    return FirebaseAuthException(
      code: 'operation-failed',
      message: 'Unable to complete the request. Please try again.',
    );
  }

  Future<T> _runWithRetry<T>(Future<T> Function() operation) async {
    FirebaseAuthException? lastError;

    for (var attempt = 0; attempt <= _maxRetryAttempts; attempt++) {
      try {
        return await operation().timeout(_requestTimeout);
      } on TimeoutException catch (e) {
        lastError = _toUiSafeAuthException(e);
      } on FirebaseAuthException catch (e) {
        if (!_isRetryableFirebaseError(e)) {
          throw _toUiSafeAuthException(e);
        }
        lastError = _toUiSafeAuthException(e);
      } catch (e) {
        throw _toUiSafeAuthException(e);
      }

      if (attempt == _maxRetryAttempts) {
        break;
      }
    }

    throw lastError ?? _defaultFailure();
  }

  // Save last login timestamp
  Future<void> _saveLastLogin() async {
    try {
      await StorageService.setString('lastLogin', DateTime.now().toIso8601String());
    } catch (_) {
      // Ignore failures
    }
  }

  Future<void> _syncCurrentSessionSafely(User? user) async {
    if (user == null) return;
    try {
      await _securityService.upsertCurrentSession(uid: user.uid);
    } catch (_) {
      // Ignore session sync failures to keep sign-in flow resilient.
    }
  }

  Future<void> _markCurrentSessionInactiveSafely(User? user) async {
    if (user == null) return;
    try {
      await _securityService.markCurrentSessionInactive(uid: user.uid);
    } catch (_) {
      // Ignore session sync failures to keep sign-out flow resilient.
    }
  }

  Future<void> _disconnectGoogleSessionSafely(GoogleSignIn? googleSignIn) async {
    if (googleSignIn == null) return;
    try {
      await googleSignIn.signOut();
      await googleSignIn.disconnect();
    } catch (_) {
      // Ignore provider-specific sign-out issues to avoid blocking app flow.
    }
  }

  Future<void> _syncGoogleProfileIfMissing({
    required User firebaseUser,
    required GoogleSignInAccount googleUser,
  }) async {
    if ((firebaseUser.photoURL == null || firebaseUser.photoURL!.isEmpty) &&
        googleUser.photoUrl != null &&
        googleUser.photoUrl!.isNotEmpty) {
      await firebaseUser.updatePhotoURL(googleUser.photoUrl);
    }

    if ((firebaseUser.displayName == null || firebaseUser.displayName!.isEmpty) &&
        googleUser.displayName != null &&
        googleUser.displayName!.isNotEmpty) {
      await firebaseUser.updateDisplayName(googleUser.displayName);
    }
  }

  Future<User?> _signInWithGoogleWeb(FirebaseAuth auth) async {
    final googleProvider = GoogleAuthProvider();
    googleProvider.setCustomParameters({'prompt': 'select_account'});
    final userCredential = await auth.signInWithPopup(googleProvider);
    await userCredential.user?.reload();
    await _saveLastLogin();
    await _syncCurrentSessionSafely(auth.currentUser);
    return auth.currentUser;
  }

  Future<User?> _signInWithGoogleMobile({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  }) async {
    // Clear previous account session so user can choose a different Google account.
    await _disconnectGoogleSessionSafely(googleSignIn);

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return null; // User cancelled
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      await _syncGoogleProfileIfMissing(
        firebaseUser: firebaseUser,
        googleUser: googleUser,
      );
    }

    await userCredential.user?.reload();
    await _saveLastLogin();
    await _syncCurrentSessionSafely(auth.currentUser);
    return auth.currentUser;
  }

  // Get current user
  User? get currentUser => _authOrNull?.currentUser;

  // Stream of user changes, including profile updates like photoURL.
  Stream<User?> get authStateChanges => _authOrNull?.userChanges() ?? Stream.value(null);

  // Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final auth = _authOrNull;
    if (auth == null) return null;

    return _runWithRetry(() async {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user display name
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

      // Save last login timestamp
      await _saveLastLogin();
      await _syncCurrentSessionSafely(userCredential.user);

      return userCredential.user;
    });
  }

  // Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final auth = _authOrNull;
    if (auth == null) return null;

    return _runWithRetry(() async {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save last login timestamp
      await _saveLastLogin();
      await _syncCurrentSessionSafely(userCredential.user);

      return userCredential.user;
    });
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({
    required String email,
    String? languageCode,
  }) async {
    final auth = _authOrNull;
    if (auth == null) return;

    await _runWithRetry(() async {
      if (languageCode != null && languageCode.isNotEmpty) {
        await auth.setLanguageCode(languageCode);
      }

      await auth.sendPasswordResetEmail(email: email.trim());
    });
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final auth = _authOrNull;
    if (auth == null) return;

    final user = auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No authenticated user found.',
      );
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'Unable to verify account email for password update.',
      );
    }

    final hasPasswordProvider = user.providerData.any((provider) => provider.providerId == 'password');
    if (!hasPasswordProvider) {
      throw FirebaseAuthException(
        code: 'no-password-provider',
        message: 'This account does not use a password sign-in method.',
      );
    }

    await _runWithRetry(() async {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      await user.reload();
    });
  }

  // Sign out
  Future<void> signOut() async {
    final auth = _authOrNull;
    if (auth == null) return;
    final googleSignIn = _googleSignInOrNull;
    final currentUser = auth.currentUser;
    try {
      await _markCurrentSessionInactiveSafely(currentUser);
      await auth.signOut();
      // Revoke previous Google session so the next login can choose account again.
      await _disconnectGoogleSessionSafely(googleSignIn);
    } on FirebaseAuthException {
      rethrow;
    } catch (_) {
      // Ignore provider-specific sign-out issues to avoid blocking app logout.
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    final auth = _authOrNull;
    if (auth == null) return null;

    return _runWithRetry(() async {
      if (kIsWeb) {
        return _signInWithGoogleWeb(auth);
      }

      final googleSignIn = _googleSignInOrNull;
      if (googleSignIn == null) return null;

      return _signInWithGoogleMobile(
        auth: auth,
        googleSignIn: googleSignIn,
      );
    });
  }

  // Delete user account
  Future<void> deleteAccount() async {
    final auth = _authOrNull;
    final googleSignIn = _googleSignInOrNull;
    if (auth == null) return;

    await _runWithRetry(() async {
      // Delete user from Firebase Auth
      await auth.currentUser?.delete();
      
      // Sign out from Google
      await _disconnectGoogleSessionSafely(googleSignIn);
    });
  }
}
