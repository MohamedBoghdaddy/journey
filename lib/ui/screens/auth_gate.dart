import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auth_service.dart';
import './home_page.dart';
import './login_page.dart';

/// A minimal gate that:
/// - shows LoginPage if no session
/// - shows HomePage if session exists
///
/// It also warms the user profile cache (role/reputation) via AuthService.

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<AuthState> _authStream =
      Supabase.instance.client.auth.onAuthStateChange;

  @override
  void initState() {
    super.initState();
    AuthService.instance.refreshCachedProfileBestEffort();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authStream,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          return const LoginPage();
        }

        AuthService.instance.refreshCachedProfileBestEffort();
        return const HomePage();
      },
    );
  }
}
