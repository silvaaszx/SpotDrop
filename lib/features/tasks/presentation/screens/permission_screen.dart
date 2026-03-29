import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_drop/core/theme/app_theme.dart';
import 'package:spot_drop/features/tasks/presentation/cubit/permission_cubit.dart';

class PermissionScreen extends StatelessWidget {
  final VoidCallback onAllGranted;

  const PermissionScreen({super.key, required this.onAllGranted});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PermissionCubit, PermissionState>(
      listener: (context, state) {
        if (state.step == PermissionStep.granted) {
          onAllGranted();
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: 56,
                      color: AppColors.scaffoldDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Title
                  Text(
                    'Enable Location',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Description
                  Text(
                    'SpotDrop needs access to your location so it can\ntrigger reminders when you arrive at a saved place.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Choose "Always Allow" for background geofencing.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 2),

                  // Status indicator
                  if (state.isLoading) ...[
                    _StepIndicator(step: state.step),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Denied state
                  if (state.step == PermissionStep.denied) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppColors.error, size: 24),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              state.message,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.read<PermissionCubit>().openSettings();
                      },
                      icon: const Icon(Icons.settings_rounded),
                      label: const Text('Open Settings'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.textMuted),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  // Primary action button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () {
                              context
                                  .read<PermissionCubit>()
                                  .requestPermissions();
                            },
                      child: state.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.scaffoldDark,
                              ),
                            )
                          : Text(
                              state.step == PermissionStep.denied
                                  ? 'Try Again'
                                  : 'Get Started',
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final PermissionStep step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    String label;
    switch (step) {
      case PermissionStep.locationWhenInUse:
        label = 'Requesting location access…';
      case PermissionStep.locationAlways:
        label = 'Requesting background access…';
      case PermissionStep.notification:
        label = 'Requesting notification access…';
      default:
        label = '';
    }
    if (label.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
