import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker_app/core/services/transaction_service.dart';
import 'package:expense_tracker_app/core/models/transaction.dart';
import '../../test_helper.dart';

void main() {
  group('TransactionService Tests', () {
    setUpAll(() async {
      // 初始化Hive用于测试
      await TestHelper.initializeHive();
      await TransactionService.init();
    });

    tearDownAll(() async {
      // 清理测试数据
      await TestHelper.cleanupHive();
    });

    setUp(() async {
      // 每个测试前清空数据
      final allTransactions = await TransactionService.getAllTransactions();
      for (final t in allTransactions) {
        await TransactionService.deleteTransaction(t.id);
      }
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