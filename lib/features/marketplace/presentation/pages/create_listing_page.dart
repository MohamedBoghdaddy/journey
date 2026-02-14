import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/usecases/create_listing.dart';

class CreateListingPage extends StatefulWidget {
  const CreateListingPage({super.key});

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final deps = DependenciesScope.of(context);
    final me = deps.authRepository.currentUser;
    if (me == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final created = await CreateListing(deps.marketRepository)(
        sellerId: me.id,
        title: _title.text.trim(),
        description: _desc.text.trim(),
        price: num.tryParse(_price.text.trim()) ?? 0,
      );
      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to create listing')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create listing')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _title,
                label: 'Title',
                prefixIcon: Icons.title,
                validator: (v) => Validators.requiredField(v ?? '', label: 'Title'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _desc,
                label: 'Description',
                maxLines: 4,
                prefixIcon: Icons.notes_outlined,
                validator: (v) => Validators.minLength(v ?? '', 6, label: 'Description'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _price,
                label: 'Price',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.payments_outlined,
                validator: (v) {
                  final n = num.tryParse((v ?? '').trim());
                  if (n == null || n <= 0) return 'Enter a valid price';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              AppButton(
                label: 'Publish',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _submit,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
