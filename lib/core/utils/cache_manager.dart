import 'dart:collection';
import '../models/transaction.dart';

/// 缓存管理器，用于优化数据处理和减少重复计算
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  // 交易数据缓存
  final Map<String, List<Transaction>> _transactionCache = {};
  final Map<String, Map<String, double>> _categoryStatsCache = {};
  final Map<String, double> _balanceCache = {};
  
  // LRU缓存，限制缓存大小
  final LinkedHashMap<String, dynamic> _lruCache = LinkedHashMap();
  static const int _maxCacheSize = 100;

  /// 获取缓存的交易列表
  List<Transaction>? getCachedTransactions(String key) {
    return _transactionCache[key];
  }

  /// 缓存交易列表
  void cacheTransactions(String key, List<Transaction> transactions) {
    _transactionCache[key] = List.from(transactions);
    _updateLRU(key);
  }

  /// 获取缓存的分类统计
  Map<String, double>? getCachedCategoryStats(String key) {
    return _categoryStatsCache[key];
  }

  /// 缓存分类统计
  void cacheCategoryStats(String key, Map<String, double> stats) {
    _categoryStatsCache[key] = Map.from(stats);
    _updateLRU(key);
  }

  /// 获取缓存的余额
  double? getCachedBalance(String key) {
    return _balanceCache[key];
  }

  /// 缓存余额
  void cacheBalance(String key, double balance) {
    _balanceCache[key] = balance;
    _updateLRU(key);
  }

  /// 更新LRU缓存
  void _updateLRU(String key) {
    _lruCache.remove(key);
    _lruCache[key] = DateTime.now();
    
    // 如果缓存超过限制，移除最旧的项
    if (_lruCache.length > _maxCacheSize) {
      final oldestKey = _lruCache.keys.first;
      _lruCache.remove(oldestKey);
      _transactionCache.remove(oldestKey);
      _categoryStatsCache.remove(oldestKey);
      _balanceCache.remove(oldestKey);
    }
  }

  /// 清除所有缓存
  void clearAll() {
    _transactionCache.clear();
    _categoryStatsCache.clear();
    _balanceCache.clear();
    _lruCache.clear();
  }

  /// 清除特定类型的缓存
  void clearTransactionCache() {
    _transactionCache.clear();
  }

  void clearCategoryStatsCache() {
    _categoryStatsCache.clear();
  }

  void clearBalanceCache() {
    _balanceCache.clear();
  }

  /// 生成缓存键
  static String generateTransactionCacheKey({
    String? filter,
    String? sort,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final parts = <String>[];
    if (filter != null) parts.add('filter:$filter');
    if (sort != null) parts.add('sort:$sort');
    if (startDate != null) parts.add('start:${startDate.millisecondsSinceEpoch}');
    if (endDate != null) parts.add('end:${endDate.millisecondsSinceEpoch}');
    return parts.join('|');
  }

  static String generateCategoryStatsCacheKey({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final parts = <String>['category_stats'];
    if (startDate != null) parts.add('start:${startDate.millisecondsSinceEpoch}');
    if (endDate != null) parts.add('end:${endDate.millisecondsSinceEpoch}');
    return parts.join('|');
  }

  static String generateBalanceCacheKey() {
    return 'total_balance';
  }
}

/// 缓存装饰器，用于自动缓存计算结果
mixin CacheableMixin {
  final CacheManager _cacheManager = CacheManager();

  /// 带缓存的计算方法
  Future<T> withCache<T>(
    String key,
    Future<T> Function() computation,
    void Function(String, T) cacheFunction,
    T? Function(String) getCacheFunction,
  ) async {
    // 尝试从缓存获取
    final cached = getCacheFunction(key);
    if (cached != null) {
      return cached;
    }

    // 执行计算
    final result = await computation();
    
    // 缓存结果
    cacheFunction(key, result);
    
    return result;
  }
}