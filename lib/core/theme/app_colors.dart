import 'package:flutter/material.dart';

/// 应用主题色彩系统
/// 
/// 提供统一的颜色定义和渐变效果，确保整个应用的视觉一致性
class AppColors {
  /// 私有构造函数，防止实例化
  AppColors._();

  // 主色调 - 奶油白
  /// 奶油白色，用于背景和卡片
  static const Color creamWhite = Color(0xFFFFF8F0);
  
  /// 纯白色，用于表面和高亮
  static const Color pureWhite = Color(0xFFFFFFFF);
  
  // 辅助色 - 粉蓝
  /// 柔和蓝色，用于辅助元素
  static const Color softBlue = Color(0xFFA8D8EA);
  
  /// 浅蓝色，用于背景和装饰
  static const Color lightBlue = Color(0xFFE3F2FD);
  
  /// 深蓝色，用于强调和按钮
  static const Color deepBlue = Color(0xFF7BB3F0);
  
  // 强调色 - 渐变紫
  /// 渐变紫色起始色
  static const Color gradientPurpleStart = Color(0xFF2563EB);
  
  /// 渐变紫色结束色
  static const Color gradientPurpleEnd = Color(0xFF22D3EE);
  
  /// 浅紫色，用于装饰
  static const Color lightPurple = Color(0xFFE1BEE7);
  
  /// 深紫色，用于强调
  static const Color deepPurple = Color(0xFF9C27B0);
  
  // 功能色彩
  /// 成功状态颜色
  static const Color success = Color(0xFF4CAF50);
  
  /// 警告状态颜色
  static const Color warning = Color(0xFFFF9800);
  
  /// 错误状态颜色
  static const Color error = Color(0xFFF44336);
  
  /// 信息状态颜色
  static const Color info = Color(0xFF2196F3);
  
  // 收入支出色彩
  /// 收入颜色，绿色系
  static const Color income = Color(0xFF66BB6A);
  
  /// 支出颜色，红色系
  static const Color expense = Color(0xFFEF5350);
  
  // 中性色
  /// 主要文本颜色
  static const Color textPrimary = Color(0xFF212121);
  
  /// 次要文本颜色
  static const Color textSecondary = Color(0xFF757575);
  
  /// 提示文本颜色
  static const Color textHint = Color(0xFFBDBDBD);
  
  /// 分割线颜色
  static const Color divider = Color(0xFFE0E0E0);
  
  /// 背景颜色
  static const Color background = Color(0xFFFAFAFA);
  
  /// 表面颜色
  static const Color surface = Color(0xFFFFFFFF);
  
  // 阴影色
  /// 浅阴影颜色
  static const Color shadowLight = Color(0x0F000000);
  
  /// 中等阴影颜色
  static const Color shadowMedium = Color(0x1A000000);
  
  /// 深阴影颜色
  static const Color shadowDark = Color(0x33000000);
  
  // 渐变定义
  /// 主要渐变效果
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[gradientPurpleStart, gradientPurpleEnd],
  );
  
  /// 蓝色渐变效果
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[lightBlue, softBlue],
  );
  
  /// 收入渐变效果
  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF81C784), Color(0xFF4CAF50)],
  );
  
  /// 支出渐变效果
  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFFE57373), Color(0xFFF44336)],
  );
}
