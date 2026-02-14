import '../../data/repositories/chat_repository.dart';

class SendMessage {
  SendMessage(this.repo);

  final ChatRepository repo;

  Future<void> call(String conversationId, String senderId, String content) =>
      repo.sendMessage(conversationId, senderId, content);
}
