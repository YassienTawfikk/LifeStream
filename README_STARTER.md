# LifeStream - Modern Flutter Starter App

A professionally structured, modular, and scalable Flutter starter application following modern UI/UX practices and best coding standards.

## 🎯 Features

### Pages
- ✅ **Splash/Onboarding** - Animated splash screen with Material 3 design
- ✅ **Authentication Flow**
  - Login with email & password validation
  - Signup with form validation
  - Forgot Password with email recovery
- ✅ **Home/Dashboard** - Featured items showcase with navigation shortcuts
- ✅ **List & Detail Pages** - Grid/list views with filter and detail views
- ✅ **Search Page** - Search functionality with categories and recent searches
- ✅ **Profile Page** - Editable user profile with stats
- ✅ **Settings Page** - Theme switching (light/dark/system) and app settings
- ✅ **Notifications Page** - Notification center with type-based styling

### Architecture & State Management
- 🏗️ **Modular Structure** - Clean folder organization for scalability
- 🎛️ **Riverpod** - Modern state management with providers
- 🛣️ **GoRouter** - Clean routing with named routes
- 💾 **Shared Preferences** - Local storage for auth tokens and preferences
- 🔐 **Auth Guard** - Route protection for authenticated pages
- 🌐 **API Service** - Dio-based HTTP client with interceptors

### Design & UI
- 🎨 **Material 3 Design** - Modern Material Design 3 components
- 🌓 **Dark/Light Themes** - Complete theme implementation with transitions
- 📱 **Responsive Layout** - Mobile and tablet optimized
- ✨ **Smooth Animations** - Page transitions and interactive elements
- 🎭 **Reusable Widgets** - Custom buttons, cards, text fields, and more

### Code Quality
- ✅ **Form Validation** - Built-in validation for auth forms
- 📝 **Constants Management** - Centralized colors, text styles, and app constants
- 🗂️ **Models & Serialization** - Type-safe data models with JSON support
- 🛡️ **Error Handling** - Proper error management and user feedback

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Root app widget configuration
│
├── constants/
│   ├── app_colors.dart      # Color palette (light & dark themes)
│   ├── app_text_styles.dart # Typography styles
│   ├── app_constants.dart   # App configuration & constants
│   └── index.dart           # Barrel exports
│
├── models/
│   ├── user.dart            # User model with JSON serialization
│   ├── item.dart            # Item/Content model
│   ├── notification.dart    # Notification model
│   └── index.dart           # Barrel exports
│
├── services/
│   ├── api_service.dart     # Dio HTTP client with interceptors
│   ├── storage_service.dart # SharedPreferences wrapper
│   └── index.dart           # Barrel exports
│
├── providers/
│   ├── auth_provider.dart   # Auth state & logic (Riverpod)
│   ├── theme_provider.dart  # Theme state management
│   ├── api_provider.dart    # API service provider
│   ├── storage_provider.dart # Storage service provider
│   └── index.dart           # Barrel exports
│
├── routes/
│   └── app_router.dart      # GoRouter configuration & routes
│
├── utils/
│   └── app_theme.dart       # Theme data (light & dark)
│
├── widgets/
│   ├── buttons.dart         # PrimaryButton, SecondaryButton, TextButton
│   ├── text_field.dart      # CustomTextField with validation
│   ├── cards.dart           # ItemCard, AppCard, EmptyStateWidget
│   └── index.dart           # Barrel exports
│
└── pages/
    ├── splash/
    │   └── splash_page.dart              # Animated splash screen
    ├── auth/
    │   ├── login_page.dart               # Login form
    │   ├── signup_page.dart              # Signup form
    │   └── forgot_password_page.dart     # Password reset
    ├── home/
    │   └── home_page.dart                # Dashboard/home
    ├── list/
    │   └── list_page.dart                # Items list with filters
    ├── detail/
    │   └── detail_page.dart              # Item detail view
    ├── search/
    │   └── search_page.dart              # Search with categories
    ├── notifications/
    │   └── notifications_page.dart       # Notification center
    ├── profile/
    │   └── profile_page.dart             # User profile
    └── settings/
        └── settings_page.dart            # App settings
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK: ^3.10.1
- Dart: ^3.10.1

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd LifeStream
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Web:**
```bash
flutter build web --release
```

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ipa --release
```

## 📦 Dependencies

```yaml
# State Management
flutter_riverpod: ^2.6.1
riverpod_annotation: ^2.3.1

# Navigation
go_router: ^14.0.0

# Storage
shared_preferences: ^2.2.3

# HTTP
dio: ^5.4.0

# UI
cupertino_icons: ^1.0.8

