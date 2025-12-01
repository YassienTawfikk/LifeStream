# LifeStream - Quick Reference Guide

## 🚀 Quick Start Commands

```bash
# Get dependencies
flutter pub get

# Run development build
flutter run

# Run on a specific device
flutter run -d <device-id>

# Analyze code
flutter analyze

# Format code
dart format lib/

# Build for web
flutter build web --release

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ipa --release
```

## 🎨 Theming Quick Reference

### Change Primary Color
Edit `lib/constants/app_colors.dart`:
```dart
static const Color lightPrimary = Color(0xFF6366F1); // Change this
```

### Change App Name
Edit `lib/constants/app_constants.dart`:
```dart
static const String appName = 'LifeStream'; // Change to your app name
```

### Change App Version
Update `pubspec.yaml`:
```yaml
version: 1.0.0+1 # Update version here
```

## 📱 Common Navigation Patterns

### Navigate to a page
```dart
context.push('/home');
```

### Navigate with parameters
```dart
context.push('/detail/$itemId');
```

### Navigate and replace current page
```dart
context.go('/home');
```

### Pop to previous page
```dart
context.pop();
```

### Navigate with result
```dart
final result = await context.push<String>('/dialog');
```

## 🧠 State Management Quick Patterns

### Watch a provider (read-only)
```dart
final user = ref.watch(authProvider).user;
```

### Modify state
```dart
ref.read(authProvider.notifier).logout();
```

### Update provider value
```dart
state = state.copyWith(newValue: value);
```

### Create a computed provider
```dart
final userNameProvider = Provider((ref) {
  final user = ref.watch(authProvider).user;
  return user?.name ?? 'Guest';
});
```

## 🎯 Form Validation Examples

### Email validation
```dart
String? _validateEmail(String? value) {
  if (value?.isEmpty ?? true) return 'Email is required';
  if (!value!.contains('@')) return 'Invalid email format';
  return null;
}
```

### Password validation
```dart
String? _validatePassword(String? value) {
  if (value?.isEmpty ?? true) return 'Password is required';
  if (value!.length < 8) return 'Min 8 characters';
  return null;
}
```

## 🛠️ API Integration Quick Setup

### 1. Create API endpoint constants
```dart
class ApiEndpoints {
  static const String users = '/users';
  static const String items = '/items';
  static const String notifications = '/notifications';
}
```

### 2. Create a provider for API calls
```dart
final itemsProvider = FutureProvider<List<Item>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get(ApiEndpoints.items);
  return (response as List).map((item) => Item.fromJson(item)).toList();
});
```

