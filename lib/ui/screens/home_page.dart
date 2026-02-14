import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/reputation_service.dart';
import '../role_guard.dart';

import 'admin_reports_page.dart';
import 'forum_page.dart';
import 'group_page.dart';
import 'space_page.dart';

/// Global guard so reputation decay runs only once per app session.
bool _didDecay = false;

/// Best-effort: run monthly decay once per app session.
/// Uses ReputationService (preferred). Falls back to direct RPC if needed.
Future<void> runReputationDecayOnce() async {
  if (_didDecay) return;

  final client = Supabase.instance.client;
  final uid = client.auth.currentUser?.id;
  if (uid == null) return;

  _didDecay = true;

  try {
    // Prefer your service method if available.
    // (Your codebase had both applyMonthlyDecayIfNeeded and applyMonthlyDecayOnce;
    //  we call the "once" version because this function already guards per session.)
    await ReputationService.instance.applyMonthlyDecayOnce();
  } catch (_) {
    // Fallback to direct RPC (in case service wiring fails)
    await client.rpc('apply_reputation_decay', params: {
      'p_user_id': uid,
    });
  }
}

/// - Bottom nav (Forums / Groups / Spaces) using Material 3 NavigationBar
/// - IndexedStack preserves tab state
/// - Logout (try/catch + snackbar)
/// - Shows reputation in the AppBar:
///    - Prefer live fetched rep (double)
///    - Fallback to user.reputation / user.communityReputation if present
/// - Admin button guarded by RoleGuard
/// - Context-aware FAB:
///    - Only on Groups tab: triggers Create Group dialog via GlobalKey -> GroupPageState
/// - Applies monthly reputation decay once on startup (best-effort + guarded)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Realtime-ish display (loaded once on warmup; can be refreshed later if needed).
  double? _rep;

  // Key to call methods inside GroupPage state (needs GroupPageState in group_page.dart)
  final GlobalKey<GroupPageState> _groupKey = GlobalKey<GroupPageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const ForumPage(),
      GroupPage(key: _groupKey),
      const SpacePage(),
    ];

    _warmUp();
  }

  Future<void> _warmUp() async {
    // Best-effort; never block UI.
    try {
      await runReputationDecayOnce();
    } catch (_) {}

    try {
      final rep = await ReputationService.instance.fetchMyReputation();
      if (mounted) setState(() => _rep = rep);
    } catch (_) {
      // Ignore; we will show fallback reputation from AuthService currentUser.
    }
  }

  String get _title {
    switch (_currentIndex) {
      case 0:
        return 'Forums';
      case 1:
        return 'Groups';
      case 2:
        return 'Spaces';
      default:
        return 'Masr Spaces';
    }
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  Future<void> _logout() async {
    try {
      await AuthService.instance.logout();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  void _onFab() {
    if (_currentIndex != 1) return;

    // Support both names (from your merged GroupPage):
    // - openCreateDialogFromParent() (newer)
    // - openCreateGroupDialog() (older)
    final state = _groupKey.currentState;
    if (state == null) return;

    // Prefer newer method if present.
    try {
      state.openCreateDialogFromParent();
      return;
    } catch (_) {}

    state.openCreateGroupDialog();
  }

  String _repLabelForAppBar(UserModel? user) {
    // 1) Prefer fetched rep
    if (_rep != null) return _rep!.toStringAsFixed(1);

    // 2) Fallback to int reputation if available
    if (user != null) {
      // Your merged UserModel includes both fields; handle either.
      final intRep = user.reputation;
      if (intRep != 0) return intRep.toString();

      final doubleRep = user.communityReputation;
      if (doubleRep != 0) return doubleRep.toStringAsFixed(1);
    }

    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final repText = _repLabelForAppBar(user);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('Rep $repText'),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          RoleGuard(
            allowedRoles: const {
              UserRole.moderator,
              UserRole.admin,
              UserRole.superAdmin,
            },
            builder: (context) => IconButton(
              tooltip: 'Admin reports',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminReportsPage()),
                );
              },
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Forums',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Groups',
          ),
          NavigationDestination(
            icon: Icon(Icons.place_outlined),
            selectedIcon: Icon(Icons.place),
            label: 'Spaces',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: _onFab,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
