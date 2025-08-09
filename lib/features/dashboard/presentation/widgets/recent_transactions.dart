import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/data_providers.dart';
import '../../../../core/models/transaction.dart';
import '../../../transaction/presentation/pages/transaction_detail_page.dart';
import '../../../transaction/presentation/pages/transaction_edit_page.dart';
import '../../../transaction/presentation/pages/transaction_list_page.dart';

/// 最近交易记录组件
class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final todayTransactions = ref.watch(todayTransactionsProvider); // 暂时注释掉未使用的变量
    final allTransactions = ref.watch(transactionsProvider);
    
    // 获取最近的交易记录（今日 + 最近几天）
    final recentTransactions = allTransactions.take(8).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近交易',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionListPage(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '查看全部',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gradientPurpleStart,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      MdiIcons.chevronRight,
                      color: AppColors.gradientPurpleStart,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 交易记录列表
          if (recentTransactions.isEmpty)
            _buildEmptyState(context)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentTransactions.length,
              itemBuilder: (context, index) {
                final transaction = recentTransactions[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  tween: Tween(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(50 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: _buildTransactionItem(context, transaction, ref),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction, WidgetRef ref) {
    final isExpense = transaction.type == TransactionType.expense;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 分类图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isExpense
                        ? AppColors.error.withAlpha((0.1 * 255).round())
                        : AppColors.success.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      transaction.categoryIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // 交易信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            transaction.category,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.textHint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(transaction.date),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 金额
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isExpense ? "-" : "+"}¥${transaction.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isExpense ? AppColors.error : AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isExpense
                            ? AppColors.error.withAlpha((0.1 * 255).round())
                            : AppColors.success.withAlpha((0.1 * 255).round()),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isExpense ? '支出' : '收入',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isExpense ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(width: 8),
                
                // 更多操作按钮
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionEditPage(transaction: transaction),
                          ),
                        );
                        break;
                      case 'delete':
                        _showDeleteDialog(context, transaction, ref);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            MdiIcons.pencil,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Text('编辑'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            MdiIcons.delete,
                            size: 16,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '删除',
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.gradientPurpleStart.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.receipt,
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
            '开始记录你的第一笔交易吧',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
  }

  void _showDeleteDialog(BuildContext context, Transaction transaction, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除这笔"${transaction.title}"的交易记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(transactionsProvider.notifier).removeTransaction(transaction.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('交易记录已删除'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}