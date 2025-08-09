import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker_app/main.dart';
import 'test_helper.dart';

void main() {
  group('Widget Tests', () {
    setUpAll(() async {
      await TestHelper.initializeHive();
    });

    tearDownAll(() async {
      await TestHelper.cleanupHive();
    });

    testWidgets('App should build without errors', (WidgetTester tester) async {
      // 构建应用
      await tester.pumpWidget(
        const ProviderScope(
          child: ExpenseTrackerApp(),
        ),
      );

      // 验证应用能够正常构建
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Dashboard should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ExpenseTrackerApp(),
        ),
      );

      // 等待异步操作完成
      await tester.pumpAndSettle();

      // 验证底部导航栏存在
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}