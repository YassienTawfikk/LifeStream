// File: lib/pages/map/map_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/constants/index.dart';
import 'package:life_stream/providers/location_provider.dart';
import 'package:life_stream/providers/location_sync_provider.dart';
import 'package:life_stream/widgets/index.dart';

class LiveMapPage extends ConsumerStatefulWidget {
  final double? targetLat;
  final double? targetLng;
  final String? targetUserId;

  const LiveMapPage({
    super.key,
    this.targetLat,
    this.targetLng,
    this.targetUserId,
  });

  @override
  ConsumerState<LiveMapPage> createState() => _LiveMapPageState();
}

class _LiveMapPageState extends ConsumerState<LiveMapPage> {
  final MapController _mapController = MapController();
  bool _hasCenteredOnTarget = false;

  @override
  Widget build(BuildContext context) {
    // Initialize Location Sync
    ref.watch(locationSyncProvider);

    final locationAsync = ref.watch(locationProvider);
    final hasTarget = widget.targetLat != null && widget.targetLng != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: locationAsync.when(
              data: (position) {
                // Determine center: Target > Current > Default
                LatLng centerLocation;
                if (hasTarget) {
                  centerLocation = LatLng(widget.targetLat!, widget.targetLng!);
                } else {
                  centerLocation = LatLng(
                    position.latitude,
                    position.longitude,
                  );
                }

                // Move map only once to target if present
                if (hasTarget && !_hasCenteredOnTarget) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _mapController.move(centerLocation, 16.0);
                    setState(() => _hasCenteredOnTarget = true);
                  });
                } else if (!hasTarget) {
                  // Optional: Follow user if no target
                  // WidgetsBinding.instance.addPostFrameCallback((_) {
                  //   _mapController.move(centerLocation, _mapController.camera.zoom);
                  // });
                }

                final markers = <Marker>[
                  // Current User (Blue)
                  Marker(
                    point: LatLng(position.latitude, position.longitude),
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                ];

                // Target User (Red SOS)
                if (hasTarget) {
                  markers.add(
                    Marker(
                      point: centerLocation,
                      width: 80,
                      height: 80,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sos, // or warning
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: centerLocation,
                    initialZoom: 16.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.yassien.lifestream',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.lightError,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error getting location:\n$err',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Retry',
                      onPressed: () => ref.refresh(locationProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Status Panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.gps_fixed, color: AppColors.success),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Live Tracking Active',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
