import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  String _currency = 'CNY';
  String _language = 'zh-CN';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 账户设置
          _buildSectionHeader('账户设置'),
          _buildSettingsTile(
            icon: Icons.person_outlined,
            title: '个人资料',
            subtitle: '管理您的个人信息',
            onTap: () => _showComingSoon('个人资料'),
          ),
          _buildSettingsTile(
            icon: Icons.security,
            title: '隐私与安全',
            subtitle: '账户安全设置',
            onTap: () => _showComingSoon('隐私与安全'),
          ),
          _buildSwitchTile(
            icon: Icons.fingerprint,
            title: '生物识别',
            subtitle: '使用指纹或面部识别',
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() {
                _biometricEnabled = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // 应用设置
          _buildSectionHeader('应用设置'),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: '推送通知',
            subtitle: '接收消费提醒和账单通知',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: '深色模式',
            subtitle: '使用深色主题',
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
            },
          ),
          _buildDropdownTile(
            icon: Icons.attach_money,
            title: '默认货币',
            subtitle: '选择默认显示货币',
            value: _currency,
            items: const [
              {'value': 'CNY', 'label': '人民币 (¥)'},
              {'value': 'USD', 'label': '美元 ($)'},
              {'value': 'EUR', 'label': '欧元 (€)'},
              {'value': 'JPY', 'label': '日元 (¥)'},
            ],
            onChanged: (value) {
              setState(() {
                _currency = value;
              });
            },
          ),
          _buildDropdownTile(
            icon: Icons.language,
            title: '语言',
            subtitle: '选择应用语言',
            value: _language,
            items: const [
              {'value': 'zh-CN', 'label': '简体中文'},
              {'value': 'en-US', 'label': 'English'},
              {'value': 'ja-JP', 'label': '日本語'},
            ],
            onChanged: (value) {
              setState(() {
                _language = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // 数据管理
          _buildSectionHeader('数据管理'),
          _buildSettingsTile(
            icon: Icons.cloud_sync_outlined,
            title: '数据同步',
            subtitle: '云端备份与同步',
            onTap: () => _showComingSoon('数据同步'),
          ),
          _buildSettingsTile(
            icon: Icons.download,
            title: '导出数据',
            subtitle: '导出所有消费记录',
            onTap: () => _showComingSoon('导出数据'),
          ),
          _buildSettingsTile(
            icon: Icons.delete_outlined,
            title: '清除数据',
            subtitle: '删除所有本地数据',
            onTap: () => _showClearDataDialog(),
            textColor: AppColors.error,
          ),

          const SizedBox(height: 24),

          // 帮助与支持
          _buildSectionHeader('帮助与支持'),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: '帮助中心',
            subtitle: '常见问题与使用指南',
            onTap: () => _showComingSoon('帮助中心'),
          ),
          _buildSettingsTile(
            icon: Icons.email_outlined,
            title: '联系我们',
            subtitle: '反馈问题或建议',
            onTap: () => _showComingSoon('联系我们'),
          ),
          _buildSettingsTile(
            icon: Icons.info_outlined,
            title: '关于应用',
            subtitle: '版本信息与开发者',
            onTap: () => _showAboutDialog(),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.creamWhite,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: textColor ?? AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textHint,
          size: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: AppColors.surface,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.creamWhite,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.gradientPurpleStart,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: AppColors.surface,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => _showDropdownDialog(title, value, items, onChanged),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.creamWhite,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              items.firstWhere((item) => item['value'] == value)['label']!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gradientPurpleStart,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textHint,
          size: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: AppColors.surface,
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature功能正在开发中，敬请期待！'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDropdownDialog(
    String title,
    String currentValue,
    List<Map<String, String>> items,
    ValueChanged<String> onChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((item) {
            final isSelected = item['value'] == currentValue;
            return ListTile(
              title: Text(item['label']!),
              leading: Radio<String>(
                value: item['value']!,
                groupValue: currentValue,
                onChanged: (value) {
                  if (value != null) {
                    onChanged(value);
                    Navigator.pop(context);
                  }
                },
                activeColor: AppColors.gradientPurpleStart,
              ),
              onTap: () {
                onChanged(item['value']!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除数据'),
        content: const Text('此操作将删除所有本地数据，包括消费记录、分类设置等。此操作不可恢复，确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('数据清除功能正在开发中'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: '智能记账',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.attach_money,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text('一款智能的个人财务管理应用，帮助您轻松记录和分析消费习惯。'),
        const SizedBox(height: 16),
        const Text('开发者：CodeBuddy Team'),
        const Text('技术支持：Flutter + Riverpod'),
      ],
    );
  }
}