import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import 'material3_theme.dart';

/// 主题模式枚举
enum AppThemeMode {
  light('light', '浅色模式'),
  dark('dark', '深色模式'),
  system('system', '跟随系统');

  const AppThemeMode(this.value, this.label);
  
  final String value;
  final String label;
}

/// 主题管理器
class ThemeManager extends StateNotifier<AppThemeMode> {
  static const String _themeKey = 'app_theme_mode';
  
  ThemeManager() : super(AppThemeMode.system) {
    _loadTheme();
  }

  /// 加载保存的主题设置
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeValue = prefs.getString(_themeKey);
      
      if (themeValue != null) {
        final themeMode = AppThemeMode.values.firstWhere(
          (mode) => mode.value == themeValue,
          orElse: () => AppThemeMode.system,
        );
        state = themeMode;
        AppLogger.info('ThemeManager', 'Loaded theme: ${themeMode.label}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('ThemeManager', 'Error loading theme: $e', stackTrace);
    }
  }

  /// 设置主题模式
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeMode.value);
      state = themeMode;
      AppLogger.info('ThemeManager', 'Theme changed to: ${themeMode.label}');
    } catch (e, stackTrace) {
      AppLogger.error('ThemeManager', 'Error saving theme: $e', stackTrace);
    }
  }

  /// 切换到下一个主题模式
  Future<void> toggleTheme() async {
    final nextTheme = switch (state) {
      AppThemeMode.light => AppThemeMode.dark,
      AppThemeMode.dark => AppThemeMode.system,
      AppThemeMode.system => AppThemeMode.light,
    };
    await setThemeMode(nextTheme);
  }

  /// 获取Flutter的ThemeMode
  ThemeMode get flutterThemeMode {
    return switch (state) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };
  }

  /// 判断当前是否为深色模式
  bool isDarkMode(BuildContext context) {
    return switch (state) {
      AppThemeMode.light => false,
      AppThemeMode.dark => true,
      AppThemeMode.system => MediaQuery.of(context).platformBrightness == Brightness.dark,
    };
  }

  /// 获取当前主题数据
  ThemeData getCurrentTheme(BuildContext context) {
    return isDarkMode(context) 
        ? Material3Theme.darkTheme 
        : Material3Theme.lightTheme;
  }
}

/// 主题管理器Provider
final themeManagerProvider = StateNotifierProvider<ThemeManager, AppThemeMode>(
  (ref) => ThemeManager(),
);

/// 当前主题模式Provider
final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  final themeMode = ref.watch(themeManagerProvider);
  return switch (themeMode) {
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.system => ThemeMode.system,
  };
});

/// 主题切换Widget
class ThemeToggleButton extends ConsumerWidget {
  final bool showLabel;
  final EdgeInsetsGeometry? padding;

  const ThemeToggleButton({
    super.key,
    this.showLabel = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeManagerProvider);
    final themeManager = ref.read(themeManagerProvider.notifier);

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: showLabel
          ? ListTile(
              leading: Icon(_getThemeIcon(currentTheme)),
              title: const Text('主题模式'),
              subtitle: Text(currentTheme.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeDialog(context, themeManager, currentTheme),
            )
          : IconButton(
              icon: Icon(_getThemeIcon(currentTheme)),
              tooltip: '切换主题: ${currentTheme.label}',
              onPressed: () => themeManager.toggleTheme(),
            ),
    );
  }

  IconData _getThemeIcon(AppThemeMode themeMode) {
    return switch (themeMode) {
      AppThemeMode.light => Icons.light_mode,
      AppThemeMode.dark => Icons.dark_mode,
      AppThemeMode.system => Icons.brightness_auto,
    };
  }

  void _showThemeDialog(
    BuildContext context,
    ThemeManager themeManager,
    AppThemeMode currentTheme,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(mode.label),
              subtitle: Text(_getThemeDescription(mode)),
              value: mode,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  themeManager.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  String _getThemeDescription(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.light => '始终使用浅色主题',
      AppThemeMode.dark => '始终使用深色主题',
      AppThemeMode.system => '跟随系统设置',
    };
  }
}

/// 主题感知Widget - 根据主题变化自动重建
class ThemeAwareBuilder extends ConsumerWidget {
  final Widget Function(BuildContext context, ThemeData theme, bool isDark) builder;

  const ThemeAwareBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeManager = ref.read(themeManagerProvider.notifier);
    final isDark = themeManager.isDarkMode(context);
    final theme = themeManager.getCurrentTheme(context);
    
    return builder(context, theme, isDark);
  }
}

/// 动态颜色支持
class DynamicColorBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ColorScheme? lightColorScheme, ColorScheme? darkColorScheme) builder;

  const DynamicColorBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // 这里可以集成dynamic_color包来支持Material You动态颜色
    // 目前返回null，使用默认颜色方案
    return builder(context, null, null);
  }
}

/// 主题工具类
class ThemeUtils {
  ThemeUtils._();

  /// 获取对比色
  static Color getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// 获取颜色的明暗变体
  static Color getLighterColor(Color color, [double factor = 0.1]) {
    return Color.lerp(color, Colors.white, factor) ?? color;
  }

  static Color getDarkerColor(Color color, [double factor = 0.1]) {
    return Color.lerp(color, Colors.black, factor) ?? color;
  }

  /// 检查颜色是否为深色
  static bool isDarkColor(Color color) {
    return color.computeLuminance() < 0.5;
  }

  /// 获取Material 3色调变体
  static Color getTonalColor(Color baseColor, double tone) {
    // 简化的色调计算，实际应用中可以使用material_color_utilities包
    final hsl = HSLColor.fromColor(baseColor);
    return hsl.withLightness(tone / 100).toColor();
  }

  /// 生成Material 3配色方案
  static ColorScheme generateColorScheme({
    required Color seedColor,
    required Brightness brightness,
  }) {
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
  }

  /// 获取表面颜色变体
  static Color getSurfaceVariant(ColorScheme colorScheme, int level) {
    // level: 0-5, 0为最浅，5为最深
    final baseColor = colorScheme.surface;
    final overlayColor = colorScheme.surfaceTint;
    final opacity = (level * 0.05).clamp(0.0, 0.3);
    
    return Color.alphaBlend(
      overlayColor.withOpacity(opacity),
      baseColor,
    );
  }

  /// 获取状态层颜色
  static Color getStateLayerColor(Color baseColor, double opacity) {
    return baseColor.withOpacity(opacity);
  }

  /// Material 3状态层透明度常量
  static const double hoverOpacity = 0.08;
  static const double focusOpacity = 0.12;
  static const double pressedOpacity = 0.12;
  static const double draggedOpacity = 0.16;
  static const double selectedOpacity = 0.12;
  static const double disabledOpacity = 0.12;
}

/// 主题动画Widget
class ThemeTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ThemeTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<ThemeTransition> createState() => _ThemeTransitionState();
}

class _ThemeTransitionState extends State<ThemeTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ThemeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: widget.child,
    );
  }
}