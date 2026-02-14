import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../services/supabase_client.dart';

/// Handles authentication-related HTTP requests.
///
/// Routes:
/// - POST /register  {email, password, name}
/// - POST /login     {email, password}
/// - POST /logout
class AuthHandler {
  Router get router {
    final r = Router();

    // Register a new user (default role=user, reputation=0 in user_metadata)
    r.post('/register', (Request request) async {
      try {
        final body = await request.readAsString();
        final data = (jsonDecode(body) as Map).cast<String, dynamic>();

        final email = data['email'] as String?;
        final password = data['password'] as String?;
        final name = data['name'] as String?;

        if (email == null || password == null || name == null) {
          return _json(400, {'error': 'Missing fields'});
        }

        final client = SupabaseService.client;

        // Stores in user_metadata; frontend can read role/reputation
        final res = await client.auth.signUp(
          email: email,
          password: password,
          data: {
            'name': name,
            'role': 'user',
            'reputation': 0,
          },
        );

        // Some setups may not create a session immediately (email confirmation)
        // so we treat "user exists" as success too if available.
        final ok = res.session != null || res.user != null;
        if (!ok) {
          return _json(400, {'error': 'Registration failed'});
        }

        return _json(200, {
          'message': 'Registration successful',
          'needs_email_confirmation': res.session == null,
        });
      } catch (e) {
        return _json(
            400, {'error': 'Invalid JSON or request', 'details': e.toString()});
      }
    });

    // Login
    r.post('/login', (Request request) async {
      try {
        final body = await request.readAsString();
        final data = (jsonDecode(body) as Map).cast<String, dynamic>();

        final email = data['email'] as String?;
        final password = data['password'] as String?;

        if (email == null || password == null) {
          return _json(400, {'error': 'Missing email or password'});
        }

        final client = SupabaseService.client;
        final res = await client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        final session = res.session;
        if (session == null) {
          return _json(401, {'error': 'Invalid credentials'});
        }

        return _json(200, {
          'access_token': session.accessToken,
          'refresh_token': session.refreshToken,
          'expires_in': session.expiresIn,
          'token_type': 'bearer',
          'user_id': session.user.id,
        });
      } catch (e) {
        return _json(
            400, {'error': 'Invalid JSON or request', 'details': e.toString()});
      }
    });

    // Logout
    r.post('/logout', (Request request) async {
      try {
        await SupabaseService.client.auth.signOut();
        return _json(200, {'message': 'Logged out'});
      } catch (e) {
        return _json(500, {'error': 'Logout failed', 'details': e.toString()});
      }
    });

    return r;
  }

  Response _json(int status, Map<String, dynamic> body) {
    return Response(
      status,
      body: jsonEncode(body),
      headers: const {'Content-Type': 'application/json'},
    );
  }
}
