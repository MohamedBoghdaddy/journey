import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/utils/logger.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/watch_messages.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    required this.authRepo,
    required this.watchMessages,
    required this.sendMessage,
    required this.conversationId,
  });

  final AuthRepository authRepo;
  final WatchMessages watchMessages;
  final SendMessage sendMessage;
  final String conversationId;

  bool isLoading = false;
  String? error;
  List<Message> messages = [];

  StreamSubscription<List<Message>>? _sub;

  Future<void> start() async {
    isLoading = true;
    error = null;
    notifyListeners();

    _sub?.cancel();
    _sub = watchMessages(conversationId).listen((items) {
      messages = items;
      isLoading = false;
      notifyListeners();
    }, onError: (e) {
      Logger.e('Watch messages failed', error: e);
      error = 'Failed to load messages';
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> send(String text) async {
    final me = authRepo.currentUser;
    if (me == null) return;
    final content = text.trim();
    if (content.isEmpty) return;
    try {
      await sendMessage(conversationId, me.id, content);
    } catch (e) {
      Logger.e('Send message failed', error: e);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
