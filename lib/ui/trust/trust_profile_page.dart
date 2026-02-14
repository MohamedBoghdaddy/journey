
import 'package:flutter/material.dart';
import 'package:masr_spaces_app/theme/tokens.dart';
import 'package:masr_spaces_app/ui/components/trust_badge.dart';
import 'package:masr_spaces_app/ui/family/family_dashboard_page.dart';

class TrustProfilePage extends StatelessWidget {
  const TrustProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.s16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.s16),
              child: Row(
                children: [
                  const CircleAvatar(radius: 22, child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Boghdaddy', style: t.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('Member since • Neighborhood', style: t.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const Icon(Icons.verified_outlined),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTokens.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Reputation'),
                        SizedBox(height: 10),
                        TrustBadge(value: 92, max: 100, title: 'Reputation', visibility: 'Neighbors'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTokens.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Trust Score'),
                        SizedBox(height: 10),
                        TrustBadge(value: 720, max: 1000, title: 'Trust Score', visibility: 'Public'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_fire_department_outlined),
              title: const Text('Weekly streak'),
              subtitle: const Text('Boosts reputation when consistent.'),
              trailing: const Text('5 weeks'),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('Verification'),
              subtitle: const Text('Unlock benefits (safer trades, higher limits).'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: () {}, child: const Text('Share profile')),
          ),
          const SizedBox(height: 16),
          Text('Recent verified events', style: t.textTheme.titleLarge),
          const SizedBox(height: 12),
          const _EventTile(title: 'Reported scam listing', delta: '+6'),
          const _EventTile(title: 'Helpful replies upvoted', delta: '+4'),
          const _EventTile(title: 'Flag appealed successfully', delta: '+3'),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.family_restroom_outlined),
              title: const Text('Family Space dashboard'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FamilyDashboardPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final String title;
  final String delta;

  const _EventTile({required this.title, required this.delta});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.verified_outlined),
        title: Text(title, style: t.textTheme.bodyLarge),
        trailing: Text(delta, style: t.textTheme.labelLarge),
      ),
    );
  }
}
