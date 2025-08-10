/// 应用基础异常类
abstract class AppException implements Exception {
  const AppException(this.message, [this.code]);
  
  final String message;
  final String? code;
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// 数据库异常
class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.code]);
}

/// 验证异常
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

/// 网络异常
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// 业务逻辑异常
class BusinessException extends AppException {
  const BusinessException(super.message, [super.code]);
}

/// 未找到异常
class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.code]);
}

/// 权限异常
class PermissionException extends AppException {
  const PermissionException(super.message, [super.code]);
}

/// 异常处理工具类
class ExceptionHandler {
  /// 将异常转换为用户友好的错误信息
  static String getErrorMessage(Exception exception) {
    return switch (exception) {
      DatabaseException e => '数据存储错误: ${e.message}',
      ValidationException e => '输入验证错误: ${e.message}',
      NetworkException e => '网络连接错误: ${e.message}',
      BusinessException e => '业务处理错误: ${e.message}',
      NotFoundException e => '未找到相关数据: ${e.message}',
      PermissionException e => '权限不足: ${e.message}',
      AppException e => '应用错误: ${e.message}',
      _ => '未知错误: ${exception.toString()}',
    };
  }
  
  /// 判断是否为用户可操作的错误
  static bool isUserActionable(Exception exception) {
    return switch (exception) {
      ValidationException _ => true,
      NetworkException _ => true,
      PermissionException _ => true,
      _ => false,
    };
  }
  
  /// 判断是否需要重试
  static bool shouldRetry(Exception exception) {
    return switch (exception) {
      NetworkException _ => true,
      DatabaseException _ => true,
      _ => false,
    };
  }
}