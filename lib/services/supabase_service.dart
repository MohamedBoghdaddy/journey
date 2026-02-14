import 'package:supabase_flutter/supabase_flutter.dart';

/// A singleton wrapper around [SupabaseClient].
///
/// The Supabase URL and anon key are read from compile‑time environment
/// variables.  Provide `--dart-define=SUPABASE_URL=...` and
/// `--dart-define=SUPABASE_ANON_KEY=...` when building or running.
class SupabaseService {
  SupabaseService._();

  static final SupabaseClient _client = SupabaseClient(
    const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://ciwvpccclguyspryyzla.supabase.co',
    ),
    const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNpd3ZwY2NjbGd1eXNwcnl5emxhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA4ODgyOTIsImV4cCI6MjA4NjQ2NDI5Mn0.VOicbyeLGcbsfzNvpI6vXa1QE8gGC_I-Tmp1Ch-FuRk',
    ),
  );

  static SupabaseClient get client => _client;
}
