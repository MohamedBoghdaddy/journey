import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// A service responsible for updating user reputation scores. Reputation is a
/// simple integer value stored alongside each user record (for example in
/// a `users` table). When users receive upvotes on their posts, their
/// reputation can be increased to reflect their positive contributions.
///
/// This service reads the current reputation value for a user and writes
/// back an updated value. It is designed to be called from other
/// services when an action merits a reputation change.
class ReputationService {
  ReputationService._();

  /// Singleton instance of [ReputationService].
  static final ReputationService instance = ReputationService._();

  final SupabaseClient _client = SupabaseService.client;

  /// Increases the reputation for the user with [userId] by the given
  /// [amount]. This method reads the current reputation value, adds
  /// [amount], and writes the new value back to the database. If the user
  /// does not have an existing reputation value, it defaults to 0.
  Future<void> increaseReputation(String userId, int amount) async {
    // Fetch the current reputation value from the users table. You may
    // customize the table name to match your schema (e.g. 'profiles' or
    // another custom table). This assumes a table named 'users' with a
    // primary key column 'id' and an integer 'reputation' column.
    final record = await _client.from('users').select('reputation').eq('id', userId).maybeSingle();
    final current = (record?['reputation'] as int?) ?? 0;
    final updated = current + amount;
    await _client.from('users').update({'reputation': updated}).eq('id', userId);
  }
}