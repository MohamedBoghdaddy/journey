import 'package:flutter/material.dart';

import '../../core/config/routes.dart';
import '../../features/chat/presentation/pages/inbox_page.dart';
import '../../features/marketplace/presentation/pages/marketplace_home_page.dart';
import '../../features/posts/presentation/pages/feed_page.dart';
import '../../features/social/presentation/pages/profile_page.dart';
import '../../features/spaces/presentation/pages/spaces_page.dart';
import 'bottom_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // Not const → avoids "non_constant_list_element" and doesn't require const constructors.
  late final List<Widget> _pages = <Widget>[
    FeedPage(),
    SpacesPage(),
    MarketplaceHomePage(),
    InboxPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    final max = _pages.length - 1;
    final i = widget.initialIndex;
    _index = (i < 0)
        ? 0
        : (i > max)
            ? max
            : i;
  }

  void _onTap(int i) => setState(() => _index = i);

  void _onFab() {
    switch (_index) {
      case 0:
        Navigator.of(context).pushNamed(Routes.appCreatePost);
        return;
      case 1:
        Navigator.of(context).pushNamed(Routes.appSpaces);
        return;
      case 2:
        Navigator.of(context).pushNamed(Routes.appCreateListing);
        return;
      case 3:
        Navigator.of(context).pushNamed(Routes.appNewDm);
        return;
      case 4:
        Navigator.of(context).pushNamed(Routes.appEditProfile);
        return;
    }
  }

  IconData get _fabIcon {
    switch (_index) {
      case 0:
        return Icons.add;
      case 1:
        return Icons.apartment_outlined;
      case 2:
        return Icons.add_business_outlined;
      case 3:
        return Icons.edit_outlined;
      case 4:
        return Icons.edit_outlined;
      default:
        return Icons.add;
    }
  }

  String get _fabLabel {
    switch (_index) {
      case 0:
        return 'Post';
      case 2:
        return 'Listing';
      case 3:
        return 'Message';
      case 4:
        return 'Edit';
      default:
        return 'Action';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onFab,
        icon: Icon(_fabIcon),
        label: Text(_fabLabel),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _index,
        onTap: _onTap,
      ),
    );
  }
}
