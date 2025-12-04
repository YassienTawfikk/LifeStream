// File: lib/providers/location_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

// Stream provider for live location updates
final locationProvider = StreamProvider.autoDispose<Position>((ref) async* {
  // Yield a specific mock location for demo purposes
  // Coordinates: 30.026000, 31.210920
  yield Position(
    latitude: 30.026000,
    longitude: 31.210920,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    altitudeAccuracy: 0,
    headingAccuracy: 0,
    isMocked: true,
  );
});
