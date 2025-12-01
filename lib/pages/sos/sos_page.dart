// File: LifeStream/lib/pages/sos/sos_page.dart (New File)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/constants/index.dart';
import 'package:life_stream/widgets/index.dart';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  bool isAlertTriggered = false;

  void _triggerSos() {
    setState(() => isAlertTriggered = true);
    // Simulate sending an alert
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS Alert Sent to Emergency Contacts!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _cancelSos() {
    setState(() => isAlertTriggered = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS Alert Canceled.'),
        backgroundColor: Colors.green,
      ),
    );
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
                isAlertTriggered ? 'ALERT ACTIVATED' : 'PRESS AND HOLD TO SEND SOS',
                style: AppTextStyles.displaySmall.copyWith(
                  color: isAlertTriggered ? Colors.red : AppColors.textPrimary,
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
                    color: isAlertTriggered ? Colors.red : Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isAlertTriggered ? Icons.warning_rounded : Icons.sos_rounded,
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
                  'Your location and vitals will be sent automatically.',
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