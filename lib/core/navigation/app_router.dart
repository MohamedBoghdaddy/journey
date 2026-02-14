import 'package:flutter/material.dart';

import '../config/routes.dart';
import 'route_guards.dart';

// Existing UI pages
import '../../ui/onboarding/welcome_onboarding_page.dart';
import '../../ui/maslaha/maslaha_lens_page.dart';
import '../../ui/foundit/kyc_modal.dart';
import '../../ui/shell/main_shell.dart';

// Spaces
import '../../features/spaces/presentation/pages/space_details_page.dart';

// Auth
import '../../features/auth/presentation/pages/login_page.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? (Routes.root ?? Routes.app);
    final signedIn = RouteGuards.isSignedIn;

    // Guard: app routes require sign-in
    if (name.startsWith('/app') && !signedIn) {
      return MaterialPageRoute(
        settings: RouteSettings(name: Routes.authSignIn),
        builder: (_) => LoginPage(redirectTo: name),
      );
    }

    // ✅ Space details: /app/spaces/<id>
    // Must come BEFORE the switch so it doesn't get treated as "unknown"
    if (name.startsWith('/app/spaces/') && name != Routes.appSpaces) {
      final id = name.split('/').last;
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => SpaceDetailsPage(spaceId: id),
      );
    }

    switch (name) {
      // Entry
      case Routes.root:
      case Routes.onboarding:
        return MaterialPageRoute(builder: (_) => const WelcomeOnboardingPage());

      // Auth
      case Routes.authSignIn:
        // If you want redirectTo via args:
        final redirectTo = (settings.arguments is Map)
            ? (settings.arguments as Map)['redirectTo'] as String?
            : null;
        return MaterialPageRoute(
          builder: (_) => LoginPage(redirectTo: redirectTo),
        );

      case Routes.authSignUp:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderPage(title: 'Sign up'),
        );

      // App root + tabs
      case Routes.app:
      case Routes.appFeed:
        return MaterialPageRoute(
            builder: (_) => const MainShell(initialIndex: 0));

      case Routes.appSpaces:
        return MaterialPageRoute(
            builder: (_) => const MainShell(initialIndex: 1));

      case Routes.appMarket:
        return MaterialPageRoute(
            builder: (_) => const MainShell(initialIndex: 2));

      case Routes.appChat:
        return MaterialPageRoute(
            builder: (_) => const MainShell(initialIndex: 3));

      case Routes.appMe:
        return MaterialPageRoute(
            builder: (_) => const MainShell(initialIndex: 4));

      // FAB / flows
      case Routes.appCreatePost:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderPage(title: 'Create Post'),
        );

      case Routes.appCreateListing:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderPage(title: 'Create Listing'),
        );

      case Routes.appNewDm:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderPage(title: 'New Message'),
        );

      case Routes.appEditProfile:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderPage(title: 'Edit Profile'),
        );

      // Drawer destinations
      case Routes.appExplore:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderPage(title: 'Explore'),
        );

      case Routes.appMyOrders:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderPage(title: 'My Orders'),
        );

      // Other
      case Routes.maslaha:
        return MaterialPageRoute(builder: (_) => const MaslahaLensPage());

      case Routes.founditKyc:
        return MaterialPageRoute(builder: (_) => const FounditKycModal());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title (TODO)')),
    );
  }
}
