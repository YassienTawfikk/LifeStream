// File: LifeStream/lib/pages/home/home_page.dart (Modified Content)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/constants/index.dart';
import 'package:life_stream/providers/auth_provider.dart';
import 'package:life_stream/widgets/index.dart';
import 'dart:math';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  // Simulated Wearable Data
  final int heartRate = 85 + Random().nextInt(15); // 85-100 BPM
  final String motionStatus = ['Idle', 'Walking', 'Running'][Random().nextInt(3)];
  final bool dangerAlert = Random().nextBool(); // Simulated low battery/fall risk

  final List<int> heartRateHistory = [75, 82, 88, 91, 86, 95, 93];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

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

            // 3. Vitals and Status Grid
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
                        Text('$heartRate BPM', style: AppTextStyles.headlineLarge),
                        const SizedBox(height: 12),
                        // Simulated Mini Chart (Progress Bar)
                        LinearProgressIndicator(
                          value: heartRate / 120,
                          color: heartRate > 100 ? AppColors.lightError : Colors.green,
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

            // 5. Heart Rate History (Mock Chart)
            Text('Heart Rate Trend', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 12),
            AppCard(
              child: SizedBox(
                height: 150,
                child: Center(
                  child: Text(
                    'Placeholder for a Line Chart showing HR history.\nLatest BPM: ${heartRateHistory.last}',
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