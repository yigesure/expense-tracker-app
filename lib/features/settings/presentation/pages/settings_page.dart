import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import '../../../../core/theme/app_colors.dart';

/// 设置页面
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部应用栏
            _buildAppBar(context),
            
            // 设置内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 用户信息卡片
                    _buildUserCard(context),
                    
                    const SizedBox(height: 24),
                    
                    // 设置分组
                    _buildSettingsGroup(
                      context,
                      '个性化',
                      [
                        _buildSettingItem(
                          context,
                          FluentSystemIcons.ic_fluent_color_regular,
                          '主题设置',
                          '浅色模式',
                          onTap: () => _showThemeDialog(context),
                        ),
                        _buildSettingItem(
                          context,
                          FluentSystemIcons.ic_fluent_money_20_regular,
                          '货币单位',
                          '人民币 (¥)',
                          onTap: () => _showCurrencyDialog(context),
                        ),
                        _buildSwitchItem(
                          context,
                          FluentSystemIcons.ic_fluent_dark_theme_regular,
                          '深色模式',
                          false,
                          onChanged: (value) {
                            // TODO: 切换深色模式
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildSettingsGroup(
                      context,
                      '记账设置',
                      [
                        _buildSettingItem(
                          context,
                          FluentSystemIcons.ic_fluent_tag_regular,
                          '分类管理',
                          '自定义分类和图标',
                          onTap: () {
                            // TODO: 打开分类管理
                          },
                        ),
                        _buildSwitchItem(
                          context,
                          FluentSystemIcons.ic_fluent_mic_20_regular,
                          '语音识别',
                          true,
                          onChanged: (value) {
                            // TODO: 切换语音识别
                          },
                        ),
                        _buildSwitchItem(
                          context,
                          FluentSystemIcons.ic_fluent_brain_20_regular,
                          'AI智能分类',
                          true,
                          onChanged: (value) {
                            // TODO: 切换AI分类
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildSettingsGroup(
                      context,
                      '数据管理',
                      [
                        _buildSettingItem(
                          context,
                          FluentSystemIcons.ic_fluent_cloud_20_regular,
                          '自动备份',
                          '已开启',
                          onTap: () {
                            // TODO: 备份设置
                          },
                        ),
                        _buildSettingItem(
                          context,
                          FluentSystemIcons.ic_fluent_document_arrow_up_20_regular,
                          '导出数据',
                          '导出为Excel或PDF',
                          onTap: () {
                            // TODO: 导出数据
                          },
                        ),
                        _buildSettingItem(
                          context,
                          FluentSystemIcons.ic_fluent_broom_20_regular,
                          '清理缓存',
                          '释放存储空间',
                          onTap: () {
                            // TODO: 清理缓存
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildSettingsGroup(
                      context,
                      '关于',
                      [
                        _buildSettingItem(
                          context,
                          FluentSystemIcons.ic_fluent_info_regular,
                          '应用版本',
                          'v1.0.0',
                          onTap: () {
                            // TODO: 显示版本信息
                          },
                        ),
                        _buildSettingItem(
                          context,
                          FluentSystemIcons.ic_fluent_star_regular,
                          '评价应用',
                          '给我们评分',
                          onTap: () {
                            // TODO: 打开应用商店评价
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '设置',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                // TODO: 帮助中心
              },
              icon: const Icon(
                FluentSystemIcons.ic_fluent_question_circle_20_regular,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientPurpleStart.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              FluentSystemIcons.ic_fluent_person_filled,
              color: Colors.white,
              size: 30,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '记账达人',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '已记账 128 天 • 节省 ¥2,580',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // 编辑按钮
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {
                // TODO: 编辑用户信息
              },
              icon: const Icon(
                FluentSystemIcons.ic_fluent_edit_regular,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (index < items.length - 1)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: 1,
                      color: AppColors.divider,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.gradientPurpleStart.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.gradientPurpleStart,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FluentSystemIcons.ic_fluent_chevron_right_regular,
                color: AppColors.textHint,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
    BuildContext context,
    IconData icon,
    String title,
    bool value, {
    ValueChanged<bool>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gradientPurpleStart.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.gradientPurpleStart,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.gradientPurpleStart,
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(FluentSystemIcons.ic_fluent_weather_sunny_regular),
              title: const Text('浅色模式'),
              trailing: Radio<int>(
                value: 0,
                groupValue: 0,
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              leading: const Icon(FluentSystemIcons.ic_fluent_weather_moon_regular),
              title: const Text('深色模式'),
              trailing: Radio<int>(
                value: 1,
                groupValue: 0,
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择货币'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('人民币 (¥)'),
              trailing: Radio<int>(
                value: 0,
                groupValue: 0,
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('美元 (\$)'),
              trailing: Radio<int>(
                value: 1,
                groupValue: 0,
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}