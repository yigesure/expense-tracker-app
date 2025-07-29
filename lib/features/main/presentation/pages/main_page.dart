import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/bottom_navigation_bar.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../statistics/presentation/pages/statistics_page.dart';
import '../../../ai_assistant/presentation/pages/ai_assistant_page.dart';
import '../../../calendar/presentation/pages/calendar_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

/// 当前页面索引状态管理
final currentPageIndexProvider = StateProvider<int>((ref) => 0);

/// 主页面 - 包含底部导航栏和页面切换
class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentPageIndexProvider);
    
    // 页面列表
    const pages = [
      DashboardPage(),
      StatisticsPage(),
      AiAssistantPage(),
      CalendarPage(),
      SettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(currentPageIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}
