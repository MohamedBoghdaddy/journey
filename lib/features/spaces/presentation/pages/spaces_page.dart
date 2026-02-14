import 'package:flutter/material.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/space_service.dart';
import '../../../../models/space_model.dart';
import '../../../../models/user_model.dart';
import '../../../../ui/screens/space_feed_page.dart';

/// Main widget name used by MainShell: SpacesPage()
class SpacesPage extends StatefulWidget {
  const SpacesPage({super.key});

  @override
  State<SpacesPage> createState() => _SpacesPageState();
}

/// Backward-compatible wrapper if anywhere still uses SpacePage()
@Deprecated('Use SpacesPage instead')
class SpacePage extends StatelessWidget {
  const SpacePage({super.key});

  @override
  Widget build(BuildContext context) => const SpacesPage();
}

class _SpacesPageState extends State<SpacesPage> {
  late Future<List<SpaceModel>> _spacesFuture;

  // Not static. Local fallback list from the stub version.
  final List<Map<String, String>> _stubSpaces = [
    {'name': 'AskEgypt / اسأل الناس', 'desc': 'Q&A + best answers'},
    {'name': 'Safety Pings / إنذار الحي', 'desc': 'Urgent alerts + scams'},
    {'name': 'What to eat / ناكل إيه', 'desc': 'Food + prices'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSpaces();
  }

  void _loadSpaces() {
    _spacesFuture = SpaceService.instance.fetchSpaces();
  }

  Future<void> _refresh() async {
    setState(_loadSpaces);
  }

  void _navigateToSpace(SpaceModel space) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SpaceFeedPage(space: space)),
    );
  }

  bool _canManage(SpaceModel space) {
    final current = AuthService.instance.currentUser;
    if (current == null) return false;
    if (current.role == UserRole.admin || current.role == UserRole.superAdmin) {
      return true;
    }
    return current.id == space.ownerId;
  }

  bool get _canCreate {
    final current = AuthService.instance.currentUser;
    if (current == null) return false;
    return current.role == UserRole.moderator ||
        current.role == UserRole.admin ||
        current.role == UserRole.superAdmin;
  }

  Future<void> _openCreateOrEdit({SpaceModel? space}) async {
    final nameController = TextEditingController(text: space?.name ?? '');
    final descController =
        TextEditingController(text: space?.description ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(space == null ? 'Create Space' : 'Edit Space'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              Navigator.of(context).pop(true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok != true) {
      nameController.dispose();
      descController.dispose();
      return;
    }

    final name = nameController.text.trim();
    final desc = descController.text.trim();

    nameController.dispose();
    descController.dispose();

    try {
      if (space == null) {
        await SpaceService.instance.createSpace(name, desc);
        _snack('Space created.');
      } else {
        await SpaceService.instance.updateSpace(space.id, name, desc);
        _snack('Space updated.');
      }
      await _refresh();
    } catch (e) {
      _snack('Failed: $e');
    }
  }

  Future<void> _delete(SpaceModel space) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Space'),
        content: Text('Delete "${space.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await SpaceService.instance.deleteSpace(space.id);
      _snack('Space deleted.');
      await _refresh();
    } catch (e) {
      _snack('Failed: $e');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildStubList() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _stubSpaces.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final s = _stubSpaces[i];
        final name = s['name'] ?? 'Space';
        final desc = s['desc'] ?? '';

        return Card(
          child: ListTile(
            leading: const Icon(Icons.place),
            title: Text(name),
            subtitle: Text(desc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _snack('Open space: $name'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Note: If MainShell already has a FAB, you may want to set it to null on the Spaces tab.
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<SpaceModel>>(
          future: _spacesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final spaces = snapshot.data ?? const <SpaceModel>[];

            // Fallback behavior: use stub list when empty.
            if (spaces.isEmpty) {
              return _buildStubList();
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: spaces.length,
              itemBuilder: (context, index) {
                final space = spaces[index];
                return ListTile(
                  leading: const Icon(Icons.place),
                  title: Text(space.name),
                  subtitle: Text(
                    space.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _navigateToSpace(space),
                  trailing: _canManage(space)
                      ? PopupMenuButton<String>(
                          onSelected: (v) async {
                            switch (v) {
                              case 'edit':
                                await _openCreateOrEdit(space: space);
                                break;
                              case 'delete':
                                await _delete(space);
                                break;
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        )
                      : null,
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: _canCreate
          ? FloatingActionButton(
              onPressed: () => _openCreateOrEdit(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
