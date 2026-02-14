import 'package:flutter/foundation.dart';

import '../../../../core/utils/logger.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/add_comment.dart';
import '../../domain/usecases/like_post.dart';
import '../../domain/usecases/list_comments.dart';
import '../../data/repositories/posts_repository.dart';

class PostDetailsController extends ChangeNotifier {
  PostDetailsController({
    required this.authRepo,
    required this.postsRepo,
    required this.likePost,
    required this.listComments,
    required this.addComment,
    required this.postId,
  });

  final AuthRepository authRepo;
  final PostsRepository postsRepo;
  final LikePost likePost;
  final ListComments listComments;
  final AddComment addComment;

  final String postId;

  bool isLoading = false;
  String? error;

  Post? post;
  List<Comment> comments = [];

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      post = await postsRepo.getPost(postId);
      comments = await listComments(postId);
    } catch (e) {
      Logger.e('Load post details failed', error: e);
      error = 'Failed to load post';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLike() async {
    final me = authRepo.currentUser;
    if (me == null) return;
    try {
      await likePost(postId, me.id);
      // Refresh (cheap and safe)
      post = await postsRepo.getPost(postId);
      notifyListeners();
    } catch (e) {
      Logger.e('Like failed', error: e);
    }
  }

  Future<void> submitComment(String content) async {
    final me = authRepo.currentUser;
    if (me == null) return;
    if (content.trim().isEmpty) return;

    try {
      final c = await addComment(postId: postId, userId: me.id, content: content.trim());
      comments = [...comments, c];
      notifyListeners();
    } catch (e) {
      Logger.e('Comment failed', error: e);
    }
  }
}
