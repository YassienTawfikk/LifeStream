// File: lib/pages/map/map_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/constants/index.dart';
import 'package:life_stream/providers/location_provider.dart';
import 'package:life_stream/widgets/index.dart';

class LiveMapPage extends ConsumerStatefulWidget {
  const LiveMapPage({super.key});

  @override
  ConsumerState<LiveMapPage> createState() => _LiveMapPageState();
}

class _LiveMapPageState extends ConsumerState<LiveMapPage> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);

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
                // Update map center if needed (optional implementation choice)
                // For now, we center on build. Ideally, we can listen to changes and move map.
                // But auto-moving map on every update can be annoying if user pans.
                // We'll trust the map controller to be handled or initial center.
                // However, the previous implementation updated camera on *every* build?
                // Yes, _updateCamera was called in build.
                // Let's replicate that behavior but maybe safer.

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _mapController.move(
                    LatLng(position.latitude, position.longitude),
                    _mapController.camera.zoom,
                  );
                });

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      position.latitude,
                      position.longitude,
                    ),
                    initialZoom: 16.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.yassien.lifestream',
                    ),
                    MarkerLayer(
                      markers: [
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
                      ],
                    ),
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
