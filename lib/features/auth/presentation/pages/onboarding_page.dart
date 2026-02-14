import 'package:flutter/material.dart';

import '../../../../core/config/routes.dart';
import '../../../../core/widgets/app_button.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masr Spaces')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Neighborhood OS for Egypt',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Spaces, trust, chat, and a local marketplace. Built to grow with your community.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            AppButton(
              label: 'Sign in',
              onPressed: () => Navigator.of(context).pushNamed(Routes.authSignIn),
              icon: Icons.login,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamed(Routes.authSignUp),
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
