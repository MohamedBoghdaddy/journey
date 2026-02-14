
import 'package:flutter/material.dart';
import 'package:masr_spaces_app/theme/tokens.dart';

class MaslahaLensPage extends StatefulWidget {
  const MaslahaLensPage({super.key});

  @override
  State<MaslahaLensPage> createState() => _MaslahaLensPageState();
}

class _MaslahaLensPageState extends State<MaslahaLensPage> {
  bool _uploaded = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Maslaha Lens')),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.s16),
        children: [
          Text('Private by design', style: t.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Encrypted in transit and at rest. You control deletion.', style: t.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTokens.rCard),
              onTap: () => setState(() => _uploaded = true),
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.s16),
                child: Row(
                  children: [
                    const Icon(Icons.document_scanner_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _uploaded ? 'Document uploaded (stub)' : 'Tap to upload/scan document',
                        style: t.textTheme.bodyLarge,
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_uploaded) ...[
            Text('Extracted fields (confirm/edit)', style: t.textTheme.titleLarge),
            const SizedBox(height: 12),
            _field(t, 'Doc type', 'Contract', 'Confidence: 0.86'),
            _field(t, 'Name', 'User name', 'Confidence: 0.71'),
            _field(t, 'Date', '2026-02-13', 'Confidence: 0.92'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                child: const Text('Generate roadmap (after confirm)'),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => setState(() => _uploaded = false),
              child: const Text('Delete now'),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: () {}, child: const Text('What we store')),
          ],
        ],
      ),
    );
  }

  Widget _field(ThemeData t, String k, String v, String meta) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k, style: t.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(v, style: t.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(meta, style: t.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
