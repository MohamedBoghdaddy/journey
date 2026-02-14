
import 'package:flutter/material.dart';
import 'package:masr_spaces_app/theme/tokens.dart';
import 'package:masr_spaces_app/ui/housing/housing_page.dart';

class SpacesExplorePage extends StatelessWidget {
  final String neighborhood;

  const SpacesExplorePage({super.key, required this.neighborhood});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final categories = const ['Food', 'Rentals', 'Scams', 'Jobs', 'Travel', 'Gaming'];

    final spaces = const <Map<String, String>>[
      {
        'name': 'AskEgypt',
        'desc': 'Q&A, stories, help',
        'tag1': 'Active today',
        'tag2': 'Trusted',
      },
      {
        'name': 'Scam Radar',
        'desc': 'Alerts, proof, actions',
        'tag1': 'Near you',
        'tag2': 'High activity',
      },
      {
        'name': 'Rent Watch',
        'desc': 'Listings + real prices',
        'tag1': 'Active today',
        'tag2': 'Near you',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.s16),
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: 'Find spaces, topics...',
              helperText: ' ',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                return Chip(label: Text(categories[i]));
              },
            ),
          ),
          const SizedBox(height: 16),
          Text('Trending spaces', style: t.textTheme.titleLarge),
          const SizedBox(height: 12),
          ...spaces.map(
            (s) => Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['name']!, style: t.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(s['desc']!, style: t.textTheme.bodyMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _tag(context, s['tag1']!),
                        _tag(context, s['tag2']!),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilledButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Preview: ${s['name']}')),
                            );
                          },
                          child: const Text('Preview'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Join: ${s['name']}')),
                            );
                          },
                          child: const Text('Join'),
                        ),
                        const Spacer(),
                        Text(neighborhood, style: t.textTheme.bodyMedium),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.home_work_outlined),
              title: const Text('Housing / Furniture'),
              subtitle: const Text('Stories + listings + scam explainers'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HousingPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.rPill),
        border: Border.all(color: isDark ? AppTokens.borderDark : AppTokens.border),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
