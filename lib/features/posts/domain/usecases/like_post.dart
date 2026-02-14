import '../../data/repositories/posts_repository.dart';

class LikePost {
  LikePost(this.repo);

  final PostsRepository repo;

  Future<void> call(String postId, String userId) => repo.toggleLike(postId, userId);
}
