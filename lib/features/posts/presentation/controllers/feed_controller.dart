import 'package:flutter/foundation.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/list_feed_posts.dart';
import '../../domain/usecases/list_space_posts.dart';

class FeedController extends ChangeNotifier {
  FeedController({
    required ListFeedPosts listFeedPosts,
    required ListSpacePosts listSpacePosts,
    this.spaceId,
  })  : _listFeedPosts = listFeedPosts,
        _listSpacePosts = listSpacePosts;

  final ListFeedPosts _listFeedPosts;
  final ListSpacePosts _listSpacePosts;

  final String? spaceId;

  bool isLoading = false;
  String? error;
  List<Post> posts = [];

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      posts = spaceId == null ? await _listFeedPosts() : await _listSpacePosts(spaceId!);
    } catch (e) {
      Logger.e('Load posts failed', error: e);
      error = 'Failed to load posts';
    }
    isLoading = false;
    notifyListeners();
  }
}
