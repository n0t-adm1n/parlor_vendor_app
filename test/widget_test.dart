// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parlor_vendor_app/main.dart';

void main() {
  testWidgets('Dashboard Screen Smoke Test', (WidgetTester tester) async {
    // Intercept Firebase/Firestore initialization exception during test run
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final errorStr = details.exception.toString();
      if (errorStr.contains('Firebase') || errorStr.contains('core/no-app')) {
        return; // Ignore Firebase initialization errors in widget tests
      }
      originalOnError?.call(details);
    };

    try {
      await tester.pumpWidget(const MyApp());
      // Verify that MyApp builds and loads successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    } finally {
      FlutterError.onError = originalOnError;
    }
  });
}
