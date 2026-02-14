// lib/app.dart
import 'package:flutter/material.dart';

import 'bootstrap/dependencies.dart';
import 'core/config/routes.dart';
import 'core/navigation/app_router.dart';
import 'theme/app_theme.dart';

/// Masr Spaces root app.
/// - Injects app-level dependencies via [DependenciesScope]
/// - Configures theming (light/dark/system)
/// - Uses a central router (onGenerateRoute) + initialRoute
class MasrSpacesApp extends StatelessWidget {
  final AppDependencies dependencies;

  const MasrSpacesApp({
    super.key,
    required this.dependencies,
  });

  @override
  Widget build(BuildContext context) {
    return DependenciesScope(
      deps: dependencies,
      child: MaterialApp(
        title: 'Masr Spaces',
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,

        // Navigation
        initialRoute: Routes.root,
        onGenerateRoute: AppRouter.onGenerateRoute,

        // Optional: put global wrappers here later (toasts, global loaders, etc.)
        builder: (context, child) {
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}
