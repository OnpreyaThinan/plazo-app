import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

class StorageService {
	static const String _itemsKey = 'plazo_items';
	static const String _languageKey = 'plazo_language';
	static const String _darkModeKey = 'plazo_dark_mode';
	static const String _privacyConsentKey = 'plazo_privacy_consent_v1';

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

	static Future<List<PlazoItem>> loadItems() async {
		return _readWithFallback((prefs) async {
			final rawItems = prefs.getStringList(_itemsKey) ?? [];
			return rawItems
					.map((entry) => jsonDecode(entry) as Map<String, dynamic>)
					.map(
						(json) => PlazoItem(
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
						),
					)
					.toList();
		}, <PlazoItem>[]);
	}

	static Future<void> saveItems(List<PlazoItem> items) async {
		await _writeIgnoringFailure((prefs) async {
			final serialized = items
					.map(
						(item) => jsonEncode({
							'id': item.id,
							'type': item.type == ItemType.exam ? 'exam' : 'task',
							'title': item.title,
							'subject': item.subject,
							'date': item.date,
							'time': item.time,
							'description': item.description,
							'location': item.location,
							'isCompleted': item.isCompleted,
						}),
					)
					.toList();
			await prefs.setStringList(_itemsKey, serialized);
		});
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
}
