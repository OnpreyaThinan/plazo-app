import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'storage_service.dart';

class AuthService {
  GoogleSignIn? get _googleSignInOrNull => kIsWeb ? null : GoogleSignIn();

  FirebaseAuth? get _authOrNull {
    if (Firebase.apps.isEmpty) {
      return null;
    }
    return FirebaseAuth.instance;
  }

  // Save last login timestamp
  Future<void> _saveLastLogin() async {
    try {
      await StorageService.setString('lastLogin', DateTime.now().toIso8601String());
    } catch (_) {
      // Ignore failures
    }
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
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user display name
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

      // Save last login timestamp
      await _saveLastLogin();

      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final auth = _authOrNull;
    if (auth == null) return null;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save last login timestamp
      await _saveLastLogin();
      
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({
    required String email,
    String? languageCode,
  }) async {
    final auth = _authOrNull;
    if (auth == null) return;
    try {
      if (languageCode != null && languageCode.isNotEmpty) {
        await auth.setLanguageCode(languageCode);
      }

      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException {
      rethrow;
    }
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

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      await user.reload();
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    final auth = _authOrNull;
    if (auth == null) return;
    final googleSignIn = _googleSignInOrNull;
    try {
      await auth.signOut();
      if (googleSignIn != null) {
        await googleSignIn.signOut();
        // Revoke previous Google session so the next login can choose account again.
        await googleSignIn.disconnect();
      }
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
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        final userCredential = await auth.signInWithPopup(googleProvider);
        await userCredential.user?.reload();
        // Save last login timestamp
        await _saveLastLogin();
        return auth.currentUser;
      }

      final googleSignIn = _googleSignInOrNull;
      if (googleSignIn == null) return null;

      // Clear previous account session so user can choose a different Google account.
      try {
        await googleSignIn.signOut();
        await googleSignIn.disconnect();
      } catch (_) {
        // Ignore if there is no existing Google session.
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        if ((userCredential.user!.photoURL == null || userCredential.user!.photoURL!.isEmpty) &&
            googleUser.photoUrl != null &&
            googleUser.photoUrl!.isNotEmpty) {
          await userCredential.user!.updatePhotoURL(googleUser.photoUrl);
        }

        if ((userCredential.user!.displayName == null || userCredential.user!.displayName!.isEmpty) &&
            googleUser.displayName != null &&
            googleUser.displayName!.isNotEmpty) {
          await userCredential.user!.updateDisplayName(googleUser.displayName);
        }
      }

      await userCredential.user?.reload();
      // Save last login timestamp
      await _saveLastLogin();
      return auth.currentUser;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    final auth = _authOrNull;
    final googleSignIn = _googleSignInOrNull;
    if (auth == null) return;
    
    try {
      // Delete user from Firebase Auth
      await auth.currentUser?.delete();
      
      // Sign out from Google
      if (googleSignIn != null) {
        try {
          await googleSignIn.signOut();
          await googleSignIn.disconnect();
        } catch (_) {
          // Ignore if there's no existing session
        }
      }
    } on FirebaseAuthException {
      rethrow;
    }
  }
}
