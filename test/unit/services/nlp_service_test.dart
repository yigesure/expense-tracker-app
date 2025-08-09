import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app/core/services/nlp_service.dart';
import 'package:expense_tracker_app/core/models/transaction.dart';

void main() {
  group('NLPService Tests', () {
    test('should parse single transaction correctly', () {
      final transactions = NLPService.parseNaturalLanguage('午饭25元');
      
      expect(transactions.length, 1);
      expect(transactions.first.title, '午饭');
      expect(transactions.first.amount, 25.0);
      expect(transactions.first.category, '餐饮');
      expect(transactions.first.type, TransactionType.expense);
    });

    test('should parse multiple transactions correctly', () {
      final transactions = NLPService.parseNaturalLanguage('午饭25元，公交2元，咖啡15元');
      
      expect(transactions.length, 3);
      
      expect(transactions[0].title, '午饭');
      expect(transactions[0].amount, 25.0);
      expect(transactions[0].category, '餐饮');
      
      expect(transactions[1].title, '公交');
      expect(transactions[1].amount, 2.0);
      expect(transactions[1].category, '交通');
      
      expect(transactions[2].title, '咖啡');
      expect(transactions[2].amount, 15.0);
      expect(transactions[2].category, '餐饮');
    });

    test('should handle different amount formats', () {
      final transactions1 = NLPService.parseNaturalLanguage('红牛6.5元');
      final transactions2 = NLPService.parseNaturalLanguage('打车15块');
      final transactions3 = NLPService.parseNaturalLanguage('电影票35');
      
      expect(transactions1.first.amount, 6.5);
      expect(transactions2.first.amount, 15.0);
      expect(transactions3.first.amount, 35.0);
    });

    test('should categorize transactions correctly', () {
      final testCases = {
        '午饭20元': '餐饮',
        '地铁3元': '交通',
        '买衣服200元': '购物',
        '电影票35元': '娱乐',
        '看病100元': '医疗',
        '买书50元': '教育',
      };

      testCases.forEach((input, expectedCategory) {
        final transactions = NLPService.parseNaturalLanguage(input);
        expect(transactions.isNotEmpty, true, reason: 'Should parse transaction from: $input');
        expect(transactions.first.category, expectedCategory, reason: 'Category mismatch for: $input');
      });
    });
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app/core/services/nlp_service.dart';
import 'package:expense_tracker_app/core/models/transaction.dart';

void main() {
  group('NLPService Tests', () {
    test('should parse single transaction correctly', () {
      final transactions = NLPService.parseNaturalLanguage('午饭25元');
      
      expect(transactions.length, 1);
      expect(transactions.first.title, '午饭');
      expect(transactions.first.amount, 25.0);
      expect(transactions.first.category, '餐饮');
      expect(transactions.first.type, TransactionType.expense);
    });

    test('should parse multiple transactions correctly', () {
      final transactions = NLPService.parseNaturalLanguage('午饭25元，公交2元，咖啡15元');
      
      expect(transactions.length, 3);
      
      expect(transactions[0].title, '午饭');
      expect(transactions[0].amount, 25.0);
      expect(transactions[0].category, '餐饮');
      
      expect(transactions[1].title, '公交');
      expect(transactions[1].amount, 2.0);
      expect(transactions[1].category, '交通');
      
      expect(transactions[2].title, '咖啡');
      expect(transactions[2].amount, 15.0);
      expect(transactions[2].category, '餐饮');
    });

    test('should handle different amount formats', () {
      final transactions1 = NLPService.parseNaturalLanguage('红牛6.5元');
      final transactions2 = NLPService.parseNaturalLanguage('打车15块');
      final transactions3 = NLPService.parseNaturalLanguage('电影票35');
      
      expect(transactions1.first.amount, 6.5);
      expect(transactions2.first.amount, 15.0);
      expect(transactions3.first.amount, 35.0);
    });

import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app/core/services/nlp_service.dart';
import 'package:expense_tracker_app/core/models/transaction.dart';

void main() {
  group('NLPService Tests', () {
    test('should parse single transaction correctly', () {
      final transactions = NLPService.parseNaturalLanguage('午饭25元');
      
      expect(transactions.length, 1);
      expect(transactions.first.title, '午饭');
      expect(transactions.first.amount, 25.0);
      expect(transactions.first.category, '餐饮');
      expect(transactions.first.type, TransactionType.expense);
    });

    test('should parse multiple transactions correctly', () {
      final transactions = NLPService.parseNaturalLanguage('午饭25元，公交2元，咖啡15元');
      
      expect(transactions.length, 3);
      
      expect(transactions[0].title, '午饭');
      expect(transactions[0].amount, 25.0);
      expect(transactions[0].category, '餐饮');
      
      expect(transactions[1].title, '公交');
      expect(transactions[1].amount, 2.0);
      expect(transactions[1].category, '交通');
      
      expect(transactions[2].title, '咖啡');
      expect(transactions[2].amount, 15.0);
      expect(transactions[2].category, '餐饮');
    });

    test('should handle different amount formats', () {
      final transactions1 = NLPService.parseNaturalLanguage('红牛6.5元');
      final transactions2 = NLPService.parseNaturalLanguage('打车15块');
      final transactions3 = NLPService.parseNaturalLanguage('电影票35');
      
      expect(transactions1.first.amount, 6.5);
      expect(transactions2.first.amount, 15.0);
      expect(transactions3.first.amount, 35.0);
    });

    test('should categorize transactions correctly', () {
      final testCases = {
        '午饭20元': '餐饮',
        '地铁3元': '交通',
        '买衣服200元': '购物',
        '电影票35元': '娱乐',
        '看病100元': '医疗',
        '买书50元': '教育',
      };

      testCases.forEach((input, expectedCategory) {
        final transactions = NLPService.parseNaturalLanguage(input);
        expect(transactions.first.category, expectedCategory);
      });
    });

    test('should return empty list for invalid input', () {
      final transactions1 = NLPService.parseNaturalLanguage('');
      final transactions2 = NLPService.parseNaturalLanguage('无效输入');
      final transactions3 = NLPService.parseNaturalLanguage('没有金额');
      
      expect(transactions1.isEmpty, true);
      expect(transactions2.isEmpty, true);
      expect(transactions3.isEmpty, true);
    });

    test('should provide relevant suggestions', () {
      final suggestions1 = NLPService.getSuggestions('');
      final suggestions2 = NLPService.getSuggestions('饭');
      final suggestions3 = NLPService.getSuggestions('车');
      
      expect(suggestions1.isNotEmpty, true);
      expect(suggestions2.any((s) => s.contains('饭')), true);
      expect(suggestions3.any((s) => s.contains('车') || s.contains('交通')), true);
    });
  });
}