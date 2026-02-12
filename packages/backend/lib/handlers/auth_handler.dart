import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/supabase_client.dart';

/// Handles authentication-related HTTP requests.
class AuthHandler {
  Router get router {
    final router = Router();

    // User registration
    router.post('/register', (Request request) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final email = data['email'] as String?;
      final password = data['password'] as String?;
      final name = data['name'] as String?;
      if (email == null || password == null || name == null) {
        return Response(400, body: jsonEncode({'error': 'Missing fields'}));
      }
      final client = SupabaseService.client;
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (response.session == null) {
        return Response(400, body: jsonEncode({'error': 'Registration failed'}));
      }
      return Response.ok(jsonEncode({'message': 'Registration successful'}), headers: {'Content-Type': 'application/json'});
    });

    // User login
    router.post('/login', (Request request) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final email = data['email'] as String?;
      final password = data['password'] as String?;
      if (email == null || password == null) {
        return Response(400, body: jsonEncode({'error': 'Missing email or password'}));
      }
      final client = SupabaseService.client;
      final response = await client.auth.signInWithPassword(email: email, password: password);
      final session = response.session;
      if (session == null) {
        return Response(401, body: jsonEncode({'error': 'Invalid credentials'}));
      }
      return Response.ok(jsonEncode({'access_token': session.accessToken}), headers: {'Content-Type': 'application/json'});
    });

    // User logout
    router.post('/logout', (Request request) async {
      final client = SupabaseService.client;
      await client.auth.signOut();
      return Response.ok(jsonEncode({'message': 'Logged out'}), headers: {'Content-Type': 'application/json'});
    });

    return router;
  }
}