import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';
import 'supabase_service.dart';

/// ReputationService (merged)
/// - Uses SupabaseService.client if available, otherwise Supabase.instance.client
/// - Monthly decay:
///    - applyMonthlyDecayOnce(): best-effort RPC 'apply_monthly_reputation_decay'
///    - applyMonthlyDecayIfNeeded(): per-user RPC 'apply_reputation_decay(p_user_id)'
/// - Fetch:
///    - fetchMyReputation(): prefers AuthService cached user, then profiles table
/// - Update:
///    - increaseReputation(userId, amount):
///        * tries profiles first, then users (backward compatibility)
///        * updates both 'community_reputation' and 'reputation' when possible
class ReputationService {
  ReputationService._();
  static final ReputationService instance = ReputationService._();

  SupabaseClient get _client {
    try {
      return SupabaseService.client;
    } catch (_) {
      return Supabase.instance.client;
    }
  }

  /// Best-effort monthly decay hook (global).
  /// If you don't have this DB function yet, it safely does nothing.
  Future<void> applyMonthlyDecayOnce() async {
    try {
      await _client.rpc('apply_monthly_reputation_decay');
    } catch (_) {
      // Intentionally ignore errors.
    }
  }

  /// Applies monthly decay for the current signed-in user (per-user).
  /// Calls RPC: apply_reputation_decay(p_user_id uuid)
  Future<void> applyMonthlyDecayIfNeeded() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    await _client.rpc('apply_reputation_decay', params: {
      'p_user_id': uid,
    });
  }

  /// Returns the signed-in user's reputation if available.
  /// Prefers cached user model, then profiles table.
  Future<double?> fetchMyReputation() async {
    final cached = AuthService.instance.currentUser;
    if (cached != null) return cached.communityReputation;

    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final row = await _client
          .from('profiles')
          .select('community_reputation,reputation')
          .eq('id', user.id)
          .maybeSingle();

      if (row == null) return null;

      final v = row['community_reputation'] ?? row['reputation'];
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    } catch (_) {
      return null;
    }
  }

  /// Increases reputation for [userId] by [amount].
  /// Tries 'profiles' first (recommended), then falls back to 'users'.
  Future<void> increaseReputation(String userId, int amount) async {
    if (amount == 0) return;

    // Prefer profiles schema.
    final updatedInProfiles = await _tryIncreaseOnTable(
      table: 'profiles',
      idColumn: 'id',
      repColumns: const ['community_reputation', 'reputation'],
      userId: userId,
      amount: amount,
    );

    if (updatedInProfiles) {
      // Refresh cache best-effort if it's me.
      final me = _client.auth.currentUser?.id;
      if (me != null && me == userId) {
        await AuthService.instance.refreshCachedProfileBestEffort(force: true);
      }
      return;
    }

    // Fallback to older 'users' table.
    final updatedInUsers = await _tryIncreaseOnTable(
      table: 'users',
      idColumn: 'id',
      repColumns: const ['reputation'],
      userId: userId,
      amount: amount,
    );

    if (updatedInUsers) {
      final me = _client.auth.currentUser?.id;
      if (me != null && me == userId) {
        await AuthService.instance.refreshCachedProfileBestEffort(force: true);
      }
    }
  }

  Future<bool> _tryIncreaseOnTable({
    required String table,
    required String idColumn,
    required List<String> repColumns,
    required String userId,
    required int amount,
  }) async {
    try {
      final selectCols = repColumns.join(',');
      final record = await _client
          .from(table)
          .select(selectCols)
          .eq(idColumn, userId)
          .maybeSingle();

      if (record == null) return false;

      // Choose first existing numeric-ish rep value.
      dynamic currentRaw;
      for (final c in repColumns) {
        if (record.containsKey(c) && record[c] != null) {
          currentRaw = record[c];
          break;
        }
      }

      int current = 0;
      if (currentRaw is int) current = currentRaw;
      if (currentRaw is num) current = currentRaw.toInt();
      if (currentRaw != null && currentRaw is! num) {
        current = int.tryParse(currentRaw.toString()) ?? 0;
      }

      final updated = current + amount;

      // Update all known rep columns on that table (keeps compatibility).
      final payload = <String, dynamic>{};
      for (final c in repColumns) {
        payload[c] = updated;
      }

      await _client.from(table).update(payload).eq(idColumn, userId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
