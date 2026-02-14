import 'package:flutter/material.dart';

import '../../../../models/post_model.dart';
import '../../../../models/space_model.dart';
import '../../../../models/user_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/post_service.dart';
import '../../../../services/report_service.dart';
import '../../../../ui/role_guard.dart';
import '../../../../ui/screens/comments_page.dart';
import '../../../../ui/screens/create_post_page.dart';

/// Displays the feed of posts for a particular [SpaceModel].
/// Users can create new posts, view post details, upvote/unvote,
/// view comments, report posts, and (if allowed) edit/delete their posts.
class SpaceFeedPage extends StatefulWidget {
  final SpaceModel space;
  const SpaceFeedPage({super.key, required this.space});

  @override
  State<SpaceFeedPage> createState() => _SpaceFeedPageState();
}

class _SpaceFeedPageState extends State<SpaceFeedPage> {
  late Future<List<PostModel>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    _postsFuture = PostService.instance.fetchPosts(spaceId: widget.space.id);
  }

  Future<void> _refresh() async {
    setState(_loadPosts);
  }

  Future<void> _createPost() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CreatePostPage(space: widget.space)),
    );
    await _refresh();
  }

  void _viewComments(PostModel post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CommentsPage(post: post)),
    );
  }

  Future<void> _toggleVote(PostModel post) async {
    try {
      final hasVoted = await PostService.instance.hasVoted(post.id);
      if (hasVoted) {
        await PostService.instance.removeVote(post.id);
      } else {
        await PostService.instance.upvotePost(post.id);
      }
      await _refresh();
    } catch (e) {
      _snack('Could not update vote. Please try again.');
    }
  }

  Future<void> _reportPost(PostModel post) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'Describe why you are reporting this post',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.of(context).pop(text);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (reason == null || reason.trim().isEmpty) return;

    try {
      await ReportService.instance.report(
        targetType: 'post',
        targetId: post.id,
        reason: reason.trim(),
      );
      _snack('Report submitted.');
    } catch (e) {
      _snack('Could not submit report. Please try again.');
    }
  }

  bool _canManage(PostModel post) {
    final current = AuthService.instance.currentUser;
    if (current == null) return false;
    if ({UserRole.admin, UserRole.superAdmin}.contains(current.role))
      return true;
    return current.id == post.authorId;
  }

  Future<void> _edit(PostModel post) async {
    final title = TextEditingController(text: post.title);
    final body = TextEditingController(text: post.content);

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: body,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(labelText: 'Body'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save')),
        ],
      ),
    );

    if (ok != true) return;

    final newTitle = title.text.trim();
    final newBody = body.text.trim();

    if (newTitle.isEmpty || newBody.isEmpty) {
      _snack('Title and body cannot be empty.');
      return;
    }

    try {
      await PostService.instance.updatePost(post.id, newTitle, newBody);
      await _refresh();
    } catch (e) {
      _snack('Could not update post. Please try again.');
    }
  }

  Future<void> _delete(PostModel post) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text('Delete "${post.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await PostService.instance.deletePost(post.id);
      await _refresh();
    } catch (e) {
      _snack('Could not delete post. Please try again.');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.space.name)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<PostModel>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final posts = snapshot.data ?? [];
            if (posts.isEmpty) {
              return const Center(child: Text('No posts yet.'));
            }

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(post.title),
                    subtitle: Text(
                      post.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(post.voteCount.toString()),
                        IconButton(
                          icon: const Icon(Icons.thumb_up),
                          onPressed: () => _toggleVote(post),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            switch (value) {
                              case 'report':
                                await _reportPost(post);
                                break;
                              case 'edit':
                                await _edit(post);
                                break;
                              case 'delete':
                                await _delete(post);
                                break;
                            }
                          },
                          itemBuilder: (context) {
                            final items = <PopupMenuEntry<String>>[
                              const PopupMenuItem(
                                  value: 'report', child: Text('Report')),
                            ];
                            if (_canManage(post)) {
                              items.addAll(const [
                                PopupMenuItem(
                                    value: 'edit', child: Text('Edit')),
                                PopupMenuItem(
                                    value: 'delete', child: Text('Delete')),
                              ]);
                            }
                            return items;
                          },
                        ),
                      ],
                    ),
                    onTap: () => _viewComments(post),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: RoleGuard(
        allowedRoles: {
          UserRole.user,
          UserRole.moderator,
          UserRole.admin,
          UserRole.superAdmin
        },
        builder: (context) => FloatingActionButton(
          onPressed: _createPost,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
