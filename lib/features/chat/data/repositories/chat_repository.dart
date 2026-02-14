import '../../domain/entities/chat_thread.dart';
import '../../domain/entities/message.dart';
import '../datasources/chat_remote_ds.dart';

class ChatRepository {
  ChatRepository({required this.remote});

  final ChatRemoteDs remote;

  Future<List<ChatThread>> listInbox(String userId) async {
    final list = await remote.listInbox(userId);
    return list.map((m) => m.toEntity()).toList();
  }

  Future<List<Message>> listMessages(String conversationId) async {
    final list = await remote.listMessages(conversationId);
    return list.map((m) => m.toEntity()).toList();
  }

  Future<void> sendMessage(String conversationId, String senderId, String content) =>
      remote.sendMessage(conversationId: conversationId, senderId: senderId, content: content);

  Future<String> getOrCreateDm(String meId, String otherId) =>
      remote.getOrCreateDm(meId: meId, otherId: otherId);

  Future<String> getOrCreateSpaceChat(String meId, String spaceId) =>
      remote.getOrCreateSpaceChat(meId: meId, spaceId: spaceId);

  Future<String> getOrCreateProductChat(String meId, String otherId, String productId) =>
      remote.getOrCreateProductChat(meId: meId, otherId: otherId, productId: productId);

  Stream<List<Message>> watchMessages(String conversationId) =>
      remote.watchMessages(conversationId).map((items) => items.map((m) => m.toEntity()).toList());
}
