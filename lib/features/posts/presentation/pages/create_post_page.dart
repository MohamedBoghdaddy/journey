import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../domain/usecases/create_post.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key, this.spaceId});

  final String? spaceId;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _content = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final deps = DependenciesScope.of(context);
    final auth = deps.authRepository.currentUser;
    if (auth == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final created = await CreatePost(deps.postsRepository)(
        authorId: auth.id,
        spaceId: widget.spaceId,
        title: _title.text.trim(),
        content: _content.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to create post')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.spaceId == null ? 'Create post' : 'Create space post';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _title,
                label: 'Title',
                prefixIcon: Icons.title,
                validator: (v) => Validators.requiredField(v ?? '', label: 'Title'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _content,
                label: 'Content',
                prefixIcon: Icons.edit_note,
                maxLines: 5,
                validator: (v) => Validators.minLength(v ?? '', 2, label: 'Content'),
              ),
              const SizedBox(height: 18),
              AppButton(
                label: 'Publish',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _submit,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
