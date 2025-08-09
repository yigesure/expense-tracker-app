import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/providers/transaction_provider.dart';

class TransactionEditPage extends ConsumerStatefulWidget {
  final Transaction transaction;

  const TransactionEditPage({
    super.key,
    required this.transaction,
  });

  @override
  ConsumerState<TransactionEditPage> createState() => _TransactionEditPageState();
}

class _TransactionEditPageState extends ConsumerState<TransactionEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TransactionType _selectedType;
  late String _selectedCategory;
  late String _selectedCategoryIcon;
  late DateTime _selectedDate;
  bool _isLoading = false;

  final Map<String, String> _categories = {
    '餐饮': '🍜',
    '交通': '🚇',
    '购物': '🛍️',
    '娱乐': '🎬',
    '医疗': '🏥',
    '教育': '📚',
    '生活': '🏠',
    '工作': '💼',
    '投资': '📈',
    '其他': '📝',
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction.title);
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _descriptionController = TextEditingController(text: widget.transaction.description ?? '');
    _selectedType = widget.transaction.type;
    _selectedCategory = widget.transaction.category;
    _selectedCategoryIcon = widget.transaction.categoryIcon;
    _selectedDate = widget.transaction.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(),
                    const SizedBox(height: 24),
                    _buildAmountInput(),
                    const SizedBox(height: 24),
                    _buildTitleInput(),
                    const SizedBox(height: 24),
                    _buildCategorySelector(),
                    const SizedBox(height: 24),
                    _buildDateSelector(),
                    const SizedBox(height: 24),
                    _buildDescriptionInput(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
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
              '编辑交易',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '交易类型',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedType = TransactionType.expense),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: _selectedType == TransactionType.expense
                        ? AppColors.expenseGradient
                        : null,
                    color: _selectedType == TransactionType.expense
                        ? null
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: _selectedType == TransactionType.expense
                        ? null
                        : Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        MdiIcons.arrowDown,
                        color: _selectedType == TransactionType.income
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '支出',
                        style: TextStyle(
                          color: _selectedType == TransactionType.expense
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedType = TransactionType.income),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: _selectedType == TransactionType.income
                        ? AppColors.incomeGradient
                        : null,
                    color: _selectedType == TransactionType.income
                        ? null
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: _selectedType == TransactionType.income
                        ? null
                        : Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FluentSystemIcons.ic_fluent_arrow_down_regular,
                        color: _selectedType == TransactionType.income
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '收入',
                        style: TextStyle(
                          color: _selectedType == TransactionType.income
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '金额',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              hintText: '0.00',
              prefixText: '¥ ',
              prefixStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标题',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: '输入交易标题',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分类',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.entries.map((entry) {
            final isSelected = entry.key == _selectedCategory;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = entry.key;
                  _selectedCategoryIcon = entry.value;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? null : Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(entry.value, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: TextStyle(
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
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '日期',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(
                  MdiIcons.calendar,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textHint,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '备注',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '添加备注信息（可选）',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gradientPurpleStart,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '保存修改',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      } else {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            _selectedDate.hour,
            _selectedDate.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTransaction() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入交易标题'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
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

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedTransaction = Transaction(
        id: widget.transaction.id,
        title: _titleController.text.trim(),
        amount: amount,
        category: _selectedCategory,
        categoryIcon: _selectedCategoryIcon,
        date: _selectedDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        type: _selectedType,
      );

      await ref
          .read(transactionListProvider.notifier)
          .updateTransaction(updatedTransaction);

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context); // 返回到详情页的上一页
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('交易记录已更新'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败：$e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}