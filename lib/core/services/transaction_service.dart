import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../utils/result.dart';
import '../utils/logger.dart';
import '../utils/debouncer.dart';
import '../exceptions/app_exceptions.dart';

class TransactionService {
  static const String _boxName = 'transactions';
  static Box<Map>? _box;
  
  // 性能优化：防抖动器和批处理器
  static final _saveDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
  static final _batchProcessor = BatchProcessor<Transaction>(
    batchDelay: const Duration(milliseconds: 500),
    maxBatchSize: 10,
    processor: _processBatchTransactions,
  );
  
  // 缓存层
  static final Map<String, List<Transaction>> _cache = {};
  static DateTime? _lastCacheUpdate;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  static Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  /// 批处理保存交易记录
  static Future<void> _processBatchTransactions(List<Transaction> transactions) async {
    try {
      AppLogger.info('TransactionService', 'Processing batch of ${transactions.length} transactions');
      
      for (final transaction in transactions) {
        await _box!.put(transaction.id, transaction.toJson());
      }
      
      _invalidateCache();
      AppLogger.info('TransactionService', 'Batch processing completed');
    } catch (e, stackTrace) {
      AppLogger.error('TransactionService', 'Error in batch processing: $e', stackTrace);
      rethrow;
    }
  }

  /// 使缓存失效
  static void _invalidateCache() {
    _cache.clear();
    _lastCacheUpdate = null;
  }

