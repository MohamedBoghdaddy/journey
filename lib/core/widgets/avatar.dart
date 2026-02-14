import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    this.url,
    this.radius = 18,
  });

  final String name;
  final String? url;
  final double radius;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    final first = parts.first.isNotEmpty ? parts.first[0] : '?';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: (url != null && url!.trim().isNotEmpty)
          ? NetworkImage(url!)
          : null,
      child: (url == null || url!.trim().isEmpty) ? Text(_initials) : null,
    );
  }
}
