import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:spot_drop/core/theme/app_theme.dart';
import 'package:spot_drop/core/widgets/premium_widgets.dart';
import 'package:spot_drop/features/tasks/presentation/screens/settings_sub_screens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xl),
              
              _SettingsTile(
                icon: Icons.notifications_active_rounded,
                title: 'Notification Channels',
                subtitle: 'Manage how alerts are delivered',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
                ),
              ).animate().fadeIn().slideY(begin: 0.1),
              
              const SizedBox(height: AppSpacing.md),
              
              _SettingsTile(
                icon: Icons.shield_rounded,
                title: 'Privacy & Permissions',
                subtitle: 'Check location and background status',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPermissionsScreen()),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              
              const SizedBox(height: AppSpacing.md),
              
              _SettingsTile(
                icon: Icons.auto_delete_rounded,
                title: 'Cleanup History',
                subtitle: 'Remove all completed reminders',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cleanup History?'),
                      content: const Text('This will remove all completed reminders forever.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            // Logic for clearing completed tasks
                            Navigator.pop(context);
                          },
                          child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                },
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              
              const SizedBox(height: AppSpacing.xxl),
              
              const GlassCard(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Text('SpotDrop MVP v1.0.0', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Precision Geofencing Engine', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    SizedBox(height: 12),
                    Text('Made with ❤️ for precision.', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms).scale(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
