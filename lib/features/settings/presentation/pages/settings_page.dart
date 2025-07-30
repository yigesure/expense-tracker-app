import 'package:flutter/material.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import '../../../../core/theme/app_colors.dart';

/// 设置页面
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '设置',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingsSection(
            context,
            '账户设置',
            [
              _buildSettingsItem(
                context,
                '账户管理',
                '管理您的账户信息',
                FluentSystemIcons.ic_fluent_person_regular,
                () {},
              ),
              _buildSettingsItem(
                context,
                '数据同步',
                '同步您的记账数据',
                FluentSystemIcons.ic_fluent_cloud_regular,
                () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            '应用设置',
            [
              _buildSettingsItem(
                context,
                '主题设置',
                '切换深色/浅色主题',
                FluentSystemIcons.ic_fluent_dark_theme_regular,
                () {},
              ),
              _buildSettingsItem(
                context,
                '语言设置',
                '选择应用语言',
                FluentSystemIcons.ic_fluent_local_language_regular,
                () {},
              ),
              _buildSettingsItem(
                context,
                '通知设置',
                '管理推送通知',
                FluentSystemIcons.ic_fluent_alert_regular,
                () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            '数据管理',
            [
              _buildSettingsItem(
                context,
                '数据导出',
                '导出您的记账数据',
                FluentSystemIcons.ic_fluent_document_regular,
                () {},
              ),
              _buildSettingsItem(
                context,
                '数据清理',
                '清理缓存和临时文件',
                FluentSystemIcons.ic_fluent_delete_regular,
                () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            '帮助与支持',
            [
              _buildSettingsItem(
                context,
                '帮助中心',
                '查看常见问题和帮助',
                FluentSystemIcons.ic_fluent_question_regular,
                () {},
              ),
              _buildSettingsItem(
                context,
                '关于我们',
                '应用版本和开发信息',
                FluentSystemIcons.ic_fluent_info_regular,
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
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
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
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
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        FluentSystemIcons.ic_fluent_chevron_right_regular,
        color: AppColors.textHint,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}