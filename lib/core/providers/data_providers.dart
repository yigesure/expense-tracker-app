import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';

/// 交易记录数据提供者
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
  return TransactionsNotifier();
});

/// 当前选中月份提供者
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// 交易记录状态管理
class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  TransactionsNotifier() : super(_generateSampleData());

  /// 添加交易记录
  void addTransaction(Transaction transaction) {
    state = [...state, transaction];
  }

  /// 删除交易记录
  void removeTransaction(String id) {
    state = state.where((transaction) => transaction.id != id).toList();
  }

  /// 更新交易记录
  void updateTransaction(Transaction updatedTransaction) {
    state = state.map((transaction) {
      return transaction.id == updatedTransaction.id ? updatedTransaction : transaction;
    }).toList();
  }

  /// 获取今日交易记录
  List<Transaction> getTodayTransactions() {
    final today = DateTime.now();
    return state.where((transaction) {
      return transaction.date.year == today.year &&
             transaction.date.month == today.month &&
             transaction.date.day == today.day;
    }).toList();
  }

  /// 获取本月交易记录
  List<Transaction> getMonthTransactions([DateTime? month]) {
    final targetMonth = month ?? DateTime.now();
    return state.where((transaction) {
      return transaction.date.year == targetMonth.year &&
             transaction.date.month == targetMonth.month;
    }).toList();
  }

  /// 计算总余额
  double getTotalBalance() {
    double balance = 0;
    for (final transaction in state) {
      if (transaction.type == TransactionType.income) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }
    return balance;
  }

  /// 计算本月收入
  double getMonthlyIncome([DateTime? month]) {
    final monthTransactions = getMonthTransactions(month);
    return monthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// 计算本月支出
  double getMonthlyExpense([DateTime? month]) {
    final monthTransactions = getMonthTransactions(month);
    return monthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}

/// 生成示例数据
List<Transaction> _generateSampleData() {
  final now = DateTime.now();
  return [
    Transaction(
      id: '1',
      title: '午餐',
      amount: 28.50,
      category: '餐饮',
      categoryIcon: '🍜',
      date: now.subtract(const Duration(hours: 2)),
      description: '公司楼下餐厅',
      type: TransactionType.expense,
    ),
    Transaction(
      id: '2',
      title: '地铁',
      amount: 4.00,
      category: '交通',
      categoryIcon: '🚇',
      date: now.subtract(const Duration(hours: 8)),
      description: '上班通勤',
      type: TransactionType.expense,
    ),
    Transaction(
      id: '3',
      title: '咖啡',
      amount: 25.00,
      category: '餐饮',
      categoryIcon: '☕',
      date: now.subtract(const Duration(hours: 10)),
      description: '星巴克',
      type: TransactionType.expense,
    ),
    Transaction(
      id: '4',
      title: '工资',
      amount: 8500.00,
      category: '收入',
      categoryIcon: '💰',
      date: now.subtract(const Duration(days: 1)),
      description: '月薪',
      type: TransactionType.income,
    ),
    Transaction(
      id: '5',
      title: '购物',
      amount: 156.80,
      category: '购物',
      categoryIcon: '🛍️',
      date: now.subtract(const Duration(days: 2)),
      description: '淘宝购物',
      type: TransactionType.expense,
    ),
    Transaction(
      id: '6',
      title: '电影票',
      amount: 45.00,
      category: '娱乐',
      categoryIcon: '🎬',
      date: now.subtract(const Duration(days: 3)),
      description: '周末看电影',
      type: TransactionType.expense,
    ),
    Transaction(
      id: '7',
      title: '打车',
      amount: 18.50,
      category: '交通',
      categoryIcon: '🚗',
      date: now.subtract(const Duration(days: 4)),
      description: '滴滴出行',
      type: TransactionType.expense,
    ),
    Transaction(
      id: '8',
      title: '外卖',
      amount: 32.00,
      category: '餐饮',
      categoryIcon: '🥡',
      date: now.subtract(const Duration(days: 5)),
      description: '美团外卖',
      type: TransactionType.expense,
    ),
  ];
}

/// 账户余额提供者
final balanceProvider = Provider<double>((ref) {
  ref.watch(transactionsProvider);
  final notifier = ref.read(transactionsProvider.notifier);
  return notifier.getTotalBalance();
});

/// 本月收入提供者
final monthlyIncomeProvider = Provider<double>((ref) {
  ref.watch(transactionsProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  final notifier = ref.read(transactionsProvider.notifier);
  return notifier.getMonthlyIncome(selectedMonth);
});

/// 本月支出提供者
final monthlyExpenseProvider = Provider<double>((ref) {
  ref.watch(transactionsProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  final notifier = ref.read(transactionsProvider.notifier);
  return notifier.getMonthlyExpense(selectedMonth);
});

/// 今日交易记录提供者
final todayTransactionsProvider = Provider<List<Transaction>>((ref) {
  ref.watch(transactionsProvider);
  final notifier = ref.read(transactionsProvider.notifier);
  return notifier.getTodayTransactions();
});
