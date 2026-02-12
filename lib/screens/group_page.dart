import 'package:flutter/material.dart';

/// Displays a list of groups that the user can join or create.
class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 0, // TODO: replace with groups length
        itemBuilder: (context, index) {
          return const ListTile(
            leading: Icon(Icons.group),
            title: Text('Group name'),
            subtitle: Text('Group description...'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: navigate to create group page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}