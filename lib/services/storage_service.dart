import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

class StorageService {
	static const String _itemsKey = 'plazo_items';
	static const String _guestItemsKey = 'plazo_items_guest';
	static const String _legacyNotificationLeadTimeKey = 'notification_lead_time';
	static const String _legacyNotificationsEnabledKey = 'notifications_enabled';
	static const String _legacyLastLoginKey = 'lastLogin';
	static const String _remoteItemsDocId = 'items';
	static const String _languageKey = 'plazo_language';
	static const String _darkModeKey = 'plazo_dark_mode';
	static const String _privacyConsentKey = 'plazo_privacy_consent_v1';
	static const String _privacyConsentAtKey = 'plazo_privacy_consent_at';
	static const String _privacyConsentVersionKey = 'plazo_privacy_consent_version';
	static const String _sessionIdKey = 'plazo_session_id';
	static String _avatarBytesKey(String uid) => 'plazo_avatar_bytes_$uid';
	static String _languageKeyForUid(String uid) {
		if (uid.isEmpty) return _languageKey;
		return 'plazo_language_$uid';
	}

	static String _darkModeKeyForUid(String uid) {
		if (uid.isEmpty) return _darkModeKey;
		return 'plazo_dark_mode_$uid';
	}

	static String _privacyConsentKeyForUid(String uid) {
		if (uid.isEmpty) return _privacyConsentKey;
		return 'plazo_privacy_consent_v1_$uid';
	}

	static String _privacyConsentAtKeyForUid(String uid) {
		if (uid.isEmpty) return _privacyConsentAtKey;
		return 'plazo_privacy_consent_at_$uid';
	}

	static String _privacyConsentVersionKeyForUid(String uid) {
		if (uid.isEmpty) return _privacyConsentVersionKey;
		return 'plazo_privacy_consent_version_$uid';
	}
	static String _notificationLeadTimeKeyForUid(String uid) {
		if (uid.isEmpty) return _legacyNotificationLeadTimeKey;
		return 'notification_lead_time_$uid';
	}

	static String _notificationsEnabledKeyForUid(String uid) {
		if (uid.isEmpty) return _legacyNotificationsEnabledKey;
		return 'notifications_enabled_$uid';
	}

	static String _lastLoginKeyForUid(String uid) {
		if (uid.isEmpty) return _legacyLastLoginKey;
		return 'lastLogin_$uid';
	}
	static String _itemsKeyForUid(String uid) {
		if (uid.isEmpty) {
			return _guestItemsKey;
		}
		return 'plazo_items_$uid';
	}

	static Future<T> _readWithFallback<T>(
		Future<T> Function(SharedPreferences prefs) reader,
		T fallback,
	) async {
		try {
			final prefs = await SharedPreferences.getInstance();
			return await reader(prefs);
		} catch (_) {
			return fallback;
		}
	}

	static Future<void> _writeIgnoringFailure(
		Future<void> Function(SharedPreferences prefs) writer,
	) async {
		try {
			final prefs = await SharedPreferences.getInstance();
			await writer(prefs);
		} catch (_) {
			// Ignore persistence failures in UI flow.
		}
	}

	static FirebaseFirestore? get _firestoreOrNull {
		if (Firebase.apps.isEmpty) {
			return null;
		}
		return FirebaseFirestore.instance;
	}

	static Map<String, dynamic> _itemToMap(PlazoItem item) {
		return {
			'id': item.id,
			'type': item.type == ItemType.exam ? 'exam' : 'task',
			'title': item.title,
			'subject': item.subject,
			'date': item.date,
			'time': item.time,
			'description': item.description,
			'location': item.location,
			'isCompleted': item.isCompleted,
		};
	}

	static PlazoItem _itemFromMap(Map<String, dynamic> json) {
		return PlazoItem(
			id: json['id'] as String? ?? '',
			type: (json['type'] as String? ?? 'task') == 'exam'
					? ItemType.exam
					: ItemType.task,
			title: json['title'] as String? ?? '',
			subject: json['subject'] as String? ?? '',
			date: json['date'] as String? ?? '',
			time: json['time'] as String? ?? '',
			description: json['description'] as String? ?? '',
			location: json['location'] as String?,
			isCompleted: json['isCompleted'] as bool? ?? false,
		);
	}

	static Future<List<PlazoItem>> _loadLocalItems({required String uid}) async {
		final itemsKey = _itemsKeyForUid(uid);
		return _readWithFallback((prefs) async {
			final rawItems = prefs.getStringList(itemsKey) ?? [];
			return rawItems
					.map((entry) => jsonDecode(entry) as Map<String, dynamic>)
					.map(_itemFromMap)
					.toList();
		}, <PlazoItem>[]);
	}

