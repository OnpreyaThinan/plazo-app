import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'storage_service.dart';

class UserSession {
  final String sessionId;
  final String deviceName;
  final String platform;
  final bool isActive;
  final DateTime? lastSeenAt;
  final DateTime? lastSignInAt;

  const UserSession({
    required this.sessionId,
    required this.deviceName,
    required this.platform,
    required this.isActive,
    required this.lastSeenAt,
    required this.lastSignInAt,
  });

  factory UserSession.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final lastSeenTs = data['lastSeenAt'] as Timestamp?;
    final lastSignInTs = data['lastSignInAt'] as Timestamp?;

    return UserSession(
      sessionId: (data['sessionId'] as String?) ?? doc.id,
      deviceName: (data['deviceName'] as String?) ?? 'Unknown Device',
      platform: (data['platform'] as String?) ?? 'Unknown',
      isActive: (data['isActive'] as bool?) ?? false,
      lastSeenAt: lastSeenTs?.toDate(),
      lastSignInAt: lastSignInTs?.toDate(),
    );
  }
}

class SecurityService {
  FirebaseFirestore? get _firestoreOrNull {
    if (Firebase.apps.isEmpty) {
      return null;
    }
    return FirebaseFirestore.instance;
  }

  String _platformLabel() {
    if (kIsWeb) return 'Web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.fuchsia:
        return 'Fuchsia';
    }
  }

  String _deviceNameLabel() {
    final platform = _platformLabel();
    return '$platform Device';
  }

  Future<void> upsertCurrentSession({required String uid}) async {
    final firestore = _firestoreOrNull;
    if (firestore == null || uid.isEmpty) return;

    final sessionId = await StorageService.getOrCreateSessionId();
    final now = Timestamp.now();

    await firestore
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .doc(sessionId)
        .set({
      'sessionId': sessionId,
      'isActive': true,
      'deviceName': _deviceNameLabel(),
      'platform': _platformLabel(),
      'lastSeenAt': now,
      'lastSignInAt': now,
    }, SetOptions(merge: true));
  }

  Future<void> markCurrentSessionInactive({required String uid}) async {
    final firestore = _firestoreOrNull;
    if (firestore == null || uid.isEmpty) return;

    final sessionId = await StorageService.getSessionId();
    if (sessionId == null || sessionId.isEmpty) return;

    await firestore
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .doc(sessionId)
        .set({
      'sessionId': sessionId,
      'isActive': false,
      'lastSeenAt': Timestamp.now(),
      'signedOutAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Stream<List<UserSession>> watchSessions({required String uid}) {
    final firestore = _firestoreOrNull;
    if (firestore == null || uid.isEmpty) {
      return Stream.value(const <UserSession>[]);
    }

    return firestore
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .orderBy('lastSeenAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(UserSession.fromDoc).toList());
  }

  Future<DateTime?> loadLastLogin({required String uid}) async {
    final firestore = _firestoreOrNull;
    if (firestore == null || uid.isEmpty) return null;

    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .orderBy('lastSignInAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data();
    final timestamp = data['lastSignInAt'] as Timestamp?;
    return timestamp?.toDate();
  }
}
