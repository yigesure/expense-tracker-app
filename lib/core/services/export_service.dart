import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';
import 'transaction_service.dart';

class ExportService {
  static Future<String> exportToJson({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<Transaction> transactions;
    
    if (startDate != null && endDate != null) {
      transactions = await TransactionService.getTransactionsByDateRange(
        startDate,
        endDate,
      );
    } else {
      transactions = await TransactionService.getAllTransactions();
    }

    final exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'totalTransactions': transactions.length,
      'dateRange': {
        'start': startDate?.toIso8601String(),
        'end': endDate?.toIso8601String(),
      },
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  static Future<String> exportToCsv({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<Transaction> transactions;
    
    if (startDate != null && endDate != null) {
      transactions = await TransactionService.getTransactionsByDateRange(
        startDate,
        endDate,
      );
    } else {
      transactions = await TransactionService.getAllTransactions();
    }

    final csvBuffer = StringBuffer();
    
    // CSV头部
    csvBuffer.writeln('日期,标题,金额,分类,类型,描述');
    
    // 数据行
    for (final transaction in transactions) {
      final row = [
        transaction.date.toIso8601String().split('T')[0],
        _escapeCsvField(transaction.title),
        transaction.amount.toString(),
        _escapeCsvField(transaction.category),
        transaction.type == TransactionType.income ? '收入' : '支出',
        _escapeCsvField(transaction.description ?? ''),
      ];
      csvBuffer.writeln(row.join(','));
    }

    return csvBuffer.toString();
  }

  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  static Future<File> saveToFile(String content, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    return await file.writeAsString(content);
  }

  static Future<void> shareData(String content, String fileName) async {
    final file = await saveToFile(content, fileName);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: '记账数据导出 - $fileName',
    );
  }

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

    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> categoryExpenses = {};
    final Map<int, double> dailyExpenses = {};

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
        
        // 分类统计
        categoryExpenses[transaction.category] = 
            (categoryExpenses[transaction.category] ?? 0) + transaction.amount;
        
        // 日期统计
        final day = transaction.date.day;
        dailyExpenses[day] = (dailyExpenses[day] ?? 0) + transaction.amount;
      }
    }

    return {
      'period': '$year年${month}月',
      'totalTransactions': transactions.length,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netAmount': totalIncome - totalExpense,
      'categoryBreakdown': categoryExpenses,
      'dailyExpenses': dailyExpenses,
      'averageDailyExpense': totalExpense / DateTime(year, month + 1, 0).day,
      'topCategories': _getTopCategories(categoryExpenses, 5),
    };
  }

  static List<MapEntry<String, double>> _getTopCategories(
    Map<String, double> categories,
    int limit,
  ) {
    final sortedEntries = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(limit).toList();
  }
}