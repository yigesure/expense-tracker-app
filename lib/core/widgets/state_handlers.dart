import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/material3_components.dart';

/// 空状态Widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? illustration;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionText,
    this.onAction,
    this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 插图或图标
            if (illustration != null)
              illustration!
            else if (icon != null)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.gradientPurpleStart.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: AppColors.gradientPurpleStart,
                ),
              ),
            
            const SizedBox(height: 24),
            
            // 标题
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              M3Components.elevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 加载状态Widget
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool showProgress;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showProgress)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.gradientPurpleStart),
            ),
          
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// 错误状态Widget
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onRetry;
  final bool showIcon;

  const ErrorStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onRetry,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  FluentSystemIcons.ic_fluent_error_circle_regular,
                  size: 40,
                  color: AppColors.error,
                ),
              ),
            
            const SizedBox(height: 24),
            
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            if (actionText != null && onRetry != null) ...[
              const SizedBox(height: 24),
              M3Components.elevatedButton(
                onPressed: onRetry,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 异步状态构建器
class AsyncStateBuilder<T> extends StatelessWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(T data) dataBuilder;
  final Widget? loadingWidget;
  final Widget Function(Object error, StackTrace stackTrace)? errorBuilder;
  final String? loadingMessage;
  final String? emptyTitle;
  final String? emptySubtitle;
  final VoidCallback? onRetry;

  const AsyncStateBuilder({
    super.key,
    required this.asyncValue,
    required this.dataBuilder,
    this.loadingWidget,
    this.errorBuilder,
    this.loadingMessage,
    this.emptyTitle,
    this.emptySubtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: (data) {
        // 检查数据是否为空
        if (data is List && (data as List).isEmpty) {
          return EmptyStateWidget(
            title: emptyTitle ?? '暂无数据',
            subtitle: emptySubtitle,
            icon: FluentSystemIcons.ic_fluent_document_regular,
            actionText: onRetry != null ? '重新加载' : null,
            onAction: onRetry,
          );
        }
        return dataBuilder(data);
      },
      loading: () => loadingWidget ?? LoadingStateWidget(message: loadingMessage),
      error: (error, stackTrace) {
        if (errorBuilder != null) {
          return errorBuilder!(error, stackTrace);
        }
        return ErrorStateWidget(
          title: '加载失败',
          subtitle: error.toString(),
          actionText: '重试',
          onRetry: onRetry,
        );
      },
    );
  }
}

/// 网络状态Widget
class NetworkStateWidget extends StatelessWidget {
  final bool isConnected;
  final VoidCallback? onRetry;

  const NetworkStateWidget({
    super.key,
    required this.isConnected,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isConnected) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.warning,
      child: Row(
        children: [
          const Icon(
            FluentSystemIcons.ic_fluent_wifi_off_regular,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '网络连接不可用',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text(
                '重试',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

/// 搜索状态Widget
class SearchStateWidget extends StatelessWidget {
  final String query;
  final int resultCount;
  final VoidCallback? onClear;

  const SearchStateWidget({
    super.key,
    required this.query,
    required this.resultCount,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: Row(
        children: [
          const Icon(
            FluentSystemIcons.ic_fluent_search_regular,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '搜索 "$query" 找到 $resultCount 条结果',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (onClear != null)
            IconButton(
              onPressed: onClear,
              icon: const Icon(
                Icons.clear,
                size: 16,
                color: AppColors.textSecondary,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }
}

/// 刷新指示器Widget
class RefreshIndicatorWidget extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? refreshText;

  const RefreshIndicatorWidget({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshText,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.gradientPurpleStart,
      backgroundColor: AppColors.surface,
      child: child,
    );
  }
}