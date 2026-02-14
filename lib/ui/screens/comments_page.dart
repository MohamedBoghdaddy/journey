import 'package:flutter/material.dart';

import '../../models/comment_model.dart';
import '../../models/post_model.dart';
import '../../services/comment_service.dart';
import '../../services/report_service.dart';

/// Displays all comments for a post and allows the user to add a new comment
/// at the bottom of the screen.
class CommentsPage extends StatefulWidget {
  final PostModel post;
  const CommentsPage({super.key, required this.post});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  late Future<List<CommentModel>> _commentsFuture;

  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    _commentsFuture = CommentService.instance.fetchComments(widget.post.id);
  }

  Future<void> _refresh() async {
    setState(_loadComments);
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      setState(() => _error = 'Comment cannot be empty');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await CommentService.instance.addComment(widget.post.id, content);
      _commentController.clear();
      await _refresh();
    } catch (e) {
      setState(() => _error = e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _reportComment(CommentModel comment) async {
    final controller = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Comment'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'Describe why you are reporting this comment',
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
        targetType: 'comment',
        targetId: comment.id,
        reason: reason.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.post.title)),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<CommentModel>>(
                future: _commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final comments = snapshot.data ?? [];
                  if (comments.isEmpty) {
                    return const Center(child: Text('No comments yet.'));
                  }

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return ListTile(
                        title: Text(comment.content),
                        subtitle: Text('by ${comment.authorId}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'report') _reportComment(comment);
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                                value: 'report', child: Text('Report')),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Composer
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment',
                      errorText: _error,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isSubmitting ? null : _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
