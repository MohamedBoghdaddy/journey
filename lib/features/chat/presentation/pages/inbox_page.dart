import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading.dart';
import '../../domain/usecases/list_inbox.dart';
import '../controllers/inbox_controller.dart';
import '../widgets/inbox_tile.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  late final InboxController _controller;

  @override
  void initState() {
    super.initState();
    final deps = DependenciesScope.of(context);
    _controller = InboxController(
      authRepo: deps.authRepository,
      listInbox: ListInbox(deps.chatRepository),
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
    if (_controller.isLoading && _controller.threads.isEmpty) {
      return const LoadingView(message: 'Loading inbox...');
    }
    if (_controller.error != null && _controller.threads.isEmpty) {
      return ErrorView(title: _controller.error!, onRetry: _controller.load);
    }
    if (_controller.threads.isEmpty) {
      return EmptyState(
        title: 'No conversations',
        subtitle: 'Start a new chat.',
        icon: Icons.chat_bubble_outline,
        action: OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pushNamed(Routes.appNewDm),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('New message'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.threads.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final t = _controller.threads[i];
          return InboxTile(
            thread: t,
            onOpen: () => Navigator.of(context).pushNamed(
              Routes.appChatConversation(t.conversationId),
            ),
          );
        },
      ),
    );
  }
}
