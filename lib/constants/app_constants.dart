class AppConstants {
  // App Info
  static const String appName = 'LifeStream';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A modern Flutter starter app';

  // API Configuration
  static const String baseUrl = 'https://api.example.com';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Local Storage Keys
  static const String isAuthenticatedKey = 'is_authenticated';
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String lastSearchKey = 'last_search';

  // Animations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 20;
}
