import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/providers/transaction_provider.dart';
import '../../../../core/widgets/material3_components.dart';
import '../../../../core/accessibility/accessibility_helper.dart';
import '../../../../core/utils/animation_optimizer.dart';
import '../../../../core/utils/performance_keys.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  TransactionType _selectedType = TransactionType.expense;
  String _selectedCategory = '餐饮';
  String _selectedCategoryIcon = '🍜';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final Map<String, String> _expenseCategories = {
    '餐饮': '🍜',
    '交通': '🚇',
    '购物': '🛍️',
    '娱乐': '🎬',
    '医疗': '🏥',
    '教育': '📚',
    '生活': '🏠',
    '其他': '📝',
  };

  final Map<String, String> _incomeCategories = {
    '工资': '💰',
    '奖金': '🎁',
    '投资': '📈',
    '兼职': '💼',
    '红包': '🧧',
    '退款': '↩️',
    '其他': '💵',
  };

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: AnimationOptimizer.getOptimizedDuration(
        const Duration(milliseconds: 600),
      ),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AnimationOptimizer.getOptimizedCurve(Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AnimationOptimizer.getOptimizedCurve(Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Map<String, String> get _currentCategories =>
      _selectedType == TransactionType.expense ? _expenseCategories : _incomeCategories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      key: PerformanceKeys.addTransactionScrollView,
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
                          const SizedBox(height: 20), // 底部安全区域
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AccessibilityHelper.accessibleHeader(
      label: '添加交易页面',
      hint: '填写交易信息并保存',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            AccessibilityHelper.accessibleTouchTarget(
              label: '返回',
              hint: '返回上一页',
              onTap: () => Navigator.pop(context),
              child: M3Components.card(
                padding: const EdgeInsets.all(8),
                margin: EdgeInsets.zero,
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '添加交易',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return AccessibilityHelper.accessibleGroup(
      label: '交易类型选择',
      hint: '选择支出或收入',
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
              child: AccessibilityHelper.accessibleButton(
                label: '支出',
                hint: _selectedType == TransactionType.expense ? '已选中' : '点击选择支出',
                onPressed: () {
                  setState(() {
                    _selectedType = TransactionType.expense;
                    _selectedCategory = _expenseCategories.keys.first;
                    _selectedCategoryIcon = _expenseCategories.values.first;
                  });
                },
                child: AnimatedContainer(
                  duration: AnimationOptimizer.getOptimizedDuration(
                    const Duration(milliseconds: 200),
                  ),
                  curve: AnimationOptimizer.getOptimizedCurve(Curves.easeInOut),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: _selectedType == TransactionType.expense
                        ? AppColors.expenseGradient
                        : null,
                    color: _selectedType == TransactionType.expense
                        ? null
                        : Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: _selectedType == TransactionType.expense
                        ? null
                        : Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: _selectedType == TransactionType.expense
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '支出',
                        style: TextStyle(
                          color: _selectedType == TransactionType.expense
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
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
              child: AccessibilityHelper.accessibleButton(
                label: '收入',
                hint: _selectedType == TransactionType.income ? '已选中' : '点击选择收入',
                onPressed: () {
                  setState(() {
                    _selectedType = TransactionType.income;
                    _selectedCategory = _incomeCategories.keys.first;
                    _selectedCategoryIcon = _incomeCategories.values.first;
                  });
                },
                child: AnimatedContainer(
                  duration: AnimationOptimizer.getOptimizedDuration(
                    const Duration(milliseconds: 200),
                  ),
                  curve: AnimationOptimizer.getOptimizedCurve(Curves.easeInOut),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: _selectedType == TransactionType.income
                        ? AppColors.incomeGradient
                        : null,
                    color: _selectedType == TransactionType.income
                        ? null
                        : Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: _selectedType == TransactionType.income
                        ? null
                        : Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: _selectedType == TransactionType.income
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '收入',
                        style: TextStyle(
                          color: _selectedType == TransactionType.income
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
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
    return AccessibilityHelper.accessibleFormField(
      label: '金额',
      hint: '输入交易金额',
      required: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '金额 *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          M3Components.textField(
            label: '金额',
            hint: '0.00',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入金额';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return '请输入有效的金额';
              }
              return null;
            },
            prefixIcon: Icons.attach_money,
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInput() {
    return AccessibilityHelper.accessibleFormField(
      label: '标题',
      hint: '输入交易标题',
      required: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '标题 *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          M3Components.textField(
            label: '标题',
            hint: '输入交易标题',
            controller: _titleController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入交易标题';
              }
              return null;
            },
            prefixIcon: Icons.title,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return AccessibilityHelper.accessibleGroup(
      label: '分类选择',
      hint: '选择交易分类',
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
          children: _currentCategories.entries.map((entry) {
            final isSelected = entry.key == _selectedCategory;
            return AccessibilityHelper.accessibleButton(
              label: '${entry.value} ${entry.key}',
              hint: isSelected ? '已选中' : '点击选择此分类',
              onPressed: () {
                setState(() {
                  _selectedCategory = entry.key;
                  _selectedCategoryIcon = entry.value;
                });
              },
              child: AnimatedContainer(
                duration: AnimationOptimizer.getOptimizedDuration(
                  const Duration(milliseconds: 200),
                ),
                curve: AnimationOptimizer.getOptimizedCurve(Curves.easeInOut),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? null : Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(entry.value, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : Theme.of(context).colorScheme.onSurface,
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
    return AccessibilityHelper.accessibleSelector(
      label: '日期选择',
      hint: '点击选择交易日期和时间',
      currentValue: '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
      onTap: _selectDate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '日期',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          M3Components.card(
            onTap: _selectDate,
            padding: const EdgeInsets.all(16),
            margin: EdgeInsets.zero,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return AccessibilityHelper.accessibleFormField(
      label: '备注',
      hint: '输入备注信息，可选',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '备注',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          M3Components.textField(
            label: '备注',
            hint: '添加备注信息（可选）',
            controller: _descriptionController,
            maxLines: 3,
            prefixIcon: Icons.note_add,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return AccessibilityHelper.accessibleButton(
      label: '保存交易',
      hint: '保存当前填写的交易信息',
      onPressed: _isLoading ? null : _saveTransaction,
      child: SizedBox(
        width: double.infinity,
        child: M3Components.primaryButton(
          text: '保存交易',
          onPressed: _isLoading ? null : _saveTransaction,
          isLoading: _isLoading,
          icon: Icons.save,
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      const uuid = Uuid();
      final transaction = Transaction(
        id: uuid.v4(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        categoryIcon: _selectedCategoryIcon,
        date: _selectedDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        type: _selectedType,
      );

      final result = await ref
          .read(transactionListProvider.notifier)
          .addTransaction(transaction);

      if (mounted) {
        result.when(
          success: (_) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('交易记录已保存'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          failure: (message, exception) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('保存失败：$message'),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败：$e'),
            backgroundColor: Theme.of(context).colorScheme.error,
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