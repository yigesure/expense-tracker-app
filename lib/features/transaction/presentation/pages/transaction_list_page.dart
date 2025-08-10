import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/providers/transaction_provider.dart';
import '../../../../core/utils/performance_keys.dart';
import '../../../../core/widgets/swipe_action_widget.dart';
import '../../../../core/widgets/state_handlers.dart';
import '../../../../core/services/undo_service.dart';
import '../widgets/optimized_transaction_item.dart';
import 'transaction_detail_page.dart';
import 'transaction_edit_page.dart';

class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  ConsumerState<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends ConsumerState<TransactionListPage> {
  String _selectedFilter = 'all';
  String _selectedSort = 'date_desc';
  final UndoService _undoService = UndoService();

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildFilterBar(),
            if (_undoService.canUndo) _buildUndoBar(),
            Expanded(
              child: AsyncStateBuilder<List<Transaction>>(
                asyncValue: transactionsAsync,
                dataBuilder: (transactions) => _buildTransactionList(transactions),
                loadingMessage: '加载交易记录中...',
                emptyTitle: '暂无交易记录',
                emptySubtitle: '当前筛选条件下没有找到交易记录',
                onRetry: () => ref.refresh(transactionListProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '全部交易',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _showSearchDialog,
              icon: const Icon(
                Icons.search,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      key: PerformanceKeys.transactionFilterBarKey,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', '全部'),
                  const SizedBox(width: 8),
                  _buildFilterChip('expense', '支出'),
                  const SizedBox(width: 8),
                  _buildFilterChip('income', '收入'),
                  const SizedBox(width: 8),
                  _buildFilterChip('today', '今日'),
                  const SizedBox(width: 8),
                  _buildFilterChip('week', '本周'),
                  const SizedBox(width: 8),
                  _buildFilterChip('month', '本月'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: PopupMenuButton<String>(
              initialValue: _selectedSort,
              onSelected: (value) => setState(() => _selectedSort = value),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sort,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '排序',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'date_desc',
                  child: Text('时间降序'),
                ),
                const PopupMenuItem(
                  value: 'date_asc',
                  child: Text('时间升序'),
                ),
                const PopupMenuItem(
                  value: 'amount_desc',
                  child: Text('金额降序'),
                ),
                const PopupMenuItem(
                  value: 'amount_asc',
                  child: Text('金额升序'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: AppColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildUndoBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: AppColors.softBlue.withAlpha((0.1 * 255).round()),
      child: Row(
        children: [
          Icon(
            FluentSystemIcons.ic_fluent_arrow_undo_regular,
            size: 16,
            color: AppColors.softBlue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _undoService.lastActionDescription ?? '可以撤销上一步操作',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.softBlue,
              ),
            ),
          ),
          TextButton(
            onPressed: _performUndo,
            child: const Text(
              '撤销',
              style: TextStyle(
                color: AppColors.softBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> allTransactions) {
    final filteredTransactions = _filterTransactions(allTransactions);
    final sortedTransactions = _sortTransactions(filteredTransactions);

    return RefreshIndicatorWidget(
      onRefresh: () async {
        ref.refresh(transactionListProvider);
      },
      child: ListView.builder(
        key: PerformanceKeys.transactionListKey,
        padding: const EdgeInsets.all(20),
        itemCount: sortedTransactions.length,
        // 性能优化：添加缓存范围
        cacheExtent: 500,
        itemBuilder: (context, index) {
          final transaction = sortedTransactions[index];
          final showDateHeader = _shouldShowDateHeader(sortedTransactions, index);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDateHeader) _buildDateHeader(transaction.date),
              SwipeActionWidget(
                onEdit: () => _editTransaction(transaction),
                onDelete: () => _deleteTransaction(transaction),
                child: OptimizedTransactionItem(
                  transaction: transaction,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionDetailPage(transaction: transaction),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    final now = DateTime.now();
    
    switch (_selectedFilter) {
      case 'expense':
        return transactions.where((t) => t.type == TransactionType.expense).toList();
      case 'income':
        return transactions.where((t) => t.type == TransactionType.income).toList();
      case 'today':
        return transactions.where((t) {
          return t.date.year == now.year &&
                 t.date.month == now.month &&
                 t.date.day == now.day;
        }).toList();
      case 'week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return transactions.where((t) => t.date.isAfter(weekStart)).toList();
      case 'month':
        return transactions.where((t) {
          return t.date.year == now.year && t.date.month == now.month;
        }).toList();
      default:
        return transactions;
    }
  }

  List<Transaction> _sortTransactions(List<Transaction> transactions) {
    final sorted = List<Transaction>.from(transactions);
    
    switch (_selectedSort) {
      case 'date_asc':
        sorted.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'amount_desc':
        sorted.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'amount_asc':
        sorted.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      default: // date_desc
        sorted.sort((a, b) => b.date.compareTo(a.date));
        break;
    }
    
    return sorted;
  }

  bool _shouldShowDateHeader(List<Transaction> transactions, int index) {
    if (index == 0) return true;
    
    final current = transactions[index].date;
    final previous = transactions[index - 1].date;
    
    return current.year != previous.year ||
           current.month != previous.month ||
           current.day != previous.day;
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    String dateText;
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      dateText = '今天';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      dateText = '昨天';
    } else {
      dateText = '${date.month}月${date.day}日';
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        dateText,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isExpense = transaction.type == TransactionType.expense;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetailPage(transaction: transaction),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isExpense
                        ? AppColors.error.withAlpha((0.1 * 255).round())
                        : AppColors.success.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      transaction.categoryIcon,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${transaction.category} • ${_formatTime(transaction.date)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isExpense ? "-" : "+"}¥${transaction.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isExpense ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.gradientPurpleStart.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: AppColors.gradientPurpleStart,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无交易记录',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '当前筛选条件下没有找到交易记录',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(transactionListProvider),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索功能'),
        content: const Text('搜索功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _editTransaction(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionEditPage(transaction: transaction),
      ),
    ).then((_) {
      // 刷新列表
      ref.refresh(transactionListProvider);
    });
  }

  void _deleteTransaction(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除交易记录"${transaction.title}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDelete(transaction);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(Transaction transaction) async {
    // 记录删除操作到撤销服务
    _undoService.recordDelete(transaction);
    
    final result = await ref
        .read(transactionListProvider.notifier)
        .deleteTransaction(transaction.id);

    if (mounted) {
      result.when(
        success: (_) {
          setState(() {}); // 刷新撤销栏状态
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已删除 ${transaction.title}'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: '撤销',
                textColor: Colors.white,
                onPressed: _performUndo,
              ),
            ),
          );
        },
        failure: (message, exception) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('删除失败：$message'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    }
  }

  Future<void> _performUndo() async {
    final result = await _undoService.undo();
    
    if (mounted) {
      result.when(
        success: (message) {
          setState(() {}); // 刷新撤销栏状态
          ref.refresh(transactionListProvider); // 刷新数据
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        failure: (message, exception) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('撤销失败：$message'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    }
  }
}
