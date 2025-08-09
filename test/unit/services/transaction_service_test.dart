import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker_app/core/services/transaction_service.dart';
import 'package:expense_tracker_app/core/models/transaction.dart';

void main() {
  group('TransactionService Tests', () {
    setUpAll(() async {
      await Hive.initFlutter();
      await TransactionService.init();
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
    });

    test('should add transaction successfully', () async {
      final transaction = Transaction(
        id: 'test-1',
        title: '测试交易',
        amount: 100.0,
        category: '餐饮',
        categoryIcon: '🍜',
        date: DateTime.now(),
        type: TransactionType.expense,
      );

      await TransactionService.addTransaction(transaction);
      final transactions = await TransactionService.getAllTransactions();
      
      expect(transactions.length, 1);
      expect(transactions.first.title, '测试交易');
      expect(transactions.first.amount, 100.0);
    });

    test('should calculate total balance correctly', () async {
      // 清空数据
      final allTransactions = await TransactionService.getAllTransactions();
      for (final t in allTransactions) {
        await TransactionService.deleteTransaction(t.id);
      }

      // 添加收入
      await TransactionService.addTransaction(Transaction(
        id: 'income-1',
        title: '工资',
        amount: 5000.0,
        category: '收入',
        categoryIcon: '💰',
        date: DateTime.now(),
        type: TransactionType.income,
      ));

      // 添加支出
      await TransactionService.addTransaction(Transaction(
        id: 'expense-1',
        title: '午饭',
        amount: 30.0,
        category: '餐饮',
        categoryIcon: '🍜',
        date: DateTime.now(),
        type: TransactionType.expense,
      ));

      final balance = await TransactionService.getTotalBalance();
      expect(balance, 4970.0);
    });

    test('should get category totals correctly', () async {
      final categoryTotals = await TransactionService.getCategoryTotals();
      expect(categoryTotals.containsKey('餐饮'), true);
      expect(categoryTotals['餐饮'], greaterThan(0));
    });
  });
}