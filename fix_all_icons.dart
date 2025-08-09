import 'dart:io';

void main() async {
  // 图标映射表
  final iconMappings = {
    'FluentSystemIcons.ic_fluent_add_filled': 'Icons.add',
    'FluentSystemIcons.ic_fluent_add_circle_filled': 'Icons.add_circle',
    'FluentSystemIcons.ic_fluent_arrow_up_filled': 'Icons.arrow_upward',
    'FluentSystemIcons.ic_fluent_arrow_down_filled': 'Icons.arrow_downward',
    'FluentSystemIcons.ic_fluent_arrow_up_regular': 'Icons.arrow_upward_outlined',
    'FluentSystemIcons.ic_fluent_arrow_down_regular': 'Icons.arrow_downward_outlined',
    'FluentSystemIcons.ic_fluent_arrow_left_regular': 'Icons.arrow_back',
    'FluentSystemIcons.ic_fluent_arrow_swap_filled': 'Icons.swap_horiz',
    'FluentSystemIcons.ic_fluent_search_regular': 'Icons.search',
    'FluentSystemIcons.ic_fluent_arrow_sort_regular': 'Icons.sort',
    'FluentSystemIcons.ic_fluent_receipt_regular': 'Icons.receipt_outlined',
    'FluentSystemIcons.ic_fluent_calendar_regular': 'Icons.calendar_today_outlined',
    'FluentSystemIcons.ic_fluent_edit_regular': 'Icons.edit_outlined',
    'FluentSystemIcons.ic_fluent_delete_regular': 'Icons.delete_outlined',
    'FluentSystemIcons.ic_fluent_tag_regular': 'Icons.label_outlined',
    'FluentSystemIcons.ic_fluent_clock_regular': 'Icons.access_time',
    'FluentSystemIcons.ic_fluent_note_regular': 'Icons.note_outlined',
    'FluentSystemIcons.ic_fluent_chevron_right_regular': 'Icons.chevron_right',
    'FluentSystemIcons.ic_fluent_chevron_left_regular': 'Icons.chevron_left',
    'FluentSystemIcons.ic_fluent_bot_filled': 'Icons.smart_toy',
    'FluentSystemIcons.ic_fluent_person_filled': 'Icons.person',
    'FluentSystemIcons.ic_fluent_mic_regular': 'Icons.mic_outlined',
    'FluentSystemIcons.ic_fluent_send_filled': 'Icons.send',
    'FluentSystemIcons.ic_fluent_chat_filled': 'Icons.chat',
    'FluentSystemIcons.ic_fluent_settings_regular': 'Icons.settings_outlined',
    'FluentSystemIcons.ic_fluent_lightbulb_regular': 'Icons.lightbulb_outlined',
    'FluentSystemIcons.ic_fluent_chat_help_filled': 'Icons.help',
    'FluentSystemIcons.ic_fluent_target_filled': 'Icons.track_changes',
    'FluentSystemIcons.ic_fluent_alert_regular': 'Icons.notifications_outlined',
    'FluentSystemIcons.ic_fluent_document_regular': 'Icons.description_outlined',
    'FluentSystemIcons.ic_fluent_document_text_regular': 'Icons.article_outlined',
    'FluentSystemIcons.ic_fluent_chart_multiple_regular': 'Icons.bar_chart',
    'FluentSystemIcons.ic_fluent_document_bullet_list_regular': 'Icons.list_alt',
    'FluentSystemIcons.ic_fluent_table_regular': 'Icons.table_chart',
  };

  // 需要处理的文件列表
  final filesToProcess = [
    'lib/features/transaction/presentation/pages/transaction_list_page.dart',
    'lib/features/transaction/presentation/pages/transaction_edit_page.dart',
    'lib/features/transaction/presentation/pages/transaction_detail_page.dart',
    'lib/features/transaction/presentation/pages/add_transaction_page.dart',
    'lib/features/dashboard/presentation/widgets/recent_transactions.dart',
    'lib/features/dashboard/presentation/widgets/quick_input_bar.dart',
    'lib/features/dashboard/presentation/widgets/quick_actions.dart',
    'lib/features/dashboard/presentation/widgets/balance_card.dart',
    'lib/features/dashboard/presentation/pages/dashboard_page.dart',
    'lib/features/calendar/presentation/pages/calendar_page.dart',
    'lib/features/ai_assistant/presentation/pages/ai_chat_page.dart',
    'lib/features/ai_assistant/presentation/pages/ai_assistant_page.dart',
  ];

  print('开始批量修复FluentSystemIcons引用...');
  
  for (final filePath in filesToProcess) {
    final file = File(filePath);
    if (await file.exists()) {
      print('处理文件: $filePath');
      
      String content = await file.readAsString();
      
      // 移除FluentSystemIcons导入
      content = content.replaceAll(
        RegExp(r"import 'package:fluentui_icons/fluentui_icons\.dart';\s*\n"),
        ''
      );
      
      // 替换所有图标引用
      iconMappings.forEach((oldIcon, newIcon) {
        content = content.replaceAll(oldIcon, newIcon);
      });
      
      await file.writeAsString(content);
      print('✓ 已修复: $filePath');
    } else {
      print('✗ 文件不存在: $filePath');
    }
  }
  
  print('批量修复完成！');
}