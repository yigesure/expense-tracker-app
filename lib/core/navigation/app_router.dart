import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/ai_assistant/presentation/pages/ai_assistant_page.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

/// 应用路由配置
class AppRouter {
  static const String dashboard = '/dashboard';
  static const String statistics = '/statistics';
  static const String aiAssistant = '/ai-assistant';
  static const String calendar = '/calendar';
  static const String settings = '/settings';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/dashboard':
        return _createRoute(const DashboardPage());
      case '/statistics':
        return _createRoute(const StatisticsPage());
      case '/ai-assistant':
        return _createRoute(const AiAssistantPage());
      case '/calendar':
        return _createRoute(const CalendarPage());
      case '/settings':
        return _createRoute(const SettingsPage());
      default:
        return _createRoute(const DashboardPage());
    }
  }
  
  static PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}