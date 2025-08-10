import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import '../theme/app_colors.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../services/undo_service.dart';
import '../utils/logger.dart';

/// 快速添加浮动操作按钮
/// 支持快速记账和多种快捷操作
class QuickAddFAB extends ConsumerStatefulWidget {
  final VoidCallback? onAddTransaction;
  final VoidCallback? onQuickInput;

  const QuickAddFAB({
    super.key,
    this.onAddTransaction,
    this.onQuickInput,
  });

  @override
  ConsumerState<QuickAddFAB> createState() => _QuickAddFABState();
}

class _QuickAddFABState extends ConsumerState<QuickAddFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;
  static final AppLogger _logger = AppLogger('QuickAddFAB');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45度旋转
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // 背景遮罩
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleExpanded,
              child: Container(
                color: Colors.black.withAlpha((0.3 * 255).round()),
              ),
            ),
          ),

        // 快捷操作按钮
        ..._buildQuickActionButtons(),

        // 主FAB
        _buildMainFAB(),
      ],
    );
  }

  Widget _buildMainFAB() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FloatingActionButton(
          onPressed: _toggleExpanded,
          backgroundColor: AppColors.gradientPurpleStart,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildQuickActionButtons() {
    if (!_isExpanded) return [];

    return [
      // 快速支出
      _buildQuickActionButton(
        offset: const Offset(0, -70),
        icon: FluentSystemIcons.ic_fluent_arrow_down_regular,
        label: '支出',
        color: AppColors.error,
        onTap: () => _quickAddTransaction(TransactionType.expense),
      ),

      // 快速收入
      _buildQuickActionButton(
        offset: const Offset(0, -140),
        icon: FluentSystemIcons.ic_fluent_arrow_up_regular,
        label: '收入',
        color: AppColors.success,
        onTap: () => _quickAddTransaction(TransactionType.income),
      ),

      // 语音输入
      _buildQuickActionButton(
        offset: const Offset(-70, -70),
        icon: FluentSystemIcons.ic_fluent_mic_regular,
        label: '语音',
        color: AppColors.softBlue,
        onTap: _showVoiceInput,
      ),

      // 快速输入
      _buildQuickActionButton(
        offset: const Offset(-70, 0),
        icon: FluentSystemIcons.ic_fluent_keyboard_regular,
        label: '快输',
        color: AppColors.warning,
        onTap: () {
          _toggleExpanded();
          widget.onQuickInput?.call();
        },
      ),
    ];
  }

  Widget _buildQuickActionButton({
    required Offset offset,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: offset * _scaleAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: onTap,
                  backgroundColor: color,
                  heroTag: label,
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.7 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _quickAddTransaction(TransactionType type) {
    _logger.info('快速添加交易', {'type': type.toString()});
    _toggleExpanded();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickAddSheet(type),
    );
  }

  Widget _buildQuickAddSheet(TransactionType type) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    String selectedCategory = type == TransactionType.expense ? '餐饮' : '工作';
    String selectedIcon = type == TransactionType.expense ? '🍜' : '💼';

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 拖拽指示器
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.textHint,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 标题
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: type == TransactionType.expense
                            ? AppColors.expenseGradient
                            : AppColors.incomeGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        type == TransactionType.expense
                            ? FluentSystemIcons.ic_fluent_arrow_down_regular
                            : FluentSystemIcons.ic_fluent_arrow_up_regular,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '快速添加${type == TransactionType.expense ? '支出' : '收入'}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 金额输入
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      prefixText: '¥ ',
                      prefixStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 标题输入
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: '输入标题（可选）',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 快捷分类
                Text(
                  '选择分类',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _getQuickCategories(type).entries.map((entry) {
                    final isSelected = entry.key == selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = entry.key;
                          selectedIcon = entry.value;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.primaryGradient : null,
                          color: isSelected ? null : AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected ? null : Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(entry.value, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // 确认按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _saveQuickTransaction(
                      context,
                      type,
                      amountController.text,
                      titleController.text,
                      selectedCategory,
                      selectedIcon,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: type == TransactionType.expense
                          ? AppColors.error
                          : AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '添加${type == TransactionType.expense ? '支出' : '收入'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, String> _getQuickCategories(TransactionType type) {
    if (type == TransactionType.expense) {
      return {
        '餐饮': '🍜',
        '交通': '🚇',
        '购物': '🛍️',
        '娱乐': '🎬',
        '生活': '🏠',
        '其他': '📝',
      };
    } else {
      return {
        '工作': '💼',
        '投资': '📈',
        '红包': '🧧',
        '退款': '💰',
        '其他': '📝',
      };
    }
  }

  Future<void> _saveQuickTransaction(
    BuildContext context,
    TransactionType type,
    String amountText,
    String title,
    String category,
    String icon,
  ) async {
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入有效的金额'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.isEmpty ? category : title,
      amount: amount,
      category: category,
      categoryIcon: icon,
      date: DateTime.now(),
      type: type,
    );

    Navigator.pop(context);

    final result = await ref
        .read(transactionListProvider.notifier)
        .addTransaction(transaction);

    if (mounted) {
      result.when(
        success: (_) {
          // 记录添加操作到撤销服务
          UndoService().recordAdd(transaction);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已添加${type == TransactionType.expense ? '支出' : '收入'} ¥${amount.toStringAsFixed(2)}'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: '撤销',
                textColor: Colors.white,
                onPressed: () async {
                  final undoResult = await UndoService().undo();
                  undoResult.when(
                    success: (message) {
                      ref.refresh(transactionListProvider);
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
                },
              ),
            ),
          );
        },
        failure: (message, exception) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('添加失败：$message'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    }
  }

  void _showVoiceInput() {
    _toggleExpanded();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('语音输入功能正在开发中，敬请期待！'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}