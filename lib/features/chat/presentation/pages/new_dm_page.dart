import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/usecases/get_or_create_dm.dart';

class NewDmPage extends StatefulWidget {
  const NewDmPage({super.key});

  @override
  State<NewDmPage> createState() => _NewDmPageState();
}

class _NewDmPageState extends State<NewDmPage> {
  final _formKey = GlobalKey<FormState>();
  final _otherId = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _otherId.dispose();
    super.dispose();
  }

  Future<void> _startChat() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final deps = DependenciesScope.of(context);
    final me = deps.authRepository.currentUser;
    if (me == null) return;

    setState(() => _isLoading = true);
    try {
      final convoId = await GetOrCreateDm(deps.chatRepository)(
        _otherId.text.trim(),
        meId: me.id,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(Routes.appChatConversation(convoId));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to start chat')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New message')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _otherId,
                label: 'User ID',
                hintText: 'Paste user id',
                prefixIcon: Icons.person_outline,
                validator: (v) => Validators.requiredField(v ?? '', label: 'User ID'),
              ),
              const SizedBox(height: 18),
              AppButton(
                label: 'Start chat',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _startChat,
                icon: Icons.chat_bubble_outline,
              ),
              const SizedBox(height: 10),
              Text(
                'Tip: You can copy a user ID from the profile route /app/u/:userId.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
