import '../../domain/entities/space.dart';
import '../datasources/spaces_remote_ds.dart';

class SpacesRepository {
  SpacesRepository({required this.remote});

  final SpacesRemoteDs remote;

  Future<List<Space>> listSpaces() async {
    final list = await remote.listSpaces();
    return list.map((m) => m.toEntity()).toList();
  }

  Future<Space?> getSpace(String spaceId) async {
    final m = await remote.getSpace(spaceId);
    return m?.toEntity();
  }

  Future<Space> createSpace({
    required String name,
    String? description,
    String? city,
    required String ownerId,
  }) async {
    final m = await remote.createSpace(
      name: name,
      description: description,
      city: city,
      ownerId: ownerId,
    );
    return m.toEntity();
  }

  Future<void> joinSpace(String spaceId, String userId) =>
      remote.joinSpace(spaceId: spaceId, userId: userId);

  Future<void> leaveSpace(String spaceId, String userId) =>
      remote.leaveSpace(spaceId: spaceId, userId: userId);

  Future<List<Map<String, dynamic>>> listMembers(String spaceId) =>
      remote.listMembers(spaceId);

  Future<bool> isMember(String spaceId, String userId) =>
      remote.isMember(spaceId, userId);
}
