import 'package:supabase_flutter/supabase_flutter.dart';

class RouteGuards {
  RouteGuards._();

  static bool get isSignedIn {
    try {
      return Supabase.instance.client.auth.currentSession?.user != null;
    } catch (_) {
      return false;
    }
  }
}
