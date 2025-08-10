import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app/core/services/transaction_service.dart';
import 'package:expense_tracker_app/core/models/transaction.dart';
import 'package:expense_tracker_app/core/utils/result.dart';
import 'package:expense_tracker_app/core/exceptions/app_exceptions.dart';

void main() {
  group('TransactionService', () {
    late TransactionService service;

    setUp(() {
      service = TransactionService();
    });

    group('addTransaction', () {
      test('should add transaction successfully', () async {
        final transaction = Transaction(
          id: '1',
          amount: 100.0,
          description: 'Test transaction',
          category: 'Food',
          type: TransactionType.expense,
          date: DateTime.now(),
        );

        final result = await service.addTransaction(transaction);

        expect(result.isSuccess, isTrue);
      });

      test('should fail when transaction is invalid', () async {
        final transaction = Transaction(
          id: '',
          amount: -100.0, // Invalid amount
          description: '',
          category: '',
          type: TransactionType.expense,
          date: DateTime.now(),
        );

        final result = await service.addTransaction(transaction);

        expect(result.isFailure, isTrue);
        expect(result.exception, isA<AppException>());
      });
    });

    group('getTransactions', () {
      test('should return empty list initially', () async {
        final result = await service.getTransactions();

        expect(result.isSuccess, isTrue);
        expect(result.data, isEmpty);
      });

      test('should return added transactions', () async {
        final transaction = Transaction(
          id: '1',
          amount: 100.0,
          description: 'Test transaction',
          category: 'Food',
          type: TransactionType.expense,
          date: DateTime.now(),
        );

        await service.addTransaction(transaction);
        final result = await service.getTransactions();

        expect(result.isSuccess, isTrue);
        expect(result.data, hasLength(1));
        expect(result.data!.first.id, equals('1'));
      });
    });

    group('updateTransaction', () {
      test('should update existing transaction', () async {
        final transaction = Transaction(
          id: '1',
          amount: 100.0,
          description: 'Original description',
          category: 'Food',
          type: TransactionType.expense,
          date: DateTime.now(),
        );

        await service.addTransaction(transaction);

        final updatedTransaction = transaction.copyWith(
          description: 'Updated description',
        );

        final result = await service.updateTransaction(updatedTransaction);

        expect(result.isSuccess, isTrue);

        final getResult = await service.getTransactions();
        expect(getResult.data!.first.description, equals('Updated description'));
      });

      test('should fail when transaction does not exist', () async {
        final transaction = Transaction(
          id: 'non-existent',
          amount: 100.0,
          description: 'Test',
          category: 'Food',
          type: TransactionType.expense,
          date: DateTime.now(),
        );

        final result = await service.updateTransaction(transaction);

        expect(result.isFailure, isTrue);
        expect(result.exception, isA<AppException>());
      });
    });

    group('deleteTransaction', () {
      test('should delete existing transaction', () async {
        final transaction = Transaction(
          id: '1',
          amount: 100.0,
          description: 'Test transaction',
          category: 'Food',
          type: TransactionType.expense,
          date: DateTime.now(),
        );

        await service.addTransaction(transaction);
        final result = await service.deleteTransaction('1');

        expect(result.isSuccess, isTrue);

        final getResult = await service.getTransactions();
        expect(getResult.data, isEmpty);
      });

      test('should fail when transaction does not exist', () async {
        final result = await service.deleteTransaction('non-existent');

        expect(result.isFailure, isTrue);
        expect(result.exception, isA<AppException>());
      });
    });

    group('getTransactionsByDateRange', () {
      test('should return transactions within date range', () async {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final tomorrow = now.add(const Duration(days: 1));

        final transaction1 = Transaction(
          id: '1',
          amount: 100.0,
          description: 'Yesterday',
          category: 'Food',
          type: TransactionType.expense,
          date: yesterday,
        );

        final transaction2 = Transaction(
          id: '2',
          amount: 200.0,
          description: 'Today',
          category: 'Food',
          type: TransactionType.expense,
          date: now,
        );

        final transaction3 = Transaction(
          id: '3',
          amount: 300.0,
          description: 'Tomorrow',
          category: 'Food',
          type: TransactionType.expense,
          date: tomorrow,
        );

        await service.addTransaction(transaction1);
        await service.addTransaction(transaction2);
        await service.addTransaction(transaction3);

        final result = await service.getTransactionsByDateRange(
          startDate: yesterday,
          endDate: now,
        );

        expect(result.isSuccess, isTrue);
        expect(result.data, hasLength(2));
        expect(result.data!.map((t) => t.id), containsAll(['1', '2']));
      });
    });

    group('getTransactionsByCategory', () {
      test('should return transactions of specific category', () async {
        final transaction1 = Transaction(
          id: '1',
          amount: 100.0,
          description: 'Food expense',
          category: 'Food',
          type: TransactionType.expense,
          date: DateTime.now(),
        );

        final transaction2 = Transaction(
          id: '2',
          amount: 200.0,
          description: 'Transport expense',
          category: 'Transport',
          type: TransactionType.expense,
          date: DateTime.now(),
        );

        await service.addTransaction(transaction1);
        await service.addTransaction(transaction2);

        final result = await service.getTransactionsByCategory('Food');

        expect(result.isSuccess, isTrue);
        expect(result.data, hasLength(1));
        expect(result.data!.first.category, equals('Food'));
      });
    });

    group('getTotalBalance', () {
      test('should calculate correct balance', () async {
        final income = Transaction(
          id: '1',
          amount: 1000.0,
          description: 'Salary',
          category: 'Income',
          type: TransactionType.income,
          date: DateTime.now(),
        );

        final expense = Transaction(
          id: '2',
          amount: 300.0,
          description: 'Food',
          category: 'Food',
          type: TransactionType.expense,
          date: DateTime.now(),
        );

        await service.addTransaction(income);
        await service.addTransaction(expense);

        final result = await service.getTotalBalance();

        expect(result.isSuccess, isTrue);
        expect(result.data, equals(700.0)); // 1000 - 300
      });
    });
  });
}