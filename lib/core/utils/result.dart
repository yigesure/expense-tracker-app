/// 统一的结果封装类，用于处理成功/失败状态
sealed class Result<T> {
  const Result();
  
  /// 创建成功结果
  const factory Result.success(T data) = Success<T>;
  
  /// 创建失败结果
  const factory Result.failure(String message, [Exception? exception]) = Failure<T>;
  
  /// 判断是否成功
  bool get isSuccess => this is Success<T>;
  
  /// 判断是否失败
  bool get isFailure => this is Failure<T>;
  
  /// 获取数据（仅在成功时）
  T? get data => switch (this) {
    Success<T> success => success.data,
    Failure<T> _ => null,
  };
  
  /// 获取错误信息（仅在失败时）
  String? get error => switch (this) {
    Success<T> _ => null,
    Failure<T> failure => failure.message,
  };
  
  /// 获取异常（仅在失败时）
  Exception? get exception => switch (this) {
    Success<T> _ => null,
    Failure<T> failure => failure.exception,
  };
  
  /// 转换数据类型
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T> success => Result.success(transform(success.data)),
      Failure<T> failure => Result.failure(failure.message, failure.exception),
    };
  }
  
  /// 异步转换数据类型
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    return switch (this) {
      Success<T> success => {
        try {
          final result = await transform(success.data);
          Result.success(result)
        } catch (e) {
          Result.failure('转换失败: $e', e is Exception ? e : Exception(e.toString()))
        }
      },
      Failure<T> failure => Result.failure(failure.message, failure.exception),
    };
  }
  
  /// 链式操作
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return switch (this) {
      Success<T> success => transform(success.data),
      Failure<T> failure => Result.failure(failure.message, failure.exception),
    };
  }
  
  /// 处理结果
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Exception? exception) failure,
  }) {
    return switch (this) {
      Success<T> s => success(s.data),
      Failure<T> f => failure(f.message, f.exception),
    };
  }
}

/// 成功结果
final class Success<T> extends Result<T> {
  const Success(this.data);
  
  final T data;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> && runtimeType == other.runtimeType && data == other.data;
  
  @override
  int get hashCode => data.hashCode;
  
  @override
  String toString() => 'Success($data)';
}

/// 失败结果
final class Failure<T> extends Result<T> {
  const Failure(this.message, [this.exception]);
  
  final String message;
  final Exception? exception;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          exception == other.exception;
  
  @override
  int get hashCode => Object.hash(message, exception);
  
  @override
  String toString() => 'Failure($message${exception != null ? ', $exception' : ''})';
}