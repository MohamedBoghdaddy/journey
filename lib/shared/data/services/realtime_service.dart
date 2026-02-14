import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/logger.dart';

class RealtimeService {
  RealtimeService({required this.client});

  final SupabaseClient? client;

  RealtimeChannel? _channel;

  Future<void> connect({String channelName = 'realtime'}) async {
    final sb = client;
    if (sb == null) return;
    try {
      _channel ??= sb.channel(channelName);
      await _channel!.subscribe();
    } catch (e) {
      Logger.e('Realtime connect failed', error: e);
      Logger.e('Realtime disconnect failed', error: e);
    }
  }

  Future<void> disconnect() async {
    final sb = client;
    if (sb == null) return;
    try {
      final ch = _channel;
      if (ch != null) await sb.removeChannel(ch);
    } catch (e) {
      Logger.e('Realtime connect failed', error: e);
      Logger.e('Realtime disconnect failed', error: e);
    } finally {
      _channel = null;
    }
  }
}
