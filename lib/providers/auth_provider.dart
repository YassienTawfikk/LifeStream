import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_stream/models/user.dart';
import 'package:life_stream/providers/storage_provider.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

// Auth State
class AuthState {
  final bool isAuthenticated;
  final User? user;
  final String? error;
  final bool isLoading;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    String? error,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  AuthNotifier(this.ref) : super(AuthState()) {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((firebase_auth.User? firebaseUser) {
      if (firebaseUser != null) {
        final user = _mapFirebaseUser(firebaseUser);
        state = AuthState(isAuthenticated: true, user: user);
        // Optionally sync with local storage if needed, but Firebase persists auth state.
      } else {
        state = AuthState(isAuthenticated: false);
      }
    });
  }

  User _mapFirebaseUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'User', // Fallback if no name
      email: firebaseUser.email ?? '',
      profilePictureUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      // bio is not in Firebase Auth user object, so it will be null unless we fetch from DB
    );
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // State is updated via stream listener
    } on firebase_auth.FirebaseAuthException catch (e) {
      state = state.copyWith(error: e.message ?? 'Login failed');
      rethrow;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload(); // Reload to get updated profile

        // Create user place in Realtime Database with minimal info for search/id
        await _initializeUserInRealtimeDB(name: name, email: email);

        // Force refresh of state since stream might fire before reload
        final updatedFirebaseUser = _auth.currentUser;
        if (updatedFirebaseUser != null) {
          state = AuthState(
            isAuthenticated: true,
            user: _mapFirebaseUser(updatedFirebaseUser),
          );
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      state = state.copyWith(error: e.message ?? 'Signup failed');
      rethrow;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      // Storage cleanup if necessary
      final storage = await ref.read(storageServiceProvider.future);
      await storage.logout();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Re-authenticate
      final cred = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);

      // Update Password
      await user.updatePassword(newPassword);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      final message = e is firebase_auth.FirebaseAuthException
          ? e.message
          : e.toString();
      state = state.copyWith(isLoading: false, error: message);
      rethrow;
    }
  }

  Future<void> updateProfile(String name, String? bio) async {
    try {
      if (_auth.currentUser == null) throw Exception('User not found');

      await _auth.currentUser!.updateDisplayName(name);

      // We update local state/storage.
      // Note: Realtime DB profile sync is removed as requested.
      // Only initial creation logic remains.

      final currentUser = state.user;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(name: name, bio: bio);
        state = AuthState(isAuthenticated: true, user: updatedUser);

        // Also update local storage for mostly cosmetic reasons if app relies on it
        final storage = await ref.read(storageServiceProvider.future);
        await storage.setUserData(jsonEncode(updatedUser.toJson()));
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not found');

      if (!await imageFile.exists()) {
        throw Exception('File does not exist at path: ${imageFile.path}');
      }

      // 1. Read bytes and resize/compress (Simplistic approach)
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 2. Sync to Realtime Database (Restored)
      // This allows friends to download and view the image.
      final dbRef = FirebaseDatabase.instance.ref('users/${user.uid}/profile');
      await dbRef.update({'profilePictureUrl': base64Image});

      // 3. Update Local State
      final currentUser = state.user;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          profilePictureUrl: base64Image,
        );
        state = AuthState(isAuthenticated: true, user: updatedUser);

        final storage = await ref.read(storageServiceProvider.future);
        await storage.setUserData(jsonEncode(updatedUser.toJson()));
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Helper to init user in Realtime DB (for search and friends functionality)
  Future<void> _initializeUserInRealtimeDB({
    required String name,
    required String email,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // We only store essential info for search/friend lookups, dropping bio/images.
    final Map<String, dynamic> updates = {
      'name': name,
      'email': email,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // We keep it under 'profile' because existing search logic expects 'users/{uid}/profile'
    // If we change this path, we must update FriendsProvider.
    final dbRef = FirebaseDatabase.instance.ref('users/${user.uid}/profile');
    await dbRef.update(updates);

    // Also initialize the BPM node to ensuring the "place" (node) exists cleanly
    final bpmRef = FirebaseDatabase.instance.ref('users/${user.uid}/bpm');
    await bpmRef.update({'value': 0, 'timestamp': ServerValue.timestamp});

    // Initialize the Location node
    final locationRef = FirebaseDatabase.instance.ref(
      'users/${user.uid}/location',
    );
    await locationRef.update({
      'latitude': 0.0,
      'longitude': 0.0,
      'timestamp': ServerValue.timestamp,
    });
  }
}

// Load initial auth state
final loadInitialAuthProvider = FutureProvider<AuthState>((ref) async {
  // Firebase Auth handles persistence, so we can just check current user
  // However, since it's async, we might want to check if a user is already signed in
  // synchronously or wait for the first emission.
  // Actually, FirebaseAuth.instance.currentUser is populated if previously signed in
  // (after a brief init).

  // For smooth UX, we might check local storage "isAuthenticated" flag
  // to show a loading screen or optimism, but Firebase is fast.

  // We can rely on the AuthNotifier subscription.
  // But this provider is used to "await" initialization in main.

  // We'll return empty here and let AuthNotifier stream update the state.
  return AuthState(isAuthenticated: false);
});

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
