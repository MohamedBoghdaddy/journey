// lib/main.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'bootstrap/dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---- Global error handling ----
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
    if (details.stack != null) debugPrint(details.stack.toString());
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Uncaught platform error: $error');
    debugPrint(stack.toString());
    return true;
  };

  runZonedGuarded(() async {
    // 1) Load .env (optional)
    await _safeLoadEnv();

    // 2) Validate env config
    final config = _readAndValidateSupabaseConfig();
    if (!config.isValid) {
      runApp(ConfigErrorApp(message: config.errorMessage));
      return;
    }

    // 3) Init Supabase (must happen BEFORE AppDependencies.create())
    try {
      await Supabase.initialize(
        url: config.url!,
        anonKey: config.anonKey!,
        debug: kDebugMode,
      );
    } catch (e, st) {
      debugPrint('Supabase.initialize failed: $e');
      debugPrint(st.toString());
      runApp(
        ConfigErrorApp(
          message: 'Failed to initialize Supabase.\n\nError: $e\n\n'
              'Check your internet connection and Supabase credentials.',
        ),
      );
      return;
    }

    // 4) Build app dependencies (your project’s correct factory)
    final deps = await AppDependencies.create();

    // 5) Run app (your app.dart requires dependencies)
    runApp(MasrSpacesApp(dependencies: deps));
  }, (error, stack) {
    debugPrint('runZonedGuarded error: $error');
    debugPrint(stack.toString());
  });
}

Future<void> _safeLoadEnv() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('No .env file found, continuing...');
  }
}

/// ---------------- CONFIG VALIDATION ----------------

class _SupabaseConfig {
  final String? url;
  final String? anonKey;
  final bool isValid;
  final String errorMessage;

  const _SupabaseConfig({
    required this.url,
    required this.anonKey,
    required this.isValid,
    required this.errorMessage,
  });
}

_SupabaseConfig _readAndValidateSupabaseConfig() {
  // You can optionally keep a fallback URL, but I recommend forcing .env for safety
  final url = (dotenv.env['SUPABASE_URL'] ?? '').trim();
  final anon = (dotenv.env['SUPABASE_ANON_KEY'] ?? '').trim();

  final urlMissing = url.isEmpty || !url.startsWith('https://');
  final anonMissing = anon.isEmpty || anon.startsWith('YOUR_');

  if (urlMissing || anonMissing) {
    return _SupabaseConfig(
      url: null,
      anonKey: null,
      isValid: false,
      errorMessage: _buildConfigErrorMessage(urlMissing, anonMissing),
    );
  }

  return _SupabaseConfig(
    url: url,
    anonKey: anon,
    isValid: true,
    errorMessage: '',
  );
}

String _buildConfigErrorMessage(bool urlMissing, bool anonMissing) {
  final buffer = StringBuffer();

  buffer.writeln('⚙️ Configuration Required\n');

  if (urlMissing) {
    buffer.writeln('❌ SUPABASE_URL is missing or invalid');
    buffer.writeln('   Expected: https://your-project.supabase.co\n');
  }
  if (anonMissing) {
    buffer.writeln('❌ SUPABASE_ANON_KEY is missing or placeholder\n');
  }

  buffer.writeln('✅ Add these to your .env file:\n');
  buffer.writeln('SUPABASE_URL=https://your-project.supabase.co');
  buffer.writeln('SUPABASE_ANON_KEY=your-anon-key-here\n');
  buffer.writeln('Supabase Dashboard → Settings → API');

  return buffer.toString();
}

/// Minimal config error screen (safe startup).
class ConfigErrorApp extends StatelessWidget {
  final String message;

  const ConfigErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0D3B66),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF0D3B66),
      ),
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Icon(
                  Icons.settings_applications,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Masr Spaces can’t start',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .error
                        .withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .error
                          .withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(message, style: const TextStyle(height: 1.4)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
