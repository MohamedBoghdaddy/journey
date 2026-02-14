import '../entities/post.dart';
import '../../data/repositories/posts_repository.dart';

class ListSpacePosts {
  ListSpacePosts(this.repo);

  final PostsRepository repo;

  Future<List<Post>> call(String spaceId) => repo.listSpacePosts(spaceId);
}
