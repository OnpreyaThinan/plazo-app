import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plazo_app/main.dart';
import 'package:plazo_app/services/storage_service.dart';

void Function(FlutterErrorDetails details)? _previousOnError;

void main() {
  setUpAll(() {
    _previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is NetworkImageLoadException) {
        return;
      }
      _previousOnError?.call(details);
    };
  });

  tearDownAll(() {
    FlutterError.onError = _previousOnError;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Privacy notice requires explicit accept and persists consent', (WidgetTester tester) async {
    await tester.pumpWidget(const PlazoApp());
    await tester.pumpAndSettle();

    expect(find.text('Privacy Notice'), findsOneWidget);
    expect(
      find.textContaining('If you decline, app usage remains blocked until consent is accepted.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    expect(find.text('Privacy Notice'), findsNothing);
    expect(await StorageService.loadPrivacyConsent(), isTrue);
    expect(await StorageService.loadPrivacyConsentVersion(), 'v1');
    expect(await StorageService.loadPrivacyConsentAcceptedAt(), isNotNull);
  });

  testWidgets('Privacy policy opens from consent dialog', (WidgetTester tester) async {
    await tester.pumpWidget(const PlazoApp());
    await tester.pumpAndSettle();

    expect(find.text('Privacy Notice'), findsOneWidget);

    await tester.tap(find.text('View Privacy Policy'));
    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.textContaining('Last Updated: March 2026'), findsOneWidget);

    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();

    expect(find.text('Privacy Notice'), findsOneWidget);
  });

  testWidgets('Declining privacy notice does not persist consent', (WidgetTester tester) async {
    await tester.pumpWidget(const PlazoApp());
    await tester.pumpAndSettle();

    expect(find.text('Privacy Notice'), findsOneWidget);

    await tester.tap(find.text('Decline'));
    await tester.pump();
    await tester.pump();

    expect(await StorageService.loadPrivacyConsent(), isFalse);
    expect(
      find.text('You need to accept the privacy notice before using the app.'),
      findsOneWidget,
    );
    expect(find.text('Privacy Notice'), findsWidgets);
  });

  testWidgets('Login shows invalid email validation on submit', (WidgetTester tester) async {
    await tester.pumpWidget(const PlazoApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(fields, findsAtLeastNWidgets(2));

    await tester.enterText(fields.at(0), 'invalid-email');
    await tester.enterText(fields.at(1), '12345678');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email address'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
