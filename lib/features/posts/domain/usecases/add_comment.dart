import '../../data/repositories/posts_repository.dart';
import '../entities/comment.dart';

class AddComment {
  AddComment(this.repo);

  final PostsRepository repo;

  Future<Comment> call({
    required String postId,
    required String userId,
    required String content,
  }) {
    return repo.addComment(postId: postId, userId: userId, content: content);
  }
}
