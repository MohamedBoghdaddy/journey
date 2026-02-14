import '../../domain/entities/profile.dart';
import '../datasources/social_remote_ds.dart';

class SocialRepository {
  SocialRepository({required this.remote});

  final SocialRemoteDs remote;

  Future<Profile?> getProfile(String userId) async {
    final m = await remote.getProfile(userId);
    return m?.toEntity();
  }

  Future<List<Profile>> searchUsers(String query) async {
    final list = await remote.searchUsers(query);
    return list.map((m) => m.toEntity()).toList();
  }

  Future<bool> isFollowing(String followerId, String followingId) =>
      remote.isFollowing(followerId: followerId, followingId: followingId);

  Future<void> follow(String followerId, String followingId) =>
      remote.follow(followerId: followerId, followingId: followingId);

  Future<void> unfollow(String followerId, String followingId) =>
      remote.unfollow(followerId: followerId, followingId: followingId);
}
