import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/data/datasources/auth_remote_ds.dart';
import '../features/auth/data/datasources/profile_remote_ds.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/data/repositories/profile_repository.dart';
import '../features/chat/data/datasources/chat_remote_ds.dart';
import '../features/chat/data/repositories/chat_repository.dart';
import '../features/marketplace/data/datasources/market_remote_ds.dart';
import '../features/marketplace/data/repositories/market_repository.dart';
import '../features/posts/data/datasources/posts_remote_ds.dart';
import '../features/posts/data/repositories/posts_repository.dart';
import '../features/social/data/datasources/social_remote_ds.dart';
import '../features/social/data/repositories/social_repository.dart';
import '../features/spaces/data/datasources/spaces_remote_ds.dart';
import '../features/spaces/data/repositories/spaces_repository.dart';
import '../features/trust/data/datasources/trust_remote_ds.dart';
import '../features/trust/data/repositories/trust_repository.dart';
import '../features/moderation/data/datasources/moderation_remote_ds.dart';
import '../features/moderation/data/repositories/moderation_repository.dart';
import '../shared/data/services/realtime_service.dart';
import '../shared/data/services/storage_service.dart';

class AppDependencies {
  AppDependencies._({
    required this.supabase,
    required this.authRepository,
    required this.profileRepository,
    required this.spacesRepository,
    required this.postsRepository,
    required this.socialRepository,
    required this.chatRepository,
    required this.marketRepository,
    required this.moderationRepository,
    required this.trustRepository,
    required this.storageService,
    required this.realtimeService,
  });

  final SupabaseClient? supabase;

  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final SpacesRepository spacesRepository;
  final PostsRepository postsRepository;
  final SocialRepository socialRepository;
  final ChatRepository chatRepository;
  final MarketRepository marketRepository;
  final ModerationRepository moderationRepository;
  final TrustRepository trustRepository;

  final StorageService storageService;
  final RealtimeService realtimeService;

  static Future<AppDependencies> create() async {
    final SupabaseClient? sb = _trySupabaseClient();

    final storage = StorageService(client: sb);
    final realtime = RealtimeService(client: sb);

    final authRemote = AuthRemoteDs(client: sb);
    final profileRemote = ProfileRemoteDs(client: sb);

    final spacesRemote = SpacesRemoteDs(client: sb);
    final postsRemote = PostsRemoteDs(client: sb);
    final socialRemote = SocialRemoteDs(client: sb);

    final chatRemote = ChatRemoteDs(client: sb);
    final marketRemote = MarketRemoteDs(client: sb);
    final trustRemote = TrustRemoteDs(client: sb);
    final moderationRemote = ModerationRemoteDs(client: sb);

    return AppDependencies._(
      supabase: sb,
      authRepository: AuthRepository(authRemote: authRemote),
      profileRepository: ProfileRepository(profileRemote: profileRemote),
      spacesRepository: SpacesRepository(remote: spacesRemote),
      postsRepository: PostsRepository(remote: postsRemote),
      socialRepository: SocialRepository(remote: socialRemote),
      chatRepository: ChatRepository(remote: chatRemote),
      marketRepository: MarketRepository(remote: marketRemote),
      trustRepository: TrustRepository(remote: trustRemote),
      moderationRepository: ModerationRepository(remote: moderationRemote),
      storageService: storage,
      realtimeService: realtime,
    );
  }

  static SupabaseClient? _trySupabaseClient() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }
}

class DependenciesScope extends InheritedWidget {
  const DependenciesScope({
    super.key,
    required this.deps,
    required super.child,
  });

  final AppDependencies deps;

  static AppDependencies of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<DependenciesScope>();
    if (scope == null) {
      throw StateError('DependenciesScope not found in widget tree.');
    }
    return scope.deps;
  }

  @override
  bool updateShouldNotify(DependenciesScope oldWidget) => deps != oldWidget.deps;
}
