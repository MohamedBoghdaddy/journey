import 'package:flutter/material.dart';

import '../../../../core/widgets/avatar.dart';
import '../../../trust/presentation/widgets/trust_badge.dart';
import '../../domain/entities/profile.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.profile, required this.onOpen});

  final Profile profile;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Avatar(name: profile.name, url: profile.avatarUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(profile.email, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              TrustBadge(score: profile.reputation),
            ],
          ),
        ),
      ),
    );
  }
}
