import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../models/chat_thread_model.dart';
import '../models/message_model.dart';

class ChatRemoteDs {
  ChatRemoteDs({required this.client});

  final SupabaseClient? client;

  Future<List<ChatThreadModel>> listInbox(String userId) async {
    final sb = client;
    if (sb == null) return [];
    // Prefer v_inbox view if available
    try {
      final rows = await sb
          .from('v_inbox')
          .select('*')
          .eq('user_id', userId)
          .order('updated_at', ascending: false);
      return (rows as List).map((e) => ChatThreadModel.fromMap(e)).toList();
    } catch (_) {
      // fallback below
    }

    try {
      final memberships = await sb
          .from(DbTables.conversationMembers)
          .select('conversation_id')
          .eq('user_id', userId);
      final ids = (memberships as List)
          .map((e) => (e['conversation_id'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toList();
      if (ids.isEmpty) return [];

      final conversations = await sb
          .from(DbTables.conversations)
          .select('*')
          .inFilter('id', ids)
          .order('updated_at', ascending: false);

      return (conversations as List)
          .map((e) => ChatThreadModel.fromMap(e))
          .toList();
    } catch (e) {
      Logger.w('listInbox fallback failed: $e');
      return [];
    }
  }

  Future<List<MessageModel>> listMessages(String conversationId, {int limit = 100}) async {
    final sb = client;
    if (sb == null) return [];
    try {
      final rows = await sb
          .from(DbTables.messages)
          .select('*')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true)
          .limit(limit);
      return (rows as List).map((e) => MessageModel.fromMap(e)).toList();
    } catch (e) {
      Logger.w('listMessages failed: $e');
      return [];
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    final sb = client;
    if (sb == null) throw const NetworkException('Supabase not initialized.');
    try {
      await sb.from(DbTables.messages).insert({
        'conversation_id': conversationId,
        'sender_id': senderId,
        'content': content,
      });
    } catch (e) {
      throw NetworkException('Send message failed', cause: e);
    }
  }

  Future<String> _createConversation({
    required String type,
    String? spaceId,
    String? productId,
  }) async {
    final sb = client;
    if (sb == null) throw const NetworkException('Supabase not initialized.');
    final row = await sb.from(DbTables.conversations).insert({
      'type': type,
      'space_id': spaceId,
      'product_id': productId,
    }).select('id').single();
    return (row['id'] ?? '').toString();
  }

  Future<void> _ensureMember({required String conversationId, required String userId}) async {
    final sb = client;
    if (sb == null) return;
    try {
      await sb.from(DbTables.conversationMembers).upsert({
        'conversation_id': conversationId,
        'user_id': userId,
      });
    } catch (e) {
      Logger.w('_ensureMember failed: $e');
    }
  }

  Future<String> getOrCreateDm({required String meId, required String otherId}) async {
    final sb = client;
    if (sb == null) throw const NetworkException('Supabase not initialized.');

    try {
      final myMemberships = await sb
          .from(DbTables.conversationMembers)
          .select('conversation_id')
          .eq('user_id', meId);

      final myIds = (myMemberships as List)
          .map((e) => (e['conversation_id'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toList();
      if (myIds.isNotEmpty) {
        final otherMemberships = await sb
            .from(DbTables.conversationMembers)
            .select('conversation_id')
            .eq('user_id', otherId)
            .inFilter('conversation_id', myIds);

        final sharedIds = (otherMemberships as List)
            .map((e) => (e['conversation_id'] ?? '').toString())
            .where((s) => s.isNotEmpty)
            .toList();

        if (sharedIds.isNotEmpty) {
          final convo = await sb
              .from(DbTables.conversations)
              .select('id,type')
              .inFilter('id', sharedIds)
              .eq('type', 'dm')
              .maybeSingle();

          if (convo != null) return (convo['id'] ?? '').toString();
        }
      }
    } catch (e) {
      Logger.w('getOrCreateDm lookup failed: $e');
    }

    final convoId = await _createConversation(type: 'dm');
    await _ensureMember(conversationId: convoId, userId: meId);
    await _ensureMember(conversationId: convoId, userId: otherId);
    return convoId;
  }

  Future<String> getOrCreateSpaceChat({required String meId, required String spaceId}) async {
    final sb = client;
    if (sb == null) throw const NetworkException('Supabase not initialized.');

    try {
      final existing = await sb
          .from(DbTables.conversations)
          .select('id')
          .eq('type', 'space')
          .eq('space_id', spaceId)
          .maybeSingle();
      if (existing != null) {
        final id = (existing['id'] ?? '').toString();
        await _ensureMember(conversationId: id, userId: meId);
        return id;
      }
    } catch (e) {
      Logger.w('getOrCreateSpaceChat lookup failed: $e');
    }

    final id = await _createConversation(type: 'space', spaceId: spaceId);
    await _ensureMember(conversationId: id, userId: meId);
    return id;
  }

  Future<String> getOrCreateProductChat({
    required String meId,
    required String otherId,
    required String productId,
  }) async {
    final sb = client;
    if (sb == null) throw const NetworkException('Supabase not initialized.');

    try {
      final existing = await sb
          .from(DbTables.conversations)
          .select('id')
          .eq('type', 'product')
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        final id = (existing['id'] ?? '').toString();
        await _ensureMember(conversationId: id, userId: meId);
        await _ensureMember(conversationId: id, userId: otherId);
        return id;
      }
    } catch (e) {
      Logger.w('getOrCreateProductChat lookup failed: $e');
    }

    final id = await _createConversation(type: 'product', productId: productId);
    await _ensureMember(conversationId: id, userId: meId);
    await _ensureMember(conversationId: id, userId: otherId);
    return id;
  }

  Stream<List<MessageModel>> watchMessages(String conversationId, {Duration interval = const Duration(seconds: 2)}) async* {
    while (true) {
      final items = await listMessages(conversationId);
      yield items;
      await Future.delayed(interval);
    }
  }
}
