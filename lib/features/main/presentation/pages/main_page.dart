import 'package:flutter/material.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../statistics/presentation/pages/statistics_page.dart';
import '../../../ai_assistant/presentation/pages/ai_assistant_page.dart';
import '../../../calendar/presentation/pages/calendar_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../../core/widgets/bottom_navigation_bar.dart';

/// 主页面 - 包含底部导航栏和各个页面
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    StatisticsPage(),
    AiAssistantPage(),
    CalendarPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}