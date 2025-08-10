import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/material3_components.dart';
import '../../../../core/widgets/state_handlers.dart';
import '../../../../core/services/export_service.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/providers/transaction_provider.dart';
import '../../../../core/utils/logger.dart';

/// 数据管理页面
/// 提供数据导出、备份、恢复和同步功能
class DataManagementPage extends ConsumerStatefulWidget {
  const DataManagementPage({super.key});

  @override
  ConsumerState<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends ConsumerState<DataManagementPage> {
  static final AppLogger _logger = AppLogger('DataManagementPage');
  bool _isLoading = false;
  List<BackupInfo> _backupList = [];

  @override
  void initState() {
    super.initState();
    _loadBackupList();
  }

  Future<void> _loadBackupList() async {
    final result = await BackupService.getBackupList();
    if (mounted && result.isSuccess) {
      setState(() {
        _backupList = result.data!;
      });
    }
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
                    _buildExportSection(),
                    const SizedBox(height: 32),
                    _buildBackupSection(),
                    const SizedBox(height: 32),
                    _buildSyncSection(),
                    const SizedBox(height: 32),
                    _buildBackupListSection(),
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
              '数据管理',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportSection() {
    return _buildSection(
      title: '数据导出',
      subtitle: '将记账数据导出为不同格式的文件',
      icon: FluentSystemIcons.ic_fluent_document_arrow_down_regular,
      children: [
        _buildActionTile(
          icon: FluentSystemIcons.ic_fluent_document_table_regular,
          title: '导出为 CSV',
          subtitle: '适合在 Excel 中查看和分析',
          onTap: () => _exportData(ExportFormat.csv),
        ),
        _buildActionTile(
          icon: FluentSystemIcons.ic_fluent_document_code_regular,
          title: '导出为 JSON',
          subtitle: '完整的数据格式，便于程序处理',
          onTap: () => _exportData(ExportFormat.json),
        ),
        _buildActionTile(
          icon: FluentSystemIcons.ic_fluent_document_text_regular,
          title: '导出为文本',
          subtitle: '可读性强的文本格式报告',
          onTap: () => _exportData(ExportFormat.txt),
        ),
        _buildActionTile(
          icon: FluentSystemIcons.ic_fluent_chart_multiple_regular,
          title: '导出统计报告',
          subtitle: '包含详细分析的统计报告',
          onTap: _exportStatisticsReport,
        ),
      ],
    );
  }

  Widget _buildBackupSection() {
    return _buildSection(
      title: '数据备份',
      subtitle: '创建完整的数据备份，确保数据安全',
      icon: FluentSystemIcons.ic_fluent_shield_checkmark_regular,
      children: [
        _buildActionTile(
          icon: FluentSystemIcons.ic_fluent_save_regular,
          title: '创建备份',
          subtitle: '备份所有交易记录和设置',
          onTap: _createBackup,
        ),
        _buildActionTile(
          icon: FluentSystemIcons.ic_fluent_folder_open_regular,
          title: '从文件恢复',
          subtitle: '从备份文件恢复数据',
          onTap: _restoreFromFile,
        ),
        _buildActionTile(
          icon: FluentSystemIcons.ic_fluent_arrow_clockwise_regular,
          title: '自动备份',
          subtitle: '定期自动创建数据备份',
          onTap: _performAutoBackup,
        ),
      ],
    );
  }

  Widget _buildSyncSection() {
    return _buildSection(
      title: '数据同步',
      subtitle: '与云端同步数据，多设备访问',
      icon: FluentSystemIcons.ic_fluent_arrow_sync_regular,
      children: [
        StreamBuilder<SyncStatus>(
          stream: SyncService.statusStream,
          initialData: SyncService.currentStatus,
          builder: (context, snapshot) {
            final status = snapshot.data ?? SyncStatus.idle;
            return _buildSyncStatusTile(status);
          },
        ),
        _buildActionTile(
          icon: FluentSystemIcons.ic_fluent_cloud_sync_regular,
          title: '手动同步',
          subtitle: '立即与云端同步数据',
          onTap: _manualSync,
        ),
        _buildActionTile(
          icon: FluentSystemIcons.ic_fluent_history_regular,
          title: '同步历史',
          subtitle: '查看数据同步记录',
          onTap: _showSyncHistory,
        ),
      ],
    );
  }

  Widget _buildBackupListSection() {
    if (_backupList.isEmpty) {
      return _buildSection(
        title: '备份文件',
        subtitle: '管理已创建的备份文件',
        icon: FluentSystemIcons.ic_fluent_folder_regular,
        children: [
          const EmptyStateWidget(
            title: '暂无备份文件',
            subtitle: '创建第一个备份来保护您的数据',
            icon: FluentSystemIcons.ic_fluent_document_regular,
          ),
        ],
      );
    }

    return _buildSection(
      title: '备份文件',
      subtitle: '管理已创建的备份文件',
      icon: FluentSystemIcons.ic_fluent_folder_regular,
      children: _backupList.map((backup) => _buildBackupTile(backup)).toList(),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.gradientPurpleStart.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.gradientPurpleStart,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.textSecondary,
                size: 24,
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
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textHint,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatusTile(SyncStatus status) {
    IconData icon;
    String title;
    String subtitle;
    Color color;

    switch (status) {
      case SyncStatus.idle:
        icon = FluentSystemIcons.ic_fluent_checkmark_circle_regular;
        title = '同步就绪';
        subtitle = '数据已同步，可以开始使用';
        color = AppColors.success;
        break;
      case SyncStatus.syncing:
        icon = FluentSystemIcons.ic_fluent_arrow_sync_regular;
        title = '正在同步';
        subtitle = '正在与云端同步数据...';
        color = AppColors.softBlue;
        break;
      case SyncStatus.success:
        icon = FluentSystemIcons.ic_fluent_checkmark_circle_regular;
        title = '同步成功';
        subtitle = '数据已成功同步到云端';
        color = AppColors.success;
        break;
      case SyncStatus.failed:
        icon = FluentSystemIcons.ic_fluent_error_circle_regular;
        title = '同步失败';
        subtitle = '同步过程中出现错误';
        color = AppColors.error;
        break;
      case SyncStatus.conflict:
        icon = FluentSystemIcons.ic_fluent_warning_regular;
        title = '同步冲突';
        subtitle = '检测到数据冲突，需要处理';
        color = AppColors.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
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
          if (status == SyncStatus.syncing)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildBackupTile(BackupInfo backup) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showBackupOptions(backup),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(
                FluentSystemIcons.ic_fluent_document_regular,
                color: AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      backup.fileName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${backup.formattedBackupTime} • ${backup.transactionCount}条记录 • ${backup.formattedFileSize}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.more_vert,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportData(ExportFormat format) async {
    setState(() => _isLoading = true);

    try {
      final transactionsAsync = ref.read(transactionListProvider);
      final transactions = transactionsAsync.when(
        data: (data) => data,
        loading: () => <Transaction>[],
        error: (_, __) => <Transaction>[],
      );

      if (transactions.isEmpty) {
        _showMessage('没有可导出的数据', isError: true);
        return;
      }

      final result = await ExportService.exportTransactions(
        transactions: transactions,
        format: format,
      );

      result.when(
        success: (filePath) {
          _showMessage('导出成功');
          _showShareDialog(filePath);
        },
        failure: (message, exception) {
          _showMessage('导出失败：$message', isError: true);
        },
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportStatisticsReport() async {
    setState(() => _isLoading = true);

    try {
      final transactionsAsync = ref.read(transactionListProvider);
      final transactions = transactionsAsync.when(
        data: (data) => data,
        loading: () => <Transaction>[],
        error: (_, __) => <Transaction>[],
      );

      if (transactions.isEmpty) {
        _showMessage('没有可导出的数据', isError: true);
        return;
      }

      final now = DateTime.now();
      final dateRange = DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      );

      final result = await ExportService.exportStatisticsReport(
        transactions: transactions,
        dateRange: dateRange,
      );

      result.when(
        success: (filePath) {
          _showMessage('统计报告导出成功');
          _showShareDialog(filePath);
        },
        failure: (message, exception) {
          _showMessage('导出失败：$message', isError: true);
        },
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);

    try {
      final result = await BackupService.createFullBackup();

      result.when(
        success: (filePath) {
          _showMessage('备份创建成功');
          _loadBackupList();
          _showShareDialog(filePath);
        },
        failure: (message, exception) {
          _showMessage('备份失败：$message', isError: true);
        },
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreFromFile() async {
    setState(() => _isLoading = true);

    try {
      final result = await BackupService.restoreFromFilePicker();

      result.when(
        success: (restoreResult) {
          ref.refresh(transactionListProvider);
          _showMessage('恢复成功：已恢复${restoreResult.restoredTransactions}条记录');
          _loadBackupList();
        },
        failure: (message, exception) {
          _showMessage('恢复失败：$message', isError: true);
        },
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performAutoBackup() async {
    setState(() => _isLoading = true);

    try {
      final result = await BackupService.autoBackup();

      result.when(
        success: (filePath) {
          _showMessage('自动备份完成');
          _loadBackupList();
        },
        failure: (message, exception) {
          _showMessage('自动备份失败：$message', isError: true);
        },
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _manualSync() async {
    setState(() => _isLoading = true);

    try {
      final result = await SyncService.manualSync();

      result.when(
        success: (syncRecord) {
          ref.refresh(transactionListProvider);
          _showMessage('同步完成：上传${syncRecord.uploadedCount}条，下载${syncRecord.downloadedCount}条');
        },
        failure: (message, exception) {
          _showMessage('同步失败：$message', isError: true);
        },
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSyncHistory() {
    // 显示同步历史对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('同步历史'),
        content: const Text('同步历史功能正在开发中'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showBackupOptions(BackupInfo backup) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(FluentSystemIcons.ic_fluent_arrow_download_regular),
              title: const Text('恢复此备份'),
              onTap: () {
                Navigator.pop(context);
                _restoreBackup(backup);
              },
            ),
            ListTile(
              leading: const Icon(FluentSystemIcons.ic_fluent_share_regular),
              title: const Text('分享备份'),
              onTap: () {
                Navigator.pop(context);
                _shareBackup(backup);
              },
            ),
            ListTile(
              leading: const Icon(FluentSystemIcons.ic_fluent_delete_regular),
              title: const Text('删除备份'),
              textColor: AppColors.error,
              iconColor: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                _deleteBackup(backup);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restoreBackup(BackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认恢复'),
        content: const Text('恢复备份将覆盖当前所有数据，此操作无法撤销。确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final result = await BackupService.restoreFromBackup(backup.filePath);

      result.when(
        success: (restoreResult) {
          ref.refresh(transactionListProvider);
          _showMessage('恢复成功：已恢复${restoreResult.restoredTransactions}条记录');
        },
        failure: (message, exception) {
          _showMessage('恢复失败：$message', isError: true);
        },
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareBackup(BackupInfo backup) async {
    final result = await BackupService.shareBackup(backup.filePath);
    result.when(
      success: (_) => _showMessage('分享成功'),
      failure: (message, exception) => _showMessage('分享失败：$message', isError: true),
    );
  }

  Future<void> _deleteBackup(BackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除备份文件"${backup.fileName}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await BackupService.deleteBackup(backup.filePath);
    result.when(
      success: (_) {
        _showMessage('删除成功');
        _loadBackupList();
      },
      failure: (message, exception) => _showMessage('删除失败：$message', isError: true),
    );
  }

  void _showShareDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出成功'),
        content: const Text('文件已保存，是否要分享？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ExportService.shareExportedFile(filePath);
            },
            child: const Text('分享'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}