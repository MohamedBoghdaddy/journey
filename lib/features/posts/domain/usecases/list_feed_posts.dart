import '../entities/post.dart';
import '../../data/repositories/posts_repository.dart';

class ListFeedPosts {
  ListFeedPosts(this.repo);

  final PostsRepository repo;

  Future<List<Post>> call() => repo.listFeed();
}
