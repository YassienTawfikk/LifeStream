// File: lib/pages/home/home_page.dart (MODIFIED)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/constants/index.dart';
import 'package:life_stream/providers/auth_provider.dart';
import 'package:life_stream/widgets/index.dart';
import 'dart:math';
// Import the new Pulse Provider
import 'package:life_stream/providers/pulse_provider.dart'; // NEW IMPORT

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  // Simulated Wearable Data
  final String motionStatus = ['Idle', 'Walking', 'Running'][Random().nextInt(3)];
  final bool dangerAlert = Random().nextBool(); // Simulated low battery/fall risk

  final List<int> heartRateHistory = [75, 82, 88, 91, 86, 95, 93];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    
    // WATCH THE REAL-TIME PULSE PROVIDER HERE (STEP 2)
    final asyncPulse = ref.watch(realTimePulseProvider);
    
    // Determine the current heart rate to display (live data > mock data)
    final int currentHeartRate = asyncPulse.when(
      data: (pulse) => pulse ?? 0, // Use live pulse data, default to 0
      loading: () => 0, // Show 0 while loading
      error: (err, stack) => 0, // Show 0 on error
    );

    // Determine the text to display while loading/error
    final String hrText = asyncPulse.when(
      data: (pulse) => pulse != null ? '$pulse BPM' : 'No Data',
      loading: () => 'Loading...',
      error: (err, stack) => 'Error',
    );
    
    // Determine a safe value and color for the progress indicator
    final double hrProgress = currentHeartRate / 120.0;
    final Color hrColor = currentHeartRate > 100
        ? AppColors.lightError
        : currentHeartRate > 0 
          ? AppColors.success 
          : AppColors.textTertiary;


    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hi, ${user?.name ?? 'User'}!',
          style: AppTextStyles.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SOS Button - MOST CRITICAL ACTION
            PrimaryButton(
              label: 'SEND EMERGENCY SOS',
              onPressed: () => context.push('/sos'),
              icon: Icons.sos_rounded,
              isFullWidth: true,
            ),
            const SizedBox(height: 24),

            // 2. Danger Alert Indicator
            if (dangerAlert) ...[
              AppCard(
                backgroundColor: AppColors.lightError.withOpacity(0.1),
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: AppColors.lightError, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'DANGER ALERT: Bracelet needs attention (Low Battery/Fall Detected).',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightError),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 3. Vitals and Status Grid (UPDATED)
            Row(
              children: [
                // Heart Rate
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.monitor_heart_rounded, color: Theme.of(context).primaryColor),
                        const SizedBox(height: 8),
                        Text('Heart Rate', style: AppTextStyles.labelSmall),
                        const SizedBox(height: 4),
                        Text(
                          hrText, // Displaying live data/status
                          style: AppTextStyles.headlineLarge,
                        ),
                        const SizedBox(height: 12),
                        // Simulated Mini Chart (Progress Bar)
                        LinearProgressIndicator(
                          value: hrProgress.clamp(0.0, 1.0), // Use calculated progress
                          color: hrColor, // Use calculated color
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Motion Status
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.directions_run_rounded, color: AppColors.lightSecondary),
                        const SizedBox(height: 8),
                        Text('Motion Status', style: AppTextStyles.labelSmall),
                        const SizedBox(height: 4),
                        Text(motionStatus, style: AppTextStyles.headlineLarge),
                        const SizedBox(height: 12),
                        Text(
                          'Last 5 min.',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                        ),
                        // Add a mock badge for the status
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(motionStatus, style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).primaryColor)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Quick Actions
            Text('Quick Access', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                // Live Map
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/live-map'),
                    child: AppCard(
                      child: Column(
                        children: [
                          Icon(Icons.map_rounded, size: 32, color: Theme.of(context).primaryColor),
                          const SizedBox(height: 8),
                          Text('Live Map', style: AppTextStyles.titleMedium),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Emergency Contacts
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/emergency-contacts'),
                    child: AppCard(
                      child: Column(
                        children: [
                          Icon(Icons.contact_phone_rounded, size: 32, color: Theme.of(context).primaryColor),
                          const SizedBox(height: 8),
                          Text('Contacts', style: AppTextStyles.titleMedium),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 5. Heart Rate History (Mock Chart) - UPDATED
            Text('Heart Rate Trend', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 12),
            AppCard(
              child: SizedBox(
                height: 150,
                child: Center(
                  child: Text(
                    'Placeholder for a Line Chart showing HR history.\nLatest BPM: $currentHeartRate', // Updated to show live HR
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}