# Utilities
intl: ^0.19.0
```

## 🎨 Theme & Customization

### Colors
The app uses Material 3 color system. Customize colors in `lib/constants/app_colors.dart`:

```dart
class AppColors {
  // Light Theme
  static const Color lightPrimary = Color(0xFF6366F1);
  static const Color lightSecondary = Color(0xFF48D1CC);
  // ... more colors
  
  // Dark Theme
  static const Color darkPrimary = Color(0xFFB4A7FF);
  // ... more colors
}
```

### Typography
Update text styles in `lib/constants/app_text_styles.dart`:

```dart
static const TextStyle displayLarge = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.w700,
  height: 1.25,
);
```

### Themes
Modify themes in `lib/utils/app_theme.dart`:

```dart
class AppTheme {
  static ThemeData get lightTheme { ... }
  static ThemeData get darkTheme { ... }
}
```

## 🔐 Authentication

The app includes a mock authentication flow. To integrate with a real backend:

1. **Update API Service** (`lib/services/api_service.dart`)
   - Replace mock API calls with real endpoints

2. **Update Auth Provider** (`lib/providers/auth_provider.dart`)
   - Replace mock login/signup with API calls
   - Handle real JWT tokens

3. **Configure Storage**
   - Store actual tokens in secure storage
   - Update auth token headers in API service

Example:
```dart
Future<void> login(String email, String password) async {
  // Call real API
  final response = await ref.read(apiServiceProvider).post(
    '/auth/login',
    data: {'email': email, 'password': password},
  );
  
  // Store token
  final storage = ref.read(storageServiceProvider);
  await storage.setAuthToken(response['token']);
}
```

## 🛣️ Navigation

Routes are defined in `lib/routes/app_router.dart`:

```dart
GoRoute(
  path: '/detail/:id',
  builder: (context, state) {
    final id = state.pathParameters['id'] ?? '';
    return DetailPage(itemId: id);
  },
),
```

**Navigation examples:**
```dart
// Push to a page
context.push('/profile');

// Go to a page (replaces current)
context.go('/home');

// Pop the current page
context.pop();

// Pop with result
context.pop(result);
```

## 🧠 State Management with Riverpod

**Reading state:**
```dart
final authState = ref.watch(authProvider);
```

**Modifying state:**
```dart
await ref.read(authProvider.notifier).logout();
```

**Creating new providers:**
```dart
final itemsProvider = FutureProvider<List<Item>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return await api.get('/items');
});
```

## 📝 Form Validation

Built-in validators in auth pages:

```dart
String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  if (!value.contains('@')) {
    return 'Please enter a valid email';
  }
  return null;
}
```

## 🎯 Best Practices Implemented

✅ **Clean Code**
- Single responsibility principle
- Reusable widgets and functions
- Clear naming conventions

✅ **Modular Architecture**
- Separation of concerns
- Independent feature modules
- Barrel exports for clean imports

✅ **Performance**
- Lazy loading with providers
- Optimized rebuilds with Riverpod
- Efficient state updates

✅ **User Experience**
- Smooth animations
- Responsive design
- Clear error messages
- Loading states

✅ **Maintainability**
- Centralized constants
- Type-safe models
- Documented code

## 🔧 Customization Guide

### Add a New Page

1. Create page file: `lib/pages/my_feature/my_feature_page.dart`
2. Add route in `lib/routes/app_router.dart`:
   ```dart
   GoRoute(
     path: '/my-feature',
     builder: (context, state) => const MyFeaturePage(),
   ),
   ```
3. Navigate to it:
   ```dart
   context.push('/my-feature');
   ```

### Add a New Provider

1. Create provider file: `lib/providers/my_provider.dart`
2. Define provider:
   ```dart
   final myProvider = StateNotifierProvider<MyNotifier, MyState>(
     (ref) => MyNotifier(ref),
   );
   ```
3. Use it:
   ```dart
   ref.watch(myProvider);
   ```

### Customize API Calls

1. Update base URL in `lib/constants/app_constants.dart`:
   ```dart
   static const String baseUrl = 'https://your-api.com';
   ```

2. Add API methods in services

3. Create providers for API calls

## 📚 Resources

- [Flutter Documentation](https://flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Material 3 Design](https://m3.material.io)

## 🤝 Contributing

1. Follow the established code structure
2. Keep components modular and reusable
3. Add documentation for new features
4. Test all changes before committing

## 📄 License

This project is open source and available under the MIT License.

## 🎉 Ready to Extend!

This starter app is production-ready and designed to be easily extended. Start by:

1. Updating the API service with your backend endpoints
2. Customizing colors and branding
3. Adding your business logic and features
4. Deploying to your target platforms

**Happy coding! 🚀**
