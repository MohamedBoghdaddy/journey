// lib/views/admin/admin_disputes_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/admin_disputes_repository.dart';
import 'dispute_details_page.dart';

class AdminDisputesPage extends StatefulWidget {
  const AdminDisputesPage({super.key});

  @override
  State<AdminDisputesPage> createState() => _AdminDisputesPageState();
}

class _AdminDisputesPageState extends State<AdminDisputesPage> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> disputes = [];

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final repo = context.read<AdminDisputesRepository>();
      disputes = await repo.fetchOpenDisputes();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disputes Queue')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: disputes.isEmpty
                      ? ListView(children: const [
                          SizedBox(height: 140),
                          Center(child: Text('No open disputes')),
                        ])
                      : ListView.separated(
                          itemCount: disputes.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final d = disputes[i];
                            final order =
                                (d['orders'] as Map?)?.cast<String, dynamic>();
                            final orderId = d['order_id']?.toString() ??
                                order?['id']?.toString() ??
                                '';
                            final status = (d['status'] ?? '').toString();
                            final reason = (d['reason'] ?? '').toString();
                            final createdAt =
                                (d['created_at'] ?? '').toString();
                            final total = (order?['total_egp'] ?? 0).toString();

                            return ListTile(
                              title: Text('Order $orderId'),
                              subtitle: Text(
                                  '$reason • $status • EGP $total\n$createdAt'),
                              isThreeLine: true,
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () async {
                                final changed = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          DisputeDetailsPage(orderId: orderId)),
                                );
                                if (changed == true) _load();
                              },
                            );
                          },
                        ),
                ),
    );
  }
}
