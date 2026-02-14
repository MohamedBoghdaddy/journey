
  import 'package:flutter/material.dart';
  import 'package:masr_spaces_app/state/session.dart';
  import 'package:masr_spaces_app/theme/tokens.dart';

  class FounditKycModal extends StatelessWidget {
    const FounditKycModal({super.key});

    @override
    Widget build(BuildContext context) {
      final t = Theme.of(context);

      return Scaffold(
        appBar: AppBar(title: const Text('Verification required')),
        body: Padding(
          padding: const EdgeInsets.all(AppTokens.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Why we require this', style: t.textTheme.titleLarge),
              const SizedBox(height: 10),
              Text(
                'Some actions involve higher risk. Verification reduces scams and enables safer transactions.',
                style: t.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text('Steps', style: t.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('- Confirm phone - Verify identity- Unlock high-trust actions', style: t.textTheme.bodyLarge),
              const SizedBox(height: 16),
              Text('If you do later (limited access)', style: t.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('- In-app chat only - Masked contact\n- Limited transaction features', style: t.textTheme.bodyLarge),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    SessionStore.setVerified(true);
                    final bumped = (SessionStore.value.trust + 8).clamp(0, 100);
                    SessionStore.setTrust(bumped);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Verified (prototype).')),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Verify now'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Do later'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
