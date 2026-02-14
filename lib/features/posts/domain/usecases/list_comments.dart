import '../../data/repositories/posts_repository.dart';
import '../entities/comment.dart';

class ListComments {
  ListComments(this.repo);

  final PostsRepository repo;

  Future<List<Comment>> call(String postId) => repo.listComments(postId);
}
