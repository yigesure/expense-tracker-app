import 'package:flutter/foundation.dart';

/// 性能优化相关的Key管理
class PerformanceKeys {
  // 交易列表相关Keys
  static const ValueKey<String> transactionListKey = ValueKey('transaction_list');
  static const ValueKey<String> transactionFilterBarKey = ValueKey('transaction_filter_bar');
  static const ValueKey<String> transactionAppBarKey = ValueKey('transaction_app_bar');
  
  // Dashboard相关Keys
  static const ValueKey<String> balanceCardKey = ValueKey('balance_card');
  static const ValueKey<String> recentTransactionsKey = ValueKey('recent_transactions');
  static const ValueKey<String> quickActionsKey = ValueKey('quick_actions');
  static const ValueKey<String> quickInputBarKey = ValueKey('quick_input_bar');
  
  // 表单相关Keys
  static const ValueKey<String> addTransactionFormKey = ValueKey('add_transaction_form');
  static const ValueKey<String> editTransactionFormKey = ValueKey('edit_transaction_form');
  
  // 日历相关Keys
  static const ValueKey<String> calendarViewKey = ValueKey('calendar_view');
  static const ValueKey<String> calendarSummaryKey = ValueKey('calendar_summary');
  
  // 统计相关Keys
  static const ValueKey<String> statisticsChartKey = ValueKey('statistics_chart');
  static const ValueKey<String> categoryStatsKey = ValueKey('category_stats');
  
  // ListView相关Keys
  static const ValueKey<String> settingsListView = ValueKey('settings_list_view');
  static const ValueKey<String> quickActionsListView = ValueKey('quick_actions_list_view');
  static const ValueKey<String> addTransactionScrollView = ValueKey('add_transaction_scroll_view');
  
  // 生成动态Key
  static ValueKey<String> transactionItemKey(String transactionId) => 
      ValueKey('transaction_item_$transactionId');
  
  static ValueKey<String> categoryChipKey(String category) => 
      ValueKey('category_chip_$category');
  
  static ValueKey<String> filterChipKey(String filter) => 
      ValueKey('filter_chip_$filter');
  
  static ValueKey<String> dateHeaderKey(String date) => 
      ValueKey('date_header_$date');
}