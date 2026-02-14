import '../entities/message.dart';
import '../../data/repositories/chat_repository.dart';

class WatchMessages {
  WatchMessages(this.repo);

  final ChatRepository repo;

  Stream<List<Message>> call(String conversationId) => repo.watchMessages(conversationId);
}
