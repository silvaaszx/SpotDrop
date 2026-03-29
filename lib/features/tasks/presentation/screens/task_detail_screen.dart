import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:spot_drop/core/di/injection_container.dart';
import 'package:spot_drop/core/platform/geofencing_platform.dart';
import 'package:spot_drop/core/theme/app_theme.dart';
import 'package:spot_drop/core/widgets/premium_widgets.dart';
import 'package:spot_drop/features/tasks/domain/entities/geofence_task.dart';
import 'package:spot_drop/features/tasks/presentation/bloc/task_list_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskDetailScreen extends StatelessWidget {
  final GeofenceTask task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final center = LatLng(task.latitude, task.longitude);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: Column(
          children: [
            // ─── Map Header ───
            Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.spotdrop.app',
                        tileBuilder: (context, tileWidget, tile) {
                          return ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              AppColors.scaffoldDark,
                              BlendMode.saturation,
                            ),
                            child: tileWidget,
                          );
                        },
                      ),
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: center,
                            radius: task.radius,
                            useRadiusInMeter: true,
                            color: AppColors.geofenceCircleFill,
                            borderColor: AppColors.geofenceCircleStroke,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: center,
                            width: 60,
                            height: 60,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.glow,
                                border: Border.all(color: Colors.white24, width: 2),
                              ),
                              child: const Icon(Icons.location_on_rounded,
                                  color: AppColors.scaffoldDark, size: 28),
                            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 1.seconds, end: const Offset(1.2, 1.2)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Back Button Overlay
                Positioned(
                  top: MediaQuery.of(context).padding.top + AppSpacing.md,
                  left: AppSpacing.md,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldDark.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),

            // ─── Details ───
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -32),
                child: GlassCard(
                  blur: 30,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusBadge(isCompleted: task.isCompleted)
                          .animate()
                          .fadeIn()
                          .scale(alignment: Alignment.centerLeft),
                      const SizedBox(height: AppSpacing.lg),
                      
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                      
                      const SizedBox(height: AppSpacing.sm),
                      
                      if (task.description != null)
                        Text(
                          task.description!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ).animate().fadeIn(delay: 400.ms),
                        
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Info Grid
                      Row(
                        children: [
                          Expanded(
                            child: _DetailChip(
                              icon: Icons.radar_rounded,
                              title: 'Radius',
                              value: '${task.radius.round()}m',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _DetailChip(
                              icon: Icons.access_time_filled_rounded,
                              title: 'Created',
                              value: '${task.createdAt.day}/${task.createdAt.month}',
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                      
                      const Spacer(),
                      
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: GradientButton(
                              onPressed: () {
                                context.read<TaskListBloc>().add(TaskCompleted(task));
                                if (!task.isCompleted) {
                                  sl<GeofencingPlatform>().removeGeofence(task.id.toString());
                                }
                                Navigator.of(context).pop();
                              },
                              icon: Icon(task.isCompleted ? Icons.refresh_rounded : Icons.check_circle_rounded),
                              label: Text(task.isCompleted ? 'REACTIVATE' : 'COMPLETE'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              onPressed: () {
                                context.read<TaskListBloc>().add(TaskDeleted(task.id));
                                sl<GeofencingPlatform>().removeGeofence(task.id.toString());
                                Navigator.of(context).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                              ),
                              child: const Icon(Icons.delete_outline_rounded),
                            ),
                          ),
                        ],
                      ).animate(delay: 800.ms).fadeIn().scale(curve: Curves.easeOutBack),
                    ],
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

class _StatusBadge extends StatelessWidget {
  final bool isCompleted;
  const _StatusBadge({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? AppColors.success : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isCompleted ? Icons.check_circle_rounded : Icons.radio_button_checked_rounded,
              size: 14, color: color),
          const SizedBox(width: 8),
          Text(
            isCompleted ? 'COMPLETED' : 'MONITORING',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailChip({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.glassHighlight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
