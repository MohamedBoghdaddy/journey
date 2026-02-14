import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../datasources/posts_remote_ds.dart';

class PostsRepository {
  PostsRepository({required this.remote});

  final PostsRemoteDs remote;

  Future<List<Post>> listFeed() async {
    final list = await remote.listFeed();
    return list.map((m) => m.toEntity()).toList();
  }

  Future<List<Post>> listSpacePosts(String spaceId) async {
    final list = await remote.listSpacePosts(spaceId);
    return list.map((m) => m.toEntity()).toList();
  }

  Future<Post?> getPost(String postId) async {
    final m = await remote.getPost(postId);
    return m?.toEntity();
  }

  Future<Post> createPost({
    required String authorId,
    String? spaceId,
    required String title,
    required String content,
  }) async {
    final m = await remote.createPost(
      authorId: authorId,
      spaceId: spaceId,
      title: title,
      content: content,
    );
    return m.toEntity();
  }

  Future<void> toggleLike(String postId, String userId) =>
      remote.toggleLike(postId: postId, userId: userId);

  Future<List<Comment>> listComments(String postId) async {
    final list = await remote.listComments(postId);
    return list.map((m) => m.toEntity()).toList();
  }

  Future<Comment> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    final m = await remote.addComment(postId: postId, userId: userId, content: content);
    return m.toEntity();
  }
}
