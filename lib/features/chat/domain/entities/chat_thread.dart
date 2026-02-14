class ChatThread {
  const ChatThread({
    required this.conversationId,
    required this.type,
    this.spaceId,
    this.productId,
    this.lastMessageText,
    this.lastMessageAt,
  });

  final String conversationId;
  final String type; // 'dm', 'space', 'product'
  final String? spaceId;
  final String? productId;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
}
