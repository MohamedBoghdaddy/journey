// lib/views/admin/dispute_details_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/admin_disputes_repository.dart';

class DisputeDetailsPage extends StatefulWidget {
  final String orderId;
  const DisputeDetailsPage({super.key, required this.orderId});

  @override
  State<DisputeDetailsPage> createState() => _DisputeDetailsPageState();
}

class _DisputeDetailsPageState extends State<DisputeDetailsPage> {
  bool loading = true;
  String? error;
  Map<String, dynamic>? data;

  final _partialAmount = TextEditingController();

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final repo = context.read<AdminDisputesRepository>();
      data = await repo.fetchDisputeDetails(widget.orderId);
      await repo.markReviewing(widget.orderId);
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _resolve(String resolution) async {
    final repo = context.read<AdminDisputesRepository>();

    int? amount;
    if (resolution == 'partial') {
      amount = int.tryParse(_partialAmount.text.trim());
      if (amount == null || amount < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter a valid partial amount')));
        return;
      }
    }

    try {
      await repo.resolveDispute(
          orderId: widget.orderId, resolution: resolution, amountEgp: amount);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error != null)
      return Scaffold(appBar: AppBar(), body: Center(child: Text(error!)));

    final dispute = (data!['dispute'] as Map).cast<String, dynamic>();
    final order = (data!['order'] as Map).cast<String, dynamic>();
    final items = (data!['items'] as List).cast<Map<String, dynamic>>();

    final reason = (dispute['reason'] ?? '').toString();
    final details = (dispute['details'] ?? '').toString();
    final status = (dispute['status'] ?? '').toString();

    final buyer = (order['buyer_id'] ?? '').toString();
    final seller = (order['seller_id'] ?? '').toString();
    final total = (order['total_egp'] ?? 0).toString();
    final orderStatus = (order['status'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Dispute Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _kv('Order', widget.orderId),
          _kv('Order Status', orderStatus),
          _kv('Dispute Status', status),
          const SizedBox(height: 10),
          _section('Parties'),
          _kv('Buyer', buyer),
          _kv('Seller', seller),
          const SizedBox(height: 10),
          _section('Reason'),
          Text(reason, style: Theme.of(context).textTheme.titleMedium),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(details),
          ],
          const SizedBox(height: 10),
          _section('Items'),
          ...items.map((it) {
            final title = (it['title_snapshot'] ?? '').toString();
            final price = (it['price_egp_snapshot'] ?? 0).toString();
            final qty = (it['quantity'] ?? 1).toString();
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(title),
              subtitle: Text('EGP $price × $qty'),
            );
          }),
          const Divider(height: 24),
          _section('Total'),
          Text('EGP $total', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _section('Resolve'),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _resolve('refund_buyer'),
              child: const Text('Refund buyer'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _resolve('release_seller'),
              child: const Text('Release to seller (complete)'),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _partialAmount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Partial amount (EGP)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _resolve('partial'),
              child: const Text('Partial resolution'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _resolve('no_action'),
              child: const Text('No action (close as completed)'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 110,
                child: Text(k, style: Theme.of(context).textTheme.labelLarge)),
            Expanded(child: Text(v)),
          ],
        ),
      );
}
