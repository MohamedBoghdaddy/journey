import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading.dart';
import '../../domain/usecases/list_reports.dart';
import '../../domain/usecases/resolve_report.dart';
import '../controllers/reports_controller.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  late final ReportsController _controller;

  @override
  void initState() {
    super.initState();
    final deps = DependenciesScope.of(context);
    _controller = ReportsController(
      authRepo: deps.authRepository,
      listReports: ListReports(deps.moderationRepository),
      resolveReport: ResolveReport(deps.moderationRepository),
    );
    _controller.addListener(_onUpdate);
    _controller.load();
  }

  void _onUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading && _controller.reports.isEmpty) {
      return const Scaffold(body: LoadingView(message: 'Loading reports...'));
    }
    if (_controller.error != null && _controller.reports.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reports')),
        body: ErrorView(title: _controller.error!, onRetry: _controller.load),
      );
    }
    if (_controller.reports.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reports')),
        body: const EmptyState(
          title: 'No reports',
          subtitle: 'Nothing to review right now.',
          icon: Icons.inbox_outlined,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: RefreshIndicator(
        onRefresh: _controller.load,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _controller.reports.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final r = _controller.reports[i];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${r.targetType.toUpperCase()} • ${r.targetId}',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(r.reason),
                    if (r.details != null && r.details!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(r.details!),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Status: ${r.status ?? 'pending'}',
                            style: Theme.of(context).textTheme.bodySmall),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: () => _controller.resolve(r, false),
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => _controller.resolve(r, true),
                          child: const Text('Resolve'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
