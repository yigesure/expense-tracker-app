import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../utils/logger.dart';

/// 无障碍性辅助工具
class AccessibilityHelper {
  AccessibilityHelper._();

  /// 为Widget添加语义标签
  static Widget semanticLabel({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool? button,
    bool? header,
    bool? textField,
    bool? focusable,
    bool? enabled,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onScrollLeft,
    VoidCallback? onScrollRight,
    VoidCallback? onScrollUp,
    VoidCallback? onScrollDown,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      header: header,
      textField: textField,
      focusable: focusable,
      enabled: enabled,
      onTap: onTap,
      onLongPress: onLongPress,
      onScrollLeft: onScrollLeft,
      onScrollRight: onScrollRight,
      onScrollUp: onScrollUp,
      onScrollDown: onScrollDown,
      child: child,
    );
  }

  /// 为按钮添加无障碍支持
  static Widget accessibleButton({
    required Widget child,
    required String label,
    String? hint,
    required VoidCallback? onPressed,
    bool enabled = true,
  }) {
    return semanticLabel(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      focusable: true,
      onTap: onPressed,
      child: child,
    );
  }

  /// 为文本输入框添加无障碍支持
  static Widget accessibleTextField({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool enabled = true,
  }) {
    return semanticLabel(
      label: label,
      hint: hint,
      value: value,
      textField: true,
      enabled: enabled,
      focusable: true,
      child: child,
    );
  }

  /// 为标题添加无障碍支持
  static Widget accessibleHeader({
    required Widget child,
    required String label,
    String? hint,
  }) {
    return semanticLabel(
      label: label,
      hint: hint,
      header: true,
      child: child,
    );
  }

  /// 为列表项添加无障碍支持
  static Widget accessibleListItem({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return semanticLabel(
      label: label,
      hint: hint,
      value: value,
      button: onTap != null,
      enabled: enabled,
      focusable: true,
      onTap: onTap,
      child: child,
    );
  }

  /// 为图片添加无障碍支持
  static Widget accessibleImage({
    required Widget child,
    required String label,
    String? hint,
  }) {
    return semanticLabel(
      label: label,
      hint: hint,
      child: child,
    );
  }

  /// 创建无障碍的分组容器
  static Widget accessibleGroup({
    required List<Widget> children,
    required String label,
    String? hint,
    Axis direction = Axis.vertical,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      container: true,
      child: direction == Axis.vertical
          ? Column(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              children: children,
            )
          : Row(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              children: children,
            ),
    );
  }

  /// 检查颜色对比度是否符合WCAG标准
  static bool checkColorContrast(Color foreground, Color background) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();
    
    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;
    
    final contrastRatio = (lighter + 0.05) / (darker + 0.05);
    
    // WCAG AA标准要求对比度至少为4.5:1
    const minContrastRatio = 4.5;
    final isAccessible = contrastRatio >= minContrastRatio;
    
    if (!isAccessible) {
      AppLogger.warning(
        'AccessibilityHelper',
        'Color contrast ratio $contrastRatio is below WCAG AA standard ($minContrastRatio)',
      );
    }
    
    return isAccessible;
  }

  /// 获取推荐的文本大小
  static double getRecommendedTextSize(BuildContext context, double baseSize) {
    final mediaQuery = MediaQuery.of(context);
    final textScaleFactor = mediaQuery.textScaler.scale(1.0);
    
    // 确保文本大小不小于14dp（无障碍最小推荐大小）
    const minTextSize = 14.0;
    final scaledSize = baseSize * textScaleFactor;
    
    return scaledSize < minTextSize ? minTextSize : scaledSize;
  }

  /// 获取推荐的触摸目标大小
  static Size getRecommendedTouchTargetSize(Size currentSize) {
    // WCAG推荐最小触摸目标大小为44x44dp
    const minTouchTarget = 44.0;
    
    return Size(
      currentSize.width < minTouchTarget ? minTouchTarget : currentSize.width,
      currentSize.height < minTouchTarget ? minTouchTarget : currentSize.height,
    );
  }

  /// 创建无障碍的触摸目标
  static Widget accessibleTouchTarget({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
    Size? minSize,
  }) {
    final targetSize = minSize ?? const Size(44, 44);
    
    return SizedBox(
      width: targetSize.width,
      height: targetSize.height,
      child: semanticLabel(
        label: label,
        hint: hint,
        button: onTap != null,
        focusable: true,
        onTap: onTap,
        child: Center(child: child),
      ),
    );
  }

  /// 为滚动视图添加无障碍支持
  static Widget accessibleScrollView({
    required Widget child,
    required String label,
    String? hint,
    Axis scrollDirection = Axis.vertical,
  }) {
    return semanticLabel(
      label: label,
      hint: hint,
      onScrollUp: scrollDirection == Axis.vertical ? () {} : null,
      onScrollDown: scrollDirection == Axis.vertical ? () {} : null,
      onScrollLeft: scrollDirection == Axis.horizontal ? () {} : null,
      onScrollRight: scrollDirection == Axis.horizontal ? () {} : null,
      child: child,
    );
  }

  /// 创建无障碍的表单字段
  static Widget accessibleFormField({
    required Widget child,
    required String label,
    String? hint,
    String? errorText,
    bool required = false,
  }) {
    final fullLabel = required ? '$label (必填)' : label;
    final fullHint = errorText != null 
        ? '${hint ?? ''} 错误: $errorText'.trim()
        : hint;

    return semanticLabel(
      label: fullLabel,
      hint: fullHint,
      textField: true,
      focusable: true,
      child: child,
    );
  }

