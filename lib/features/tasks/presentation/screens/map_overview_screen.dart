import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:spot_drop/core/theme/app_theme.dart';
import 'package:spot_drop/features/tasks/domain/entities/geofence_task.dart';
import 'package:spot_drop/features/tasks/presentation/bloc/task_list_bloc.dart';

class MapOverviewScreen extends StatelessWidget {
  final void Function(GeofenceTask task) onTaskTap;

  const MapOverviewScreen({super.key, required this.onTaskTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskListBloc, TaskListState>(
      builder: (context, state) {
        final tasks = state is TaskListLoaded ? state.tasks : <GeofenceTask>[];
        
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(-23.5505, -46.6333),
                    initialZoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.spotdrop.app',
                    ),
                    CircleLayer(
                      circles: tasks.map((t) => CircleMarker(
                        point: LatLng(t.latitude, t.longitude),
                        radius: t.radius,
                        useRadiusInMeter: true,
                        color: t.isCompleted 
                            ? Colors.grey.withOpacity(0.1) 
                            : AppColors.geofenceCircleFill,
                        borderColor: t.isCompleted
                            ? Colors.grey.withOpacity(0.2)
                            : AppColors.geofenceCircleStroke,
                        borderStrokeWidth: 1,
                      )).toList(),
                    ),
                    MarkerLayer(
                      markers: tasks.map((t) => Marker(
                        point: LatLng(t.latitude, t.longitude),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => onTaskTap(t),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: t.isCompleted ? null : AppColors.primaryGradient,
                              color: t.isCompleted ? Colors.grey : null,
                              shape: BoxShape.circle,
                              boxShadow: t.isCompleted ? null : AppShadows.glow,
                              border: Border.all(color: Colors.white24, width: 1.5),
                            ),
                            child: Icon(
                              t.isCompleted ? Icons.check_rounded : Icons.location_on_rounded,
                              color: AppColors.scaffoldDark,
                              size: 20,
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              
              // Header
              Positioned(
                top: MediaQuery.of(context).padding.top + AppSpacing.md,
                left: AppSpacing.lg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Global Radar', style: Theme.of(context).textTheme.headlineSmall),
                    Text(
                      '${tasks.where((t) => !t.isCompleted).length} active geofences',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ).animate().fadeIn().slideX(begin: -0.2),
              ),
            ],
          ),
        );
      },
    );
  }
}
