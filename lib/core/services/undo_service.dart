import '../models/transaction.dart';
import '../utils/logger.dart';
import '../utils/result.dart';
import 'transaction_service.dart';

/// 撤销操作类型
enum UndoActionType {
  add,
  update,
  delete,
}

/// 撤销操作数据
class UndoAction {
  final String id;
  final UndoActionType type;
  final Transaction? transaction;
  final Transaction? previousTransaction;
  final DateTime timestamp;

  UndoAction({
    required this.id,
    required this.type,
    this.transaction,
    this.previousTransaction,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    switch (type) {
      case UndoActionType.add:
        return '添加了 ${transaction?.title}';
      case UndoActionType.update:
        return '修改了 ${transaction?.title}';
      case UndoActionType.delete:
        return '删除了 ${transaction?.title}';
    }
  }
}

/// 撤销服务
/// 提供操作撤销和重做功能
class UndoService {
  static final UndoService _instance = UndoService._internal();
  factory UndoService() => _instance;
  UndoService._internal();

  static final AppLogger _logger = AppLogger('UndoService');
  
  final List<UndoAction> _undoStack = [];
  final List<UndoAction> _redoStack = [];
  static const int _maxStackSize = 50;

  /// 是否可以撤销
  bool get canUndo => _undoStack.isNotEmpty;

  /// 是否可以重做
  bool get canRedo => _redoStack.isNotEmpty;

  /// 获取最后一个操作的描述
  String? get lastActionDescription => 
      _undoStack.isNotEmpty ? _undoStack.last.toString() : null;

  /// 记录添加操作
  void recordAdd(Transaction transaction) {
    final action = UndoAction(
      id: transaction.id,
      type: UndoActionType.add,
      transaction: transaction,
    );
    _addToUndoStack(action);
    _logger.info('记录添加操作', {'transaction': transaction.title});
  }

  /// 记录更新操作
  void recordUpdate(Transaction newTransaction, Transaction oldTransaction) {
    final action = UndoAction(
      id: newTransaction.id,
      type: UndoActionType.update,
      transaction: newTransaction,
      previousTransaction: oldTransaction,
    );
    _addToUndoStack(action);
    _logger.info('记录更新操作', {'transaction': newTransaction.title});
  }

  /// 记录删除操作
  void recordDelete(Transaction transaction) {
    final action = UndoAction(
      id: transaction.id,
      type: UndoActionType.delete,
      transaction: transaction,
    );
    _addToUndoStack(action);
    _logger.info('记录删除操作', {'transaction': transaction.title});
  }

  /// 撤销操作
  Future<Result<String>> undo() async {
    if (!canUndo) {
      return const Result.failure('没有可撤销的操作', null);
    }

    final action = _undoStack.removeLast();
    _redoStack.add(action);

    try {
      switch (action.type) {
        case UndoActionType.add:
          // 撤销添加 = 删除
          final result = await TransactionService.deleteTransaction(action.id);
          if (result.isSuccess) {
            _logger.info('撤销添加操作成功', {'id': action.id});
            return Result.success('已撤销添加 ${action.transaction?.title}');
          } else {
            return Result.failure('撤销失败：${result.error}', result.exception);
          }

        case UndoActionType.update:
          // 撤销更新 = 恢复到之前的状态
          if (action.previousTransaction != null) {
            final result = await TransactionService.updateTransaction(action.previousTransaction!);
            if (result.isSuccess) {
              _logger.info('撤销更新操作成功', {'id': action.id});
              return Result.success('已撤销修改 ${action.transaction?.title}');
            } else {
              return Result.failure('撤销失败：${result.error}', result.exception);
            }
          } else {
            return const Result.failure('撤销失败：缺少原始数据', null);
          }

        case UndoActionType.delete:
          // 撤销删除 = 重新添加
          if (action.transaction != null) {
            final result = await TransactionService.addTransaction(action.transaction!);
            if (result.isSuccess) {
              _logger.info('撤销删除操作成功', {'id': action.id});
              return Result.success('已撤销删除 ${action.transaction?.title}');
            } else {
              return Result.failure('撤销失败：${result.error}', result.exception);
            }
          } else {
            return const Result.failure('撤销失败：缺少交易数据', null);
          }
      }
    } catch (e, stackTrace) {
      _logger.error('撤销操作异常', e, stackTrace);
      // 撤销失败，需要恢复栈状态
      _redoStack.removeLast();
      _undoStack.add(action);
      return Result.failure('撤销失败：${e.toString()}', e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 重做操作
  Future<Result<String>> redo() async {
    if (!canRedo) {
      return const Result.failure('没有可重做的操作', null);
    }

    final action = _redoStack.removeLast();
    _undoStack.add(action);

    try {
      switch (action.type) {
        case UndoActionType.add:
          // 重做添加
          if (action.transaction != null) {
            final result = await TransactionService.addTransaction(action.transaction!);
            if (result.isSuccess) {
              _logger.info('重做添加操作成功', {'id': action.id});
              return Result.success('已重做添加 ${action.transaction?.title}');
            } else {
              return Result.failure('重做失败：${result.error}', result.exception);
            }
          } else {
            return const Result.failure('重做失败：缺少交易数据', null);
          }

        case UndoActionType.update:
          // 重做更新
          if (action.transaction != null) {
            final result = await TransactionService.updateTransaction(action.transaction!);
            if (result.isSuccess) {
              _logger.info('重做更新操作成功', {'id': action.id});
              return Result.success('已重做修改 ${action.transaction?.title}');
            } else {
              return Result.failure('重做失败：${result.error}', result.exception);
            }
          } else {
            return const Result.failure('重做失败：缺少交易数据', null);
          }

        case UndoActionType.delete:
          // 重做删除
          final result = await TransactionService.deleteTransaction(action.id);
          if (result.isSuccess) {
            _logger.info('重做删除操作成功', {'id': action.id});
            return Result.success('已重做删除 ${action.transaction?.title}');
          } else {
            return Result.failure('重做失败：${result.error}', result.exception);
          }
      }
    } catch (e, stackTrace) {
      _logger.error('重做操作异常', e, stackTrace);
      // 重做失败，需要恢复栈状态
      _undoStack.removeLast();
      _redoStack.add(action);
      return Result.failure('重做失败：${e.toString()}', e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 清空撤销栈
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
    _logger.info('清空撤销栈');
  }

  /// 添加到撤销栈
  void _addToUndoStack(UndoAction action) {
    _undoStack.add(action);
    _redoStack.clear(); // 新操作会清空重做栈
    
    // 限制栈大小
    if (_undoStack.length > _maxStackSize) {
      _undoStack.removeAt(0);
    }
  }

  /// 获取撤销栈状态（用于调试）
  Map<String, dynamic> getStackStatus() {
    return {
      'undoCount': _undoStack.length,
      'redoCount': _redoStack.length,
      'canUndo': canUndo,
      'canRedo': canRedo,
      'lastAction': lastActionDescription,
    };
  }
}