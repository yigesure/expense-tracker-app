import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import '../models/transaction.dart';
import '../utils/result.dart';
import '../utils/logger.dart';
import '../exceptions/app_exceptions.dart';

/// 导出格式枚举
enum ExportFormat {
  csv,
  json,
  txt,
}

/// 导出服务
/// 提供交易数据的导出功能，支持多种格式
class ExportService {
  static final AppLogger _logger = AppLogger('ExportService');

  /// 导出交易数据
  static Future<Result<String>> exportTransactions({
    required List<Transaction> transactions,
    required ExportFormat format,
    String? fileName,
    DateTimeRange? dateRange,
    TransactionType? typeFilter,
  }) async {
    try {
      _logger.info('开始导出交易数据', {
        'count': transactions.length,
        'format': format.toString(),
        'fileName': fileName,
      });

      // 过滤数据
      final filteredTransactions = _filterTransactions(
        transactions,
        dateRange: dateRange,
        typeFilter: typeFilter,
      );

      if (filteredTransactions.isEmpty) {
        return const Result.failure('没有符合条件的交易记录', null);
      }

      // 生成文件名
      final actualFileName = fileName ?? _generateFileName(format);

      // 根据格式导出
      String filePath;
      switch (format) {
        case ExportFormat.csv:
          filePath = await _exportToCsv(filteredTransactions, actualFileName);
          break;
        case ExportFormat.json:
          filePath = await _exportToJson(filteredTransactions, actualFileName);
          break;
        case ExportFormat.txt:
          filePath = await _exportToTxt(filteredTransactions, actualFileName);
          break;
      }

      _logger.info('导出完成', {'filePath': filePath});
      return Result.success(filePath);
    } catch (e, stackTrace) {
      _logger.error('导出失败', e, stackTrace);
      return Result.failure('导出失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 分享导出的文件
  static Future<Result<void>> shareExportedFile(String filePath) async {
    try {
      _logger.info('分享文件', {'filePath': filePath});
      
      final file = File(filePath);
      if (!await file.exists()) {
        return const Result.failure('文件不存在', null);
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        text: '我的记账数据导出',
        subject: '记账数据分享',
      );

      return const Result.success(null);
    } catch (e, stackTrace) {
      _logger.error('分享文件失败', e, stackTrace);
      return Result.failure('分享失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 导出统计报告
  static Future<Result<String>> exportStatisticsReport({
    required List<Transaction> transactions,
    required DateTimeRange dateRange,
    String? fileName,
  }) async {
    try {
      _logger.info('导出统计报告', {
        'count': transactions.length,
        'dateRange': '${dateRange.start} - ${dateRange.end}',
      });

      final filteredTransactions = _filterTransactions(
        transactions,
        dateRange: dateRange,
      );

      final report = _generateStatisticsReport(filteredTransactions, dateRange);
      final actualFileName = fileName ?? 'statistics_report_${_formatDate(DateTime.now())}.txt';
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$actualFileName');
      await file.writeAsString(report, encoding: utf8);

      _logger.info('统计报告导出完成', {'filePath': file.path});
      return Result.success(file.path);
    } catch (e, stackTrace) {
      _logger.error('导出统计报告失败', e, stackTrace);
      return Result.failure('导出统计报告失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 过滤交易记录
  static List<Transaction> _filterTransactions(
    List<Transaction> transactions, {
    DateTimeRange? dateRange,
    TransactionType? typeFilter,
  }) {
    var filtered = transactions;

    if (dateRange != null) {
      filtered = filtered.where((t) {
        return t.date.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
               t.date.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }

    if (typeFilter != null) {
      filtered = filtered.where((t) => t.type == typeFilter).toList();
    }

    return filtered;
  }

  /// 导出为CSV格式
  static Future<String> _exportToCsv(List<Transaction> transactions, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    // 准备CSV数据
    final csvData = [
      ['日期', '时间', '标题', '分类', '类型', '金额', '备注'], // 表头
      ...transactions.map((t) => [
        _formatDate(t.date),
        _formatTime(t.date),
        t.title,
        t.category,
        t.type == TransactionType.income ? '收入' : '支出',
        t.amount.toStringAsFixed(2),
        t.description ?? '',
      ]),
    ];

    // 转换为CSV字符串
    final csvString = const ListToCsvConverter().convert(csvData);
    
    // 添加BOM以支持中文
    final bomCsvString = '\uFEFF$csvString';
    
    await file.writeAsString(bomCsvString, encoding: utf8);
    return file.path;
  }

  /// 导出为JSON格式
  static Future<String> _exportToJson(List<Transaction> transactions, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    final jsonData = {
      'exportTime': DateTime.now().toIso8601String(),
      'totalCount': transactions.length,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    await file.writeAsString(jsonString, encoding: utf8);
    return file.path;
  }

  /// 导出为TXT格式
  static Future<String> _exportToTxt(List<Transaction> transactions, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    final buffer = StringBuffer();
    buffer.writeln('=== 个人记账数据导出 ===');
    buffer.writeln('导出时间：${_formatDateTime(DateTime.now())}');
    buffer.writeln('记录总数：${transactions.length}');
    buffer.writeln('');

    // 按日期分组
    final groupedTransactions = <String, List<Transaction>>{};
    for (final transaction in transactions) {
      final dateKey = _formatDate(transaction.date);
      groupedTransactions.putIfAbsent(dateKey, () => []).add(transaction);
    }

    // 按日期排序
    final sortedDates = groupedTransactions.keys.toList()..sort((a, b) => b.compareTo(a));

    for (final date in sortedDates) {
      final dayTransactions = groupedTransactions[date]!;
      buffer.writeln('--- $date ---');
      
      double dayTotal = 0;
      for (final transaction in dayTransactions) {
        final sign = transaction.type == TransactionType.income ? '+' : '-';
        final amount = transaction.amount;
        dayTotal += transaction.type == TransactionType.income ? amount : -amount;
        
        buffer.writeln('${_formatTime(transaction.date)} ${transaction.categoryIcon} ${transaction.title}');
        buffer.writeln('  分类：${transaction.category} | 金额：$sign¥${amount.toStringAsFixed(2)}');
        if (transaction.description?.isNotEmpty == true) {
          buffer.writeln('  备注：${transaction.description}');
        }
        buffer.writeln('');
      }
      
      buffer.writeln('当日合计：${dayTotal >= 0 ? '+' : ''}¥${dayTotal.toStringAsFixed(2)}');
      buffer.writeln('');
    }

    // 统计信息
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpense;

    buffer.writeln('=== 统计汇总 ===');
    buffer.writeln('总收入：¥${totalIncome.toStringAsFixed(2)}');
    buffer.writeln('总支出：¥${totalExpense.toStringAsFixed(2)}');
    buffer.writeln('净收支：${balance >= 0 ? '+' : ''}¥${balance.toStringAsFixed(2)}');

    await file.writeAsString(buffer.toString(), encoding: utf8);
    return file.path;
  }

  /// 生成统计报告
  static String _generateStatisticsReport(List<Transaction> transactions, DateTimeRange dateRange) {
    final buffer = StringBuffer();
    
    buffer.writeln('=== 记账统计报告 ===');
    buffer.writeln('报告时间：${_formatDateTime(DateTime.now())}');
    buffer.writeln('统计期间：${_formatDate(dateRange.start)} 至 ${_formatDate(dateRange.end)}');
    buffer.writeln('');

    // 基本统计
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpense;

    buffer.writeln('=== 收支概览 ===');
    buffer.writeln('总收入：¥${totalIncome.toStringAsFixed(2)}');
    buffer.writeln('总支出：¥${totalExpense.toStringAsFixed(2)}');
    buffer.writeln('净收支：${balance >= 0 ? '+' : ''}¥${balance.toStringAsFixed(2)}');
    buffer.writeln('交易笔数：${transactions.length}');
    buffer.writeln('');

    // 分类统计
    final categoryStats = <String, double>{};
    for (final transaction in transactions.where((t) => t.type == TransactionType.expense)) {
      categoryStats[transaction.category] = 
          (categoryStats[transaction.category] ?? 0) + transaction.amount;
    }

    if (categoryStats.isNotEmpty) {
      buffer.writeln('=== 支出分类统计 ===');
      final sortedCategories = categoryStats.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      for (final entry in sortedCategories) {
        final percentage = (entry.value / totalExpense * 100);
        buffer.writeln('${entry.key}：¥${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)');
      }
      buffer.writeln('');
    }

    // 日均统计
    final days = dateRange.end.difference(dateRange.start).inDays + 1;
    if (days > 0) {
      buffer.writeln('=== 日均统计 ===');
      buffer.writeln('日均收入：¥${(totalIncome / days).toStringAsFixed(2)}');
      buffer.writeln('日均支出：¥${(totalExpense / days).toStringAsFixed(2)}');
      buffer.writeln('日均净收支：¥${(balance / days).toStringAsFixed(2)}');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  /// 生成文件名
  static String _generateFileName(ExportFormat format) {
    final now = DateTime.now();
    final dateStr = _formatDate(now).replaceAll('-', '');
    final timeStr = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    
    String extension;
    switch (format) {
      case ExportFormat.csv:
        extension = 'csv';
        break;
      case ExportFormat.json:
        extension = 'json';
        break;
      case ExportFormat.txt:
        extension = 'txt';
        break;
    }
    
    return 'transactions_${dateStr}_$timeStr.$extension';
  }

  /// 格式化日期
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 格式化时间
  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化日期时间
  static String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${_formatTime(date)}';
  }

  /// 获取导出目录
  static Future<String> getExportDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir.path;
  }

  /// 清理旧的导出文件
  static Future<Result<int>> cleanupOldExports({int keepDays = 30}) async {
    try {
      final exportDir = Directory(await getExportDirectory());
      if (!await exportDir.exists()) {
        return const Result.success(0);
      }

      final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
      final files = await exportDir.list().toList();
      int deletedCount = 0;

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await file.delete();
            deletedCount++;
            _logger.info('删除旧导出文件', {'filePath': file.path});
          }
        }
      }

      _logger.info('清理完成', {'deletedCount': deletedCount});
      return Result.success(deletedCount);
    } catch (e, stackTrace) {
      _logger.error('清理导出文件失败', e, stackTrace);
      return Result.failure('清理失败：${e.toString()}', 
                           e is Exception ? e : Exception(e.toString()));
    }
  }
}

/// 日期时间范围扩展
extension DateTimeRangeExtension on DateTimeRange {
  /// 获取天数
  int get days => end.difference(start).inDays + 1;
  
  /// 是否包含指定日期
  bool contains(DateTime date) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
           date.isBefore(end.add(const Duration(days: 1)));
  }
}