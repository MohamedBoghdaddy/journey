import '../../data/repositories/chat_repository.dart';

class GetOrCreateSpaceChat {
  GetOrCreateSpaceChat(this.repo);

  final ChatRepository repo;

  Future<String> call(String spaceId, {required String meId}) {
    return repo.getOrCreateSpaceChat(meId, spaceId);
  }
}