  /// 创建无障碍的进度指示器
  static Widget accessibleProgressIndicator({
    required Widget child,
    required String label,
    String? hint,
    double? value,
  }) {
    final progressHint = value != null 
        ? '${hint ?? ''} 进度: ${(value * 100).round()}%'.trim()
        : hint ?? '加载中';

    return semanticLabel(
      label: label,
      hint: progressHint,
      value: value?.toString(),
      child: child,
    );
  }

  /// 创建无障碍的选择器
  static Widget accessibleSelector({
    required Widget child,
    required String label,
    String? hint,
    required String currentValue,
    VoidCallback? onTap,
  }) {
    return semanticLabel(
      label: label,
      hint: hint,
      value: '当前选择: $currentValue',
      button: true,
      focusable: true,
      onTap: onTap,
      child: child,
    );
  }

  /// 创建无障碍的开关
  static Widget accessibleSwitch({
    required Widget child,
    required String label,
    String? hint,
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    final switchHint = '${hint ?? ''} 当前状态: ${value ? '开启' : '关闭'}'.trim();
    
    return semanticLabel(
      label: label,
      hint: switchHint,
      value: value ? '开启' : '关闭',
      button: true,
      focusable: true,
      enabled: onChanged != null,
      onTap: onChanged != null ? () => onChanged(!value) : null,
      child: child,
    );
  }

  /// 创建无障碍的标签页
  static Widget accessibleTab({
    required Widget child,
    required String label,
    String? hint,
    required bool selected,
    VoidCallback? onTap,
  }) {
    final tabHint = '${hint ?? ''} ${selected ? '已选中' : '未选中'}'.trim();
    
    return semanticLabel(
      label: label,
      hint: tabHint,
      button: true,
      focusable: true,
      onTap: onTap,
      child: child,
    );
  }

  /// 无障碍性检查报告
  static Map<String, dynamic> generateAccessibilityReport(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    
    return {
      'textScaleFactor': mediaQuery.textScaler.scale(1.0),
      'platformBrightness': mediaQuery.platformBrightness.name,
      'accessibleNavigation': mediaQuery.accessibleNavigation,
      'invertColors': mediaQuery.invertColors,
      'highContrast': mediaQuery.highContrast,
      'disableAnimations': mediaQuery.disableAnimations,
      'boldText': mediaQuery.boldText,
      'devicePixelRatio': mediaQuery.devicePixelRatio,
      'themeColorScheme': {
        'primary': theme.colorScheme.primary.value.toRadixString(16),
        'onPrimary': theme.colorScheme.onPrimary.value.toRadixString(16),
        'surface': theme.colorScheme.surface.value.toRadixString(16),
        'onSurface': theme.colorScheme.onSurface.value.toRadixString(16),
      },
      'recommendations': _generateRecommendations(mediaQuery, theme),
    };
  }

  /// 生成无障碍性改进建议
  static List<String> _generateRecommendations(MediaQuery mediaQuery, ThemeData theme) {
    final recommendations = <String>[];
    
    // 检查文本缩放
    final textScale = mediaQuery.textScaler.scale(1.0);
    if (textScale > 1.3) {
      recommendations.add('用户使用了较大的文本缩放，确保UI布局能够适应');
    }
    
    // 检查高对比度模式
    if (mediaQuery.highContrast) {
      recommendations.add('用户启用了高对比度模式，确保颜色对比度足够');
    }
    
    // 检查动画禁用
    if (mediaQuery.disableAnimations) {
      recommendations.add('用户禁用了动画，确保功能不依赖动画效果');
    }
    
    // 检查粗体文本
    if (mediaQuery.boldText) {
      recommendations.add('用户启用了粗体文本，确保文本权重适当调整');
    }
    
    // 检查颜色对比度
    final primaryContrast = checkColorContrast(
      theme.colorScheme.onPrimary,
      theme.colorScheme.primary,
    );
    if (!primaryContrast) {
      recommendations.add('主要颜色的对比度不足，建议调整颜色方案');
    }
    
    return recommendations;
  }

  /// 启用无障碍性调试
  static void enableAccessibilityDebugging() {
    // 启用语义调试
    SemanticsBinding.instance.ensureSemantics();
    AppLogger.info('AccessibilityHelper', 'Accessibility debugging enabled');
  }

  /// 禁用无障碍性调试
  static void disableAccessibilityDebugging() {
    AppLogger.info('AccessibilityHelper', 'Accessibility debugging disabled');
  }
}

/// 无障碍性扩展
extension AccessibilityExtension on Widget {
  /// 为Widget添加语义标签的便捷方法
  Widget withSemantics({
    required String label,
    String? hint,
    String? value,
    bool? button,
    bool? header,
    bool? textField,
    VoidCallback? onTap,
  }) {
    return AccessibilityHelper.semanticLabel(
      label: label,
      hint: hint,
      value: value,
      button: button,
      header: header,
      textField: textField,
      onTap: onTap,
      child: this,
    );
  }

  /// 为按钮添加无障碍支持的便捷方法
  Widget asAccessibleButton({
    required String label,
    String? hint,
    VoidCallback? onPressed,
  }) {
    return AccessibilityHelper.accessibleButton(
      label: label,
      hint: hint,
      onPressed: onPressed,
      child: this,
    );
  }

  /// 为标题添加无障碍支持的便捷方法
  Widget asAccessibleHeader({
    required String label,
    String? hint,
  }) {
    return AccessibilityHelper.accessibleHeader(
      label: label,
      hint: hint,
      child: this,
    );
  }
}