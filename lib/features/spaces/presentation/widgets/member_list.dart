import 'package:flutter/material.dart';

import '../../../../core/widgets/avatar.dart';

class MemberList extends StatelessWidget {
  const MemberList({super.key, required this.rows});

  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const Divider(height: 20),
      itemBuilder: (context, i) {
        final r = rows[i];
        final profile = (r['profiles'] as Map?)?.cast<String, dynamic>();
        final name =
            (profile?['display_name'] ?? profile?['email'] ?? r['user_id'])
                .toString();
        final avatar = profile?['avatar_url']?.toString();
        return Row(
          children: [
            Avatar(name: name, url: avatar, radius: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(name)),
          ],
        );
      },
    );
  }
}
