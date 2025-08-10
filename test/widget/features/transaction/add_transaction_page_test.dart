import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker_app/features/transaction/presentation/pages/add_transaction_page.dart';
import 'package:expense_tracker_app/core/models/transaction.dart';

void main() {
  group('AddTransactionPage Widget Tests', () {
    testWidgets('should display all required form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const AddTransactionPage(),
          ),
        ),
      );

      // 验证页面标题
      expect(find.text('添加交易'), findsOneWidget);

      // 验证金额输入框
      expect(find.byType(TextFormField), findsWidgets);
      
      // 验证交易类型选择
      expect(find.text('支出'), findsOneWidget);
      expect(find.text('收入'), findsOneWidget);

      // 验证保存按钮
      expect(find.text('保存'), findsOneWidget);
    });

    testWidgets('should validate required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const AddTransactionPage(),
          ),
        ),
      );

      // 点击保存按钮而不填写任何字段
      await tester.tap(find.text('保存'));
      await tester.pump();

      // 验证错误消息显示
      expect(find.text('请输入金额'), findsOneWidget);
      expect(find.text('请输入描述'), findsOneWidget);
    });

    testWidgets('should switch between expense and income types', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const AddTransactionPage(),
          ),
        ),
      );

      // 默认应该选中支出
      expect(find.text('支出'), findsOneWidget);

      // 点击收入选项
      await tester.tap(find.text('收入'));
      await tester.pump();

      // 验证收入被选中
      // 这里需要根据实际UI实现来验证选中状态
    });

    testWidgets('should format amount input correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const AddTransactionPage(),
          ),
        ),
      );

      // 找到金额输入框
      final amountField = find.byKey(const Key('amount_field'));
      expect(amountField, findsOneWidget);

      // 输入金额
      await tester.enterText(amountField, '123.45');
      await tester.pump();

      // 验证格式化后的显示
      expect(find.text('123.45'), findsOneWidget);
    });

    testWidgets('should show date picker when date field is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const AddTransactionPage(),
          ),
        ),
      );

      // 点击日期字段
      await tester.tap(find.byKey(const Key('date_field')));
      await tester.pumpAndSettle();

      // 验证日期选择器显示
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('should show category selection dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const AddTransactionPage(),
          ),
        ),
      );

      // 点击分类字段
      await tester.tap(find.byKey(const Key('category_field')));
      await tester.pumpAndSettle();

      // 验证分类选择对话框显示
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('选择分类'), findsOneWidget);
    });

    testWidgets('should navigate back when cancel is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddTransactionPage()),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      // 打开添加交易页面
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // 验证页面已打开
      expect(find.text('添加交易'), findsOneWidget);

      // 点击取消按钮
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // 验证已返回上一页
      expect(find.text('添加交易'), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('should show loading state when saving', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const AddTransactionPage(),
          ),
        ),
      );

      // 填写表单
      await tester.enterText(find.byKey(const Key('amount_field')), '100');
      await tester.enterText(find.byKey(const Key('description_field')), '测试交易');
      
      // 点击保存
      await tester.tap(find.text('保存'));
      await tester.pump();

      // 验证加载状态
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}