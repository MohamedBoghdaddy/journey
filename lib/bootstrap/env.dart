// lib/bootstrap/env.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static bool _attemptedLoad = false;
  static bool _dotenvReady = false;

  /// Load .env best-effort (works only if .env is bundled as an asset).
  /// Never throws.
  static Future<void> load({String fileName = '.env'}) async {
    if (_attemptedLoad) return;
    _attemptedLoad = true;

    try {
      await dotenv.load(fileName: fileName);
      _dotenvReady = true;
    } catch (e) {
      // On Flutter Web and/or when .env isn't added to pubspec assets,
      // dotenv.load will throw. We treat it as "not available".
      _dotenvReady = false;
      if (kDebugMode) {
        debugPrint('[Env] dotenv load skipped/failed: $e');
      }
    }
  }

  /// Prefer --dart-define first (works on all platforms), fallback to dotenv.
  static String _get(String key) {
    final fromDefine = const String.fromEnvironment('');
    // The above line can't be dynamic; use a switch instead:
    switch (key) {
      case 'SUPABASE_URL':
        final v = const String.fromEnvironment('SUPABASE_URL');
        if (v.isNotEmpty) return v;
        break;
      case 'SUPABASE_ANON_KEY':
        final v = const String.fromEnvironment('SUPABASE_ANON_KEY');
        if (v.isNotEmpty) return v;
        break;
    }

    if (_dotenvReady) {
      // IMPORTANT: never use dotenv.env directly; it throws when not initialized.
      return dotenv.get(key, fallback: '');
    }
    return '';
  }

  static String get supabaseUrl => _get('SUPABASE_URL');
  static String get supabaseAnonKey => _get('SUPABASE_ANON_KEY');

  static bool get hasValidSupabaseConfig =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
}
