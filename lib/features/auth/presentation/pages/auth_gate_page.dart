import 'package:flutter/material.dart';

import '../../../../bootstrap/dependencies.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/widgets/loading.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  void _redirect() {
    final deps = DependenciesScope.of(context);
    final isSignedIn = deps.authRepository.currentUser != null;

    Navigator.of(context).pushReplacementNamed(
      isSignedIn ? Routes.app : Routes.onboarding,
    );
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoadingView(message: 'Preparing...'));
  }
}
