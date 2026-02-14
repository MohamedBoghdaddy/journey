import '../../data/repositories/social_repository.dart';

class UnfollowUser {
  UnfollowUser(this.repo);

  final SocialRepository repo;

  Future<void> call(String followerId, String followingId) => repo.unfollow(followerId, followingId);
}
