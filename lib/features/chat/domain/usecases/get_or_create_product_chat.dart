import '../../data/repositories/chat_repository.dart';

class GetOrCreateProductChat {
  GetOrCreateProductChat(this.repo);

  final ChatRepository repo;

  Future<String> call(String productId, String otherId, {required String meId}) {
    return repo.getOrCreateProductChat(meId, otherId, productId);
  }
}
