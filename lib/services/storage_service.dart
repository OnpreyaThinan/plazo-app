import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

class StorageService {
	static const String _itemsKey = 'plazo_items';
	static const String _remoteItemsDocId = 'items';
	static const String _languageKey = 'plazo_language';
	static const String _darkModeKey = 'plazo_dark_mode';
	static const String _privacyConsentKey = 'plazo_privacy_consent_v1';
	static const String _privacyConsentAtKey = 'plazo_privacy_consent_at';
	static const String _privacyConsentVersionKey = 'plazo_privacy_consent_version';
	static const String _sessionIdKey = 'plazo_session_id';

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

	static Future<List<PlazoItem>> _loadLocalItems() async {
		return _readWithFallback((prefs) async {
			final rawItems = prefs.getStringList(_itemsKey) ?? [];
			return rawItems
					.map((entry) => jsonDecode(entry) as Map<String, dynamic>)
					.map(_itemFromMap)
					.toList();
		}, <PlazoItem>[]);
	}

	static Future<void> _saveLocalItems(List<PlazoItem> items) async {
		await _writeIgnoringFailure((prefs) async {
			final serialized = items.map((item) => jsonEncode(_itemToMap(item))).toList();
			await prefs.setStringList(_itemsKey, serialized);
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
		final localItems = await _loadLocalItems();

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
				await _saveLocalItems(mergedItems);

				if (uid.isNotEmpty) {
					await _saveRemoteItems(uid: uid, items: mergedItems);
				}

				return mergedItems;
			}
		} catch (_) {
			debugPrint('StorageService.loadItems: falling back to local cache due to remote error.');
		}

		return localItems;
	}

	static Future<void> saveItems({String uid = '', required List<PlazoItem> items}) async {
		await _saveLocalItems(items);

		try {
			await _saveRemoteItems(uid: uid, items: items);
		} catch (_) {
			debugPrint('StorageService.saveItems: remote save failed, local cache kept.');
		}
	}

	static Future<String> loadLanguage() async {
		return _readWithFallback((prefs) async {
			return prefs.getString(_languageKey) ?? 'en';
		}, 'en');
	}

	static Future<void> saveLanguage(String language) async {
		await _writeIgnoringFailure((prefs) async {
			await prefs.setString(_languageKey, language);
		});
	}

	static Future<bool> loadDarkMode() async {
		return _readWithFallback((prefs) async {
			return prefs.getBool(_darkModeKey) ?? false;
		}, false);
	}

	static Future<void> saveDarkMode(bool value) async {
		await _writeIgnoringFailure((prefs) async {
			await prefs.setBool(_darkModeKey, value);
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
	}) async {
		await _writeIgnoringFailure((prefs) async {
			await prefs.setBool(_privacyConsentKey, accepted);
			if (accepted) {
				final timestamp = (acceptedAt ?? DateTime.now()).toIso8601String();
				await prefs.setString(_privacyConsentAtKey, timestamp);
				await prefs.setString(_privacyConsentVersionKey, policyVersion);
			} else {
				await prefs.remove(_privacyConsentAtKey);
				await prefs.remove(_privacyConsentVersionKey);
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
}
