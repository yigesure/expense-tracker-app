import 'dart:io';

void main() async {
  print('开始修复Flutter代码问题...');
  
  // 修复withValues方法
  await fixWithValuesMethod();
  
  // 修复FluentSystemIcons图标
  await fixFluentIcons();
  
  print('修复完成！');
}

Future<void> fixWithValuesMethod() async {
  print('修复withValues方法...');
  
  final libDir = Directory('lib');
  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = await entity.readAsString();
      
      // 替换withValues(alpha: x)为withOpacity(x)
      content = content.replaceAllMapped(
        RegExp(r'\.withValues\(alpha:\s*([\d.]+)\)'),
        (match) => '.withOpacity(${match.group(1)})',
      );
      
      await entity.writeAsString(content);
    }
  }
}

Future<void> fixFluentIcons() async {
  print('修复FluentSystemIcons图标...');
  
  final iconMappings = {
    'ic_fluent_mic_regular': 'ic_fluent_mic_20_regular',
    'ic_fluent_calendar_ltr_20_regular': 'ic_fluent_calendar_20_regular',
    'ic_fluent_receipt_20_regular': 'ic_fluent_receipt_20_regular',
    'ic_fluent_eye_regular': 'ic_fluent_eye_20_regular',
    'ic_fluent_arrow_down_20_filled': 'ic_fluent_arrow_down_20_filled',
    'ic_fluent_wallet_20_filled': 'ic_fluent_wallet_20_filled',
    'ic_fluent_chart_multiple_20_filled': 'ic_fluent_chart_multiple_20_filled',
    'ic_fluent_more_horizontal_20_regular': 'ic_fluent_more_horizontal_20_regular',
    'ic_fluent_money_20_regular': 'ic_fluent_money_20_regular',
    'ic_fluent_mic_20_regular': 'ic_fluent_mic_20_regular',
    'ic_fluent_brain_20_regular': 'ic_fluent_brain_20_regular',
    'ic_fluent_cloud_20_regular': 'ic_fluent_cloud_20_regular',
    'ic_fluent_document_arrow_up_20_regular': 'ic_fluent_document_arrow_up_20_regular',
    'ic_fluent_broom_20_regular': 'ic_fluent_broom_20_regular',
    'ic_fluent_question_circle_20_regular': 'ic_fluent_question_circle_20_regular',
    'ic_fluent_arrow_up_20_regular': 'ic_fluent_arrow_up_20_regular',
    'ic_fluent_savings_20_regular': 'ic_fluent_savings_20_regular',
  };
  
  final libDir = Directory('lib');
  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = await entity.readAsString();
      bool changed = false;
      
      iconMappings.forEach((oldIcon, newIcon) {
        if (content.contains(oldIcon)) {
          content = content.replaceAll(oldIcon, newIcon);
          changed = true;
        }
      });
      
      if (changed) {
        await entity.writeAsString(content);
      }
    }
  }
}