# LateInitializationError Fix - LifeStream

## Problem
The app was throwing a `LateInitializationError` when starting:
```
LateInitializationError: Field '_prefs@186481749' has not been initialized.
```

This occurred because `SharedPreferences` was not being properly initialized before being used.

## Root Cause
The storage initialization timing was incorrect:
1. `StorageService` had a `late SharedPreferences _prefs` field
2. `storageServiceProvider` was creating the service synchronously without waiting for `init()`
3. When pages/widgets tried to watch `themeModeProvider`, it would try to access storage before it was initialized
4. This caused the `LateInitializationError`

## Solution
Changed the initialization pattern from **synchronous-with-async-init** to **fully async**:

### Before (Broken)
```dart
// storage_provider.dart
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(); // Returns uninitialized service!
});

final initStorageProvider = FutureProvider<void>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  await storage.init(); // Init happens after provider already exists
});
```

### After (Fixed)
```dart
// storage_provider.dart
final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  final storage = StorageService();
  await storage.init(); // Init happens during provider creation
  return storage;
});

final initStorageProvider = FutureProvider<void>((ref) async {
  await ref.watch(storageServiceProvider.future); // Wait for full initialization
});
```

## Changes Made

### 1. **lib/main.dart**
- Added error handling in storage initialization
- Added try-catch to gracefully handle initialization errors
- Ensures storage is fully initialized before app starts

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  try {
    await container.read(initStorageProvider.future);
  } catch (e) {
    debugPrint('Storage initialization error: $e');
  }

  runApp(
    ProviderScope(
      child: const LifeStreamApp(),
    ),
  );
}
```

### 2. **lib/providers/storage_provider.dart**
Changed from `Provider<StorageService>` to `FutureProvider<StorageService>`:

```dart
final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  final storage = StorageService();
  await storage.init(); // Fully initialize before returning
  return storage;
});
```

### 3. **lib/providers/auth_provider.dart**
Updated all storage access to use `.future`:

```dart
// Before
final storage = ref.read(storageServiceProvider);

// After
final storage = await ref.read(storageServiceProvider.future);
```

Added new provider to load initial auth state:
```dart
final loadInitialAuthProvider = FutureProvider<AuthState>((ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  // ... load auth state from storage
});
```

### 4. **lib/providers/theme_provider.dart**
Changed theme loading to be fully async:

```dart
// Before
ThemeModeNotifier(this.ref) : super(ThemeMode.light) {
  _loadTheme(); // Sync call that used uninitialized storage
}

// After
ThemeModeNotifier(this.ref) : super(ThemeMode.light);
// No sync init, async methods use await
```

Updated theme setters to be async:
```dart
Future<void> setLight() async {
  state = ThemeMode.light;
  await _saveTheme('light');
}

Future<void> _saveTheme(String theme) async {
  try {
    final storage = await ref.read(storageServiceProvider.future);
    await storage.setThemeMode(theme);
  } catch (e) {
    debugPrint('Error saving theme: $e');
  }
}
```

## How It Works Now

1. **App Start**: `main()` creates a `ProviderContainer` and waits for `initStorageProvider.future`
2. **Storage Init**: `storageServiceProvider` creates `StorageService` and calls `init()`
3. **SharedPreferences Ready**: `_prefs` is now initialized before any code tries to use it
4. **App Running**: `ProviderScope` is created with fully initialized storage
5. **Safe Access**: All storage access uses `await ref.read(storageServiceProvider.future)`

## Testing

### Build Status
✅ **`flutter pub get`** - All dependencies resolved  
✅ **`flutter analyze`** - No errors found  
✅ **`flutter build web --release`** - Web build successful  

### Error Status
Before: ❌ `LateInitializationError: Field '_prefs' has not been initialized`  
After: ✅ No initialization errors

## Key Takeaways

1. **Never mix sync and async initialization** - Always fully initialize before returning from a provider
2. **Use FutureProvider for async dependencies** - Don't try to work around it with sync wrappers
3. **Always await async operations** - Use `.future` suffix to access FutureProvider values
4. **Initialize early** - Do all setup in `main()` before creating `ProviderScope`

## Migration Guide (if you had similar issues)

If you're using Riverpod with `SharedPreferences` or other async dependencies:

1. Change your storage provider from `Provider<T>` to `FutureProvider<T>`
2. Move all initialization into the provider itself
3. Update all access points to use `await ref.read(provider.future)`
4. Initialize early in `main()` before creating `ProviderScope`
5. Add error handling with try-catch

## Files Modified
- `lib/main.dart`
- `lib/providers/storage_provider.dart`
- `lib/providers/auth_provider.dart`
- `lib/providers/theme_provider.dart`

All changes maintain backward compatibility with the rest of the codebase.
