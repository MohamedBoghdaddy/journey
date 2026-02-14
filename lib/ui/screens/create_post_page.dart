import 'package:flutter/material.dart';

import '../../models/space_model.dart';
import '../../services/post_service.dart';
import '../../services/space_service.dart';

/// Create Post page (unified):
/// - If [space] is provided => posts directly to that space (no dropdown).
/// - If [space] is null => loads spaces + shows a dropdown to pick one.
/// Shows inline error + snackbar on failures.
class CreatePostPage extends StatefulWidget {
  final SpaceModel? space;
  const CreatePostPage({super.key, this.space});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late final Future<List<SpaceModel>> _spacesFuture;
  SpaceModel? _selected;

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = widget.space;

    _spacesFuture = widget.space != null
        ? Future.value([widget.space!])
        : SpaceService.instance.fetchSpaces();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _setError(String? msg) {
    if (!mounted) return;
    setState(() => _error = msg);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    final space = _selected;
    if (space == null) {
      _setError('Please select a space.');
      return;
    }

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      _setError('Title and content cannot be empty');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await PostService.instance.createPost(space.id, title, content);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      _setError(e.toString());
      _snack('Failed: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildForm(List<SpaceModel> spaces) {
    if (spaces.isEmpty) {
      return const Center(child: Text('Create a space first.'));
    }

    _selected ??= spaces.first;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.space == null)
            DropdownButtonFormField<SpaceModel>(
              value: _selected,
              items: spaces
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged:
                  _isSubmitting ? null : (v) => setState(() => _selected = v),
              decoration: const InputDecoration(
                labelText: 'Space',
                border: OutlineInputBorder(),
              ),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Space: ${_selected!.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            enabled: !_isSubmitting,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _contentController,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              expands: true,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Post'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.space == null ? 'Create Post' : 'New Post')),
      body: FutureBuilder<List<SpaceModel>>(
        future: _spacesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return _buildForm(snapshot.data ?? []);
        },
      ),
    );
  }
}
