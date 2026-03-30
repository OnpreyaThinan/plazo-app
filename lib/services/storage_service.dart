import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

class StorageService {
	static const String _itemsKey = 'plazo_items';
	static const String _languageKey = 'plazo_language';
	static const String _darkModeKey = 'plazo_dark_mode';

	static Future<List<PlazoItem>> loadItems() async {
		try {
			final prefs = await SharedPreferences.getInstance();
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
		} catch (_) {
			return [];
		}
	}

	static Future<void> saveItems(List<PlazoItem> items) async {
		try {
			final prefs = await SharedPreferences.getInstance();
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
		} catch (_) {
			// Ignore persistence failures in UI flow.
		}
	}

	static Future<String> loadLanguage() async {
		try {
			final prefs = await SharedPreferences.getInstance();
			return prefs.getString(_languageKey) ?? 'en';
		} catch (_) {
			return 'en';
		}
	}

	static Future<void> saveLanguage(String language) async {
		try {
			final prefs = await SharedPreferences.getInstance();
			await prefs.setString(_languageKey, language);
		} catch (_) {
			// Ignore persistence failures in UI flow.
		}
	}

	static Future<bool> loadDarkMode() async {
		try {
			final prefs = await SharedPreferences.getInstance();
			return prefs.getBool(_darkModeKey) ?? false;
		} catch (_) {
			return false;
		}
	}

	static Future<void> saveDarkMode(bool value) async {
		try {
			final prefs = await SharedPreferences.getInstance();
			await prefs.setBool(_darkModeKey, value);
		} catch (_) {
			// Ignore persistence failures in UI flow.
		}
	}

	// Generic string storage methods for app state
	static Future<String?> getString(String key) async {
		try {
			final prefs = await SharedPreferences.getInstance();
			return prefs.getString(key);
		} catch (_) {
			return null;
		}
	}

	static Future<void> setString(String key, String value) async {
		try {
			final prefs = await SharedPreferences.getInstance();
			await prefs.setString(key, value);
		} catch (_) {
			// Ignore persistence failures in UI flow.
		}
	}
}
