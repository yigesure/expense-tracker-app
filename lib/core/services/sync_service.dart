import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/transaction.dart';
import '../utils/result.dart';
import '../utils/logger.dart';
import '../exceptions/app_exceptions.dart';
import 'transaction_service.dart';
import 'backup_service.dart';

/// 同步状态枚举
enum SyncStatus {
  idle,
  syncing,
  success,
  failed,
  conflict,
}

/// 同步冲突解决策略
enum ConflictResolution {
  keepLocal,
  keepRemote,
  merge,
  askUser,
}

/// 同步记录
class SyncRecord {
  final String id;
  final DateTime timestamp;
  final SyncStatus status;
  final String? error;
  final int uploadedCount;
  final int downloadedCount;
  final int conflictCount;

  SyncRecord({
    required this.id,
    required this.timestamp,
    required this.status,
    this.error,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.conflictCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString(),
      'error': error,
      'uploadedCount': uploadedCount,
      'downloadedCount': downloadedCount,
      'conflictCount': conflictCount,
    };
  }

  factory SyncRecord.fromJson(Map<String, dynamic> json) {
    return SyncRecord(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      status: SyncStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => SyncStatus.idle,
      ),
      error: json['error'],
      uploadedCount: json['uploadedCount'] ?? 0,
      downloadedCount: json['downloadedCount'] ?? 0,
      conflictCount: json['conflictCount'] ?? 0,
    );
  }
}

/// 数据同步服务
/// 提供本地与云端数据同步功能
class SyncService {
  static final AppLogger _logger = AppLogger('SyncService');
  static final Connectivity _connectivity = Connectivity();
  
  static SyncStatus _currentStatus = SyncStatus.idle;
  static final StreamController<SyncStatus> _statusController = 
      StreamController<SyncStatus>.broadcast();
  
  static Timer? _autoSyncTimer;
  static bool _isAutoSyncEnabled = false;

  /// 同步状态流
  static Stream<SyncStatus> get statusStream => _statusController.stream;

  /// 当前同步状态
  static SyncStatus get currentStatus => _currentStatus;

  /// 初始化同步服务
  static Future<void> initialize() async {
    _logger.info('初始化同步服务');
    
    // 监听网络状态变化
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    
    // 启动自动同步
    await _startAutoSync();
  }

  /// 手动同步
  static Future<Result<SyncRecord>> manualSync({
    ConflictResolution conflictResolution = ConflictResolution.askUser,
  }) async {
    if (_currentStatus == SyncStatus.syncing) {
      return const Result.failure('同步正在进行中', null);
    }

    return await _performSync(conflictResolution: conflictResolution);
  }

