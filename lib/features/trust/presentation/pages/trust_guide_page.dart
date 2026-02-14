import 'package:flutter/material.dart';

class TrustGuidePage extends StatelessWidget {
  const TrustGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trust guide')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Trust is a product feature, not a mystery.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Text(
            'Badges reflect signals such as account age, community participation, and report outcomes. '
            'We keep the system understandable and avoid hidden penalties.',
          ),
          SizedBox(height: 16),
          Text('Levels', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text(
            'Verified (80+): consistent positive activity.\n'
            'Trusted (60+): good standing.\n'
            'New (40+): limited history.\n'
            'Low (<40): requires caution.',
          ),
        ],
      ),
    );
  }
}
