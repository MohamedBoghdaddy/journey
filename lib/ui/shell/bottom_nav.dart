import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Feed'),
        NavigationDestination(icon: Icon(Icons.apartment_outlined), label: 'Spaces'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Inbox'),
        NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Market'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Me'),
      ],
    );
  }
}
