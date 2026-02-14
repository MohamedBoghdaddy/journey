
import 'package:flutter/material.dart';
import 'package:masr_spaces_app/models/content.dart';
import 'package:masr_spaces_app/theme/tokens.dart';
import 'package:masr_spaces_app/ui/components/ai_assist_inline.dart';

class CreateComposerPage extends StatefulWidget {
  final ContentType initialType;
  final String initialNeighborhood;

  const CreateComposerPage({
    super.key,
    required this.initialType,
    required this.initialNeighborhood,
  });

  @override
  State<CreateComposerPage> createState() => _CreateComposerPageState();
}

class _CreateComposerPageState extends State<CreateComposerPage> {
  int _step = 0;

  final _formKey = GlobalKey<FormState>();

  ContentType? _type;
  String? _space;
  String _problem = '';
  String _need = '';
  String? _location;

  bool _blurIds = true;
  bool _hidePhones = true;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  bool get _basicsValid {
    return _space != null &&
        _problem.trim().length >= 12 &&
        _problem.trim().length <= 120 &&
        _need.trim().isNotEmpty &&
        _need.trim().length <= 300;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 0 ? 'Create: Basics' : 'Create: Details'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppTokens.s16),
            children: [
              if (_step == 0) ...[
                _basics(),
                const SizedBox(height: 14),
                AiAssistInline(
                  enabled: _problem.trim().isNotEmpty,
                  onImprove: _improveDraft,
                  onAutoTag: _autoTag,
                  onSafetyScan: _safetyScan,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _basicsValid ? () => setState(() => _step = 1) : null,
                    child: Text(_basicsValid ? 'Continue to Details' : 'Complete required fields'),
                  ),
                ),
              ] else ...[
                _details(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _basicsValid ? _post : null,
                    child: Text(_basicsValid ? 'Post' : 'Complete required fields'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _basics() {
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Basics', style: t.textTheme.titleLarge),
        const SizedBox(height: 12),
        DropdownButtonFormField<ContentType>(
          value: _type,
          items: ContentType.values
              .map((v) => DropdownMenuItem(value: v, child: Text(v.name)))
              .toList(),
          onChanged: (v) => setState(() => _type = v),
          decoration: const InputDecoration(
            hintText: 'Content type',
            helperText: ' ',
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _space,
          items: const ['AskEgypt', 'Scam Radar', 'Rent Watch', 'Jobs', 'Food']
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) => setState(() => _space = v),
          validator: (v) => v == null ? 'Choose a space' : null,
          decoration: const InputDecoration(
            hintText: 'Space (required)',
            helperText: ' ',
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _problem,
          maxLength: 120,
          onChanged: (v) => setState(() => _problem = v),
          validator: (v) {
            final s = (v ?? '').trim();
            if (s.length < 12) return 'Min 12 characters';
            if (s.length > 120) return 'Max 120 characters';
            return null;
          },
          decoration: const InputDecoration(
            hintText: 'Problem (required)',
            helperText: 'One sentence summary.',
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _need,
          maxLength: 300,
          maxLines: 4,
          onChanged: (v) => setState(() => _need = v),
          validator: (v) {
            final s = (v ?? '').trim();
            if (s.isEmpty) return 'Required';
            if (s.length > 300) return 'Max 300 characters';
            return null;
          },
          decoration: const InputDecoration(
            hintText: 'What I need (required)',
            helperText: ' ',
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _location,
          onChanged: (v) => setState(() => _location = v.trim().isEmpty ? null : v),
          decoration: InputDecoration(
            hintText: 'Location (recommended)',
            helperText: 'Prefill: ${widget.initialNeighborhood}',
          ),
        ),
      ],
    );
  }

  Widget _details() {
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Details', style: t.textTheme.titleLarge),
        const SizedBox(height: 12),
        const ExpansionTile(
          title: Text('Context'),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppTokens.s16, 0, AppTokens.s16, AppTokens.s16),
              child: Text('Add timeline, agreements, background details.'),
            ),
          ],
        ),
        const ExpansionTile(
          title: Text('What I tried'),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppTokens.s16, 0, AppTokens.s16, AppTokens.s16),
              child: Text('Steps you already tried before posting.'),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Evidence & media'),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTokens.s16, 0, AppTokens.s16, AppTokens.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _blurIds,
                    onChanged: (v) => setState(() => _blurIds = v),
                    title: const Text('Blur IDs'),
                    subtitle: const Text('Core utility near attachments'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _hidePhones,
                    onChanged: (v) => setState(() => _hidePhones = v),
                    title: const Text('Hide phone numbers automatically'),
                    subtitle: const Text('Applies to text content'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Add attachment (stub)'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const ExpansionTile(
          title: Text('Tags'),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppTokens.s16, 0, AppTokens.s16, AppTokens.s16),
              child: Text('AI suggestions should be user-approved.'),
            ),
          ],
        ),
      ],
    );
  }

  void _post() {
    _formKey.currentState?.validate();
    if (!_basicsValid) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Posted (prototype).')),
    );
    Navigator.of(context).pop();
  }

  void _improveDraft() {
    if (_problem.trim().isEmpty) return;
    final original = _problem;
    final suggestion = _problem.trim().endsWith('?') ? _problem.trim() : '${_problem.trim()}?';

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.s16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Preview changes', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text('Before', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(original),
              const SizedBox(height: 12),
              Text('After', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(suggestion),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        setState(() => _problem = suggestion);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Undo'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _autoTag() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Auto-tag (stub).')),
    );
  }

  void _safetyScan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Safety scan: hide phones/IDs (stub).')),
    );
  }
}
