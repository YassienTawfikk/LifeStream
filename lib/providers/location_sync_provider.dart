import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:life_stream/providers/auth_provider.dart';
import 'package:life_stream/providers/location_provider.dart';

final locationSyncProvider = Provider.autoDispose<void>((ref) {
  final user = ref.watch(authProvider).user;
  final locationAsync = ref.watch(locationProvider);

  if (user == null) {
    return; // Don't sync if not authenticated
  }

  // When location updates, write to Firebase
  locationAsync.whenData((position) async {
    try {
      final database = FirebaseDatabase.instance;
      await database.ref('users/${user.id}/location').set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      // Silently fail or log error
    }
  });
});
