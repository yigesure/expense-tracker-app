import '../models/transaction.dart';
import '../utils/logger.dart';

/// 自然语言处理服务
/// 用于解析用户输入的自然语言并转换为交易记录
class NLPService {
  static final AppLogger _logger = AppLogger('NLPService');

  /// 解析自然语言输入
  /// 支持格式：
  /// - "红牛6.5" -> 餐饮支出6.5元
  /// - "午饭20元" -> 餐饮支出20元
  /// - "公交2" -> 交通支出2元
  /// - "工资5000/收入" -> 工作收入5000元
  static List<Transaction> parseNaturalLanguage(String input) {
    _logger.info('开始解析自然语言输入', {'input': input});
    
    final transactions = <Transaction>[];
    
    try {
      // 按逗号、分号、换行符分割多个记录
      final records = input
          .split(RegExp(r'[,，;；\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      
      for (final record in records) {
        final transaction = _parseRecord(record);
        if (transaction != null) {
          transactions.add(transaction);
        }
      }
      
      _logger.info('解析完成', {'count': transactions.length});
      return transactions;
    } catch (e, stackTrace) {
      _logger.error('解析失败', e, stackTrace);
      return [];
    }
  }

  /// 解析单条记录
  static Transaction? _parseRecord(String record) {
    try {
      // 移除多余空格
      record = record.trim();
      if (record.isEmpty) return null;

      // 检查是否为收入（包含"收入"、"工资"、"奖金"等关键词）
      final isIncome = _isIncomeKeyword(record);
      
      // 提取金额
      final amount = _extractAmount(record);
      if (amount == null || amount <= 0) return null;

      // 提取标题和分类
      final titleAndCategory = _extractTitleAndCategory(record, amount);
      
      return Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleAndCategory['title'] ?? '未知消费',
        amount: amount,
        category: titleAndCategory['category'] ?? '其他',
        categoryIcon: titleAndCategory['icon'] ?? '📝',
        date: DateTime.now(),
        type: isIncome ? TransactionType.income : TransactionType.expense,
      );
    } catch (e) {
      _logger.warning('解析单条记录失败', {'record': record, 'error': e.toString()});
      return null;
    }
  }

  /// 检查是否为收入关键词
  static bool _isIncomeKeyword(String text) {
    final incomeKeywords = [
      '收入', '工资', '薪水', '奖金', '红包', '退款', '返现', 
      '利息', '分红', '兼职', '外快', '报销'
    ];
    
    return incomeKeywords.any((keyword) => text.contains(keyword));
  }

  /// 提取金额
  static double? _extractAmount(String text) {
    // 匹配数字（支持小数点）
    final amountRegex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = amountRegex.firstMatch(text);
    
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    
    return null;
  }

  /// 提取标题和分类
  static Map<String, String> _extractTitleAndCategory(String text, double amount) {
    // 移除金额部分
    String cleanText = text.replaceAll(RegExp(r'\d+(?:\.\d+)?'), '').trim();
    cleanText = cleanText.replaceAll(RegExp(r'[元块钱¥￥/]'), '').trim();
    
    // 分类映射
    final categoryMap = {
      // 餐饮
      '餐饮': ['吃', '饭', '餐', '食', '喝', '茶', '咖啡', '奶茶', '红牛', '可乐', '水', '零食', '外卖', '早餐', '午餐', '晚餐', '夜宵'],
      // 交通
      '交通': ['车', '公交', '地铁', '出租', '滴滴', '打车', '油费', '停车', '过路', '高速', '火车', '飞机', '船'],
      // 购物
      '购物': ['买', '购', '衣服', '鞋', '包', '化妆品', '护肤', '洗发', '牙膏', '纸巾', '日用品', '超市', '商场'],
      // 娱乐
      '娱乐': ['电影', '游戏', 'KTV', '酒吧', '旅游', '景点', '门票', '娱乐', '玩', '乐'],
      // 医疗
      '医疗': ['医院', '药', '看病', '体检', '医疗', '治疗', '挂号', '检查'],
      // 教育
      '教育': ['书', '学费', '培训', '课程', '教育', '学习', '考试'],
      // 生活
      '生活': ['房租', '水电', '燃气', '物业', '网费', '话费', '生活'],
      // 工作
      '工作': ['工资', '薪水', '奖金', '报销', '差旅'],
    };

    // 分类图标映射
    final iconMap = {
      '餐饮': '🍜',
      '交通': '🚇',
      '购物': '🛍️',
      '娱乐': '🎬',
      '医疗': '🏥',
      '教育': '📚',
      '生活': '🏠',
      '工作': '💼',
      '其他': '📝',
    };

    // 查找匹配的分类
    String category = '其他';
    for (final entry in categoryMap.entries) {
      if (entry.value.any((keyword) => cleanText.contains(keyword))) {
        category = entry.key;
        break;
      }
    }

    // 生成标题
    String title = cleanText.isNotEmpty ? cleanText : category;
    if (title.length > 10) {
      title = title.substring(0, 10);
    }

    return {
      'title': title,
      'category': category,
      'icon': iconMap[category] ?? '📝',
    };
  }
}