	static Future<void> _saveLocalItems({
		required String uid,
		required List<PlazoItem> items,
	}) async {
		final itemsKey = _itemsKeyForUid(uid);
		await _writeIgnoringFailure((prefs) async {
			final serialized = items.map((item) => jsonEncode(_itemToMap(item))).toList();
			await prefs.setStringList(itemsKey, serialized);

			// Remove legacy shared cache to prevent cross-account data mixing.
			if (uid.isNotEmpty && prefs.containsKey(_itemsKey)) {
				await prefs.remove(_itemsKey);
			}
		});
	}

	static Future<List<PlazoItem>> _loadRemoteItems({required String uid}) async {
		final firestore = _firestoreOrNull;
		if (firestore == null || uid.isEmpty) {
			return <PlazoItem>[];
		}

		final snapshot = await firestore.collection('users').doc(uid).collection('app_data').doc(_remoteItemsDocId).get();
		final data = snapshot.data();
		final rawItems = (data?['items'] as List<dynamic>?) ?? const <dynamic>[];

		return rawItems
				.whereType<Map>()
				.map((entry) => Map<String, dynamic>.from(entry))
				.map(_itemFromMap)
				.toList();
	}

	static Future<void> _saveRemoteItems({required String uid, required List<PlazoItem> items}) async {
		final firestore = _firestoreOrNull;
		if (firestore == null || uid.isEmpty) {
			return;
		}

		await firestore.collection('users').doc(uid).collection('app_data').doc(_remoteItemsDocId).set({
			'items': items.map(_itemToMap).toList(),
			'updatedAt': FieldValue.serverTimestamp(),
		}, SetOptions(merge: true));
	}

	static Future<List<PlazoItem>> loadItems({String uid = ''}) async {
		final localItems = await _loadLocalItems(uid: uid);

		if (uid.isEmpty) {
			return localItems;
		}

		try {
			final remoteItems = await _loadRemoteItems(uid: uid);
			if (remoteItems.isNotEmpty || localItems.isNotEmpty) {
				final mergedById = <String, PlazoItem>{};

				for (final item in localItems) {
					mergedById[item.id] = item;
				}

				for (final item in remoteItems) {
					mergedById[item.id] = item;
				}

				final mergedItems = mergedById.values.toList();
				await _saveLocalItems(uid: uid, items: mergedItems);
				await _saveRemoteItems(uid: uid, items: mergedItems);

				return mergedItems;
			}
		} catch (_) {
			debugPrint('StorageService.loadItems: falling back to local cache due to remote error.');
		}

		return localItems;
	}

	static Future<void> saveItems({String uid = '', required List<PlazoItem> items}) async {
		await _saveLocalItems(uid: uid, items: items);

		try {
			await _saveRemoteItems(uid: uid, items: items);
		} catch (_) {
			debugPrint('StorageService.saveItems: remote save failed, local cache kept.');
		}
	}

	static Future<String> loadLanguage() async => loadLanguageForUid(uid: '');

	static Future<String> loadLanguageForUid({required String uid}) async {
		return _readWithFallback((prefs) async {
			final scoped = prefs.getString(_languageKeyForUid(uid));
			if (scoped != null && scoped.isNotEmpty) {
				return scoped;
			}

			return 'en';
		}, 'en');
	}

	static Future<void> saveLanguage(String language) async =>
		saveLanguageForUid(uid: '', language: language);

	static Future<void> saveLanguageForUid({
		required String uid,
		required String language,
	}) async {
		await _writeIgnoringFailure((prefs) async {
			await prefs.setString(_languageKeyForUid(uid), language);
		});
	}

	static Future<bool> loadDarkMode() async => loadDarkModeForUid(uid: '');

	static Future<bool> loadDarkModeForUid({required String uid}) async {
		return _readWithFallback((prefs) async {
			final scoped = prefs.getBool(_darkModeKeyForUid(uid));
			if (scoped != null) {
				return scoped;
			}

			return false;
		}, false);
	}

	static Future<void> saveDarkMode(bool value) async =>
		saveDarkModeForUid(uid: '', value: value);

	static Future<void> saveDarkModeForUid({
		required String uid,
		required bool value,
	}) async {
		await _writeIgnoringFailure((prefs) async {
			await prefs.setBool(_darkModeKeyForUid(uid), value);
		});
	}

	static Future<bool> loadPrivacyConsent() async {
		return _readWithFallback((prefs) async {
			return prefs.getBool(_privacyConsentKey) ?? false;
		}, false);
	}

	static Future<void> savePrivacyConsent(bool value) async {
		await _writeIgnoringFailure((prefs) async {
			await prefs.setBool(_privacyConsentKey, value);
		});
	}

	static Future<void> savePrivacyConsentRecord({
		required bool accepted,
		required String policyVersion,
		DateTime? acceptedAt,
	}) async =>
		savePrivacyConsentRecordForUid(
			uid: '',
			accepted: accepted,
			policyVersion: policyVersion,
			acceptedAt: acceptedAt,
		);