### 3. Use in UI
```dart
final asyncItems = ref.watch(itemsProvider);
asyncItems.when(
  data: (items) => ListView.builder(itemCount: items.length, ...),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

## 🔐 Auth Integration Quick Setup

### 1. Update login method
```dart
Future<void> login(String email, String password) async {
  try {
    final response = await ref.read(apiServiceProvider).post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    
    // Store token
    final storage = ref.read(storageServiceProvider);
    await storage.setAuthToken(response['token']);
    
    // Update state
    state = AuthState(isAuthenticated: true, user: User.fromJson(response['user']));
  } catch (e) {
    state = AuthState(isAuthenticated: false, error: e.toString());
  }
}
```

### 2. Add auth headers to API calls
```dart
void setAuthToken(String token) {
  _dio.options.headers['Authorization'] = 'Bearer $token';
}
```

### 3. Load auth state on app startup
```dart
void _loadAuthState() {
  final storage = ref.read(storageServiceProvider);
  if (storage.getIsAuthenticated()) {
    // Load user data
  }
}
```

## 📝 Adding a New Feature Page

### Step 1: Create the page file
```dart
// lib/pages/my_feature/my_feature_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyFeaturePage extends ConsumerWidget {
  const MyFeaturePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Feature')),
      body: Center(child: const Text('Hello!')),
    );
  }
}
```

### Step 2: Add route
```dart
// In lib/routes/app_router.dart
GoRoute(
  path: '/my-feature',
  builder: (context, state) => const MyFeaturePage(),
),
```

### Step 3: Navigate to it
```dart
context.push('/my-feature');
```

## 🎨 Using Reusable Widgets

### PrimaryButton
```dart
PrimaryButton(
  label: 'Click Me',
  onPressed: () {},
  isLoading: false,
  icon: Icons.check,
)
```

### CustomTextField
```dart
CustomTextField(
  label: 'Email',
  hint: 'Enter your email',
  controller: emailController,
  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
  prefixIcon: Icons.email,
)
```

### ItemCard
```dart
ItemCard(
  title: 'Item Title',
  description: 'Item description',
  imageUrl: 'https://...',
  rating: 4.5,
  onTap: () {},
)
```

### AppCard
```dart
AppCard(
  child: Text('Custom content'),
  onTap: () {},
  backgroundColor: Colors.blue,
)
```

## 🔄 Refresh/Reload Patterns

### Refresh a provider
```dart
ref.refresh(myProvider);
```

### Invalidate a provider
```dart
ref.invalidate(myProvider);
```

### Listen to provider changes
```dart
ref.listen(authProvider, (previous, next) {
  if (next.isAuthenticated) {
    context.go('/home');
  }
});
```

## 🎯 Common UI Patterns

### Loading State
```dart
if (isLoading) {
  return CircularProgressIndicator();
}
```

### Empty State
```dart
EmptyStateWidget(
  icon: Icons.inbox,
  title: 'No Items',
  description: 'Try adding some items',
  onRetry: () => setState(() {}),
)
```

### Error Handling
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Error: $error'),
    backgroundColor: Colors.red,
  ),
);
```

### Alert Dialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Confirm'),
    content: const Text('Are you sure?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Yes')),
    ],
  ),
);
```

## 🌓 Theme Switching

### Get current theme
```dart
final themeMode = ref.watch(themeModeProvider);
```

### Switch theme
```dart
// Light
ref.read(themeModeProvider.notifier).setLight();

// Dark
ref.read(themeModeProvider.notifier).setDark();

// System
ref.read(themeModeProvider.notifier).setSystem();
```

## 💾 Local Storage Quick Reference

### Save data
```dart
final storage = ref.read(storageServiceProvider);
await storage.setAuthToken('token');
await storage.setUserData(jsonEncode(user));
```

### Read data
```dart
final token = storage.getAuthToken();
final userData = storage.getUserData();
```

### Clear data
```dart
await storage.logout(); // Clears all
await storage.clearAuthToken();
```

## 🐛 Debugging Tips

### Print provider state
```dart
print('Auth state: ${ref.read(authProvider)}');
```

### Check navigation
Enable router logging in GoRouter
```dart
debugLogDiagnostics: true,
```

### Analyze performance
```bash
flutter run --profile
```

### Check code issues
```bash
flutter analyze
```

## 📊 Useful Tools

- **DevTools**: `flutter pub global activate devtools` then `devtools`
- **Profiler**: `flutter run --profile`
- **Analyzer**: `flutter analyze`
- **Formatter**: `dart format lib/`

## 🎓 Tips & Best Practices

1. **Always use const** for widgets that don't change
2. **Use providers** instead of setState when possible
3. **Extract widgets** to keep files under 300 lines
4. **Use named routes** for better code organization
5. **Handle errors** gracefully with user feedback
6. **Test on multiple devices** before release
7. **Keep API calls** in services/providers
8. **Use barrel exports** (index.dart) for clean imports
9. **Validate forms** before submission
10. **Show loading states** for async operations

## 🆘 Troubleshooting

**Build errors?**
```bash
flutter clean && flutter pub get
```

**Analyzer errors?**
```bash
dart fix --apply
```

**Hot reload issues?**
- Use hot restart: `shift+c` (or `r` in terminal)
- Or rebuild: `flutter clean && flutter run`

**State not updating?**
- Check if using `ref.watch()` instead of `ref.read()`
- Verify provider is being invalidated/refreshed

**Navigation not working?**
- Check route paths match exactly
- Verify GoRouter is properly initialized
- Check route guards/redirects

---

**Need more help?** Check the full README_STARTER.md or Flutter documentation!
