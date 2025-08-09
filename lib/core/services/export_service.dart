import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'transaction_service.dart';
import '../models/transaction.dart';

class ExportService {
  /// 导出为CSV格式
  static Future<String> exportToCsv({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final transactions = await TransactionService.getTransactionsByDateRange(
      startDate,
      endDate,
    );

    final buffer = StringBuffer();
    
    // CSV头部
    buffer.writeln('日期,标题,金额,分类,类型');
    
    // 数据行
    for (final transaction in transactions) {
      buffer.writeln([
        transaction.date.toIso8601String().split('T')[0],
        transaction.title,
        transaction.amount.toStringAsFixed(2),
        transaction.category,
        transaction.type == TransactionType.income ? '收入' : '支出',
      ].join(','));
    }
    
    return buffer.toString();
  }

  /// 导出为JSON格式
  static Future<String> exportToJson({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final transactions = await TransactionService.getTransactionsByDateRange(
      startDate,
      endDate,
    );

    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// 生成月度报告
  static Future<Map<String, dynamic>> generateMonthlyReport(
    int year,
    int month,
  ) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
    
    final transactions = await TransactionService.getTransactionsByDateRange(
      startDate,
      endDate,
    );

    final incomeTransactions = transactions
        .where((t) => t.type == TransactionType.income)
        .toList();
    final expenseTransactions = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    final totalIncome = incomeTransactions
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalExpense = expenseTransactions
        .fold<double>(0, (sum, t) => sum + t.amount);

    // 分类统计
    final categoryTotals = <String, double>{};
    for (final transaction in expenseTransactions) {
      categoryTotals[transaction.category] = 
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    // 排序获取前5个分类
    final topCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'period': '${year}年${month}月',
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netAmount': totalIncome - totalExpense,
      'totalTransactions': transactions.length,
      'averageDailyExpense': totalExpense / DateTime(year, month + 1, 0).day,
      'topCategories': topCategories.take(5).toList(),
    };
  }

  /// 分享数据
  static Future<void> shareData(String content, String fileName) async {
    await Share.share(
      content,
      subject: fileName,
    );
  }
}