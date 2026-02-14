
import 'package:flutter/material.dart';
import 'package:masr_spaces_app/models/content.dart';
import 'package:masr_spaces_app/ui/create/create_composer_page.dart';
import 'package:masr_spaces_app/ui/create/create_hub_sheet.dart';
import 'package:masr_spaces_app/ui/explore/spaces_explore_page.dart';
import 'package:masr_spaces_app/ui/home/home_feed_v2.dart';
import 'package:masr_spaces_app/ui/tasks/tasks_gigs_page.dart';
import 'package:masr_spaces_app/ui/trust/trust_profile_page.dart';

class AppShell extends StatefulWidget {
  final String neighborhood;
  final List<String> interests;

  const AppShell({
    super.key,
    required this.neighborhood,
    required this.interests,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0; // 0,1,3,4 (2 is Create)
  int _lastNonCreateIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeFeedV2(neighborhood: widget.neighborhood, interests: widget.interests),
      SpacesExplorePage(neighborhood: widget.neighborhood),
      const SizedBox.shrink(),
      const TasksGigsPage(),
      const TrustProfilePage(),
    ];

    return Scaffold(
      body: pages[_index],
      floatingActionButton: _buildContextFab(context),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          if (i == 2) {
            _openCreateHub(context);
            setState(() => _index = _lastNonCreateIndex);
            return;
          }
          setState(() {
            _index = i;
            _lastNonCreateIndex = i;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Create',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  FloatingActionButton? _buildContextFab(BuildContext context) {
    switch (_index) {
      case 0:
        return FloatingActionButton.extended(
          onPressed: () => _openComposer(context, ContentType.question),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('New Post'),
        );
      case 1:
        return FloatingActionButton.extended(
          onPressed: () {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Start Space: wire to create-space flow')),
            );
          },
          icon: const Icon(Icons.flag_outlined),
          label: const Text('Start Space'),
        );
      case 3:
        return FloatingActionButton.extended(
          onPressed: () => _openComposer(context, ContentType.service),
          icon: const Icon(Icons.add_task_outlined),
          label: const Text('New Gig'),
        );
      default:
        return null;
    }
  }

  void _openCreateHub(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => CreateHubSheet(
        onPick: (pick) {
          Navigator.of(context).pop();
          if (pick == CreateHubPick.maslahaLens) {
            Navigator.of(context).pushNamed('/maslaha');
            return;
          }
          if (pick == CreateHubPick.founditKyc) {
            Navigator.of(context).pushNamed('/foundit_kyc');
            return;
          }
          _openComposer(context, _mapPickToType(pick));
        },
      ),
    );
  }

  ContentType _mapPickToType(CreateHubPick pick) {
    switch (pick) {
      case CreateHubPick.ask:
        return ContentType.question;
      case CreateHubPick.report:
        return ContentType.alert;
      case CreateHubPick.list:
        return ContentType.listing;
      case CreateHubPick.offer:
        return ContentType.service;
      case CreateHubPick.foundit:
      case CreateHubPick.postInSpace:
      case CreateHubPick.maslahaLens:
      case CreateHubPick.founditKyc:
        return ContentType.story;
    }
  }

  void _openComposer(BuildContext context, ContentType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateComposerPage(
          initialType: type,
          initialNeighborhood: widget.neighborhood,
        ),
      ),
    );
  }
}
