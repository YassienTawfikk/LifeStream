import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_stream/providers/storage_provider.dart';
import 'package:life_stream/providers/auth_provider.dart';

// Theme Mode Notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref ref;

  ThemeModeNotifier(this.ref) : super(ThemeMode.system) {
    // Listen to auth changes to switch theme preferences
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && next.user != null) {
        _loadThemeForUser(next.user!.id);
      } else if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        // User logged out, revert to system or global default
        state = ThemeMode.system;
      }
    });
  }

  Future<void> _loadThemeForUser(String userId) async {
    try {
      final storage = await ref.read(storageServiceProvider.future);
      final themeStr = storage.getThemeMode(userId: userId);
      if (themeStr == 'light') {
        state = ThemeMode.light;
      } else if (themeStr == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    } catch (e) {
      debugPrint('Error loading user theme: $e');
    }
  }

  Future<void> setLight() async {
    state = ThemeMode.light;
    await _saveTheme('light');
  }

  Future<void> setDark() async {
    state = ThemeMode.dark;
    await _saveTheme('dark');
  }

  Future<void> setSystem() async {
    state = ThemeMode.system;
    await _saveTheme('system');
  }

  Future<void> _saveTheme(String theme) async {
    try {
      final storage = await ref.read(storageServiceProvider.future);
      final user = ref.read(authProvider).user;

      // Save for current user if logged in
      if (user != null) {
        await storage.setThemeMode(theme, userId: user.id);
      } else {
        // Fallback for unauthenticated state (though mostly we care about auth users)
        await storage.setThemeMode(theme);
      }
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}

// Load initial theme from storage (global/last known)
final loadInitialThemeProvider = FutureProvider<ThemeMode>((ref) async {
  try {
    final storage = await ref.watch(storageServiceProvider.future);
    // On startup, we might not know the user yet, so we load the global default
    // or wait for auth. For simplicity, we start with system/global.
    // If the auth provider restores a session effectively immediately,
    // the listener in the notifier will catch it and reload.
    final themeStr = storage.getThemeMode();
    if (themeStr == 'dark') {
      return ThemeMode.dark;
    } else if (themeStr == 'light') {
      return ThemeMode.light;
    } else if (themeStr == 'system') {
      return ThemeMode.system;
    }
  } catch (e) {
    debugPrint('Error loading theme: $e');
  }
  return ThemeMode.system;
});

// Theme provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ref),
);
