import '../../domain/entities/message.dart';

class MessageModel {
  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.createdAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime? createdAt;

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: (map['id'] ?? '').toString(),
      conversationId: (map['conversation_id'] ?? '').toString(),
      senderId: (map['sender_id'] ?? map['user_id'] ?? '').toString(),
      content: (map['content'] ?? map['text'] ?? '').toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }

  Message toEntity() => Message(
    id: id,
    conversationId: conversationId,
    senderId: senderId,
    content: content,
    createdAt: createdAt,
  );
}
