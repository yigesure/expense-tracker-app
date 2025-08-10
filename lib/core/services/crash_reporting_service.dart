import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/logger.dart';
import '../exceptions/app_exceptions.dart';

/// 崩溃报告服务
/// 负责捕获和报告应用崩溃、异常和错误
class CrashReportingService {
  static final AppLogger _logger = AppLogger('CrashReportingService');
  static bool _isInitialized = false;
  static final List<CrashReport> _crashReports = [];
  static const int _maxReports = 100;

  /// 初始化崩溃报告服务
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 设置Flutter错误处理器
      FlutterError.onError = _handleFlutterError;

      // 设置平台调度器错误处理器
      PlatformDispatcher.instance.onError = _handlePlatformError;

      // 设置Zone错误处理器
      runZonedGuarded(
        () {
          // 应用启动代码将在这个Zone中运行
        },
        _handleZoneError,
      );

      _isInitialized = true;
      _logger.info('崩溃报告服务初始化成功');
    } catch (e, stackTrace) {
      _logger.error('崩溃报告服务初始化失败', e, stackTrace);
    }
  }

  /// 处理Flutter框架错误
  static void _handleFlutterError(FlutterErrorDetails details) {
    _logger.error(
      'Flutter错误: ${details.exception}',
      details.exception,
      details.stack,
    );

    final crashReport = CrashReport(
      type: CrashType.flutter,
      exception: details.exception,
      stackTrace: details.stack,
      context: details.context?.toString(),
      library: details.library,
      timestamp: DateTime.now(),
    );

    _recordCrashReport(crashReport);

    // 在调试模式下显示红屏
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }

  /// 处理平台错误
  static bool _handlePlatformError(Object error, StackTrace stackTrace) {
    _logger.error('平台错误: $error', error, stackTrace);

    final crashReport = CrashReport(
      type: CrashType.platform,
      exception: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );

    _recordCrashReport(crashReport);
    return true; // 表示错误已被处理
  }

  /// 处理Zone错误
  static void _handleZoneError(Object error, StackTrace stackTrace) {
    _logger.error('Zone错误: $error', error, stackTrace);

    final crashReport = CrashReport(
      type: CrashType.zone,
      exception: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );

    _recordCrashReport(crashReport);
  }

  /// 手动记录异常
  static void recordException(
    Object exception, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
    bool isFatal = false,
  }) {
    _logger.error(
      '手动记录异常: $exception',
      exception,
      stackTrace,
      additionalData,
    );

    final crashReport = CrashReport(
      type: isFatal ? CrashType.fatal : CrashType.handled,
      exception: exception,
      stackTrace: stackTrace,
      context: context,
      additionalData: additionalData,
      timestamp: DateTime.now(),
    );

    _recordCrashReport(crashReport);
  }

  /// 记录崩溃报告
  static void _recordCrashReport(CrashReport report) {
    _crashReports.add(report);

    // 保持报告数量在限制内
    if (_crashReports.length > _maxReports) {
      _crashReports.removeAt(0);
    }

    // 在生产环境中，这里可以发送到崩溃报告服务
    if (kReleaseMode) {
      _sendCrashReport(report);
    }
  }

  /// 发送崩溃报告到远程服务
  static Future<void> _sendCrashReport(CrashReport report) async {
    try {
      // 这里可以集成第三方崩溃报告服务
      // 例如：Firebase Crashlytics, Sentry, Bugsnag等
      
      final reportData = {
        'type': report.type.name,
        'exception': report.exception.toString(),
        'stackTrace': report.stackTrace.toString(),
        'context': report.context,
        'library': report.library,
        'timestamp': report.timestamp.toIso8601String(),
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'additionalData': report.additionalData,
      };

      _logger.info('发送崩溃报告', reportData);
      
      // TODO: 实际发送到崩溃报告服务
      // await crashReportingAPI.send(reportData);
      
    } catch (e, stackTrace) {
      _logger.error('发送崩溃报告失败', e, stackTrace);
    }
  }

  /// 获取所有崩溃报告
  static List<CrashReport> getCrashReports() {
    return List.unmodifiable(_crashReports);
  }

  /// 获取最近的崩溃报告
  static List<CrashReport> getRecentCrashReports({int limit = 10}) {
    final reports = _crashReports.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return reports.take(limit).toList();
  }

  /// 清除所有崩溃报告
  static void clearCrashReports() {
    _crashReports.clear();
    _logger.info('已清除所有崩溃报告');
  }

  /// 获取崩溃统计信息
  static CrashStatistics getCrashStatistics() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final last7Days = now.subtract(const Duration(days: 7));

    final last24HoursReports = _crashReports
        .where((report) => report.timestamp.isAfter(last24Hours))
        .toList();

    final last7DaysReports = _crashReports
        .where((report) => report.timestamp.isAfter(last7Days))
        .toList();

    final typeCount = <CrashType, int>{};
    for (final report in _crashReports) {
      typeCount[report.type] = (typeCount[report.type] ?? 0) + 1;
    }

    return CrashStatistics(
      totalCrashes: _crashReports.length,
      crashesLast24Hours: last24HoursReports.length,
      crashesLast7Days: last7DaysReports.length,
      crashesByType: typeCount,
      mostRecentCrash: _crashReports.isNotEmpty 
          ? _crashReports.last.timestamp 
          : null,
    );
  }

  /// 生成崩溃报告摘要
  static String generateCrashSummary() {
    final stats = getCrashStatistics();
    final buffer = StringBuffer();

    buffer.writeln('=== 崩溃报告摘要 ===');
    buffer.writeln('总崩溃次数: ${stats.totalCrashes}');
    buffer.writeln('最近24小时: ${stats.crashesLast24Hours}');
    buffer.writeln('最近7天: ${stats.crashesLast7Days}');
    
    if (stats.mostRecentCrash != null) {
      buffer.writeln('最近崩溃时间: ${stats.mostRecentCrash}');
    }

    buffer.writeln('\n按类型统计:');
    stats.crashesByType.forEach((type, count) {
      buffer.writeln('  ${type.name}: $count');
    });

    if (_crashReports.isNotEmpty) {
      buffer.writeln('\n最近崩溃详情:');
      final recentReports = getRecentCrashReports(limit: 5);
      for (int i = 0; i < recentReports.length; i++) {
        final report = recentReports[i];
        buffer.writeln('${i + 1}. [${report.type.name}] ${report.exception}');
        buffer.writeln('   时间: ${report.timestamp}');
        if (report.context != null) {
          buffer.writeln('   上下文: ${report.context}');
        }
        buffer.writeln();
      }
    }

    return buffer.toString();
  }
}

