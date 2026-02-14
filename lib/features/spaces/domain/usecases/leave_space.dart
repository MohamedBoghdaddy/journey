import '../../data/repositories/spaces_repository.dart';

class LeaveSpace {
  LeaveSpace(this.repo);

  final SpacesRepository repo;

  Future<void> call(String spaceId, String userId) => repo.leaveSpace(spaceId, userId);
}
