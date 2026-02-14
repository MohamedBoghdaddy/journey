import 'package:flutter/material.dart';

import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../role_guard.dart';

/// Admin dashboard for viewing and resolving content reports.
///
/// Notes:
/// - Access control should be enforced via [RoleGuard] at navigation time.
/// - This page includes:
///   - Reports queue (real, fetched from [ReportService])
///   - Audit log (stub)
///   - User actions (stub)
class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  late Future<List<ReportModel>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    _reportsFuture = ReportService.instance.fetchReports();
  }

  Future<void> _refresh() async {
    setState(_loadReports);
  }

  Future<void> _resolveReport(String reportId) async {
    try {
      await ReportService.instance.resolveReport(reportId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report resolved')),
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resolve report: $e')),
      );
    }
  }

  bool _canAccess() {
    final u = AuthService.instance.currentUser;
    if (u == null) return false;
    return u.role == UserRole.moderator ||
        u.role == UserRole.admin ||
        u.role == UserRole.superAdmin;
  }

  @override
  Widget build(BuildContext context) {
    // Defensive runtime guard (RoleGuard should enforce before navigation too).
    if (!_canAccess()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin reports')),
        body: const Center(child: Text('Access denied')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin reports'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _ReportsQueueCard(
              reportsFuture: _reportsFuture,
              onResolve: _resolveReport,
            ),
            const SizedBox(height: 12),
            const _StubCard(
              title: 'Audit log (stub)',
              subtitle: 'Connect to your audit_events table',
              icon: Icons.receipt_long,
            ),
            const SizedBox(height: 12),
            const _StubCard(
              title: 'User actions (stub)',
              subtitle: 'Ban/timeout/escalation workflows',
              icon: Icons.gavel,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsQueueCard extends StatelessWidget {
  final Future<List<ReportModel>> reportsFuture;
  final Future<void> Function(String reportId) onResolve;

  const _ReportsQueueCard({
    required this.reportsFuture,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder<List<ReportModel>>(
          future: reportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Reports queue'),
                    subtitle: Text('Failed to load reports'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            }

            final reports = snapshot.data ?? const <ReportModel>[];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reports queue'),
                  subtitle: Text(
                    reports.isEmpty
                        ? 'No reports'
                        : '${reports.length} pending/resolved report(s)',
                  ),
                ),
                if (reports.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Nothing to review right now.'),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reports.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final r = reports[index];
                      final isResolved =
                          (r.status).toString().toLowerCase() == 'resolved';

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '[${r.targetType.toUpperCase()}] ${r.reason}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Target ID: ${r.targetId}\n'
                          'Status: ${r.status}\n'
                          'Reported on: ${r.createdAt}',
                        ),
                        trailing: isResolved
                            ? const Icon(Icons.check, color: Colors.green)
                            : IconButton(
                                tooltip: 'Resolve',
                                icon: const Icon(Icons.done),
                                onPressed: () => onResolve(r.id),
                              ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StubCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _StubCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
