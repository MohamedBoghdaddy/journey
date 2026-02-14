import '../entities/post.dart';
import '../../data/repositories/posts_repository.dart';

class CreatePost {
  CreatePost(this.repo);

  final PostsRepository repo;

  Future<Post> call({
    required String authorId,
    String? spaceId,
    required String title,
    required String content,
  }) {
    return repo.createPost(
      authorId: authorId,
      spaceId: spaceId,
      title: title,
      content: content,
    );
  }
}
