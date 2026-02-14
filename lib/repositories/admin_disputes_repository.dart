// lib/repositories/admin_disputes_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDisputesRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch open disputes with optional limit.
  Future<List<Map<String, dynamic>>> fetchOpenDisputes({
    int limit = 200,
  }) async {
    final response = await _client
        .from('disputes')
        .select('*, orders(*)')
        .inFilter('status', ['open', 'reviewing']) // ✅ correct method
        .order('created_at', ascending: false)
        .limit(limit);

    // Ensure response is a list
    return (response as List).cast<Map<String, dynamic>>();
  }

  /// Fetch full details for a specific dispute, including order and items.
  Future<Map<String, dynamic>> fetchDisputeDetails(String orderId) async {
    final dispute = await _client
        .from('disputes')
        .select('*')
        .eq('order_id', orderId)
        .single();

    final order =
        await _client.from('orders').select('*').eq('id', orderId).single();

    final items =
        await _client.from('order_items').select('*').eq('order_id', orderId);

    return {
      'dispute': dispute,
      'order': order,
      'items': (items as List).cast<Map<String, dynamic>>(),
    };
  }

  /// Mark a dispute as 'reviewing'.
  Future<void> markReviewing(String orderId) async {
    await _client.from('disputes').update({
      'status': 'reviewing',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('order_id', orderId);
  }

  /// Resolve a dispute via a Supabase Edge Function or RPC.
  /// Expects resolution to be one of: 'refund_buyer', 'release_seller', 'partial', 'no_action'.
  Future<void> resolveDispute({
    required String orderId,
    required String resolution,
    int? amountEgp,
  }) async {
    await _client.rpc('resolve_dispute', params: {
      'p_order_id': orderId,
      'p_resolution': resolution,
      'p_amount_egp': amountEgp,
    });
  }
}
