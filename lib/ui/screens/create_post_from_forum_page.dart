import 'package:flutter/material.dart';

import '../../models/space_model.dart';
import '../../services/post_service.dart';
import '../../services/space_service.dart';

class CreatePostFromForumPage extends StatefulWidget {
  const CreatePostFromForumPage({super.key});

  @override
  State<CreatePostFromForumPage> createState() => _CreatePostFromForumPageState();
}

class _CreatePostFromForumPageState extends State<CreatePostFromForumPage> {
  late Future<List<SpaceModel>> _spacesFuture;
  SpaceModel? _selected;
  final _title = TextEditingController();
  final _content = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _spacesFuture = SpaceService.instance.fetchSpaces();
  }

  Future<void> _submit() async {
    if (_selected == null) return;
    final t = _title.text.trim();
    final c = _content.text.trim();
    if (t.isEmpty || c.isEmpty) return;
    setState(() => _saving = true);
    try {
      await PostService.instance.createPost(_selected!.id, t, c);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: FutureBuilder<List<SpaceModel>>(
        future: _spacesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final spaces = snapshot.data ?? [];
          if (spaces.isEmpty) {
            return const Center(child: Text('Create a space first.'));
          }
          _selected ??= spaces.first;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<SpaceModel>(
                  value: _selected,
                  items: spaces
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _selected = v),
                  decoration: const InputDecoration(labelText: 'Space'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    controller: _content,
                    minLines: null,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(labelText: 'Content'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    child: Text(_saving ? 'Saving...' : 'Post'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
