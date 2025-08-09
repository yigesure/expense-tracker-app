import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

// 交易列表提供者
final transactionListProvider = StateNotifierProvider<TransactionListNotifier, AsyncValue<List<Transaction>>>((ref) {
  return TransactionListNotifier();
});

class TransactionListNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  TransactionListNotifier() : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      state = const AsyncValue.loading();
      final transactions = await TransactionService.getAllTransactions();
      state = AsyncValue.data(transactions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await TransactionService.addTransaction(transaction);
      await loadTransactions(); // 重新加载数据
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await TransactionService.updateTransaction(transaction);
      await loadTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await TransactionService.deleteTransaction(id);
      await loadTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addMultipleTransactions(List<Transaction> transactions) async {
    try {
      for (final transaction in transactions) {
        await TransactionService.addTransaction(transaction);
      }
      await loadTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// 余额提供者
final balanceProvider = FutureProvider<double>((ref) async {
  // 监听交易列表变化
  ref.watch(transactionListProvider);
  return await TransactionService.getTotalBalance();
});

// 分类统计提供者
final categoryStatsProvider = FutureProvider<Map<String, double>>((ref) async {
  ref.watch(transactionListProvider);
  return await TransactionService.getCategoryTotals();
});

// 今日交易提供者
final todayTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  final transactionsAsync = ref.watch(transactionListProvider);
  
  return transactionsAsync.when(
    data: (transactions) {
      final today = DateTime.now();
      final todayTransactions = transactions.where((t) {
        return t.date.year == today.year &&
               t.date.month == today.month &&
               t.date.day == today.day;
      }).toList();
      return AsyncValue.data(todayTransactions);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// 本月交易提供者
final monthlyTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  final transactionsAsync = ref.watch(transactionListProvider);
  
  return transactionsAsync.when(
    data: (transactions) {
      final now = DateTime.now();
      final monthlyTransactions = transactions.where((t) {
        return t.date.year == now.year && t.date.month == now.month;
      }).toList();
      return AsyncValue.data(monthlyTransactions);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});