import '../../data/repositories/social_repository.dart';

class FollowUser {
  FollowUser(this.repo);

  final SocialRepository repo;

  Future<void> call(String followerId, String followingId) => repo.follow(followerId, followingId);
}
