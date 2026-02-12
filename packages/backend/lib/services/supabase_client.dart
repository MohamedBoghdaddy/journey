import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:supabase/supabase.dart';

/// A helper to create a Supabase client using environment variables.
class SupabaseService {
  SupabaseService._();
  static final SupabaseClient _client = SupabaseClient(
    dotenv.env['SUPABASE_URL'] ?? 'your-supabase-url',
    dotenv.env['SUPABASE_SERVICE_KEY'] ?? 'your-service-role-key',
  );

  static SupabaseClient get client => _client;
}