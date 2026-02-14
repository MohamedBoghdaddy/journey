// lib/services/order_notifications_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderNotificationsService {
  RealtimeChannel? _channel;

  /// Start listening to order status changes for the current user.
  void start(BuildContext context) {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;

    // Create a channel for the user (covers both buyer and seller roles)
    _channel = Supabase.instance.client.channel('orders-$uid')
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'orders',
        filter: PostgresChangeFilter(
          column: 'buyer_id',
          type: PostgresChangeFilterType.eq,
          value: uid,
        ),
        callback: (payload) => _handle(context, payload),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'orders',
        filter: PostgresChangeFilter(
          column: 'seller_id',
          type: PostgresChangeFilterType.eq,
          value: uid,
        ),
        callback: (payload) => _handle(context, payload),
      )
      ..subscribe();
  }

  /// Handle incoming change notifications.
  void _handle(BuildContext context, PostgresChangePayload payload) {
    final oldRow = payload.oldRecord;
    final newRow = payload.newRecord;
    if (oldRow.isEmpty || newRow.isEmpty) return;

    final oldStatus = (oldRow['status'] ?? '').toString();
    final newStatus = (newRow['status'] ?? '').toString();
    if (oldStatus == newStatus) return;

    final orderId = (newRow['id'] ?? '').toString();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order $orderId: $oldStatus → $newStatus')),
    );
  }

  /// Stop listening and clean up the channel.
  void stop() {
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
      _channel = null;
    }
  }
}
