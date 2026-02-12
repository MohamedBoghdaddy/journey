import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_model.dart';
import 'supabase_service.dart';

/// A service that handles CRUD operations for groups via Supabase.
class GroupService {
  GroupService._();
  static final GroupService instance = GroupService._();
  final SupabaseClient _client = SupabaseService.client;

  Future<List<GroupModel>> fetchGroups() async {
    final response = await _client.from('groups').select();
    final data = response as List<dynamic>;
    return data.map((row) => GroupModel.fromMap(row as Map<String, dynamic>)).toList();
  }

  Future<GroupModel> createGroup(String name, String description) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    final response = await _client.from('groups').insert({
      'name': name,
      'description': description,
      'owner_id': userId,
    }).select().single();
    return GroupModel.fromMap(response as Map<String, dynamic>);
  }

  Future<void> updateGroup(String groupId, String name, String description) async {
    await _client.from('groups').update({
      'name': name,
      'description': description,
    }).eq('id', groupId);
  }

  Future<void> deleteGroup(String groupId) async {
    await _client.from('groups').delete().eq('id', groupId);
  }
}