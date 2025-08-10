import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/utils/performance_keys.dart';

/// 优化的交易项Widget，减少重建和提升性能
class OptimizedTransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const OptimizedTransactionItem({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    
    return Container(
      key: PerformanceKeys.transactionItemKey(transaction.id),
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
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
                // 缓存图标容器，避免重复创建
                _CategoryIcon(
                  icon: transaction.categoryIcon,
                  isExpense: isExpense,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TransactionInfo(
                    title: transaction.title,
                    category: transaction.category,
                    date: transaction.date,
                  ),
                ),
                _AmountText(
                  amount: transaction.amount,
                  isExpense: isExpense,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 分离的分类图标组件，避免不必要的重建
class _CategoryIcon extends StatelessWidget {
  final String icon;
  final bool isExpense;

  const _CategoryIcon({
    required this.icon,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          icon,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

/// 分离的交易信息组件
class _TransactionInfo extends StatelessWidget {
  final String title;
  final String category;
  final DateTime date;

  const _TransactionInfo({
    required this.title,
    required this.category,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '$category • ${_formatTime(date)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// 分离的金额文本组件
class _AmountText extends StatelessWidget {
  final double amount;
  final bool isExpense;

  const _AmountText({
    required this.amount,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '${isExpense ? "-" : "+"}¥${amount.toStringAsFixed(2)}',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: isExpense ? AppColors.error : AppColors.success,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}