import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading.dart';
import '../../domain/usecases/search_users.dart';
import '../controllers/social_controller.dart';
import '../widgets/user_tile.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late final SocialController _controller;

  @override
  void initState() {
    super.initState();
    final deps = DependenciesScope.of(context);
    _controller = SocialController(searchUsers: SearchUsers(deps.socialRepository));
    _controller.addListener(_onUpdate);
    _controller.search('');
  }

  void _onUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: _controller.search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search people',
              ),
            ),
          ),
          Expanded(
            child: _controller.isLoading && _controller.results.isEmpty
                ? const LoadingView(message: 'Searching...')
                : _controller.results.isEmpty
                    ? const EmptyState(
                        title: 'No users found',
                        subtitle: 'Try a different search term.',
                        icon: Icons.person_search_outlined,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _controller.results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final u = _controller.results[i];
                          return UserTile(
                            profile: u,
                            onOpen: () => Navigator.of(context)
                                .pushNamed(Routes.appUserProfile(u.id)),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
