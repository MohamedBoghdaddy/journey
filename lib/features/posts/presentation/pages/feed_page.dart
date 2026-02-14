import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading.dart';
import '../../domain/usecases/list_feed_posts.dart';
import '../../domain/usecases/list_space_posts.dart';
import '../controllers/feed_controller.dart';
import '../widgets/post_card.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late final FeedController _controller;

  @override
  void initState() {
    super.initState();
    final deps = DependenciesScope.of(context);
    _controller = FeedController(
      listFeedPosts: ListFeedPosts(deps.postsRepository),
      listSpacePosts: ListSpacePosts(deps.postsRepository),
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
    if (_controller.isLoading && _controller.posts.isEmpty) {
      return const LoadingView(message: 'Loading feed...');
    }
    if (_controller.error != null && _controller.posts.isEmpty) {
      return ErrorView(title: _controller.error!, onRetry: _controller.load);
    }
    if (_controller.posts.isEmpty) {
      return EmptyState(
        title: 'No posts yet',
        subtitle: 'Create the first post in your neighborhood.',
        icon: Icons.forum_outlined,
        action: OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pushNamed(Routes.appCreatePost),
          icon: const Icon(Icons.add),
          label: const Text('Create post'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final post = _controller.posts[i];
          return PostCard(
            post: post,
            onOpen: () => Navigator.of(context).pushNamed(Routes.appPostDetails(post.id)),
          );
        },
      ),
    );
  }
}
