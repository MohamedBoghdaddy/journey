import 'package:flutter/material.dart';

/// Displays a list of spaces (neighbourhoods/businesses) the user is part of.
class SpacePage extends StatelessWidget {
  const SpacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 0, // TODO: replace with spaces length
        itemBuilder: (context, index) {
          return const ListTile(
            leading: Icon(Icons.place),
            title: Text('Space name'),
            subtitle: Text('Space description...'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: navigate to create space page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}