/// 崩溃报告类型
enum CrashType {
  flutter,    // Flutter框架错误
  platform,   // 平台错误
  zone,       // Zone错误
  handled,    // 已处理异常
  fatal,      // 致命错误
}

/// 崩溃报告数据类
class CrashReport {
  final CrashType type;
  final Object exception;
  final StackTrace? stackTrace;
  final String? context;
  final String? library;
  final DateTime timestamp;
  final Map<String, dynamic>? additionalData;

  const CrashReport({
    required this.type,
    required this.exception,
    this.stackTrace,
    this.context,
    this.library,
    required this.timestamp,
    this.additionalData,
  });

  @override
  String toString() {
    return 'CrashReport(type: $type, exception: $exception, timestamp: $timestamp)';
  }
}

/// 崩溃统计信息
class CrashStatistics {
  final int totalCrashes;
  final int crashesLast24Hours;
  final int crashesLast7Days;
  final Map<CrashType, int> crashesByType;
  final DateTime? mostRecentCrash;

  const CrashStatistics({
    required this.totalCrashes,
    required this.crashesLast24Hours,
    required this.crashesLast7Days,
    required this.crashesByType,
    this.mostRecentCrash,
  });
}

/// 全局异常处理装饰器
class ExceptionHandler {
  /// 安全执行异步操作
  static Future<T?> safeAsync<T>(
    Future<T> Function() operation, {
    String? context,
    T? fallback,
    bool logError = true,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      if (logError) {
        CrashReportingService.recordException(
          e,
          stackTrace: stackTrace,
          context: context,
        );
      }
      return fallback;
    }
  }

  /// 安全执行同步操作
  static T? safeSync<T>(
    T Function() operation, {
    String? context,
    T? fallback,
    bool logError = true,
  }) {
    try {
      return operation();
    } catch (e, stackTrace) {
      if (logError) {
        CrashReportingService.recordException(
          e,
          stackTrace: stackTrace,
          context: context,
        );
      }
      return fallback;
    }
  }

  /// 安全执行Widget构建
  static Widget safeWidget(
    Widget Function() builder, {
    Widget? fallback,
    String? context,
  }) {
    try {
      return builder();
    } catch (e, stackTrace) {
      CrashReportingService.recordException(
        e,
        stackTrace: stackTrace,
        context: context ?? 'Widget构建',
      );
      
      return fallback ?? const _ErrorWidget();
    }
  }
}

/// 错误显示Widget
class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            '出现了一些问题',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '我们正在努力修复这个问题',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}