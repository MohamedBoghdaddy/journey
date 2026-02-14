import 'constants.dart';

class AppConfig {
  AppConfig._();

  static const String appName = AppConstants.appName;

  // Toggle features progressively without changing code paths everywhere.
  static const bool enableMarketplace = true;
  static const bool enableChat = true;
  static const bool enableTrust = true;
  static const bool enableSpaces = true;
  static const bool enableSocial = true;
}
