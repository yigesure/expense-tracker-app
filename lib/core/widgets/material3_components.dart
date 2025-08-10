import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/animation_optimizer.dart';

/// Material 3 统一组件库
class M3Components {
  M3Components._();

  /// 主要按钮（Filled Button）
  static Widget primaryButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
    EdgeInsetsGeometry? padding,
  }) {
    return SizedBox(
      width: width,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }

  /// 次要按钮（Filled Tonal Button）
  static Widget secondaryButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
    EdgeInsetsGeometry? padding,
  }) {
    return SizedBox(
      width: width,
      child: FilledButton.tonal(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }

  /// 轮廓按钮（Outlined Button）
  static Widget outlinedButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
    EdgeInsetsGeometry? padding,
  }) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }

  /// 文本按钮
  static Widget textButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    EdgeInsetsGeometry? padding,
  }) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(text),
              ],
            ),
    );
  }

  /// 标准卡片
  static Widget card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    Color? color,
    double? elevation,
  }) {
    final cardWidget = Card(
      color: color,
      elevation: elevation,
      margin: margin ?? const EdgeInsets.all(8),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      return OptimizedTapAnimation(
        onTap: onTap,
        child: cardWidget,
      );
    }

    return cardWidget;
  }

  /// 填充卡片
  static Widget filledCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    Color? color,
  }) {
    return Card.filled(
      color: color,
      margin: margin ?? const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  /// 轮廓卡片
  static Widget outlinedCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    Color? color,
  }) {
    return Card.outlined(
      color: color,
      margin: margin ?? const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  /// 输入框
  static Widget textField({
    required String label,
    String? hint,
    TextEditingController? controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
    int? maxLines = 1,
    bool enabled = true,
    VoidCallback? onTap,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      enabled: enabled,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }

  /// 搜索框
  static Widget searchField({
    required String hint,
    TextEditingController? controller,
    Function(String)? onChanged,
    VoidCallback? onClear,
  }) {
    return SearchBar(
      controller: controller,
      hintText: hint,
      onChanged: onChanged,
      leading: const Icon(Icons.search),
      trailing: controller?.text.isNotEmpty == true
          ? [
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller?.clear();
                  onClear?.call();
                },
              ),
            ]
          : null,
    );
  }

  /// 列表项
  static Widget listTile({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    bool selected = false,
    bool enabled = true,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      leading: leading,
      trailing: trailing,
      onTap: enabled ? onTap : null,
      selected: selected,
      enabled: enabled,
    );
  }

  /// 开关列表项
  static Widget switchListTile({
    required String title,
    String? subtitle,
    Widget? secondary,
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool enabled = true,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      secondary: secondary,
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }

  /// 复选框列表项
  static Widget checkboxListTile({
    required String title,
    String? subtitle,
    Widget? secondary,
    required bool? value,
    required ValueChanged<bool?>? onChanged,
    bool enabled = true,
  }) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      secondary: secondary,
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }

  /// 单选按钮列表项
  static Widget radioListTile<T>({
    required String title,
    String? subtitle,
    Widget? secondary,
    required T value,
    required T? groupValue,
    required ValueChanged<T?>? onChanged,
    bool enabled = true,
  }) {
    return RadioListTile<T>(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      secondary: secondary,
      value: value,
      groupValue: groupValue,
      onChanged: enabled ? onChanged : null,
    );
  }

  /// 芯片
  static Widget chip({
    required String label,
    Widget? avatar,
    VoidCallback? onDeleted,
    VoidCallback? onPressed,
    bool selected = false,
  }) {
    if (onPressed != null) {
      return ActionChip(
        label: Text(label),
        avatar: avatar,
        onPressed: onPressed,
      );
    } else if (selected) {
      return FilterChip(
        label: Text(label),
        avatar: avatar,
        selected: selected,
        onSelected: (_) {},
        onDeleted: onDeleted,
      );
    } else {
      return Chip(
        label: Text(label),
        avatar: avatar,
        onDeleted: onDeleted,
      );
    }
  }

  /// 浮动操作按钮
  static Widget fab({
    required VoidCallback onPressed,
    required IconData icon,
    String? tooltip,
    bool extended = false,
    String? label,
  }) {
    if (extended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        tooltip: tooltip,
      );
    }
    
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }

  /// 小型浮动操作按钮
  static Widget smallFab({
    required VoidCallback onPressed,
    required IconData icon,
    String? tooltip,
  }) {
    return FloatingActionButton.small(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }

  /// 大型浮动操作按钮
  static Widget largeFab({
    required VoidCallback onPressed,
    required IconData icon,
    String? tooltip,
  }) {
    return FloatingActionButton.large(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }

  /// 底部表单
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    double? height,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: height != null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: height,
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  /// 对话框
  static Future<T?> showDialog<T>({
    required BuildContext context,
    required String title,
    String? content,
    Widget? contentWidget,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showAdaptiveDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: contentWidget ?? (content != null ? Text(content) : null),
        actions: actions,
      ),
    );
  }

  /// 确认对话框
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    String? content,
    String confirmText = '确定',
    String cancelText = '取消',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      title: title,
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                )
              : null,
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// 加载指示器
  static Widget loadingIndicator({
    String? message,
    double size = 24,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OptimizedLoadingAnimation(size: size),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// 空状态
  static Widget emptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }

  /// 错误状态
  static Widget errorState({
    required String title,
    String? subtitle,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              outlinedButton(
                text: '重试',
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}