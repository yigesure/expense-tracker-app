import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import '../../../../core/theme/app_colors.dart';
// import '../../../../core/providers/data_providers.dart'; // 暂时注释掉未使用的导入
import '../widgets/balance_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/quick_input_bar.dart';

/// 首页Dashboard
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部应用栏
            _buildAppBar(context),
            
            // 主要内容区域
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    
                    // 账户余额卡片
                    BalanceCard(),

                    SizedBox(height: 24),

                    // 快捷操作
                    QuickActions(),

                    SizedBox(height: 24),
                    
                    // 今日消费记录
                    RecentTransactions(),

                    SizedBox(height: 100), // 为底部导航栏留出空间
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // 快捷输入栏
      floatingActionButton: const QuickInputBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '早上好 👋',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '今天也要好好记账哦',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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
              onPressed: () {
                // TODO: 实现通知功能
              },
              icon: const Icon(
                FluentSystemIcons.ic_fluent_alert_regular,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}