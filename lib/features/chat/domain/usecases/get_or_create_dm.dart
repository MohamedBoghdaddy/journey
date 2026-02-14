import '../../data/repositories/chat_repository.dart';

class GetOrCreateDm {
  GetOrCreateDm(this.repo);

  final ChatRepository repo;

  Future<String> call(String otherId, {required String meId}) {
    return repo.getOrCreateDm(meId, otherId);
  }
}
