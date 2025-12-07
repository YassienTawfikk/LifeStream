// File: lib/pages/sos/sos_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:life_stream/constants/index.dart';
import 'package:life_stream/providers/auth_provider.dart';
import 'package:life_stream/providers/friends_provider.dart';
import 'package:life_stream/providers/pulse_provider.dart';
import 'package:life_stream/widgets/index.dart';

class SosPage extends ConsumerStatefulWidget {
  const SosPage({super.key});

  @override
  ConsumerState<SosPage> createState() => _SosPageState();
}

class _SosPageState extends ConsumerState<SosPage> {
  bool isAlertTriggered = false;
  bool isSending = false;

  Future<void> _triggerSos() async {
    setState(() {
      isAlertTriggered = true;
      isSending = true;
    });

    try {
      // 1. Get User ID
      final user = ref.read(authProvider).user;
      final userId = user?.id ?? 'unknown_user';

      // 2. Get Current Location
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // 3. Notify Friends
      // Ideally this should be a Cloud Function triggered by a single write.
      // But we will write to each friend's alert node from the client for this prototype.
      final friends = ref.read(friendsProvider).friends;
      final database = FirebaseDatabase.instance;

      // Get current BPM
      final bpmAsync = ref.read(realTimePulseProvider);
      final int? currentBpm = bpmAsync.valueOrNull;

      final alertData = {
        'status': 'ACTIVE',
        'timestamp': ServerValue.timestamp,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'bpm': currentBpm,
        'senderId': userId,
        'senderName': user?.name ?? 'Unknown',
        'message':
            'SOS Alert! I need help! (BPM: ${currentBpm ?? 'N/A'}, Loc: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})',
      };

      // Write to own SOS log
      await database.ref('sos_alerts/$userId').set(alertData);

      // Write to friends modules
      for (var friend in friends) {
        // Pushing a new alert to the friend's Alerts collection
        // Assuming we have a path like `users/{friendId}/alerts`
        await database.ref('users/${friend.id}/alerts').push().set(alertData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SOS Sent! Notified ${friends.length} friends.'),
            backgroundColor: AppColors.lightError,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send SOS: $e'),
            backgroundColor: AppColors.textPrimary,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSending = false);
      }
    }
  }

  Future<void> _cancelSos() async {
    setState(() => isAlertTriggered = false);

    try {
      final user = ref.read(authProvider).user;
      final userId = user?.id ?? 'unknown_user';

      // Update own status to RESOLVED
      await FirebaseDatabase.instance.ref('sos_alerts/$userId').update({
        'status': 'RESOLVED',
        'resolved_at': ServerValue.timestamp,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS Alert Canceled.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error canceling SOS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Alert'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isAlertTriggered
                    ? 'ALERT ACTIVATED'
                    : 'PRESS AND HOLD TO SEND SOS',
                style: AppTextStyles.displaySmall.copyWith(
                  color: isAlertTriggered
                      ? AppColors.lightError
                      : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onLongPress: isAlertTriggered ? null : _triggerSos,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: isAlertTriggered
                        ? AppColors.lightError
                        : AppColors.lightError.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lightError.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSending)
                        const CircularProgressIndicator(color: Colors.white)
                      else ...[
                        Icon(
                          isAlertTriggered
                              ? Icons.warning_rounded
                              : Icons.sos_rounded,
                          size: 96,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isAlertTriggered ? 'EMERGENCY' : 'SOS',
                          style: AppTextStyles.displaySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (isAlertTriggered)
                PrimaryButton(
                  label: 'Cancel Alert',
                  onPressed: _cancelSos,
                  isLoading: false,
                  icon: Icons.close,
                )
              else
                Text(
                  'Your location and vitals will be sent automatically to your Emergency Friends.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
