import 'package:supabase_flutter/supabase_flutter.dart';

/// A singleton wrapper around [Supabase] client.
///
/// Replace `your-supabase-url` and `your-anon-key` with the values from your
/// Supabase project. This class exposes the [SupabaseClient] instance for
/// other services to use.
class SupabaseService {
  SupabaseService._();

  static final SupabaseClient _client = SupabaseClient(
    'your-supabase-url',
    'your-anon-key',
  );

  static SupabaseClient get client => _client;
}