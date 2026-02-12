import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/space_model.dart';
import 'supabase_service.dart';

/// A service that handles CRUD operations for spaces via Supabase.
class SpaceService {
  SpaceService._();
  static final SpaceService instance = SpaceService._();
  final SupabaseClient _client = SupabaseService.client;

  Future<List<SpaceModel>> fetchSpaces() async {
    final response = await _client.from('spaces').select();
    final data = response as List<dynamic>;
    return data.map((row) => SpaceModel.fromMap(row as Map<String, dynamic>)).toList();
  }

  Future<SpaceModel> createSpace(String name, String description) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    final response = await _client.from('spaces').insert({
      'name': name,
      'description': description,
      'owner_id': userId,
    }).select().single();
    return SpaceModel.fromMap(response as Map<String, dynamic>);
  }

  Future<void> updateSpace(String spaceId, String name, String description) async {
    await _client.from('spaces').update({
      'name': name,
      'description': description,
    }).eq('id', spaceId);
  }

  Future<void> deleteSpace(String spaceId) async {
    await _client.from('spaces').delete().eq('id', spaceId);
  }
}