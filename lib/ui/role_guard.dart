import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

/// RoleGuard
/// Restricts access to a widget subtree based on the signed-in user's role.
///
/// Features:
/// - Supports multiple roles via [allowedRoles]
/// - Optional [fallbackBuilder] when access is denied
/// - Optional [requireSignedIn] to control what happens when user is null
/// - Convenience constructors for common patterns
/// - Static helper [canAccess] for non-widget contexts
class RoleGuard extends StatelessWidget {
  /// Roles that are allowed to see the protected subtree.
  final Set<UserRole> allowedRoles;

  /// Builds the protected subtree when access is granted.
  final WidgetBuilder builder;

  /// Builds an alternative subtree when access is denied.
  /// If null, defaults to an empty box.
  final WidgetBuilder? fallbackBuilder;

  /// If true (default) and the user is null, access is denied.
  /// If false, a null user is still denied by default, but you can decide what
  /// to show via [fallbackBuilder].
  final bool requireSignedIn;

  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.builder,
    this.fallbackBuilder,
    this.requireSignedIn = true,
  });

  /// Allow a single role quickly.
  factory RoleGuard.role({
    Key? key,
    required UserRole role,
    required WidgetBuilder builder,
    WidgetBuilder? fallbackBuilder,
    bool requireSignedIn = true,
  }) {
    return RoleGuard(
      key: key,
      allowedRoles: {role},
      builder: builder,
      fallbackBuilder: fallbackBuilder,
      requireSignedIn: requireSignedIn,
    );
  }

  /// Allow everyone except a set of roles.
  factory RoleGuard.notRoles({
    Key? key,
    required Set<UserRole> deniedRoles,
    required WidgetBuilder builder,
    WidgetBuilder? fallbackBuilder,
    bool requireSignedIn = true,
  }) {
    final all = UserRole.values.toSet();
    final allowed = all.difference(deniedRoles);
    return RoleGuard(
      key: key,
      allowedRoles: allowed,
      builder: builder,
      fallbackBuilder: fallbackBuilder,
      requireSignedIn: requireSignedIn,
    );
  }

  /// Static helper for non-widget contexts.
  static bool canAccess(Set<UserRole> allowedRoles, UserModel? user) {
    if (user == null) return false;
    return allowedRoles.contains(user.role);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    final bool signedInOk = !requireSignedIn || user != null;
    final bool roleOk = user != null && allowedRoles.contains(user.role);
    final bool allowed = signedInOk && roleOk;

    if (allowed) return builder(context);
    if (fallbackBuilder != null) return fallbackBuilder!(context);
    return const SizedBox.shrink();
  }
}

/* -------------------------------------------------------------------------- */
/*                         RUNNABLE USAGE EXAMPLES                            */
/* -------------------------------------------------------------------------- */

