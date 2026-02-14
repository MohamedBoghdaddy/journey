import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading.dart';
import '../../domain/usecases/add_comment.dart';
import '../../domain/usecases/like_post.dart';
import '../../domain/usecases/list_comments.dart';
import '../controllers/post_details_controller.dart';
import '../widgets/comment_tile.dart';
import '../widgets/post_composer.dart';

class PostDetailsPage extends StatefulWidget {
  const PostDetailsPage({super.key, required this.postId, this.spaceId});

  final String postId;
  final String? spaceId;

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  late final PostDetailsController _controller;

  @override
  void initState() {
    super.initState();
    final deps = DependenciesScope.of(context);
    _controller = PostDetailsController(
      authRepo: deps.authRepository,
      postsRepo: deps.postsRepository,
      likePost: LikePost(deps.postsRepository),
      listComments: ListComments(deps.postsRepository),
      addComment: AddComment(deps.postsRepository),
      postId: widget.postId,
    );
    _controller.addListener(_onUpdate);
    _controller.load();
  }

  void _onUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading && _controller.post == null) {
      return const Scaffold(body: LoadingView(message: 'Loading post...'));
    }
    if (_controller.error != null && _controller.post == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(title: _controller.error!, onRetry: _controller.load),
      );
    }

    final post = _controller.post!;
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
        actions: [
          IconButton(
            onPressed: _controller.toggleLike,
            icon: const Icon(Icons.thumb_up_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(post.content),
                const SizedBox(height: 12),
                Text(
                  post.createdAt != null ? Formatters.dateTime(post.createdAt!) : '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _controller.comments.isEmpty
                ? const EmptyState(
                    title: 'No comments yet',
                    subtitle: 'Be the first to comment.',
                    icon: Icons.chat_bubble_outline,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _controller.comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final c = _controller.comments[i];
                      return CommentTile(comment: c);
                    },
                  ),
          ),
          PostComposer(onSubmit: _controller.submitComment),
        ],
      ),
    );
  }
}
