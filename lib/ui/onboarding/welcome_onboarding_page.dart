
import 'package:flutter/material.dart';
import 'package:masr_spaces_app/theme/tokens.dart';
import 'package:masr_spaces_app/ui/shell/app_shell.dart';

class WelcomeOnboardingPage extends StatefulWidget {
  const WelcomeOnboardingPage({super.key});

  @override
  State<WelcomeOnboardingPage> createState() => _WelcomeOnboardingPageState();
}

class _WelcomeOnboardingPageState extends State<WelcomeOnboardingPage> {
  int _step = 0;

  final List<String> _neighborhoods = const [
    'Maadi',
    'Nasr City',
    'Heliopolis',
    'Zamalek',
    'Dokki',
    '6th of October',
    'New Cairo',
  ];

  final List<String> _interests = const [
    'Food',
    'Jobs',
    'Football',
    'Rentals',
    'Scam Alerts',
    'Travel',
    'Gaming',
    'Home Improvement',
    'Relationships',
    'Marketplace',
  ];

  String? _selectedNeighborhood;
  final Set<String> _selectedInterests = {};

  bool get _canContinueStep2 => _selectedInterests.isNotEmpty;

  void _toggleInterest(String v) {
    setState(() {
      if (_selectedInterests.contains(v)) {
        _selectedInterests.remove(v);
      } else {
        if (_selectedInterests.length >= 3) return;
        _selectedInterests.add(v);
      }
    });
  }

  void _goToApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AppShell(
          neighborhood: _selectedNeighborhood ?? 'Nearby',
          interests: _selectedInterests.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 0 ? 'Welcome' : 'Personalize'),
        actions: [
          TextButton(
            onPressed: _goToApp,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.s16),
          child: _step == 0 ? _stepOne(t) : _stepTwo(t),
        ),
      ),
    );
  }

  Widget _stepOne(ThemeData t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your neighborhood, organized.', style: t.textTheme.headlineSmall),
        const SizedBox(height: 10),
        Text('Spaces near you', style: t.textTheme.bodyLarge),
        const SizedBox(height: 6),
        Text('Trust profiles', style: t.textTheme.bodyLarge),
        const SizedBox(height: 6),
        Text('Alerts, services, and marketplace', style: t.textTheme.bodyLarge),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => setState(() => _step = 1),
            child: const Text('Continue'),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign in: wire to auth later')),
            );
          },
          child: const Text('I already have an account'),
        ),
      ],
    );
  }

  Widget _stepTwo(ThemeData t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Where do you live?', style: t.textTheme.titleLarge),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedNeighborhood,
          items: _neighborhoods
              .map((n) => DropdownMenuItem(value: n, child: Text(n)))
              .toList(),
          onChanged: (v) => setState(() => _selectedNeighborhood = v),
          decoration: const InputDecoration(
            hintText: 'Neighborhood (optional but recommended)',
            helperText: 'Used to show nearby posts and safety alerts.',
          ),
        ),
        const SizedBox(height: 16),
        Text('What interests you?', style: t.textTheme.titleLarge),
        const SizedBox(height: 10),
        Text('Pick 1–3', style: t.textTheme.bodyMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _interests.map((i) {
            final selected = _selectedInterests.contains(i);
            return FilterChip(
              selected: selected,
              showCheckmark: false,
              label: Text(i),
              onSelected: (_) => _toggleInterest(i),
            );
          }).toList(),
        ),
        const Spacer(),
        Text(
          'Verification unlocks higher trust features later.',
          style: t.textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _canContinueStep2 ? _goToApp : null,
            child: Text(_canContinueStep2 ? 'Continue' : 'Pick at least 1 interest'),
          ),
        ),
      ],
    );
  }
}
