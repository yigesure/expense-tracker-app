import 'dart:async';

/// 防抖动工具类，用于优化频繁的异步操作
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  /// 执行防抖动操作
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// 取消当前的防抖动操作
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// 释放资源
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// 节流器，用于限制操作频率
class Throttler {
  final Duration duration;
  DateTime? _lastExecuted;

  Throttler({required this.duration});

  /// 执行节流操作
  bool canExecute() {
    final now = DateTime.now();
    if (_lastExecuted == null || now.difference(_lastExecuted!) >= duration) {
      _lastExecuted = now;
      return true;
    }
    return false;
  }

  /// 重置节流器
  void reset() {
    _lastExecuted = null;
  }
}

/// 异步防抖动器，用于异步操作
class AsyncDebouncer<T> {
  final Duration delay;
  Timer? _timer;
  Completer<T>? _completer;

  AsyncDebouncer({required this.delay});

  /// 执行异步防抖动操作
  Future<T> run(Future<T> Function() action) {
    _timer?.cancel();
    _completer?.complete(null as T);
    
    _completer = Completer<T>();
    
    _timer = Timer(delay, () async {
      try {
        final result = await action();
        if (!_completer!.isCompleted) {
          _completer!.complete(result);
        }
      } catch (error) {
        if (!_completer!.isCompleted) {
          _completer!.completeError(error);
        }
      }
    });

    return _completer!.future;
  }

  /// 取消当前操作
  void cancel() {
    _timer?.cancel();
    _timer = null;
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError('Operation cancelled');
    }
    _completer = null;
  }

  /// 释放资源
  void dispose() {
    cancel();
  }
}

/// 批处理器，用于批量处理操作
class BatchProcessor<T> {
  final Duration batchDelay;
  final int maxBatchSize;
  final Future<void> Function(List<T>) processor;
  
  final List<T> _batch = [];
  Timer? _timer;

  BatchProcessor({
    required this.batchDelay,
    required this.maxBatchSize,
    required this.processor,
  });

  /// 添加项目到批处理
  void add(T item) {
    _batch.add(item);
    
    // 如果达到最大批处理大小，立即处理
    if (_batch.length >= maxBatchSize) {
      _processBatch();
      return;
    }
    
    // 否则启动或重置定时器
    _timer?.cancel();
    _timer = Timer(batchDelay, _processBatch);
  }

  /// 立即处理当前批次
  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;
    await _processBatch();
  }

  /// 处理批次
  Future<void> _processBatch() async {
    if (_batch.isEmpty) return;
    
    final currentBatch = List<T>.from(_batch);
    _batch.clear();
    _timer = null;
    
    try {
      await processor(currentBatch);
    } catch (e) {
      // 处理错误，可以根据需要重新添加到批次或记录日志
      rethrow;
    }
  }

  /// 释放资源
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _batch.clear();
  }
}