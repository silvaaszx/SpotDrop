import 'package:flutter/material.dart';
import 'package:spot_drop/core/theme/app_theme.dart';
import 'package:spot_drop/core/widgets/premium_widgets.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const GlassCard(
              padding: EdgeInsets.all(AppSpacing.md),
              child: ListTile(
                leading: Icon(Icons.notifications_active, color: AppColors.primary),
                title: Text('Push Notifications'),
                subtitle: Text('Receive alerts when entering geofences'),
                trailing: Switch(value: true, onChanged: null),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const GlassCard(
              padding: EdgeInsets.all(AppSpacing.md),
              child: ListTile(
                leading: Icon(Icons.vibration, color: AppColors.primary),
                title: Text('Haptic Feedback'),
                subtitle: Text('Vibrate on trigger'),
                trailing: Switch(value: true, onChanged: null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPermissionsScreen extends StatelessWidget {
  const PrivacyPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Permissions')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const GlassCard(
              padding: EdgeInsets.all(AppSpacing.md),
              child: ListTile(
                leading: Icon(Icons.location_on, color: AppColors.primary),
                title: Text('Location Access'),
                subtitle: Text('Always / When in use'),
                trailing: Icon(Icons.check_circle, color: AppColors.success),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const GlassCard(
              padding: EdgeInsets.all(AppSpacing.md),
              child: ListTile(
                leading: Icon(Icons.history_toggle_off_rounded, color: AppColors.primary),
                title: Text('Background Processing'),
                subtitle: Text('Enabled for geofencing'),
                trailing: Icon(Icons.check_circle, color: AppColors.success),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
