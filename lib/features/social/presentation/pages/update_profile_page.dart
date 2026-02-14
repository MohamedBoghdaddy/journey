import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/domain/entities/user_profile.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _bio = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final deps = DependenciesScope.of(context);
    final me = deps.authRepository.currentUser;
    if (me == null) return;

    deps.profileRepository.getProfile(me.id).then((p) {
      if (!mounted || p == null) return;
      _name.text = p.displayName ?? '';
      _bio.text = p.bio ?? '';
      setState(() {});
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final deps = DependenciesScope.of(context);
    final me = deps.authRepository.currentUser;
    if (me == null) return;

    setState(() => _isLoading = true);
    try {
      final current = await deps.profileRepository.getProfile(me.id);
      final updated = (current ?? UserProfile(id: me.id, email: me.email ?? '')).copyWith(
        displayName: _name.text.trim().isEmpty ? null : _name.text.trim(),
        bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
      );
      await deps.profileRepository.upsertProfile(updated);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Update failed')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _name,
                label: 'Display name',
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _bio,
                label: 'Bio',
                maxLines: 4,
                prefixIcon: Icons.notes_outlined,
                validator: (v) => (v == null || v.length <= 280)
                    ? null
                    : 'Bio must be 280 characters or less',
              ),
              const SizedBox(height: 18),
              AppButton(
                label: 'Save',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _submit,
                icon: Icons.check,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
