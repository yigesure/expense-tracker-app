import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/material3_theme.dart';
import 'core/theme/theme_manager.dart';
import 'core/theme/app_colors.dart';
import 'core/services/transaction_service.dart';
import 'core/services/crash_reporting_service.dart';
import 'core/utils/image_cache_manager.dart';
import 'core/utils/animation_optimizer.dart';
import 'core/utils/logger.dart';
import 'core/widgets/state_widgets.dart';
import 'features/main/presentation/pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化崩溃报告服务（必须最先初始化）
  await CrashReportingService.initialize();
  
  // 使用安全执行包装初始化过程
  await ExceptionHandler.safeAsync(() async {
    // 初始化Hive数据库
    await Hive.initFlutter();
    
    // 初始化交易服务
    await TransactionService.init();
    
    // 初始化性能优化组件
    await ImageCacheManager.warmUpCache();
    AnimationPerformanceMonitor.startMonitoring();
  }, context: 'App初始化');
  
  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // 设置首选方向为竖屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // 在Zone中运行应用，捕获所有未处理的异常
  runZonedGuarded(
    () {
      runApp(
        const ProviderScope(
          child: ExpenseTrackerApp(),
        ),
      );
    },
    (error, stackTrace) {
      CrashReportingService.recordException(
        error,
        stackTrace: stackTrace,
        context: 'App运行时异常',
        isFatal: true,
      );
    },
  );
}

class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(currentThemeModeProvider);
    
    return DynamicColorBuilder(
      builder: (context, lightColorScheme, darkColorScheme) {
        return MaterialApp(
          title: '个人记账助手',
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationService.navigatorKey,
          theme: lightColorScheme != null
              ? Material3Theme.lightTheme.copyWith(colorScheme: lightColorScheme)
              : Material3Theme.lightTheme,
          darkTheme: darkColorScheme != null
              ? Material3Theme.darkTheme.copyWith(colorScheme: darkColorScheme)
              : Material3Theme.darkTheme,
          themeMode: themeMode,
          home: const ThemeTransition(child: MainPage()),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0), // 修复已弃用的textScaleFactor
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
