// File: lib/providers/pulse_provider.dart (New File)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';

// The path in your Firebase Realtime Database where the ESP32 sends data.
// C Code path: "/pulseData/value"
const String pulseDataPath = 'pulseData/bpm';

// Riverpod StreamProvider to listen to real-time pulse data
// It streams an integer (the heart rate) or null if no data exists.
final realTimePulseProvider = StreamProvider.autoDispose<int?>((ref) {
  // 1. Get a reference to the Realtime Database instance and the specific path
  final databaseRef = FirebaseDatabase.instance.ref(pulseDataPath);

  // 2. Return a stream that listens to value changes (onValue)
  // The stream automatically fetches the data any time the value at the path changes.
  return databaseRef.onValue.map((event) {
    if (event.snapshot.exists) {
      // The ESP32 sends an integer, which Firebase stores as a generic number (num).
      final value = event.snapshot.value;
      if (value is num) {
        return value.toInt(); // Convert the number to an integer
      }
    }
    // Return null if no data exists or if data is not in the expected format
    return null;
  });
});
