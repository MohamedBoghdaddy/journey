import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';

/// Entry point for the Masr Spaces application.
///
/// The app uses a [MaterialApp] with a simple theme and routes to the
/// different screens. Authentication logic is encapsulated in
/// [LoginPage]. Once authenticated, the user is redirected to [HomePage].
void main() {
  runApp(const MasrSpacesApp());
}

/// Top-level widget for the Masr Spaces mobile app.
class MasrSpacesApp extends StatelessWidget {
  const MasrSpacesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masr Spaces',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}