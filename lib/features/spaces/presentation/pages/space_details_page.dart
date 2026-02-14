import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../posts/domain/usecases/list_feed_posts.dart';
import '../../../posts/presentation/widgets/post_card.dart';
import '../../../posts/domain/entities/post.dart';
import '../../../posts/domain/usecases/list_space_posts.dart';
import '../../../posts/presentation/controllers/feed_controller.dart';
import '../../../chat/presentation/controllers/inbox_controller.dart';
import '../../../chat/domain/usecases/get_or_create_space_chat.dart';
import '../../../chat/domain/usecases/list_inbox.dart';
import '../../../chat/domain/usecases/get_or_create_dm.dart';
import '../../../chat/domain/usecases/send_message.dart';
import '../../../chat/domain/usecases/watch_messages.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../domain/entities/space.dart';
import '../../domain/usecases/list_spaces.dart';
import '../../domain/usecases/create_space.dart';
import '../../domain/usecases/join_space.dart';
import '../../domain/usecases/leave_space.dart';
import '../controllers/spaces_controller.dart';
import '../widgets/member_list.dart';

class SpaceDetailsPage extends StatefulWidget {
  const SpaceDetailsPage({super.key, required this.spaceId});

  final String spaceId;

  @override
  State<SpaceDetailsPage> createState() => _SpaceDetailsPageState();
}

class _SpaceDetailsPageState extends State<SpaceDetailsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  late final SpacesController _spacesController;
  late final FeedController _postsController;

  bool _loadingSpace = true;
  String? _spaceName;
  String? _spaceDesc;
  Space? _space;
  String? _error;
  bool _isMember = false;

  List<Map<String, dynamic>> _members = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);

    final deps = DependenciesScope.of(context);

    _spacesController = SpacesController(
      authRepo: deps.authRepository,
      listSpaces: ListSpaces(deps.spacesRepository),
      createSpace: CreateSpace(deps.spacesRepository),
      joinSpace: JoinSpace(deps.spacesRepository),
      leaveSpace: LeaveSpace(deps.spacesRepository),
      spacesRepo: deps.spacesRepository,
    );

    _postsController = FeedController(
      listFeedPosts: ListFeedPosts(deps.postsRepository),
      listSpacePosts: ListSpacePosts(deps.postsRepository),
      spaceId: widget.spaceId,
    );

    _loadSpace();
    _postsController.load();
    _loadMembers();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _spacesController.dispose();
    _postsController.dispose();
    super.dispose();
  }

  Future<void> _loadSpace() async {
    setState(() {
      _loadingSpace = true;
      _error = null;
    });
    try {
      final s = await DependenciesScope.of(context).spacesRepository.getSpace(widget.spaceId);
      final me = DependenciesScope.of(context).authRepository.currentUser;
      bool member = false;
      if (me != null) {
        member = await DependenciesScope.of(context).spacesRepository.isMember(widget.spaceId, me.id);
      }
      setState(() {
        _space = s;
        _spaceName = s?.name ?? 'Space';
        _spaceDesc = s?.description;
        _isMember = member;
      });
    } catch (e) {
      setState(() => _error = 'Failed to load space');
    } finally {
      setState(() => _loadingSpace = false);
    }
  }

  Future<void> _loadMembers() async {
    final deps = DependenciesScope.of(context);
    final rows = await deps.spacesRepository.listMembers(widget.spaceId);
    setState(() => _members = rows);
  }

  Future<void> _toggleJoin() async {
    final s = _space;
    if (s == null) return;
    await _spacesController.toggleMembership(s, _isMember);
    await _loadSpace();
  }

  Future<void> _openSpaceChat() async {
    final deps = DependenciesScope.of(context);
    final me = deps.authRepository.currentUser;
    if (me == null) return;

    final usecase = GetOrCreateSpaceChat(deps.chatRepository);
    final convoId = await usecase(widget.spaceId, meId: me.id);

    if (!mounted) return;
    Navigator.of(context).pushNamed(Routes.appChatConversation(convoId));
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingSpace && _spaceName == null) {
      return const LoadingView(message: 'Loading space...');
    }
    if (_error != null && _spaceName == null) {
      return ErrorView(title: _error!, onRetry: _loadSpace);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_spaceName ?? 'Space'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Posts'),
            Tab(text: 'Chat'),
            Tab(text: 'Members'),
            Tab(text: 'About'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _toggleJoin,
            child: Text(_isMember ? 'Leave' : 'Join'),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildPostsTab(),
          _buildChatTab(),
          _buildMembersTab(),
          _buildAboutTab(),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    if (_postsController.isLoading && _postsController.posts.isEmpty) {
      return const LoadingView(message: 'Loading posts...');
    }
    if (_postsController.error != null && _postsController.posts.isEmpty) {
      return ErrorView(title: _postsController.error!, onRetry: _postsController.load);
    }
    if (_postsController.posts.isEmpty) {
      return EmptyState(
        title: 'No posts yet',
        subtitle: 'Start the conversation in this space.',
        icon: Icons.forum_outlined,
        action: OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pushNamed(
            Routes.appCreateSpacePost(widget.spaceId),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Create post'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _postsController.load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _postsController.posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final post = _postsController.posts[i];
          return PostCard(
            post: post,
            onOpen: () => Navigator.of(context).pushNamed(
              Routes.appSpacePostDetails(widget.spaceId, post.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 44),
            const SizedBox(height: 12),
            const Text('Space chat'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _openSpaceChat,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open chat'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersTab() {
    if (_members.isEmpty) {
      return const EmptyState(
        title: 'No members found',
        subtitle: 'Join this space to become the first member.',
        icon: Icons.people_outline,
      );
    }
    return MemberList(rows: _members);
  }

  Widget _buildAboutTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(_spaceDesc ?? 'No description provided.'),
    );
  }
}
