import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_stream/models/user.dart';
import 'package:life_stream/providers/storage_provider.dart';
import 'dart:convert';

// Auth State
class AuthState {
  final bool isAuthenticated;
  final User? user;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState());

  Future<void> login(String email, String password) async {
    try {
      // Mock login - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 1500));

      final user = User(
        id: '1',
        name: 'John Doe',
        email: email,
        createdAt: DateTime.now(),
      );

      final storage = await ref.read(storageServiceProvider.future);
      await storage.setIsAuthenticated(true);
      await storage.setAuthToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await storage.setUserData(jsonEncode(user.toJson()));

      state = AuthState(isAuthenticated: true, user: user);
    } catch (e) {
      state = AuthState(isAuthenticated: false, error: e.toString());
    }
  }

  Future<void> signup(String name, String email, String password) async {
    try {
      // Mock signup - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 1500));

      final user = User(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      final storage = await ref.read(storageServiceProvider.future);
      await storage.setIsAuthenticated(true);
      await storage.setAuthToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await storage.setUserData(jsonEncode(user.toJson()));

      state = AuthState(isAuthenticated: true, user: user);
    } catch (e) {
      state = AuthState(isAuthenticated: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    final storage = await ref.read(storageServiceProvider.future);
    await storage.logout();
    state = AuthState(isAuthenticated: false);
  }

  Future<void> updateProfile(String name, String? bio) async {
    try {
      if (state.user == null) throw Exception('User not found');

      final updatedUser = state.user!.copyWith(name: name, bio: bio);
      final storage = await ref.read(storageServiceProvider.future);
      await storage.setUserData(jsonEncode(updatedUser.toJson()));

      state = AuthState(isAuthenticated: true, user: updatedUser);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Load initial auth state from storage
final loadInitialAuthProvider = FutureProvider<AuthState>((ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  final isAuth = storage.getIsAuthenticated();
  final userData = storage.getUserData();

  if (isAuth && userData != null) {
    try {
      final userJson = jsonDecode(userData) as Map<String, dynamic>;
      return AuthState(
        isAuthenticated: true,
        user: User.fromJson(userJson),
      );
    } catch (e) {
      return AuthState(isAuthenticated: false, error: e.toString());
    }
  }
  return AuthState(isAuthenticated: false);
});

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
