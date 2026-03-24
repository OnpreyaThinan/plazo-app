import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of user changes, including profile updates like photoURL.
  Stream<User?> get authStateChanges => _auth.userChanges();

  // Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user display name
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

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
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      // Revoke previous Google session so the next login can choose account again.
      await _googleSignIn.disconnect();
    } on FirebaseAuthException {
      rethrow;
    } catch (_) {
      // Ignore provider-specific sign-out issues to avoid blocking app logout.
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        final userCredential = await _auth.signInWithPopup(googleProvider);
        await userCredential.user?.reload();
        return _auth.currentUser;
      }

      // Clear previous account session so user can choose a different Google account.
      try {
        await _googleSignIn.signOut();
        await _googleSignIn.disconnect();
      } catch (_) {
        // Ignore if there is no existing Google session.
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

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
      return _auth.currentUser;
    } on FirebaseAuthException {
      rethrow;
    }
  }
}
