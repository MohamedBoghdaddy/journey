import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading.dart';
import '../../domain/usecases/create_space.dart';
import '../../domain/usecases/join_space.dart';
import '../../domain/usecases/leave_space.dart';
import '../../domain/usecases/list_spaces.dart';
import '../controllers/spaces_controller.dart';
import '../widgets/space_card.dart';
import '../../../../features/spaces/presentation/pages/space_details_page.dart';

class SpacesHomePage extends StatefulWidget {
  const SpacesHomePage({super.key});

  @override
  State<SpacesHomePage> createState() => _SpacesHomePageState();
}

class _SpacesHomePageState extends State<SpacesHomePage> {
  late final SpacesController _controller;

  @override
  void initState() {
    super.initState();
    final deps = DependenciesScope.of(context);
    _controller = SpacesController(
      authRepo: deps.authRepository,
      listSpaces: ListSpaces(deps.spacesRepository),
      createSpace: CreateSpace(deps.spacesRepository),
      joinSpace: JoinSpace(deps.spacesRepository),
      leaveSpace: LeaveSpace(deps.spacesRepository),
      spacesRepo: deps.spacesRepository,
    );
    _controller.addListener(_onUpdate);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading && _controller.spaces.isEmpty) {
      return const LoadingView(message: 'Loading spaces...');
    }
    if (_controller.error != null && _controller.spaces.isEmpty) {
      return ErrorView(
        title: _controller.error!,
        onRetry: _controller.load,
      );
    }
    if (_controller.spaces.isEmpty) {
      return const EmptyState(
        title: 'No spaces yet',
        subtitle: 'Create the first space for your neighborhood.',
        icon: Icons.apartment_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.spaces.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final s = _controller.spaces[i];
          return SpaceCard(
            space: s,
            onOpen: () => Navigator.of(context).pushNamed(Routes.appSpaceDetails(s.id)),
            isMemberFuture: _controller.isMember(s.id),
            onToggleJoin: (isMember) => _controller.toggleMembership(s, isMember),
          );
        },
      ),
    );
  }
}
