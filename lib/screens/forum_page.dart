import 'package:flutter/material.dart';

/// Displays a list of forum posts and a floating action button to create a new post.
class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 0, // TODO: replace with posts length
        itemBuilder: (context, index) {
          // TODO: replace with actual post widget
          return const ListTile(
            title: Text('Post title'),
            subtitle: Text('Post excerpt...'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: navigate to create post page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}