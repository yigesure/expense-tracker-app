import 'package:flutter/material.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../statistics/presentation/pages/statistics_page.dart';
import '../../../ai_assistant/presentation/pages/ai_assistant_page.dart';
import '../../../calendar/presentation/pages/calendar_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../transaction/presentation/pages/add_transaction_page.dart';
import '../../../../core/widgets/bottom_navigation_bar.dart';
import '../../../../core/widgets/quick_add_fab.dart';
import '../../../dashboard/presentation/widgets/quick_input_bar.dart';

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
      floatingActionButton: QuickAddFAB(
        onAddTransaction: _navigateToAddTransaction,
        onQuickInput: _showQuickInput,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _navigateToAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTransactionPage(),
      ),
    );
  }

  void _showQuickInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickInputBar(),
    );
  }
}
