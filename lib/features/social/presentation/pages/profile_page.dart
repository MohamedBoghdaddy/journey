import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading.dart';
import '../../../chat/domain/usecases/get_or_create_dm.dart';
import '../../domain/usecases/follow_user.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/unfollow_user.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.userId});

  final String? userId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _init() {
    final deps = DependenciesScope.of(context);
    final uid = widget.userId ?? deps.authRepository.currentUser?.id;
    if (uid == null) return;

    _controller = ProfileController(
      authRepo: deps.authRepository,
      getProfile: GetProfile(deps.socialRepository),
      followUser: FollowUser(deps.socialRepository),
      unfollowUser: UnfollowUser(deps.socialRepository),
      socialRepo: deps.socialRepository,
      userId: uid,
    )..addListener(_onUpdate);

    _controller!.load();
    setState(() {});
  }

  void _onUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onUpdate);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _messageUser() async {
    final deps = DependenciesScope.of(context);
    final me = deps.authRepository.currentUser;
    final otherId = widget.userId;
    if (me == null || otherId == null || otherId == me.id) return;

    final convoId = await GetOrCreateDm(deps.chatRepository)(otherId, meId: me.id);
    if (!mounted) return;
    Navigator.of(context).pushNamed(Routes.appChatConversation(convoId));
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null) return const SizedBox.shrink();

    if (c.isLoading && c.profile == null) {
      return const Scaffold(body: LoadingView(message: 'Loading profile...'));
    }
    if (c.error != null && c.profile == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(title: c.error!, onRetry: c.load),
      );
    }

    final p = c.profile!;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          if (c.isMe)
            IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.appEditProfile),
              icon: const Icon(Icons.edit_outlined),
            )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileHeader(profile: p),
          const SizedBox(height: 14),
          if (!c.isMe)
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: c.toggleFollow,
                    child: Text(c.isFollowing ? 'Unfollow' : 'Follow'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _messageUser,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Message'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
