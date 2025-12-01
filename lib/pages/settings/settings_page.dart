// File: LifeStream/lib/pages/settings/settings_page.dart (Modified Content - Added _buildToggleSettingTile and Device Settings section)
// ... existing imports ...
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/constants/index.dart';
import 'package:life_stream/providers/auth_provider.dart';
import 'package:life_stream/providers/theme_provider.dart';
import 'package:life_stream/widgets/index.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // Device specific settings state (simulated)
  bool _vibrationEnabled = true;
  bool _fallDetectionAlerts = true;
  bool _lowBatteryAlerts = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // NEW SECTION: Device Settings
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Device Settings',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: [
                        _buildToggleSettingTile(
                          icon: Icons.vibration_rounded,
                          title: 'Device Vibration',
                          value: _vibrationEnabled,
                          onChanged: (value) {
                            setState(() => _vibrationEnabled = value);
                            // Mock save action
                          },
                        ),
                        const Divider(height: 1),
                        _buildToggleSettingTile(
                          icon: Icons.emergency_share_rounded,
                          title: 'Fall Detection Alerts',
                          value: _fallDetectionAlerts,
                          onChanged: (value) {
                            setState(() => _fallDetectionAlerts = value);
                            // Mock save action
                          },
                        ),
                        const Divider(height: 1),
                        _buildToggleSettingTile(
                          icon: Icons.battery_alert_rounded,
                          title: 'Low Battery Alerts',
                          value: _lowBatteryAlerts,
                          onChanged: (value) {
                            setState(() => _lowBatteryAlerts = value);
                            // Mock save action
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Appearance Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: [
                        _buildSettingTile(
                          icon: Icons.light_mode,
                          title: 'Light Theme',
                          onTap: () => ref
                              .read(themeModeProvider.notifier)
                              .setLight(),
                          isSelected: themeMode == ThemeMode.light,
                        ),
                        const Divider(height: 1),
                        _buildSettingTile(
                          icon: Icons.dark_mode,
                          title: 'Dark Theme',
                          onTap: () =>
                              ref.read(themeModeProvider.notifier).setDark(),
                          isSelected: themeMode == ThemeMode.dark,
                        ),
                        const Divider(height: 1),
                        _buildSettingTile(
                          icon: Icons.brightness_auto,
                          title: 'System Default',
                          onTap: () => ref
                              .read(themeModeProvider.notifier)
                              .setSystem(),
                          isSelected: themeMode == ThemeMode.system,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Account Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: [
                        _buildSimpleSettingTile(
                          icon: Icons.person,
                          title: 'Edit Profile',
                          onTap: () => context.push('/profile'),
                        ),
                        const Divider(height: 1),
                        _buildSimpleSettingTile(
                          icon: Icons.lock,
                          title: 'Change Password',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Feature coming soon'),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildSimpleSettingTile(
                          icon: Icons.privacy_tip,
                          title: 'Privacy Settings',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Feature coming soon'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // App Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: [
                        _buildSimpleSettingTile(
                          icon: Icons.info_outline,
                          title: 'About LifeStream',
                          onTap: () => _showAboutDialog(),
                        ),
                        const Divider(height: 1),
                        _buildSimpleSettingTile(
                          icon: Icons.description,
                          title: 'Terms & Conditions',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Feature coming soon'),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildSimpleSettingTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Feature coming soon'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PrimaryButton(
                label: 'Logout',
                onPressed: () => _handleLogout(),
              ),
            ),
            const SizedBox(height: 24),

            // Version Info
            Center(
              child: Text(
                'LifeStream ${AppConstants.appVersion}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppConstants.appName,
          style: AppTextStyles.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.appDescription,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Version: ${AppConstants.appVersion}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSimpleSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildToggleSettingTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Theme.of(context).primaryColor,
      ),
      onTap: () => onChanged(!value),
    );
  }
}