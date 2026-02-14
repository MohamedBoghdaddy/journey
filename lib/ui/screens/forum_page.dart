import 'package:flutter/material.dart';

import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/post_service.dart';
import '../../services/report_service.dart';
import '../role_guard.dart';
import 'comments_page.dart';
import 'create_post_page.dart'; // unified page (space optional)

/// Forum feed (all posts across spaces).
///
/// - Real feed via [PostService.fetchPosts()]
/// - Shows a safe fallback "stub list" when feed is empty or user is not logged in
/// - Users can:
///   - open comments
///   - upvote/unvote
///   - report
///   - edit/delete (owner OR admin/superAdmin)
///   - create a post (RoleGuard)
class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  late Future<List<PostModel>> _postsFuture;

  // lightweight local stubs (from your simple version)
  static const List<String> _stubTitles = [
    'Scam warning: fake delivery refund',
    'Where can I renew my ID quickly?',
    'Best koshary in Dokki?',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _postsFuture = PostService.instance.fetchPosts(); // global feed
  }

  Future<void> _refresh() async {
    setState(_load);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _canManage(PostModel post) {
    final current = AuthService.instance.currentUser;
    if (current == null) return false;
    if (current.role == UserRole.admin || current.role == UserRole.superAdmin) {
      return true;
    }
    return current.id == post.authorId;
  }

  Future<void> _openEdit(PostModel post) async {
    final titleCtrl = TextEditingController(text: post.title);
    final bodyCtrl = TextEditingController(text: post.content);

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyCtrl,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(labelText: 'Body'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final newTitle = titleCtrl.text.trim();
    final newBody = bodyCtrl.text.trim();
    if (newTitle.isEmpty || newBody.isEmpty) {
      _snack('Title and body cannot be empty.');
      return;
    }

    try {
      await PostService.instance.updatePost(post.id, newTitle, newBody);
      await _refresh();
    } catch (e) {
      _snack('Failed to update post: $e');
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await PostService.instance.deletePost(post.id);
      await _refresh();
    } catch (e) {
      _snack('Failed to delete post: $e');
    }
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
    } catch (_) {
      _snack('Could not update vote. Try again.');
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(context, text);
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
      _snack('Failed to submit report: $e');
    }
  }

  void _openComments(PostModel post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CommentsPage(post: post)),
    );
  }

  Future<void> _createPost() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreatePostPage()),
    );
    await _refresh();
  }

  Widget _buildStubList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _stubTitles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final title = _stubTitles[i];
        return Card(
          child: ListTile(
            title: Text(title),
            subtitle: const Text('Stub post preview'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _snack('Open post: $title'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forum')),
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

            final posts = snapshot.data ?? const <PostModel>[];

            // Merge behavior: if there are no real posts, show the simple stub feed.
            if (posts.isEmpty) {
              return _buildStubList(context);
            }

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, i) {
                final post = posts[i];

                // Prefer a real field if it exists, otherwise fallback to spaceId.
                final String spaceLabel = (() {
                  try {
                    final dyn = post as dynamic;
                    final v = dyn.spaceName;
                    if (v is String && v.trim().isNotEmpty) return v;
                  } catch (_) {}
                  return post.spaceId;
                })();

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(post.title),
                    subtitle: Text(
                      '$spaceLabel\n${post.content}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    onTap: () => _openComments(post),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(post.voteCount.toString()),
                        IconButton(
                          icon: const Icon(Icons.thumb_up),
                          onPressed: () => _toggleVote(post),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (v) async {
                            switch (v) {
                              case 'report':
                                await _reportPost(post);
                                break;
                              case 'edit':
                                await _openEdit(post);
                                break;
                              case 'delete':
                                await _delete(post);
                                break;
                            }
                          },
                          itemBuilder: (_) {
                            final items = <PopupMenuEntry<String>>[
                              const PopupMenuItem(
                                value: 'report',
                                child: Text('Report'),
                              ),
                            ];
                            if (_canManage(post)) {
                              items.addAll(const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ]);
                            }
                            return items;
                          },
                        ),
                      ],
                    ),
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
          UserRole.superAdmin,
        },
        builder: (context) => FloatingActionButton(
          onPressed: _createPost,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