	static Future<void> savePrivacyConsentRecordForUid({
		required String uid,
		required bool accepted,
		required String policyVersion,
		DateTime? acceptedAt,
	}) async {
		await _writeIgnoringFailure((prefs) async {
			await prefs.setBool(_privacyConsentKeyForUid(uid), accepted);
			if (accepted) {
				final timestamp = (acceptedAt ?? DateTime.now()).toIso8601String();
				await prefs.setString(_privacyConsentAtKeyForUid(uid), timestamp);
				await prefs.setString(_privacyConsentVersionKeyForUid(uid), policyVersion);
			} else {
				await prefs.remove(_privacyConsentAtKeyForUid(uid));
				await prefs.remove(_privacyConsentVersionKeyForUid(uid));
			}
		});
	}

	static Future<String?> loadPrivacyConsentAcceptedAt() async {
		return _readWithFallback((prefs) async {
			return prefs.getString(_privacyConsentAtKey);
		}, null);
	}

	static Future<String?> loadPrivacyConsentVersion() async {
		return _readWithFallback((prefs) async {
			return prefs.getString(_privacyConsentVersionKey);
		}, null);
	}

	static Future<bool> hasAcceptedCurrentPrivacyPolicy({
		required String policyVersion,
	}) async => hasAcceptedCurrentPrivacyPolicyForUid(
		uid: '',
		policyVersion: policyVersion,
	);

	static Future<bool> hasAcceptedCurrentPrivacyPolicyForUid({
		required String uid,
		required String policyVersion,
	}) async {
		return _readWithFallback((prefs) async {
			final accepted = (prefs.getBool(_privacyConsentKeyForUid(uid)) ?? false);
			if (!accepted) {
				return false;
			}

			final acceptedVersion = prefs.getString(_privacyConsentVersionKeyForUid(uid));
			return acceptedVersion == policyVersion;
		}, false);
	}

	// Generic string storage methods for app state
	static Future<String?> getString(String key) async {
		return _readWithFallback((prefs) async {
			return prefs.getString(key);
		}, null);
	}

	static Future<void> setString(String key, String value) async {
		await _writeIgnoringFailure((prefs) async {
			await prefs.setString(key, value);
		});
	}

	static Future<String?> loadNotificationLeadTime({required String uid}) async {
		return _readWithFallback((prefs) async {
			final scopedKey = _notificationLeadTimeKeyForUid(uid);
			final scoped = prefs.getString(scopedKey);
			if (scoped != null) return scoped;

			return null;
		}, null);
	}

	static Future<void> saveNotificationLeadTime({
		required String uid,
		required String leadTime,
	}) async {
		await _writeIgnoringFailure((prefs) async {
			await prefs.setString(_notificationLeadTimeKeyForUid(uid), leadTime);
		});
	}

	static Future<bool> loadNotificationsEnabled({required String uid}) async {
		return _readWithFallback((prefs) async {
			final scopedKey = _notificationsEnabledKeyForUid(uid);
			final scoped = prefs.getString(scopedKey);
			if (scoped != null) return scoped == 'true';

			return false;
		}, false);
	}

	static Future<void> saveNotificationsEnabled({
		required String uid,
		required bool enabled,
	}) async {
		await _writeIgnoringFailure((prefs) async {
			await prefs.setString(
				_notificationsEnabledKeyForUid(uid),
				enabled.toString(),
			);
		});
	}

	static Future<void> saveLastLoginAt({
		required String uid,
		DateTime? at,
	}) async {
		await _writeIgnoringFailure((prefs) async {
			await prefs.setString(
				_lastLoginKeyForUid(uid),
				(at ?? DateTime.now()).toIso8601String(),
			);
		});
	}

	static Future<DateTime?> loadLastLoginAt({required String uid}) async {
		return _readWithFallback((prefs) async {
			final scoped = prefs.getString(_lastLoginKeyForUid(uid));
			if (scoped != null && scoped.isNotEmpty) {
				return DateTime.tryParse(scoped);
			}

			return null;
		}, null);
	}

	static Future<String> getOrCreateSessionId() async {
		final existing = await getString(_sessionIdKey);
		if (existing != null && existing.isNotEmpty) {
			return existing;
		}

		final random = Random();
		final sessionId = 'session_${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(1 << 32)}';
		await setString(_sessionIdKey, sessionId);
		return sessionId;
	}

	static Future<String?> getSessionId() async {
		return getString(_sessionIdKey);
	}

	static Future<void> saveAvatarBytes({
		required String uid,
		required List<int> bytes,
	}) async {
		if (uid.isEmpty || bytes.isEmpty) return;
		await setString(_avatarBytesKey(uid), base64Encode(bytes));
	}

	static Future<Uint8List?> loadAvatarBytes({required String uid}) async {
		if (uid.isEmpty) return null;
		final encoded = await getString(_avatarBytesKey(uid));
		if (encoded == null || encoded.isEmpty) return null;
		try {
			return Uint8List.fromList(base64Decode(encoded));
		} catch (_) {
			return null;
		}
	}
}
