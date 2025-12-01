import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_stream/providers/storage_provider.dart';

// Theme Mode Notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref ref;

  ThemeModeNotifier(this.ref) : super(ThemeMode.light);

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
      await storage.setThemeMode(theme);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}

// Load initial theme from storage
final loadInitialThemeProvider = FutureProvider<ThemeMode>((ref) async {
  try {
    final storage = await ref.watch(storageServiceProvider.future);
    final themeStr = storage.getThemeMode();
    if (themeStr == 'dark') {
      return ThemeMode.dark;
    } else if (themeStr == 'system') {
      return ThemeMode.system;
    }
  } catch (e) {
    debugPrint('Error loading theme: $e');
  }
  return ThemeMode.light;
});

// Theme provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ref),
);
