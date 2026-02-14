import 'package:flutter/material.dart';
import '../../services/group_service.dart';

/// Displays a list of groups that the user can join or create.
///
/// Merged + enhanced:
/// - Keeps the original `openCreateGroupDialog()` method used by your older HomePage/FAB
/// - Also exposes `openCreateDialogFromParent()` for the newer GlobalKey trigger
/// - Loads groups from Supabase (and falls back to local stub groups if empty)
/// - Pull-to-refresh
/// - Validation + loading states + error handling
///
/// IMPORTANT: State class name MUST be GroupPageState
/// so HomePage's `GlobalKey<GroupPageState>` works.
class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  GroupPageState createState() => GroupPageState();
}

class GroupPageState extends State<GroupPage> {
  bool _loading = true;
  bool _creating = false;
  String? _error;

  // Supabase rows like: { id, name, description, owner_id, created_at }
  List<Map<String, dynamic>> _groups = const [];

  // Local fallback (from your simple version)
  final List<String> _stubGroups = <String>[
    'Neighborhood Helpers',
    'Football Crew',
    'Study Circle',
  ];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  /// Backward-compatible method (your first code used this name).
  Future<void> openCreateGroupDialog() async {
    await _openCreateDialog(simpleMode: true);
  }

  /// Newer method name (your second code used this).
  Future<void> openCreateDialogFromParent() async {
    await _openCreateDialog(simpleMode: false);
  }

  Future<void> _loadGroups() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rows = await GroupService.instance.listGroups();
      if (!mounted) return;
      setState(() => _groups = rows);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _openCreateDialog({required bool simpleMode}) async {
    if (_creating) return;

    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    try {
      final created = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Create group'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Group name'),
                  textInputAction:
                      simpleMode ? TextInputAction.done : TextInputAction.next,
                  onSubmitted:
                      simpleMode ? (_) => Navigator.pop(ctx, true) : null,
                ),
                if (!simpleMode) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Create'),
              ),
            ],
          );
        },
      );

      if (created != true) return;

      final name = nameCtrl.text.trim();
      final description = descCtrl.text.trim();

      if (name.isEmpty) {
        _showSnack('Group name is required.');
        return;
      }

      setState(() => _creating = true);

      // If your backend supports description, pass it.
      await GroupService.instance.createGroupVoid(
        name,
        simpleMode ? '' : description,
      );

      if (!mounted) return;

      // Also update local stubs list for immediate UI feel (even if backend is slow)
      _stubGroups.remove(name);
      _stubGroups.insert(0, name);

      _showSnack('Group created: $name');
      await _loadGroups();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed: ${e.toString()}');
    } finally {
      nameCtrl.dispose();
      descCtrl.dispose();
      if (mounted) setState(() => _creating = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildStubList() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _stubGroups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final name = _stubGroups[i];
        return ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text('Tap to open (stub)'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showSnack('Open group: $name'),
        );
      },
    );
  }

  Widget _buildSupabaseList() {
    return RefreshIndicator(
      onRefresh: _loadGroups,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _groups.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final g = _groups[index];
          final name = (g['name'] ?? '').toString().trim();
          final desc = (g['description'] ?? '').toString().trim();

          return ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            leading: const Icon(Icons.group),
            title: Text(
              name.isEmpty ? 'Untitled group' : name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: desc.isEmpty
                ? const Text('Tap to open')
                : Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: navigate to group details / join flow
              _showSnack(
                  'Open group: ${name.isEmpty ? 'Untitled group' : name}');
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadGroups,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Merge behavior:
    // - If backend returns no groups yet, show the original local stub list.
    if (_groups.isEmpty) {
      return _buildStubList();
    }

    return _buildSupabaseList();
  }
}
