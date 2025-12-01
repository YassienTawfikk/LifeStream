// File: LifeStream/lib/pages/map/map_page.dart (Modified Content)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/constants/index.dart';
import 'package:life_stream/widgets/index.dart'; // Import for PrimaryButton

class LiveMapPage extends StatelessWidget {
  const LiveMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated current mobile location (acting as the wearable location for the demo)
    const String mobileGpsLocation = 'Mobile Device GPS (Giza, Egypt)';
    const String simulatedWearableStatus = 'Tracking Mobile Location';

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
          // Simulated Map Container
          Expanded(
            child: Container(
              color: Colors.blueGrey[900], // Dark color to simulate a map view
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.gps_fixed_rounded,
                      color: AppColors.lightPrimary,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Interactive Map Placeholder',
                      style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
                    ),
                    Text(
                      'Displaying current device location as simulated wearable data.',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Location Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildLocationDetail(
                  context,
                  Icons.watch,
                  'Simulated Wearable Location:',
                  mobileGpsLocation,
                  Theme.of(context).primaryColor,
                ),
                const Divider(height: 20),
                _buildLocationDetail(
                  context,
                  Icons.sync_rounded,
                  'Status:',
                  simulatedWearableStatus,
                  Colors.green,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Simulate Location Update',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Simulating receipt of new location data.')),
                    );
                  },
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDetail(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              subtitle,
              style: AppTextStyles.titleMedium,
            ),
          ],
        ),
      ],
    );
  }
}