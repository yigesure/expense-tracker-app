import 'package:flutter/material.dart';

/// 应用主题色彩系统
class AppColors {
  // 主色调 - 奶油白
  static const Color creamWhite = Color(0xFFFFF8F0);
  static const Color pureWhite = Color(0xFFFFFFFF);
  
  // 辅助色 - 粉蓝
  static const Color softBlue = Color(0xFFA8D8EA);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color deepBlue = Color(0xFF7BB3F0);
  
  // 强调色 - 渐变紫
  static const Color gradientPurpleStart = Color(0xFFAA96DA);
  static const Color gradientPurpleEnd = Color(0xFFFCBAD3);
  static const Color lightPurple = Color(0xFFE1BEE7);
  static const Color deepPurple = Color(0xFF9C27B0);
  
  // 功能色彩
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // 收入支出色彩
  static const Color income = Color(0xFF66BB6A);
  static const Color expense = Color(0xFFEF5350);
  
  // 中性色
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  
  // 阴影色
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
  
  // 渐变定义
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientPurpleStart, gradientPurpleEnd],
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightBlue, softBlue],
  );
  
  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
  );
  
  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE57373), Color(0xFFF44336)],
  );
}