import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:life_stream/providers/auth_provider.dart';

final heartRateSimulatorProvider = Provider((ref) => HeartRateSimulator(ref));

class HeartRateSimulator {
  final Ref _ref;
  Timer? _timer;
  final Random _random = Random();
  bool _isActive = false;

  HeartRateSimulator(this._ref);

  void startSimulation() {
    if (_isActive) return;
    _isActive = true;
    debugPrint('Heart Rate Simulator Started');

    // Update every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final user = _ref.read(authProvider).user;
      if (user == null) {
        stopSimulation();
        return;
      }

      // Generate random BPM between 65 and 95
      final bpm = 65 + _random.nextInt(30);

      try {
        final path = 'users/${user.id}/bpm';
        await FirebaseDatabase.instance.ref(path).update({
          'value': bpm,
          'timestamp': ServerValue.timestamp,
        });
        // debugPrint('Simulated BPM: $bpm');
      } catch (e) {
        debugPrint('Error simulating BPM: $e');
      }
    });
  }

  void stopSimulation() {
    _timer?.cancel();
    _timer = null;
    _isActive = false;
    debugPrint('Heart Rate Simulator Stopped');
  }
}
