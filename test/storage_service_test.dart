import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plazo_app/models.dart';
import 'package:plazo_app/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StorageService items', () {
    test('saveItems and loadItems should persist and restore data', () async {
      final items = <PlazoItem>[
        PlazoItem(
          id: '1',
          type: ItemType.task,
          title: 'Read chapter',
          subject: 'Math',
          date: '2026-04-03',
          time: '09:00',
          description: 'Linear algebra',
          isCompleted: false,
        ),
        PlazoItem(
          id: '2',
          type: ItemType.exam,
          title: 'Midterm',
          subject: 'Physics',
          date: '2026-04-10',
          time: '13:30',
          description: 'Room B2',
          location: 'Building B',
          isCompleted: true,
        ),
      ];

      await StorageService.saveItems(items);
      final loaded = await StorageService.loadItems();

      expect(loaded, hasLength(2));
      expect(loaded[0].id, '1');
      expect(loaded[0].type, ItemType.task);
      expect(loaded[0].subject, 'Math');
      expect(loaded[0].isCompleted, false);

      expect(loaded[1].id, '2');
      expect(loaded[1].type, ItemType.exam);
      expect(loaded[1].location, 'Building B');
      expect(loaded[1].isCompleted, true);
    });

    test('loadItems should return empty list on malformed JSON', () async {
      SharedPreferences.setMockInitialValues({
        'plazo_items': <String>['{malformed-json'],
      });

      final loaded = await StorageService.loadItems();

      expect(loaded, isEmpty);
    });
  });

  group('StorageService preferences', () {
    test('language should default to en and then save/load correctly', () async {
      final defaultLanguage = await StorageService.loadLanguage();
      expect(defaultLanguage, 'en');

      await StorageService.saveLanguage('th');
      final savedLanguage = await StorageService.loadLanguage();

      expect(savedLanguage, 'th');
    });

    test('dark mode should default to false and then save/load correctly', () async {
      final defaultDarkMode = await StorageService.loadDarkMode();
      expect(defaultDarkMode, false);

      await StorageService.saveDarkMode(true);
      final savedDarkMode = await StorageService.loadDarkMode();

      expect(savedDarkMode, true);
    });

    test('privacy consent should default to false and then save/load correctly', () async {
      final defaultConsent = await StorageService.loadPrivacyConsent();
      expect(defaultConsent, false);

      await StorageService.savePrivacyConsent(true);
      final savedConsent = await StorageService.loadPrivacyConsent();

      expect(savedConsent, true);
    });
  });

  group('StorageService generic string', () {
    test('setString and getString should persist value', () async {
      await StorageService.setString('lastLogin', '2026-04-03T10:00:00.000Z');

      final value = await StorageService.getString('lastLogin');

      expect(value, '2026-04-03T10:00:00.000Z');
    });

    test('getString should return null for missing key', () async {
      final value = await StorageService.getString('missing_key');

      expect(value, isNull);
    });
  });
}
