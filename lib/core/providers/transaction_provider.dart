import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../utils/result.dart';
import '../utils/logger.dart';
import '../exceptions/app_exceptions.dart';

// 交易列表提供者
final transactionListProvider = StateNotifierProvider<TransactionListNotifier, AsyncValue<List<Transaction>>>((ref) {
  return TransactionListNotifier();
});

class TransactionListNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  TransactionListNotifier() : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    
    final result = await TransactionService.getAllTransactions();
    result.when(
      success: (transactions) {
        state = AsyncValue.data(transactions);
      },
      failure: (message, exception) {
        AppLogger.error('加载交易列表失败: $message', exception);
        state = AsyncValue.error(
          exception ?? Exception(message), 
          StackTrace.current,
        );
      },
    );
  }

  Future<Result<void>> addTransaction(Transaction transaction) async {
    final result = await TransactionService.addTransaction(transaction);
    if (result.isSuccess) {
      await loadTransactions(); // 重新加载数据
    }
    return result;
  }

  Future<Result<void>> updateTransaction(Transaction transaction) async {
    final result = await TransactionService.updateTransaction(transaction);
    if (result.isSuccess) {
      await loadTransactions();
    }
    return result;
  }

  Future<Result<void>> deleteTransaction(String id) async {
    final result = await TransactionService.deleteTransaction(id);
    if (result.isSuccess) {
      await loadTransactions();
    }
    return result;
  }

  Future<Result<void>> addMultipleTransactions(List<Transaction> transactions) async {
    try {
      for (final transaction in transactions) {
        final result = await TransactionService.addTransaction(transaction);
        if (result.isFailure) {
          AppLogger.error('批量添加交易失败: ${result.error}', result.exception);
          return result;
        }
      }
      await loadTransactions();
      return const Result.success(null);
    } catch (e) {
      final error = '批量添加交易失败: ${e.toString()}';
      AppLogger.error(error, e is Exception ? e : Exception(e.toString()));
      return Result.failure(error, e is Exception ? e : Exception(e.toString()));
    }
  }
}

// 余额提供者
final balanceProvider = FutureProvider<double>((ref) async {
  // 监听交易列表变化
  ref.watch(transactionListProvider);
  final result = await TransactionService.getTotalBalance();
  return result.when(
    success: (balance) => balance,
    failure: (message, exception) {
      AppLogger.error('获取余额失败: $message', exception);
      throw exception ?? Exception(message);
    },
  );
});

// 分类统计提供者
final categoryStatsProvider = FutureProvider<Map<String, double>>((ref) async {
  ref.watch(transactionListProvider);
  final result = await TransactionService.getCategoryTotals();
  return result.when(
    success: (stats) => stats,
    failure: (message, exception) {
      AppLogger.error('获取分类统计失败: $message', exception);
      throw exception ?? Exception(message);
    },
  );
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