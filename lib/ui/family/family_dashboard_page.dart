
import 'package:flutter/material.dart';
import 'package:masr_spaces_app/theme/tokens.dart';

class FamilyDashboardPage extends StatelessWidget {
  const FamilyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Family Space')),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.s16),
        children: [
          Text('Chores', style: t.textTheme.titleLarge),
          const SizedBox(height: 12),
          const _TaskTile(title: 'Buy groceries', assignee: 'Amin', due: 'Tomorrow', priority: 'High'),
          const _TaskTile(title: 'Pay electricity bill', assignee: 'Hasan', due: 'Saturday', priority: 'Medium'),
          const SizedBox(height: 16),
          Text('Pantry', style: t.textTheme.titleLarge),
          const SizedBox(height: 12),
          const _PantryItem(name: 'Rice', unit: 'kg', threshold: '2', current: '1.5'),
          const _PantryItem(name: 'Oil', unit: 'L', threshold: '1', current: '0.3'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: () {}, child: const Text('Add item')),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final String title;
  final String assignee;
  final String due;
  final String priority;

  const _TaskTile({
    required this.title,
    required this.assignee,
    required this.due,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.checklist_outlined),
        title: Text(title, style: t.textTheme.titleMedium),
        subtitle: Text('Assignee: $assignee • Due: $due • Priority: $priority', style: t.textTheme.bodyMedium),
      ),
    );
  }
}

class _PantryItem extends StatelessWidget {
  final String name;
  final String unit;
  final String threshold;
  final String current;

  const _PantryItem({
    required this.name,
    required this.unit,
    required this.threshold,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.inventory_2_outlined),
        title: Text(name, style: t.textTheme.titleMedium),
        subtitle: Text('Current: $current $unit • Threshold: $threshold $unit', style: t.textTheme.bodyMedium),
      ),
    );
  }
}
