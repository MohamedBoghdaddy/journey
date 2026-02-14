import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/widgets/loading.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/watch_messages.dart';
import '../controllers/chat_controller.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController _controller;

  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    final deps = DependenciesScope.of(context);
    _controller = ChatController(
      authRepo: deps.authRepository,
      watchMessages: WatchMessages(deps.chatRepository),
      sendMessage: SendMessage(deps.chatRepository),
      conversationId: widget.conversationId,
    );
    _controller.addListener(_onUpdate);
    _controller.start();
  }

  void _onUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    _text.dispose();
    super.dispose();
  }

  void _send() {
    final msg = _text.text;
    _controller.send(msg);
    _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final me = DependenciesScope.of(context).authRepository.currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: _controller.isLoading && _controller.messages.isEmpty
                ? const LoadingView(message: 'Loading messages...')
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _controller.messages.length,
                    itemBuilder: (context, i) {
                      final m = _controller.messages[i];
                      final mine = me != null && m.senderId == me;
                      return MessageBubble(message: m, isMine: mine);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      decoration: const InputDecoration(hintText: 'Message...'),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(onPressed: _send, icon: const Icon(Icons.send)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
