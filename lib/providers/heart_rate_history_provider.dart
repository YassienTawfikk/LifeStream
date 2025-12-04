// File: lib/providers/heart_rate_history_provider.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_stream/providers/pulse_provider.dart';

// StateNotifier to manage the list of chart data points
class HeartRateHistoryNotifier extends StateNotifier<List<FlSpot>> {
  HeartRateHistoryNotifier(this.ref) : super([]) {
    // Listen to the real-time pulse provider
    ref.listen<AsyncValue<int?>>(realTimePulseProvider, (previous, next) {
      next.whenData((bpm) {
        if (bpm != null && bpm > 0) {
          _addReading(bpm);
        }
      });
    });
  }

  final Ref ref;
  static const int _maxHistoryLength = 30; // Keep last 30 readings
  double _xValue = 0;

  void _addReading(int bpm) {
    final newSpot = FlSpot(_xValue, bpm.toDouble());
    _xValue += 1;

    // Create a new list to trigger state update
    final List<FlSpot> newList = [...state, newSpot];

    // Maintain fixed window size
    if (newList.length > _maxHistoryLength) {
      newList.removeAt(0);
    }

    state = newList;
  }
}

// The provider to be consumed by the UI
final heartRateHistoryProvider =
    StateNotifierProvider<HeartRateHistoryNotifier, List<FlSpot>>((ref) {
      return HeartRateHistoryNotifier(ref);
    });
