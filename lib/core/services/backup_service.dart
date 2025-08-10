import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/transaction.dart';
import '../utils/result.dart';
import '../utils/logger.dart';
import '../exceptions/app_exceptions.dart';
import 'transaction_service.dart';

/// 备份数据结构
class BackupData {
  final String version;
  final DateTime backupTime;
  final List<Transaction> transactions;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> metadata;

  BackupData({
    required this.version,
    required this.backupTime,
    required this.transactions,
    required this.settings,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'backupTime': backupTime.toIso8601String(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'settings': settings,
      'metadata': metadata,
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      version: json['version'] ?? '1.0.0',
      backupTime: DateTime.parse(json['backupTime']),
      transactions: (json['transactions'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList(),
      settings: json['settings'] ?? {},
      metadata: json['metadata'] ?? {},
    );
  }
}

/// 备份服务
/// 提供数据备份、恢复和同步功能
class BackupService {
  static final AppLogger _logger = AppLogger('BackupService');
  static const String _currentVersion = '1.0.0';

  /// 创建完整备份
  static Future<Result<String>> createFullBackup({
    String? fileName,
    bool includeSettings = true,
  }) async {
    try {
      _logger.info('开始创建完整备份', {'includeSettings': includeSettings});

      // 获取所有交易数据
      final transactionsResult = await TransactionService.getAllTransactions();
      if (transactionsResult.isFailure) {
        return Result.failure('获取交易数据失败：${transactionsResult.error}', 
                             transactionsResult.exception);
      }

      final transactions = transactionsResult.data!;

      // 获取设置数据
      final settings = includeSettings ? await _getSettingsData() : <String, dynamic>{};

      // 创建备份数据
      final backupData = BackupData(
        version: _currentVersion,
        backupTime: DateTime.now(),
        transactions: transactions,
        settings: settings,
        metadata: {
          'deviceInfo': await _getDeviceInfo(),
          'appVersion': _currentVersion,
          'transactionCount': transactions.length,
        },
      );

      // 生成备份文件
      final actualFileName = fileName ?? _generateBackupFileName();
      final filePath = await _saveBackupFile(backupData, actualFileName);

      _logger.info('备份创建完成', {
        'filePath': filePath,
        'transactionCount': transactions.length,
      });

      return Result.success(filePath);
    } catch (e, stackTrace) {
      _logger.error('创建备份失败', e, stackTrace);
      return Result.failure('创建备份失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 恢复备份数据
  static Future<Result<BackupRestoreResult>> restoreFromBackup(String filePath) async {
    try {
      _logger.info('开始恢复备份', {'filePath': filePath});

      final file = File(filePath);
      if (!await file.exists()) {
        return const Result.failure('备份文件不存在', null);
      }

      // 读取备份文件
      final jsonString = await file.readAsString(encoding: utf8);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // 验证备份文件格式
      final validationResult = _validateBackupData(jsonData);
      if (validationResult.isFailure) {
        return Result.failure(validationResult.error!, validationResult.exception);
      }

      final backupData = BackupData.fromJson(jsonData);

      // 检查版本兼容性
      final compatibilityResult = _checkVersionCompatibility(backupData.version);
      if (compatibilityResult.isFailure) {
        return Result.failure(compatibilityResult.error!, compatibilityResult.exception);
      }

      // 创建当前数据备份（用于回滚）
      final rollbackBackupResult = await createFullBackup(
        fileName: 'rollback_${_generateBackupFileName()}',
      );

      // 清空现有数据
      await _clearAllData();

      // 恢复交易数据
      int restoredCount = 0;
      int failedCount = 0;
      
      for (final transaction in backupData.transactions) {
        final result = await TransactionService.addTransaction(transaction);
        if (result.isSuccess) {
          restoredCount++;
        } else {
          failedCount++;
          _logger.warning('恢复交易失败', {
            'transactionId': transaction.id,
            'error': result.error,
          });
        }
      }

      // 恢复设置数据
      if (backupData.settings.isNotEmpty) {
        await _restoreSettingsData(backupData.settings);
      }

      final restoreResult = BackupRestoreResult(
        totalTransactions: backupData.transactions.length,
        restoredTransactions: restoredCount,
        failedTransactions: failedCount,
        backupTime: backupData.backupTime,
        rollbackBackupPath: rollbackBackupResult.isSuccess ? rollbackBackupResult.data : null,
      );

      _logger.info('备份恢复完成', {
        'totalTransactions': restoreResult.totalTransactions,
        'restoredTransactions': restoreResult.restoredTransactions,
        'failedTransactions': restoreResult.failedTransactions,
      });

      return Result.success(restoreResult);
    } catch (e, stackTrace) {
      _logger.error('恢复备份失败', e, stackTrace);
      return Result.failure('恢复备份失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 从文件选择器恢复备份
  static Future<Result<BackupRestoreResult>> restoreFromFilePicker() async {
    try {
      _logger.info('从文件选择器恢复备份');

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'backup'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return const Result.failure('未选择文件', null);
      }

      final file = result.files.first;
      if (file.path == null) {
        return const Result.failure('文件路径无效', null);
      }

      return await restoreFromBackup(file.path!);
    } catch (e, stackTrace) {
      _logger.error('从文件选择器恢复备份失败', e, stackTrace);
      return Result.failure('恢复失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 分享备份文件
  static Future<Result<void>> shareBackup(String filePath) async {
    try {
      _logger.info('分享备份文件', {'filePath': filePath});

      final file = File(filePath);
      if (!await file.exists()) {
        return const Result.failure('备份文件不存在', null);
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        text: '我的记账数据备份',
        subject: '记账数据备份分享',
      );

      return const Result.success(null);
    } catch (e, stackTrace) {
      _logger.error('分享备份文件失败', e, stackTrace);
      return Result.failure('分享失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 获取备份列表
  static Future<Result<List<BackupInfo>>> getBackupList() async {
    try {
      final backupDir = Directory(await getBackupDirectory());
      if (!await backupDir.exists()) {
        return const Result.success([]);
      }

      final files = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.backup'))
          .cast<File>()
          .toList();

      final backupInfos = <BackupInfo>[];
      for (final file in files) {
        try {
          final info = await _getBackupInfo(file);
          if (info != null) {
            backupInfos.add(info);
          }
        } catch (e) {
          _logger.warning('读取备份信息失败', {'filePath': file.path, 'error': e.toString()});
        }
      }

      // 按时间倒序排列
      backupInfos.sort((a, b) => b.backupTime.compareTo(a.backupTime));

      return Result.success(backupInfos);
    } catch (e, stackTrace) {
      _logger.error('获取备份列表失败', e, stackTrace);
      return Result.failure('获取备份列表失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 删除备份文件
  static Future<Result<void>> deleteBackup(String filePath) async {
    try {
      _logger.info('删除备份文件', {'filePath': filePath});

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      return const Result.success(null);
    } catch (e, stackTrace) {
      _logger.error('删除备份文件失败', e, stackTrace);
      return Result.failure('删除失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 自动备份
  static Future<Result<String>> autoBackup() async {
    try {
      _logger.info('执行自动备份');

      // 检查是否需要自动备份
      final shouldBackup = await _shouldPerformAutoBackup();
      if (!shouldBackup) {
        return const Result.failure('暂不需要自动备份', null);
      }

      // 创建自动备份
      final fileName = 'auto_${_generateBackupFileName()}';
      final result = await createFullBackup(fileName: fileName);

      if (result.isSuccess) {
        // 更新最后备份时间
        await _updateLastBackupTime();
        
        // 清理旧的自动备份
        await _cleanupOldAutoBackups();
      }

      return result;
    } catch (e, stackTrace) {
      _logger.error('自动备份失败', e, stackTrace);
      return Result.failure('自动备份失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 验证备份数据
  static Result<void> _validateBackupData(Map<String, dynamic> jsonData) {
    try {
      // 检查必需字段
      if (!jsonData.containsKey('version')) {
        return const Result.failure('备份文件缺少版本信息', null);
      }

      if (!jsonData.containsKey('backupTime')) {
        return const Result.failure('备份文件缺少备份时间', null);
      }

      if (!jsonData.containsKey('transactions')) {
        return const Result.failure('备份文件缺少交易数据', null);
      }

      // 验证交易数据格式
      final transactions = jsonData['transactions'];
      if (transactions is! List) {
        return const Result.failure('交易数据格式错误', null);
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failure('备份文件格式验证失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 检查版本兼容性
  static Result<void> _checkVersionCompatibility(String backupVersion) {
    // 简单的版本兼容性检查
    final supportedVersions = ['1.0.0'];
    
    if (!supportedVersions.contains(backupVersion)) {
      return Result.failure('不支持的备份版本：$backupVersion', null);
    }

    return const Result.success(null);
  }

  /// 保存备份文件
  static Future<String> _saveBackupFile(BackupData backupData, String fileName) async {
    final directory = await getBackupDirectory();
    final file = File('$directory/$fileName');

    final jsonString = const JsonEncoder.withIndent('  ').convert(backupData.toJson());
    await file.writeAsString(jsonString, encoding: utf8);

    return file.path;
  }

  /// 获取设置数据
  static Future<Map<String, dynamic>> _getSettingsData() async {
    // 这里应该从实际的设置存储中获取数据
    // 暂时返回空数据
    return {};
  }

  /// 恢复设置数据
  static Future<void> _restoreSettingsData(Map<String, dynamic> settings) async {
    // 这里应该将设置数据恢复到实际的设置存储中
    _logger.info('恢复设置数据', {'settingsCount': settings.length});
  }

  /// 清空所有数据
  static Future<void> _clearAllData() async {
    // 清空交易数据
    final transactions = await TransactionService.getAllTransactions();
    if (transactions.isSuccess) {
      for (final transaction in transactions.data!) {
        await TransactionService.deleteTransaction(transaction.id);
      }
    }
  }

  /// 获取设备信息
  static Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
    };
  }

  /// 生成备份文件名
  static String _generateBackupFileName() {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    return 'backup_${dateStr}_$timeStr.backup';
  }

  /// 获取备份目录
  static Future<String> getBackupDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir.path;
  }

  /// 获取备份信息
  static Future<BackupInfo?> _getBackupInfo(File file) async {
    try {
      final jsonString = await file.readAsString(encoding: utf8);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return BackupInfo(
        filePath: file.path,
        fileName: file.path.split('/').last,
        backupTime: DateTime.parse(jsonData['backupTime']),
        version: jsonData['version'] ?? 'unknown',
        transactionCount: (jsonData['transactions'] as List?)?.length ?? 0,
        fileSize: await file.length(),
      );
    } catch (e) {
      return null;
    }
  }

  /// 是否应该执行自动备份
  static Future<bool> _shouldPerformAutoBackup() async {
    // 这里应该检查上次备份时间和设置的备份频率
    // 暂时返回true
    return true;
  }

  /// 更新最后备份时间
  static Future<void> _updateLastBackupTime() async {
    // 这里应该保存最后备份时间到设置中
    _logger.info('更新最后备份时间');
  }

  /// 清理旧的自动备份
  static Future<void> _cleanupOldAutoBackups() async {
    try {
      final backupDir = Directory(await getBackupDirectory());
      if (!await backupDir.exists()) return;

      final files = await backupDir
          .list()
          .where((entity) => entity is File && 
                 entity.path.contains('auto_') && 
                 entity.path.endsWith('.backup'))
          .cast<File>()
          .toList();

      // 保留最近的5个自动备份
      if (files.length > 5) {
        files.sort((a, b) => b.path.compareTo(a.path));
        for (int i = 5; i < files.length; i++) {
          await files[i].delete();
          _logger.info('删除旧的自动备份', {'filePath': files[i].path});
        }
      }
    } catch (e) {
      _logger.warning('清理旧备份失败', {'error': e.toString()});
    }
  }
}

/// 备份恢复结果
class BackupRestoreResult {
  final int totalTransactions;
  final int restoredTransactions;
  final int failedTransactions;
  final DateTime backupTime;
  final String? rollbackBackupPath;

  BackupRestoreResult({
    required this.totalTransactions,
    required this.restoredTransactions,
    required this.failedTransactions,
    required this.backupTime,
    this.rollbackBackupPath,
  });

  bool get isFullySuccessful => failedTransactions == 0;
  bool get hasFailures => failedTransactions > 0;
  double get successRate => totalTransactions > 0 ? restoredTransactions / totalTransactions : 0.0;
}

/// 备份信息
class BackupInfo {
  final String filePath;
  final String fileName;
  final DateTime backupTime;
  final String version;
  final int transactionCount;
  final int fileSize;

  BackupInfo({
    required this.filePath,
    required this.fileName,
    required this.backupTime,
    required this.version,
    required this.transactionCount,
    required this.fileSize,
  });

  String get formattedFileSize {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  String get formattedBackupTime {
    final now = DateTime.now();
    final difference = now.difference(backupTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}