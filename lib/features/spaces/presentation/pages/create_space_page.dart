import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/usecases/create_space.dart';
import '../controllers/spaces_controller.dart';
import '../../domain/usecases/join_space.dart';
import '../../domain/usecases/leave_space.dart';
import '../../domain/usecases/list_spaces.dart';

class CreateSpacePage extends StatefulWidget {
  const CreateSpacePage({super.key});

  @override
  State<CreateSpacePage> createState() => _CreateSpacePageState();
}

class _CreateSpacePageState extends State<CreateSpacePage> {
  late final SpacesController _controller;

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _desc = TextEditingController();

  @override
  void initState() {
    super.initState();
    final deps = DependenciesScope.of(context);
    _controller = SpacesController(
      authRepo: deps.authRepository,
      listSpaces: ListSpaces(deps.spacesRepository),
      createSpace: CreateSpace(deps.spacesRepository),
      joinSpace: JoinSpace(deps.spacesRepository),
      leaveSpace: LeaveSpace(deps.spacesRepository),
      spacesRepo: deps.spacesRepository,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _name.dispose();
    _city.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final created = await _controller.create(
      name: _name.text.trim(),
      city: _city.text.trim().isEmpty ? null : _city.text.trim(),
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
    );

    if (!mounted) return;

    if (created != null) {
      Navigator.of(context).pop(created);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.error ?? 'Failed to create space')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create space')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _name,
                label: 'Name',
                prefixIcon: Icons.apartment_outlined,
                validator: (v) => Validators.requiredField(v ?? '', label: 'Name'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _city,
                label: 'City / Area',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _desc,
                label: 'Description',
                maxLines: 3,
                prefixIcon: Icons.notes_outlined,
              ),
              const SizedBox(height: 18),
              AppButton(
                label: 'Create',
                onPressed: _submit,
                icon: Icons.check,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
