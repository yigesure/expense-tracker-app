import 'package:flutter/material.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import '../theme/app_colors.dart';

/// 自定义底部导航栏
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: FluentSystemIcons.ic_fluent_home_regular,
                activeIcon: FluentSystemIcons.ic_fluent_home_filled,
                label: '首页',
                index: 0,
              ),
              _buildNavItem(
                icon: FluentSystemIcons.ic_fluent_data_pie_regular,
                activeIcon: FluentSystemIcons.ic_fluent_data_pie_filled,
                label: '统计',
                index: 1,
              ),
              _buildNavItem(
                icon: FluentSystemIcons.ic_fluent_bot_regular,
                activeIcon: FluentSystemIcons.ic_fluent_bot_filled,
                label: 'AI助手',
                index: 2,
              ),
              _buildNavItem(
                icon: FluentSystemIcons.ic_fluent_calendar_regular,
                activeIcon: FluentSystemIcons.ic_fluent_calendar_filled,
                label: '日历',
                index: 3,
              ),
              _buildNavItem(
                icon: FluentSystemIcons.ic_fluent_settings_regular,
                activeIcon: FluentSystemIcons.ic_fluent_settings_filled,
                label: '设置',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? AppColors.gradientPurpleStart.withOpacity(0.1) : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive ? AppColors.gradientPurpleStart : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.gradientPurpleStart : AppColors.textSecondary,
                fontFamily: 'SF Pro Display',
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}