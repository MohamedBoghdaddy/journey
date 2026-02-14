import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Masr Spaces';

  static const Color brandSeed = Color(0xFF0D3B66);

  static const int defaultPageSize = 20;
}

class DbTables {
  DbTables._();

  // Auth / profile
  static const String profiles = 'profiles';

  // Spaces
  static const String spaces = 'spaces';
  static const String spaceMembers = 'space_members';

  // Posts
  static const String posts = 'posts';
  static const String comments = 'comments';
  // "votes" exists in older schema; "reactions" is newer. We support both.
  static const String votes = 'votes';
  static const String reactions = 'reactions';

  // Social
  static const String follows = 'follows';
  static const String savedPosts = 'saved_posts';

  // Chat
  static const String conversations = 'conversations';
  static const String conversationMembers = 'conversation_members';
  static const String messages = 'messages';
  static const String inboxView = 'v_inbox';

  // Marketplace
  static const String products = 'products';
  static const String categories = 'categories';
  static const String orders = 'orders';
  static const String orderItems = 'order_items';
  static const String reviews = 'reviews';

  // Trust
  static const String reports = 'reports';
  static const String blocks = 'blocks';
}
