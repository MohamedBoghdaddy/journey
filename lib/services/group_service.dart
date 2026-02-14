import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_model.dart';
import 'supabase_service.dart';

class GroupService {
  GroupService._();
  static final GroupService instance = GroupService._();

  final SupabaseClient _client = SupabaseService.client;

  static const _cols = 'id,name,description,owner_id,created_at,updated_at';

  // -----------------------------
  // Helpers
  // -----------------------------
  String _requireAuth() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated. Please sign in.');
    return uid;
  }

  Map<String, dynamic> _payload({
    required String name,
    required String description,
    String? ownerId,
  }) {
    final n = name.trim();
    final d = description.trim();

    if (n.isEmpty) throw Exception('Group name is required.');

    return {
      'name': n,
      'description': d,
      if (ownerId != null) 'owner_id': ownerId,
    };
  }

  // Builds a base query with ordering + pagination.
  dynamic _baseQuery({required int limit, required int offset}) {
    return _client
        .from('groups')
        .select(_cols)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // Case-insensitive search (compatible): filter('col', 'ilike', '%q%')
  dynamic _applyILike(dynamic builder, String column, String query) {
    // Most compatible approach across supabase-dart versions:
    return builder.filter(column, 'ilike', '%$query%');

    // If YOUR package is so old that `.filter` doesn’t exist:
    // return builder.like(column, '%$query%'); // (case-sensitive)
  }

  // -----------------------------
  // READ
  // -----------------------------

  Future<List<GroupModel>> fetchGroups({
    String? search,
    int limit = 50,
    int offset = 0,
    bool searchInDescription = false,
  }) async {
    final rows = await listGroups(
      search: search,
      limit: limit,
      offset: offset,
      searchInDescription: searchInDescription,
    );
    return rows.map(GroupModel.fromMap).toList();
  }

  Future<List<Map<String, dynamic>>> listGroups({
    String? search,
    int limit = 50,
    int offset = 0,
    bool searchInDescription = false,
  }) async {
    final q = (search ?? '').trim();

    // No search
    if (q.isEmpty) {
      final res = await _baseQuery(limit: limit, offset: offset);
      return (res as List).cast<Map<String, dynamic>>();
    }

    // Name-only search (fast)
    if (!searchInDescription) {
      final res = await _applyILike(
          _baseQuery(limit: limit, offset: offset), 'name', q);
      return (res as List).cast<Map<String, dynamic>>();
    }

    // Name OR description search without `.or()`: do 2 queries and merge.
    final resName =
        await _applyILike(_baseQuery(limit: limit, offset: offset), 'name', q);
    final resDesc = await _applyILike(
        _baseQuery(limit: limit, offset: offset), 'description', q);

    final nameRows = (resName as List).cast<Map<String, dynamic>>();
    final descRows = (resDesc as List).cast<Map<String, dynamic>>();

    final byId = <String, Map<String, dynamic>>{};
    for (final r in nameRows) {
      final id = (r['id'] ?? '').toString();
      if (id.isNotEmpty) byId[id] = r;
    }
    for (final r in descRows) {
      final id = (r['id'] ?? '').toString();
      if (id.isNotEmpty) byId[id] = r;
    }

    final merged = byId.values.toList();

    // Keep newest-first (string compare works for ISO timestamps)
    merged.sort((a, b) {
      final ac = (a['created_at'] ?? '').toString();
      final bc = (b['created_at'] ?? '').toString();
      return bc.compareTo(ac);
    });

    return merged.take(limit).toList();
  }

  // -----------------------------
  // CREATE
  // -----------------------------

  Future<GroupModel> createGroup(String name, String description) async {
    final ownerId = _requireAuth();

    final res = await _client
        .from('groups')
        .insert(
            _payload(name: name, description: description, ownerId: ownerId))
        .select(_cols)
        .single();

    return GroupModel.fromMap(res as Map<String, dynamic>);
  }

  Future<void> createGroupVoid(String name, String description) async {
    final ownerId = _requireAuth();
    await _client.from('groups').insert(
          _payload(name: name, description: description, ownerId: ownerId),
        );
  }

  // -----------------------------
  // UPDATE
  // -----------------------------

  Future<GroupModel?> updateGroup(
    String groupId,
    String name,
    String description, {
    bool returnRow = false,
  }) async {
    final gid = groupId.trim();
    if (gid.isEmpty) throw Exception('Group id is required.');

    final payload = _payload(name: name, description: description);

    if (!returnRow) {
      await _client.from('groups').update(payload).eq('id', gid);
      return null;
    }

    final res = await _client
        .from('groups')
        .update(payload)
        .eq('id', gid)
        .select(_cols)
        .single();

    return GroupModel.fromMap(res as Map<String, dynamic>);
  }

  // -----------------------------
  // DELETE
  // -----------------------------

  Future<void> deleteGroup(String groupId) async {
    final gid = groupId.trim();
    if (gid.isEmpty) throw Exception('Group id is required.');
    await _client.from('groups').delete().eq('id', gid);
  }

  // -----------------------------
  // GET ONE
  // -----------------------------

  Future<GroupModel> getGroupById(String groupId) async {
    final gid = groupId.trim();
    if (gid.isEmpty) throw Exception('Group id is required.');

    final res =
        await _client.from('groups').select(_cols).eq('id', gid).single();
    return GroupModel.fromMap(res as Map<String, dynamic>);
  }
}
