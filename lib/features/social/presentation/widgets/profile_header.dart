import 'package:flutter/material.dart';

import '../../../../core/widgets/avatar.dart';
import '../../../trust/presentation/widgets/trust_badge.dart';
import '../../domain/entities/profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Avatar(name: profile.name, url: profile.avatarUrl, radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  if (profile.bio != null && profile.bio!.trim().isNotEmpty)
                    Text(profile.bio!, maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            TrustBadge(score: profile.reputation),
          ],
        ),
      ),
    );
  }
}
