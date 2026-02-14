import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/usecases/get_me.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/update_profile.dart';
import '../controllers/auth_controller.dart';
import '../state/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthController _controller;

  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    final deps = DependenciesScope.of(context);
    _controller = AuthController(
      signIn: SignIn(deps.authRepository),
      signUp: SignUp(deps.authRepository),
      signOut: SignOut(deps.authRepository),
      getMe: GetMe(authRepo: deps.authRepository, profileRepo: deps.profileRepository),
      updateProfile: UpdateProfile(deps.profileRepository),
    );
    _controller.addListener(_onStateChanged);
    _controller.bootstrap();
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    final st = _controller.state;

    if (st.status == AuthStatus.authenticated) {
      final target = widget.redirectTo?.startsWith('/app') == true
          ? widget.redirectTo!
          : Routes.appFeed;

      Navigator.of(context).pushNamedAndRemoveUntil(target, (_) => false);
    }

    if (st.status == AuthStatus.error && st.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(st.errorMessage!)));
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _controller.signIn(_email.text.trim(), _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final st = _controller.state;
    final isLoading = st.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _email,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (v) =>
                    Validators.isValidEmail(v ?? '') ? null : 'Enter a valid email',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _password,
                label: 'Password',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: (v) => Validators.minLength(v ?? '', 6, label: 'Password'),
              ),
              const SizedBox(height: 18),
              AppButton(
                label: 'Sign in',
                isLoading: isLoading,
                onPressed: isLoading ? null : _submit,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed(Routes.authSignUp),
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
