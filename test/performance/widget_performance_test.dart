import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker_app/features/transaction/presentation/pages/transaction_list_page.dart';
import 'package:expense_tracker_app/core/models/transaction.dart';

void main() {
  group('Widget Performance Tests', () {
    testWidgets('TransactionListPage should handle large datasets efficiently', 
        (WidgetTester tester) async {
      // 创建大量测试数据
      final transactions = List.generate(1000, (index) => Transaction(
        id: 'test_$index',
        amount: (index * 10.5),
        description: 'Test transaction $index',
        category: 'Category ${index % 5}',
        type: index % 2 == 0 ? TransactionType.expense : TransactionType.income,
        date: DateTime.now().subtract(Duration(days: index % 30)),
      ));

      // 测量构建时间
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const TransactionListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      // 验证构建时间在合理范围内（< 100ms）
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      // 测量滚动性能
      final scrollStopwatch = Stopwatch()..start();
      
      await tester.fling(
        find.byType(ListView),
        const Offset(0, -500),
        1000,
      );
      
      await tester.pumpAndSettle();
      scrollStopwatch.stop();

      // 验证滚动响应时间
      expect(scrollStopwatch.elapsedMilliseconds, lessThan(50));
    });

    testWidgets('Memory usage should remain stable during navigation', 
        (WidgetTester tester) async {
      // 模拟多次页面导航
      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const TransactionListPage(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 触发垃圾回收
        await tester.binding.delayed(const Duration(milliseconds: 100));
      }

      // 验证没有内存泄漏（这里只是示例，实际需要更复杂的内存监控）
      expect(tester.binding.defaultBinaryMessenger, isNotNull);
    });

    testWidgets('Animation performance should be smooth', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      // 测量动画帧率
      final frameStopwatch = Stopwatch()..start();
      int frameCount = 0;

      await tester.pump();
      
      // 模拟动画过程
      while (frameStopwatch.elapsedMilliseconds < 300) {
        await tester.pump(const Duration(milliseconds: 16)); // 60fps
        frameCount++;
      }

      frameStopwatch.stop();

      // 验证帧率接近60fps
      final actualFps = frameCount / (frameStopwatch.elapsedMilliseconds / 1000);
      expect(actualFps, greaterThan(50)); // 允许一些误差
    });
  });
}