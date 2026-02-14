import 'package:flutter/foundation.dart';

import '../../../../core/utils/logger.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/usecases/list_inbox.dart';

class InboxController extends ChangeNotifier {
  InboxController({
    required this.authRepo,
    required this.listInbox,
  });

  final AuthRepository authRepo;
  final ListInbox listInbox;

  bool isLoading = false;
  String? error;
  List<ChatThread> threads = [];

  Future<void> load() async {
    final me = authRepo.currentUser;
    if (me == null) {
      error = 'Not signed in';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      threads = await listInbox(me.id);
    } catch (e) {
      Logger.e('Load inbox failed', error: e);
      error = 'Failed to load inbox';
    }

    isLoading = false;
    notifyListeners();
  }
}
