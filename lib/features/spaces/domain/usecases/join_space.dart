import '../../data/repositories/spaces_repository.dart';

class JoinSpace {
  JoinSpace(this.repo);

  final SpacesRepository repo;

  Future<void> call(String spaceId, String userId) => repo.joinSpace(spaceId, userId);
}
