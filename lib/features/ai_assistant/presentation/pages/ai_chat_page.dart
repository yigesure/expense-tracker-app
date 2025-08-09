import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' show Icons;
import '../../../../core/theme/app_colors.dart';

class AIChatPage extends ConsumerStatefulWidget {
  const AIChatPage({super.key});

  @override
  ConsumerState<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends ConsumerState<AIChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text: '你好！我是你的智能记账助手 🤖\n\n我可以帮你：\n• 快速记录消费：\"午饭30元\"\n• 分析消费习惯\n• 提供理财建议\n• 回答财务问题\n\n试试对我说话吧！',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                MdiIcons.robot,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI助手',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _isTyping ? '正在输入...' : '在线',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _clearChat,
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 聊天消息列表
          Expanded(
            child: Container(
              color: AppColors.creamWhite,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
          ),
          
          // 输入区域
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                FluentSystemIcons.ic_fluent_bot_filled,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isUser 
                    ? AppColors.primaryGradient 
                    : null,
                color: message.isUser 
                    ? null 
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUser 
                      ? const Radius.circular(16) 
                      : const Radius.circular(4),
                  bottomRight: message.isUser 
                      ? const Radius.circular(4) 
                      : const Radius.circular(16),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser 
                          ? Colors.white 
                          : AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser 
                          ? Colors.white.withAlpha((0.7 * 255).round())
                          : AppColors.textHint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 语音输入按钮
          Container(
            decoration: BoxDecoration(
              color: AppColors.creamWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _startVoiceInput,
              icon: const Icon(
                Icons.mic,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 文本输入框
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.creamWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: '输入消息或说"午饭30元"...',
                  hintStyle: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 发送按钮
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // 添加用户消息
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // 模拟AI回复
    _simulateAIResponse(text);
  }

  void _simulateAIResponse(String userMessage) {
    Future.delayed(const Duration(seconds: 1), () {
      String response = _generateAIResponse(userMessage);
      
      setState(() {
        _messages.add(
          ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isTyping = false;
      });
      
      _scrollToBottom();
    });
  }

  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    // 记账相关
    if (message.contains('元') || message.contains('钱') || message.contains('花了')) {
      return '我帮你记录了这笔消费！💰\n\n已自动识别：\n• 金额：从你的描述中提取\n• 分类：智能推荐分类\n• 时间：当前时间\n\n你还可以说"查看今天的消费"来查看记录哦！';
    }
    
    // 查询相关
    if (message.contains('今天') || message.contains('本月') || message.contains('消费')) {
      return '📊 根据你的消费记录：\n\n今天消费：¥156.50\n本月消费：¥3,420.50\n主要分类：餐饮 (45%)、交通 (20%)\n\n💡 小贴士：你的餐饮支出较高，建议适当控制外食频率哦！';
    }
    
    // 建议相关
    if (message.contains('建议') || message.contains('理财') || message.contains('省钱')) {
      return '💡 基于你的消费习惯，我的建议：\n\n1. 🍽️ 餐饮优化：可以尝试自己做饭，每月能省约500元\n2. 🚗 交通规划：合理规划出行路线\n3. 📱 记账习惯：坚持每日记账，提高财务意识\n\n要不要我帮你制定一个月度预算计划？';
    }
    
    // 默认回复
    return '我理解你的问题！🤔\n\n我可以帮你：\n• 记录消费：直接说"午饭30元"\n• 查看统计：问"今天花了多少钱"\n• 理财建议：问"有什么省钱建议"\n• 分析习惯：问"我的消费习惯怎么样"\n\n还有什么想了解的吗？';
  }

  void _startVoiceInput() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('语音输入功能正在开发中，敬请期待！'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空聊天记录'),
        content: const Text('确定要清空所有聊天记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}