import 'package:flutter/material.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import '../../../../core/theme/app_colors.dart';

/// 快捷操作组件
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '快捷操作',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildActionCard(
                context,
                '记一笔',
                FluentSystemIcons.ic_fluent_add_circle_filled,
                AppColors.primaryGradient,
                () {
                  // TODO: 打开记账页面
                },
              ),
              _buildActionCard(
                context,
                '转账',
                FluentSystemIcons.ic_fluent_arrow_swap_filled,
                AppColors.blueGradient,
                () {
                  // TODO: 打开转账页面
                },
              ),
              _buildActionCard(
                context,
                '预算',
                FluentSystemIcons.ic_fluent_target_filled,
                AppColors.incomeGradient,
                () {
                  // TODO: 打开预算页面
                },
              ),
              _buildActionCard(
                context,
                '分析',
                FluentSystemIcons.ic_fluent_chart_multiple_20_filled,
                AppColors.expenseGradient,
                () {
                  // TODO: 打开分析页面
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 16),
        width: 100,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}