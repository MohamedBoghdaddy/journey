import 'package:flutter/material.dart';
import 'forum_page.dart';
import 'group_page.dart';
import 'space_page.dart';
import '../../services/auth_service.dart';
import '../role_guard.dart';
import '../../models/user_model.dart';
import 'admin_reports_page.dart';

/// Home page with a bottom navigation bar to navigate between forums, groups and spaces.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  static const List<Widget> _pages = <Widget>[
    ForumPage(),
    GroupPage(),
    SpacePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Masr Spaces'),
            const Spacer(),
            // Display the current user's reputation as a badge. If the user is
            // not signed in, this will show nothing. We extract the
            // reputation from [AuthService.currentUser].
            Builder(
              builder: (_) {
                final user = AuthService.instance.currentUser;
                if (user == null) return const SizedBox.shrink();
                return Row(
                  children: [
                    const Icon(Icons.star, size: 18, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('Rep: \${user.reputation}')
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          // Only administrators and super administrators should see the
          // moderation/dashboard button. We wrap the action in a [RoleGuard]
          // so that users without sufficient privileges simply don’t see it.
          RoleGuard(
            allowedRoles: {UserRole.admin, UserRole.superAdmin, UserRole.moderator},
            builder: (context) => IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                // Navigate to the admin reports dashboard when tapped.
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminReportsPage()),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _pages.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Forums',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place),
            label: 'Spaces',
          ),
        ],
      ),
    );
  }
}