import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class TransactionService {
  static const String _boxName = 'transactions';
  static Box<Map>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  static Future<void> addTransaction(Transaction transaction) async {
    if (_box == null) await init();
    await _box!.put(transaction.id, transaction.toJson());
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    if (_box == null) await init();
    await _box!.put(transaction.id, transaction.toJson());
  }

  static Future<void> deleteTransaction(String id) async {
    if (_box == null) await init();
    await _box!.delete(id);
  }

  static Future<List<Transaction>> getAllTransactions() async {
    if (_box == null) await init();
    return _box!.values
        .map((json) => Transaction.fromJson(Map<String, dynamic>.from(json)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final allTransactions = await getAllTransactions();
    return allTransactions
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList();
  }

  static Future<double> getTotalBalance() async {
    final transactions = await getAllTransactions();
    double balance = 0;
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }
    return balance;
  }

  static Future<Map<String, double>> getCategoryTotals() async {
    final transactions = await getAllTransactions();
    final Map<String, double> categoryTotals = {};
    
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        categoryTotals[transaction.category] = 
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }
    
    return categoryTotals;
  }
}