import '../../domain/entities/chat_thread.dart';

class ChatThreadModel {
  const ChatThreadModel({
    required this.conversationId,
    required this.type,
    this.spaceId,
    this.productId,
    this.lastMessageText,
    this.lastMessageAt,
  });

  final String conversationId;
  final String type;
  final String? spaceId;
  final String? productId;
  final String? lastMessageText;
  final DateTime? lastMessageAt;

  factory ChatThreadModel.fromMap(Map<String, dynamic> map) {
    return ChatThreadModel(
      conversationId: (map['conversation_id'] ?? map['id'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      spaceId: map['space_id']?.toString(),
      productId: map['product_id']?.toString(),
      lastMessageText: map['last_message_text']?.toString() ?? map['last_message']?.toString(),
      lastMessageAt: map['last_message_at'] != null
          ? DateTime.tryParse(map['last_message_at'].toString())
          : (map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null),
    );
  }

  ChatThread toEntity() => ChatThread(
    conversationId: conversationId,
    type: type,
    spaceId: spaceId,
    productId: productId,
    lastMessageText: lastMessageText,
    lastMessageAt: lastMessageAt,
  );
}