  /// 执行同步
  static Future<Result<SyncRecord>> _performSync({
    ConflictResolution conflictResolution = ConflictResolution.askUser,
  }) async {
    final syncId = DateTime.now().millisecondsSinceEpoch.toString();
    _updateStatus(SyncStatus.syncing);

    try {
      _logger.info('开始数据同步', {'syncId': syncId});

      // 检查网络连接
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _updateStatus(SyncStatus.failed);
        return const Result.failure('网络连接不可用', null);
      }

      // 获取本地数据
      final localDataResult = await TransactionService.getAllTransactions();
      if (localDataResult.isFailure) {
        _updateStatus(SyncStatus.failed);
        return Result.failure('获取本地数据失败：${localDataResult.error}', 
                             localDataResult.exception);
      }

      final localTransactions = localDataResult.data!;

      // 模拟云端数据获取（实际应用中需要实现云端API）
      final remoteDataResult = await _getRemoteData();
      if (remoteDataResult.isFailure) {
        _updateStatus(SyncStatus.failed);
        return Result.failure('获取云端数据失败：${remoteDataResult.error}', 
                             remoteDataResult.exception);
      }

      final remoteTransactions = remoteDataResult.data!;

      // 比较和合并数据
      final mergeResult = await _mergeData(
        localTransactions,
        remoteTransactions,
        conflictResolution,
      );

      if (mergeResult.isFailure) {
        _updateStatus(SyncStatus.failed);
        return Result.failure('数据合并失败：${mergeResult.error}', 
                             mergeResult.exception);
      }

      final syncRecord = mergeResult.data!;

      // 上传本地更改到云端
      final uploadResult = await _uploadLocalChanges(localTransactions);
      if (uploadResult.isFailure) {
        _logger.warning('上传本地更改失败', {'error': uploadResult.error});
      }

      // 记录同步历史
      await _saveSyncRecord(syncRecord);

      _updateStatus(SyncStatus.success);
      _logger.info('数据同步完成', {
        'syncId': syncId,
        'uploadedCount': syncRecord.uploadedCount,
        'downloadedCount': syncRecord.downloadedCount,
        'conflictCount': syncRecord.conflictCount,
      });

      return Result.success(syncRecord);
    } catch (e, stackTrace) {
      _logger.error('数据同步失败', e, stackTrace);
      _updateStatus(SyncStatus.failed);
      
      final errorRecord = SyncRecord(
        id: syncId,
        timestamp: DateTime.now(),
        status: SyncStatus.failed,
        error: e.toString(),
      );
      
      await _saveSyncRecord(errorRecord);
      
      return Result.failure('同步失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 获取云端数据（模拟实现）
  static Future<Result<List<Transaction>>> _getRemoteData() async {
    try {
      // 这里应该实现实际的云端API调用
      // 暂时返回空数据模拟
      await Future.delayed(const Duration(seconds: 1));
      return const Result.success([]);
    } catch (e) {
      return Result.failure('获取云端数据失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 上传本地更改到云端（模拟实现）
  static Future<Result<int>> _uploadLocalChanges(List<Transaction> transactions) async {
    try {
      // 这里应该实现实际的云端API调用
      // 暂时模拟上传成功
      await Future.delayed(const Duration(seconds: 1));
      return Result.success(transactions.length);
    } catch (e) {
      return Result.failure('上传数据失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 合并本地和云端数据
  static Future<Result<SyncRecord>> _mergeData(
    List<Transaction> localTransactions,
    List<Transaction> remoteTransactions,
    ConflictResolution conflictResolution,
  ) async {
    try {
      final syncId = DateTime.now().millisecondsSinceEpoch.toString();
      int uploadedCount = 0;
      int downloadedCount = 0;
      int conflictCount = 0;

      // 创建本地交易ID映射
      final localMap = <String, Transaction>{};
      for (final transaction in localTransactions) {
        localMap[transaction.id] = transaction;
      }

      // 处理云端数据
      for (final remoteTransaction in remoteTransactions) {
        final localTransaction = localMap[remoteTransaction.id];
        
        if (localTransaction == null) {
          // 云端有，本地没有 - 下载
          final result = await TransactionService.addTransaction(remoteTransaction);
          if (result.isSuccess) {
            downloadedCount++;
          }
        } else {
          // 检查是否有冲突
          if (_hasConflict(localTransaction, remoteTransaction)) {
            conflictCount++;
            
            // 根据冲突解决策略处理
            final resolvedTransaction = await _resolveConflict(
              localTransaction,
              remoteTransaction,
              conflictResolution,
            );
            
            if (resolvedTransaction != null) {
              await TransactionService.updateTransaction(resolvedTransaction);
            }
          }
        }
      }

      // 处理本地独有的数据（需要上传）
      final remoteIds = remoteTransactions.map((t) => t.id).toSet();
      for (final localTransaction in localTransactions) {
        if (!remoteIds.contains(localTransaction.id)) {
          uploadedCount++;
        }
      }

      final syncRecord = SyncRecord(
        id: syncId,
        timestamp: DateTime.now(),
        status: conflictCount > 0 ? SyncStatus.conflict : SyncStatus.success,
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
        conflictCount: conflictCount,
      );

      return Result.success(syncRecord);
    } catch (e, stackTrace) {
      _logger.error('数据合并失败', e, stackTrace);
      return Result.failure('数据合并失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 检查是否有冲突
  static bool _hasConflict(Transaction local, Transaction remote) {
    // 简单的冲突检测：比较修改时间或内容
    return local.title != remote.title ||
           local.amount != remote.amount ||
           local.category != remote.category ||
           local.description != remote.description;
  }

  /// 解决冲突
  static Future<Transaction?> _resolveConflict(
    Transaction local,
    Transaction remote,
    ConflictResolution strategy,
  ) async {
    switch (strategy) {
      case ConflictResolution.keepLocal:
        return local;
      case ConflictResolution.keepRemote:
        return remote;
      case ConflictResolution.merge:
        return _mergeTransactions(local, remote);
      case ConflictResolution.askUser:
        // 这里应该弹出用户选择对话框
        // 暂时默认保留本地
        return local;
    }
  }

  /// 合并交易记录
  static Transaction _mergeTransactions(Transaction local, Transaction remote) {
    // 简单的合并策略：保留本地的主要信息，合并描述
    return Transaction(
      id: local.id,
      title: local.title,
      amount: local.amount,
      category: local.category,
      categoryIcon: local.categoryIcon,
      date: local.date,
      type: local.type,
      description: _mergeDescriptions(local.description, remote.description),
    );
  }

  /// 合并描述
  static String? _mergeDescriptions(String? local, String? remote) {
    if (local == null && remote == null) return null;
    if (local == null) return remote;
    if (remote == null) return local;
    if (local == remote) return local;
    
    return '$local\n[云端备注] $remote';
  }

  /// 启动自动同步
  static Future<void> _startAutoSync() async {
    if (_isAutoSyncEnabled) return;
    
    _isAutoSyncEnabled = true;
    _autoSyncTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _performAutoSync();
    });
    
    _logger.info('自动同步已启动');
  }

  /// 停止自动同步
  static void stopAutoSync() {
    _isAutoSyncEnabled = false;
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    _logger.info('自动同步已停止');
  }

  /// 执行自动同步
  static Future<void> _performAutoSync() async {
    if (_currentStatus == SyncStatus.syncing) return;
    
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) return;
      
      _logger.info('执行自动同步');
      await _performSync(conflictResolution: ConflictResolution.keepLocal);
    } catch (e) {
      _logger.warning('自动同步失败', {'error': e.toString()});
    }
  }

  /// 网络状态变化处理
  static void _onConnectivityChanged(ConnectivityResult result) {
    _logger.info('网络状态变化', {'connectivity': result.toString()});
    
    if (result != ConnectivityResult.none && _isAutoSyncEnabled) {
      // 网络恢复时执行同步
      Timer(const Duration(seconds: 5), () {
        _performAutoSync();
      });
    }
  }

  /// 更新同步状态
  static void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  /// 保存同步记录
  static Future<void> _saveSyncRecord(SyncRecord record) async {
    try {
      // 这里应该将同步记录保存到本地存储
      _logger.info('保存同步记录', record.toJson());
    } catch (e) {
      _logger.warning('保存同步记录失败', {'error': e.toString()});
    }
  }

  /// 获取同步历史
  static Future<Result<List<SyncRecord>>> getSyncHistory({int limit = 50}) async {
    try {
      // 这里应该从本地存储读取同步历史
      // 暂时返回空列表
      return const Result.success([]);
    } catch (e, stackTrace) {
      _logger.error('获取同步历史失败', e, stackTrace);
      return Result.failure('获取同步历史失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 清除同步历史
  static Future<Result<void>> clearSyncHistory() async {
    try {
      // 这里应该清除本地存储的同步历史
      _logger.info('清除同步历史');
      return const Result.success(null);
    } catch (e, stackTrace) {
      _logger.error('清除同步历史失败', e, stackTrace);
      return Result.failure('清除同步历史失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 检查是否需要同步
  static Future<bool> needsSync() async {
    try {
      // 检查本地是否有未同步的更改
      // 这里应该实现实际的检查逻辑
      return false;
    } catch (e) {
      _logger.warning('检查同步状态失败', {'error': e.toString()});
      return false;
    }
  }

  /// 强制同步
  static Future<Result<SyncRecord>> forceSync() async {
    _logger.info('强制同步');
    return await _performSync(conflictResolution: ConflictResolution.keepLocal);
  }

  /// 销毁同步服务
  static void dispose() {
    stopAutoSync();
    _statusController.close();
    _logger.info('同步服务已销毁');
  }
}

/// 离线数据管理器
class OfflineDataManager {
  static final AppLogger _logger = AppLogger('OfflineDataManager');
  
  /// 缓存离线操作
  static Future<Result<void>> cacheOfflineOperation({
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger.info('缓存离线操作', {'operation': operation});
      
      // 这里应该将离线操作保存到本地队列
      // 等网络恢复时执行
      
      return const Result.success(null);
    } catch (e, stackTrace) {
      _logger.error('缓存离线操作失败', e, stackTrace);
      return Result.failure('缓存操作失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 执行离线操作队列
  static Future<Result<int>> executeOfflineQueue() async {
    try {
      _logger.info('执行离线操作队列');
      
      // 这里应该执行所有缓存的离线操作
      int executedCount = 0;
      
      return Result.success(executedCount);
    } catch (e, stackTrace) {
      _logger.error('执行离线操作队列失败', e, stackTrace);
      return Result.failure('执行离线操作失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 清空离线操作队列
  static Future<Result<void>> clearOfflineQueue() async {
    try {
      _logger.info('清空离线操作队列');
      return const Result.success(null);
    } catch (e, stackTrace) {
      _logger.error('清空离线操作队列失败', e, stackTrace);
      return Result.failure('清空队列失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 获取离线操作数量
  static Future<int> getOfflineOperationCount() async {
    try {
      // 这里应该返回实际的离线操作数量
      return 0;
    } catch (e) {
      _logger.warning('获取离线操作数量失败', {'error': e.toString()});
      return 0;
    }
  }
}