  /// 检查缓存是否有效
  static bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheExpiry;
  }

  static Future<void> addTransaction(Transaction transaction) async {
    if (_box == null) await init();
    
    // 使用防抖动优化保存操作
    _saveDebouncer.run(() async {
      await _box!.put(transaction.id, transaction.toJson());
      _invalidateCache();
    });
  }

  /// 批量添加交易（性能优化）
  static void addTransactionToBatch(Transaction transaction) {
    _batchProcessor.add(transaction);
  }

  /// 立即处理批次
  static Future<void> flushBatch() async {
    await _batchProcessor.flush();
  }

  static Future<Result<void>> updateTransaction(Transaction transaction) async {
    try {
      AppLogger.logOperationStart('更新交易', {'id': transaction.id});
      
      if (_box == null) await init();
      
      // 检查交易是否存在
      if (!_box!.containsKey(transaction.id)) {
        const error = '要更新的交易不存在';
        AppLogger.logOperationFailure('更新交易', error);
        return const Result.failure(error, NotFoundException(error));
      }
      
      await _box!.put(transaction.id, transaction.toJson());
      _invalidateCache(); // 使缓存失效
      
      AppLogger.logOperationSuccess('更新交易', transaction.id);
      return const Result.success(null);
    } catch (e) {
      final error = '更新交易失败: ${e.toString()}';
      AppLogger.logOperationFailure('更新交易', error, e is Exception ? e : Exception(e.toString()));
      return Result.failure(error, DatabaseException(error));
    }
  }

  static Future<Result<void>> deleteTransaction(String id) async {
    try {
      AppLogger.logOperationStart('删除交易', {'id': id});
      
      if (_box == null) await init();
      
      // 检查交易是否存在
      if (!_box!.containsKey(id)) {
        const error = '要删除的交易不存在';
        AppLogger.logOperationFailure('删除交易', error);
        return const Result.failure(error, NotFoundException(error));
      }
      
      await _box!.delete(id);
      _invalidateCache(); // 使缓存失效
      
      AppLogger.logOperationSuccess('删除交易', id);
      return const Result.success(null);
    } catch (e) {
      final error = '删除交易失败: ${e.toString()}';
      AppLogger.logOperationFailure('删除交易', error, e is Exception ? e : Exception(e.toString()));
      return Result.failure(error, DatabaseException(error));
    }
  }

  /// 清理资源
  static void dispose() {
    _saveDebouncer.dispose();
    _batchProcessor.dispose();
    _invalidateCache();
  }

  static Future<Result<List<Transaction>>> getAllTransactions() async {
    try {
      AppLogger.logOperationStart('获取所有交易');
      
      if (_box == null) await init();

      // 检查缓存
      const cacheKey = 'all_transactions';
      if (_isCacheValid() && _cache.containsKey(cacheKey)) {
        AppLogger.logOperationSuccess('获取所有交易', '从缓存返回${_cache[cacheKey]!.length}条记录');
        return Result.success(_cache[cacheKey]!);
      }
      
      final transactions = _box!.values
          .map((json) => Transaction.fromJson(Map<String, dynamic>.from(json)))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      // 更新缓存
      _cache[cacheKey] = transactions;
      _lastCacheUpdate = DateTime.now();
      
      AppLogger.logOperationSuccess('获取所有交易', '共${transactions.length}条记录');
      return Result.success(transactions);
    } catch (e) {
      final error = '获取交易列表失败: ${e.toString()}';
      AppLogger.logOperationFailure('获取所有交易', error, e is Exception ? e : Exception(e.toString()));
      return Result.failure(error, DatabaseException(error));
    }
  }

  static Future<Result<List<Transaction>>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      AppLogger.logOperationStart('按日期范围获取交易', {
        'start': start.toIso8601String(),
        'end': end.toIso8601String()
      });
      
      final allTransactionsResult = await getAllTransactions();
      if (allTransactionsResult.isFailure) {
        return Result.failure(allTransactionsResult.error!, allTransactionsResult.exception);
      }
      
      final filteredTransactions = allTransactionsResult.data!
          .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
          .toList();
      
      AppLogger.logOperationSuccess('按日期范围获取交易', '共${filteredTransactions.length}条记录');
      return Result.success(filteredTransactions);
    } catch (e) {
      final error = '按日期范围获取交易失败: ${e.toString()}';
      AppLogger.logOperationFailure('按日期范围获取交易', error, e is Exception ? e : Exception(e.toString()));
      return Result.failure(error, DatabaseException(error));
    }
  }

  static Future<Result<double>> getTotalBalance() async {
    try {
      AppLogger.logOperationStart('计算总余额');
      
      final transactionsResult = await getAllTransactions();
      if (transactionsResult.isFailure) {
        return Result.failure(transactionsResult.error!, transactionsResult.exception);
      }
      
      double balance = 0;
      for (final transaction in transactionsResult.data!) {
        if (transaction.type == TransactionType.income) {
          balance += transaction.amount;
        } else {
          balance -= transaction.amount;
        }
      }
      
      AppLogger.logOperationSuccess('计算总余额', balance);
      return Result.success(balance);
    } catch (e) {
      final error = '计算总余额失败: ${e.toString()}';
      AppLogger.logOperationFailure('计算总余额', error, e is Exception ? e : Exception(e.toString()));
      return Result.failure(error, BusinessException(error));
    }
  }

  static Future<Result<Map<String, double>>> getCategoryTotals() async {
    try {
      AppLogger.logOperationStart('计算分类统计');
      
      final transactionsResult = await getAllTransactions();
      if (transactionsResult.isFailure) {
        return Result.failure(transactionsResult.error!, transactionsResult.exception);
      }
      
      final Map<String, double> categoryTotals = {};
      
      for (final transaction in transactionsResult.data!) {
        if (transaction.type == TransactionType.expense) {
          categoryTotals[transaction.category] = 
              (categoryTotals[transaction.category] ?? 0) + transaction.amount;
        }
      }
      
      AppLogger.logOperationSuccess('计算分类统计', '共${categoryTotals.length}个分类');
      return Result.success(categoryTotals);
    } catch (e) {
      final error = '计算分类统计失败: ${e.toString()}';
      AppLogger.logOperationFailure('计算分类统计', error, e is Exception ? e : Exception(e.toString()));
      return Result.failure(error, BusinessException(error));
    }
  }
}