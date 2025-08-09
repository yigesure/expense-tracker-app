import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/providers/transaction_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildFilterBar(),
            Expanded(
              child: transactionsAsync.when(
                data: (transactions) => _buildTransactionList(transactions),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState(error),
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

  Widget _buildTransactionList(List<Transaction> allTransactions) {
    final filteredTransactions = _filterTransactions(allTransactions);
    final sortedTransactions = _sortTransactions(filteredTransactions);

    if (sortedTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sortedTransactions.length,
      itemBuilder: (context, index) {
        final transaction = sortedTransactions[index];
        final showDateHeader = _shouldShowDateHeader(sortedTransactions, index);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader) _buildDateHeader(transaction.date),
            _buildTransactionItem(transaction),
          ],
        );
      },
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
}