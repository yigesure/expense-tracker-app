import 'dart:developer' as developer;

/// 统一的日志记录器
class AppLogger {
  static const String _name = 'ExpenseTracker';
  
  /// 调试日志
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 500, // DEBUG
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// 信息日志
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 800, // INFO
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// 警告日志
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 900, // WARNING
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// 错误日志
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 1000, // SEVERE
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// 记录操作开始
  static void logOperationStart(String operation, [Map<String, dynamic>? params]) {
    debug('开始执行: $operation${params != null ? ' 参数: $params' : ''}');
  }
  
  /// 记录操作成功
  static void logOperationSuccess(String operation, [dynamic result]) {
    info('操作成功: $operation${result != null ? ' 结果: $result' : ''}');
  }
  
  /// 记录操作失败
  static void logOperationFailure(String operation, String error, [Exception? exception]) {
    AppLogger.error('操作失败: $operation - $error', exception);
  }
}