import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:spot_drop/core/theme/app_theme.dart';
import 'package:spot_drop/core/widgets/premium_widgets.dart';
import 'package:spot_drop/features/tasks/presentation/cubit/create_task_cubit.dart';

class CreateTaskScreen extends StatefulWidget {
  final VoidCallback onSaved;

  const CreateTaskScreen({super.key, required this.onSaved});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _mapController = MapController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _mapController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<CreateTaskCubit>().searchLocation(_searchController.text);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateTaskCubit, CreateTaskState>(
      listener: (context, state) {
        if (state.status == CreateTaskStatus.saved) {
          widget.onSaved();
        }
        if (state.status == CreateTaskStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        // Sync map center if changed by search
        if (state.status != CreateTaskStatus.searching) {
           _mapController.move(state.center, _mapController.camera.zoom);
        }
      },
      builder: (context, state) {
        final cubit = context.read<CreateTaskCubit>();

        return Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // ─── Map ───
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: state.center,
                  initialZoom: 15,
                  onPositionChanged: (pos, hasGesture) {
                    if (hasGesture) {
                      cubit.updateCenter(pos.center);
                    }
                  },
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
                        point: state.center,
                        radius: state.radiusMeters,
                        useRadiusInMeter: true,
                        color: AppColors.geofenceCircleFill,
                        borderColor: AppColors.geofenceCircleStroke,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                ],
              ),

              // ─── Search Overlay ───
              Positioned(
                top: MediaQuery.of(context).padding.top + AppSpacing.md,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                child: _SearchOverlay(
                  controller: _searchController,
                  onSearch: _onSearch,
                  isSearching: state.status == CreateTaskStatus.searching,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.5),
              ),

              // ─── Centre Pin ───
              const Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 36),
                      child: _MapPin(),
                    ),
                  ),
                ),
              ),

              // ─── Bottom Panel ───
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _CreateTaskBottomPanel(
                  state: state,
                  titleController: _titleController,
                  descController: _descController,
                  onTitleChanged: cubit.updateTitle,
                  onDescChanged: cubit.updateDescription,
                  onRadiusChanged: cubit.updateRadius,
                  onSave: cubit.save,
                ).animate().fadeIn().slideY(begin: 0.3, curve: Curves.easeOutCubic),
              ),

              // ─── Close Button ───
              Positioned(
                top: MediaQuery.of(context).padding.top + AppSpacing.md,
                left: AppSpacing.md,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        );
      },
    );
  }
}

class _SearchOverlay extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final bool isSearching;

  const _SearchOverlay({
    required this.controller,
    required this.onSearch,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: TextField(
        controller: controller,
        onSubmitted: (_) => onSearch(),
        decoration: InputDecoration(
          hintText: 'Search location...',
          filled: false,
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
          suffixIcon: isSearching
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  onPressed: onSearch,
                ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: AppShadows.glow,
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: AppColors.scaffoldDark,
            size: 24,
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .scale(duration: 1.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
         .shimmer(delay: 2.seconds),
        Container(
          width: 4,
          height: 12,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
          ),
        ),
      ],
    );
  }
}

class _CreateTaskBottomPanel extends StatelessWidget {
  final CreateTaskState state;
  final TextEditingController titleController;
  final TextEditingController descController;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescChanged;
  final ValueChanged<double> onRadiusChanged;
  final VoidCallback onSave;

  const _CreateTaskBottomPanel({
    required this.state,
    required this.titleController,
    required this.descController,
    required this.onTitleChanged,
    required this.onDescChanged,
    required this.onRadiusChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return GlassCard(
      blur: 20,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + (bottomPadding > 0 ? bottomPadding : MediaQuery.of(context).padding.bottom),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Drop a Reminder', style: Theme.of(context).textTheme.headlineSmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '${state.radiusMeters.round()}m',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: titleController,
            onChanged: onTitleChanged,
            decoration: const InputDecoration(
              hintText: 'Task Title',
              prefixIcon: Icon(Icons.edit_location_rounded, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: descController,
            onChanged: onDescChanged,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Additional notes (optional)',
              prefixIcon: Icon(Icons.notes_rounded, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Slider(
            value: state.radiusMeters,
            min: 100,
            max: 2000,
            divisions: 19,
            onChanged: onRadiusChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              onPressed: state.status == CreateTaskStatus.saving ? null : onSave,
              isLoading: state.status == CreateTaskStatus.saving,
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('ACTIVATE GEOFENCE'),
            ),
          ),
        ],
      ),
    );
  }
}
