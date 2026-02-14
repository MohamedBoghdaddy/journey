import 'package:flutter/material.dart';

class PostComposer extends StatefulWidget {
  const PostComposer({super.key, required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  State<PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends State<PostComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Write a comment...',
                ),
                minLines: 1,
                maxLines: 4,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: _send,
              icon: const Icon(Icons.send),
            )
          ],
        ),
      ),
    );
  }
}
