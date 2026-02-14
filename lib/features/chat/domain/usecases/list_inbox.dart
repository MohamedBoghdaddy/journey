import '../entities/chat_thread.dart';
import '../../data/repositories/chat_repository.dart';

class ListInbox {
  ListInbox(this.repo);

  final ChatRepository repo;

  Future<List<ChatThread>> call(String userId) => repo.listInbox(userId);
}
