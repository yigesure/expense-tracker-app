/// 交易记录模型
class Transaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String categoryIcon;
  final DateTime date;
  final String? description;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.categoryIcon,
    required this.date,
    this.description,
    required this.type,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      categoryIcon: json['categoryIcon'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      type: TransactionType.values[json['type'] as int],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'categoryIcon': categoryIcon,
      'date': date.toIso8601String(),
      'description': description,
      'type': type.index,
    };
  }
}

/// 交易类型枚举
enum TransactionType {
  expense, // 支出
  income,  // 收入
}

/// 聊天消息模型
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isExpenseRecord;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isExpenseRecord = false,
  });
}