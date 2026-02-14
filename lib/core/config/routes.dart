/// lib/core/config/routes.dart
class Routes {
  Routes._();

  // Entry
  static const String root = '/';
  static const String onboarding = '/onboarding';

  // Auth
  static const String authSignIn = '/auth/sign-in';
  static const String authSignUp = '/auth/sign-up';

  // Main shell
  static const String app = '/app';

  // Shell tabs (deep links)
  static const String appFeed = '/app/feed';
  static const String appSpaces = '/app/spaces';
  static const String appMarket = '/app/market';
  static const String appChat = '/app/chat';
  static const String appMe = '/app/me';

  // FAB / flows
  static const String appCreatePost = '/app/posts/create';
  static const String appCreateListing = '/app/market/create';
  static const String appNewDm = '/app/chat/new-dm';
  static const String appEditProfile = '/app/me/edit';

  // Drawer destinations
  static const String appExplore = '/app/explore';
  static const String appMyOrders = '/app/my-orders';

  // Other
  static const String maslaha = '/maslaha';
  static const String founditKyc = '/foundit_kyc';

   // Spaces
  static String appSpaceDetails(String id) => '/app/spaces/$id';

  // Create post inside a space
  static String appCreateSpacePost(String spaceId) =>
      '/app/spaces/$spaceId/posts/new';

  // Space post details
  static String appSpacePostDetails(String spaceId, String postId) =>
      '/app/spaces/$spaceId/posts/$postId';

  // Chat conversation
  static String appChatConversation(String conversationId) =>
      '/app/chat/$conversationId';


// User profile details
  static String appUserProfile(String userId) => '/app/users/$userId';

// Marketplace product details
  static String appProductDetails(String productId) => '/app/market/$productId';

// Marketplace product details
  static String appPostDetails(String postId) => '/app/pages/$postId';


}
