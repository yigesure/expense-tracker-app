// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker_app/main.dart';

void main() {
  testWidgets('ExpenseTracker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ExpenseTrackerApp(),
      ),
    );

    // Verify that the app loads successfully
    await tester.pumpAndSettle();
    
    // The test passes if the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
