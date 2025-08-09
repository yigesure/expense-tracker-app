import 'dart:math';
import '../models/transaction.dart';
import 'package:uuid/uuid.dart';

class NLPService {
  static final Map<String, String> _categoryKeywords = {
    '餐饮': '吃饭,午饭,晚饭,早饭,餐厅,外卖,快餐,咖啡,奶茶,饮料,红牛,可乐,水,面包,蛋糕',
    '交通': '公交,地铁,打车,滴滴,出租车,汽油,加油,停车,高速,过路费,火车,飞机',
    '购物': '买,购买,商场,超市,淘宝,京东,衣服,鞋子,包包,化妆品,日用品',
    '娱乐': '电影,KTV,游戏,网吧,酒吧,旅游,景点,门票,演唱会',
    '医疗': '医院,药店,看病,体检,药品,挂号费,治疗费',
    '教育': '学费,培训,书籍,文具,课程,补习',
    '生活': '房租,水电费,网费,话费,物业费,维修',
    '其他': '其他,杂项,未分类'
  };

  static final Map<String, String> _categoryIcons = {
    '餐饮': '🍜',
    '交通': '🚇',
    '购物': '🛍️',
    '娱乐': '🎬',
    '医疗': '🏥',
    '教育': '📚',
    '生活': '🏠',
    '其他': '📝'
  };

  static List<Transaction> parseNaturalLanguage(String input) {
    final List<Transaction> transactions = [];
    final uuid = const Uuid();
    
    // 清理输入文本
    String cleanInput = input.replaceAll(RegExp(r'[，。！？；：]'), ',');
    
    // 按逗号分割
    final parts = cleanInput.split(',').where((part) => part.trim().isNotEmpty);
    
    for (String part in parts) {
      final transaction = _parseSingleTransaction(part.trim(), uuid);
      if (transaction != null) {
        transactions.add(transaction);
      }
    }
    
    return transactions;
  }

  static Transaction? _parseSingleTransaction(String text, Uuid uuid) {
    // 提取金额的正则表达式
    final amountRegex = RegExp(r'(\d+(?:\.\d+)?)[元块钱]?');
    final match = amountRegex.firstMatch(text);
    
    if (match == null) return null;
    
    final amount = double.tryParse(match.group(1)!) ?? 0.0;
    if (amount <= 0) return null;
    
    // 提取描述（去掉金额部分）
    String description = text.replaceAll(amountRegex, '').trim();
    if (description.isEmpty) {
      description = '消费记录';
    }
    
    // 智能分类
    final category = _categorizeTransaction(description);
    
    return Transaction(
      id: uuid.v4(),
      title: description,
      amount: amount,
      category: category,
      categoryIcon: _categoryIcons[category] ?? '📝',
      date: DateTime.now(),
      type: TransactionType.expense,
    );
  }

  static String _categorizeTransaction(String description) {
    final lowerDescription = description.toLowerCase();
    
    for (final entry in _categoryKeywords.entries) {
      final keywords = entry.value.split(',');
      for (final keyword in keywords) {
        if (lowerDescription.contains(keyword.toLowerCase())) {
          return entry.key;
        }
      }
    }
    
    return '其他';
  }

  static List<String> getSuggestions(String input) {
    final suggestions = <String>[];
    
    if (input.isEmpty) {
      suggestions.addAll([
        '午饭25元',
        '公交2元',
        '咖啡15元',
        '电影票35元',
        '超市购物68元'
      ]);
    } else {
      // 基于输入提供智能建议
      final lowerInput = input.toLowerCase();
      
      if (lowerInput.contains('饭') || lowerInput.contains('吃')) {
        suggestions.addAll(['午饭20元', '晚饭35元', '早饭8元']);
      } else if (lowerInput.contains('车') || lowerInput.contains('交通')) {
        suggestions.addAll(['公交2元', '地铁3元', '打车15元']);
      } else if (lowerInput.contains('买') || lowerInput.contains('购')) {
        suggestions.addAll(['超市购物50元', '衣服200元', '日用品30元']);
      }
    }
    
    return suggestions.take(5).toList();
  }
}