/// Drop this page anywhere to see all RoleGuard examples in action.
class RoleGuardExamplesPage extends StatelessWidget {
  const RoleGuardExamplesPage({super.key});

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Example 8: static helper in non-widget logic
    final user = AuthService.instance.currentUser;
    final canSeeAdmin = RoleGuard.canAccess(
      {UserRole.admin, UserRole.superAdmin},
      user,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('RoleGuard Examples'),
        actions: [
          // Example 1: Hide an admin-only button in an AppBar
          RoleGuard(
            allowedRoles: {
              UserRole.admin,
              UserRole.superAdmin,
              UserRole.moderator,
            },
            builder: (context) => IconButton(
              tooltip: 'Admin',
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => _toast(context, 'Open /admin'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Signed-in user: ${user?.email ?? user?.id ?? 'none'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Role: ${user?.role.name ?? 'none'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Static helper canSeeAdmin: $canSeeAdmin',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Example 2: Show "Access denied" text if user lacks permission
          _ExampleCard(
            title: 'Example 2: Admin-only panel with Access denied fallback',
            child: RoleGuard(
              allowedRoles: {UserRole.admin, UserRole.superAdmin},
              builder: (context) => const _AdminDashboardStub(),
              fallbackBuilder: (context) => const _AccessDeniedCentered(),
            ),
          ),

          // Example 3: Guard a full page (route widget style)
          _ExampleCard(
            title: 'Example 3: Guard a full page',
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminRouteExample()),
                );
              },
              child: const Text('Open guarded route'),
            ),
          ),

          // Example 4: Guard a floating action button (only moderators and above)
          _ExampleCard(
            title: 'Example 4: Guard a FAB (opens a demo page)',
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FabGuardDemoPage()),
                );
              },
              child: const Text('Open FAB demo'),
            ),
          ),

          // Example 5: Guard with custom fallback that navigates to login
          _ExampleCard(
            title: 'Example 5: Custom fallback (sign in button)',
            child: RoleGuard(
              allowedRoles: {UserRole.admin},
              builder: (context) => const _AdminPanelStub(),
              fallbackBuilder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => _toast(context, 'Navigate to /login'),
                  child: const Text('Sign in'),
                ),
              ),
            ),
          ),

          // Example 6: Convenience constructor for a single role
          _ExampleCard(
            title: 'Example 6: RoleGuard.role(single role)',
            child: RoleGuard.role(
              role: UserRole.moderator,
              builder: (context) => const _TeacherToolsStub(),
              fallbackBuilder: (context) => const _Shrink(),
            ),
          ),

          // Example 7: Allow everyone except a role (deny user)
          _ExampleCard(
            title: 'Example 7: RoleGuard.notRoles(deny user)',
            child: RoleGuard.notRoles(
              deniedRoles: {UserRole.user},
              builder: (context) => const _StaffOnlyStub(),
              fallbackBuilder: (context) => const _StaffOnlyDeniedStub(),
            ),
          ),

          // Example 9: Recommended: guard routes at the router level
          _ExampleCard(
            title: 'Example 9: Router-level guarding (pattern)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Use onGenerateRoute and return a guarded route widget.\n'
                  'See AdminRouteExample class in this file.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------ Example #2 ------------------------------ */

class _AdminDashboardStub extends StatelessWidget {
  const _AdminDashboardStub();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Text('AdminDashboard (stub): you have access.'),
    );
  }
}

class _AccessDeniedCentered extends StatelessWidget {
  const _AccessDeniedCentered();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Access denied'));
  }
}

/* ------------------------------ Example #3 ------------------------------ */

class AdminRouteExample extends StatelessWidget {
  const AdminRouteExample({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: {UserRole.admin, UserRole.superAdmin},
      builder: (context) => Scaffold(
        // ✅ removed const because AppBar is not const
        appBar: AppBar(title: const Text('Admin Dashboard Page')),
        body: const Center(child: Text('Authorized: Admin dashboard content')),
      ),
      fallbackBuilder: (context) => Scaffold(
        // ✅ removed const
        appBar: AppBar(title: const Text('Admin Dashboard Page')),
        body: const Center(child: Text('Not authorized')),
      ),
    );
  }
}

/* ------------------------------ Example #4 ------------------------------ */

class FabGuardDemoPage extends StatelessWidget {
  const FabGuardDemoPage({super.key});

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAB Guard Demo')),
      body: const Center(
        child: Text('FAB appears only for moderator/admin/superAdmin'),
      ),
      floatingActionButton: RoleGuard(
        allowedRoles: {UserRole.moderator, UserRole.admin, UserRole.superAdmin},
        builder: (context) => FloatingActionButton(
          onPressed: () => _toast(context, 'Open /create'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

/* ------------------------------ Example #5 ------------------------------ */

class _AdminPanelStub extends StatelessWidget {
  const _AdminPanelStub();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Text('AdminPanel (stub): admin-only tools here.'),
    );
  }
}

/* ------------------------------ Example #6 ------------------------------ */

class _TeacherToolsStub extends StatelessWidget {
  const _TeacherToolsStub();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Text('Moderator tools (stub)'),
    );
  }
}

/* ------------------------------ Example #7 ------------------------------ */

class _StaffOnlyStub extends StatelessWidget {
  const _StaffOnlyStub();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Text('Staff-only panel (stub)'),
    );
  }
}

class _StaffOnlyDeniedStub extends StatelessWidget {
  const _StaffOnlyDeniedStub();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Text('Staff only'),
    );
  }
}

/* ------------------------------ Shared small widgets ------------------------------ */

class _ExampleCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ExampleCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _Shrink extends StatelessWidget {
  const _Shrink();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
