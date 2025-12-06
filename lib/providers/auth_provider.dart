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

  AuthState({this.isAuthenticated = false, this.user, this.error});

  AuthState copyWith({bool? isAuthenticated, User? user, String? error}) {
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

      // Update display name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload(); // Reload to get updated profile
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

  Future<void> updateProfile(String name, String? bio) async {
    try {
      if (_auth.currentUser == null) throw Exception('User not found');

      await _auth.currentUser!.updateDisplayName(name);

      // Bio handling is tricky without a DB.
      // For now, we update local state/storage or just accept it's not fully persisted in Auth.
      // If we want to persist bio, we need a separate DB like Firestore or Realtime Database.
      // We should ideally sync this with Realtime DB 'users/{uid}/profile' as well.

      // Update Realtime DB profile
      await _updateRealtimeDatabaseProfile(name: name, bio: bio);

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

      // 1. Read bytes and resize/compress (Simplistic approach: strict 100kb limit logic usually needed)
      // For this prototype, we'll read bytes and converting to base64.
      // WARNING: Large strings in Realtime DB can be slow. Ideally strictly resize to 200x200px.
      // We will assume the user picks a reasonable image or we rely on the DB capacity.
      // A better approach in production without storage is a dedicated media server or strict client-side compression.

      final bytes = await imageFile.readAsBytes();
      // Basic check for size to prevent massive payload hanging the app
      if (bytes.lengthInBytes > 500 * 1024) {
        // 500KB limit for prototype safety.
        // In real app, we would use 'flutter_image_compress' package here.
        // throw Exception('Image too large. Please pick an image under 500KB.');
        // We won't throw for now to allow testing, but performance may suffer.
      }

      final base64Image = base64Encode(bytes);

      // 2. Update Realtime DB (This is where the image lives now)
      await _updateRealtimeDatabaseProfile(photoUrl: base64Image);

      // 3. Update Local State
      // Note: We cannot update user.updatePhotoURL() with base64 (limit is ~2k chars).
      // So auth.currentUser.photoURL will remain null or old URL.
      // We rely completely on the 'user' object in state and Realtime DB.

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

  // Helper to sync with Realtime DB (crucial for search and friends)
  Future<void> _updateRealtimeDatabaseProfile({
    String? name,
    String? bio,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Use a transaction or simple update
    // We only update fields that are passed
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (bio != null) updates['bio'] = bio;
    if (photoUrl != null) updates['profilePictureUrl'] = photoUrl;
    // Always ensure email is there
    updates['email'] = user.email;

    final dbRef = FirebaseDatabase.instance.ref('users/${user.uid}/profile');
    await dbRef.update(updates);
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
