import 'package:flutter/material.dart';

import '../../bootstrap/dependencies.dart';
import '../../core/config/routes.dart';
import '../../core/utils/logger.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = DependenciesScope.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.space_dashboard_outlined),
              title: const Text('Masr Spaces'),
              subtitle: const Text('Neighborhood OS'),
              onTap: () => Navigator.of(context).pop(),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.explore_outlined),
              title: const Text('Explore'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(Routes.appExplore);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('My Orders'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(Routes.appMyOrders);
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  await deps.authRepository.signOut();
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(Routes.authSignIn, (_) => false);
                  }
                } catch (e) {
                  Logger.e('Logout failed', error: e);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout failed')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
