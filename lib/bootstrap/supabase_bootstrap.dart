import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';

class SupabaseBootstrap {
  SupabaseBootstrap._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    final url = Env.supabaseUrl;
    final anon = Env.supabaseAnonKey;

    if (url.isEmpty || anon.isEmpty) {
      if (kDebugMode) {
        debugPrint(
            'SupabaseBootstrap: Missing SUPABASE_URL or SUPABASE_ANON_KEY');
      }
      // Allow the app to run; pages will show a friendly error.
      _initialized = true;
      return;
    }

    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    _initialized = true;
  }
}
