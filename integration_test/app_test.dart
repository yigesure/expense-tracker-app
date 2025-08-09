import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:expense_tracker_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Expense Tracker App Integration Tests', () {
    testWidgets('should launch app and show main page', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 验证应用启动成功
      expect(find.text('个人记账助手'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should navigate between tabs', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 点击统计页面
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // 点击日历页面
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // 点击AI助手页面
      await tester.tap(find.byIcon(Icons.smart_toy));
      await tester.pumpAndSettle();

      // 返回首页
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
    });

    testWidgets('should open quick input dialog', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 查找并点击快捷输入按钮
      final quickInputButton = find.byType(FloatingActionButton);
      expect(quickInputButton, findsOneWidget);
      
      await tester.tap(quickInputButton);
      await tester.pumpAndSettle();

      // 验证输入对话框打开
      expect(find.text('快速记账'), findsOneWidget);
      expect(find.text('输入消费记录...'), findsOneWidget);
    });

    testWidgets('should add transaction via quick input', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 打开快捷输入
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // 输入交易信息
      final textField = find.byType(TextField);
      await tester.enterText(textField, '午饭25元');
      await tester.pumpAndSettle();

      // 点击添加按钮
      await tester.tap(find.text('添加记录'));
      await tester.pumpAndSettle();

      // 验证成功提示
      expect(find.text('成功添加 1 条记录'), findsOneWidget);
    });

    testWidgets('should handle invalid input gracefully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 打开快捷输入
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // 输入无效信息
      final textField = find.byType(TextField);
      await tester.enterText(textField, '无效输入');
      await tester.pumpAndSettle();

      // 点击添加按钮
      await tester.tap(find.text('添加记录'));
      await tester.pumpAndSettle();

      // 验证错误提示
      expect(find.text('无法识别输入内容，请检查格式'), findsOneWidget);
    });
  });
}