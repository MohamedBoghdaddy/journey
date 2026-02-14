
import 'package:flutter/material.dart';
import 'package:masr_spaces_app/theme/tokens.dart';

enum CreateHubPick { ask, report, list, offer, foundit, maslahaLens, postInSpace, founditKyc }

class CreateHubSheet extends StatelessWidget {
  final void Function(CreateHubPick pick) onPick;

  const CreateHubSheet({super.key, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _item(context, 'Ask (Question)', Icons.help_outline, () => onPick(CreateHubPick.ask)),
            _item(context, 'Report (Alert / Scam)', Icons.report_gmailerrorred_outlined,
                () => onPick(CreateHubPick.report)),
            _item(context, 'List (Housing / Buy & Sell)', Icons.home_work_outlined,
                () => onPick(CreateHubPick.list)),
            _item(context, 'Offer / Request (Service / Gig)', Icons.handyman_outlined,
                () => onPick(CreateHubPick.offer)),
            _item(context, 'Foundit (Lost & Found)', Icons.search_outlined,
                () => onPick(CreateHubPick.foundit)),
            _item(context, 'Maslaha Lens (Scan document)', Icons.document_scanner_outlined,
                () => onPick(CreateHubPick.maslahaLens)),
            _item(context, 'Post in a Space', Icons.forum_outlined,
                () => onPick(CreateHubPick.postInSpace)),
            _item(context, 'Verification (KYC)', Icons.verified_user_outlined,
                () => onPick(CreateHubPick.founditKyc)),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
