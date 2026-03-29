import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spot_drop/core/theme/app_theme.dart';
import 'package:spot_drop/core/widgets/premium_widgets.dart';
import 'package:spot_drop/features/tasks/domain/entities/geofence_task.dart';
import 'package:spot_drop/features/tasks/presentation/bloc/task_list_bloc.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onCreateTask;
  final void Function(GeofenceTask task) onTaskTap;

  const HomeScreen({
    super.key,
    required this.onCreateTask,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ───
              _HomeHeader(onCreateTask: onCreateTask),

              // ─── Task list ───
              Expanded(
                child: BlocBuilder<TaskListBloc, TaskListState>(
                  builder: (context, state) {
                    return switch (state) {
                      TaskListInitial() ||
                      TaskListLoading() =>
                        _LoadingState(),
                      TaskListError(message: final msg) => _ErrorState(message: msg),
                      TaskListLoaded() => state.tasks.isEmpty
                          ? _EmptyState(onCreateTask: onCreateTask)
                          : _TaskListView(
                              state: state,
                              onTaskTap: onTaskTap,
                            ),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onCreateTask,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('New Reminder'),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final VoidCallback onCreateTask;
  const _HomeHeader({required this.onCreateTask});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: AppShadows.glow,
                ),
                child: const Icon(Icons.location_on_rounded,
                    color: AppColors.scaffoldDark, size: 28),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SpotDrop',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'Precision Reminders',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
            ],
          ),
          // Profile placeholder
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surfaceLight,
              child: Icon(Icons.person_outline_rounded,
                  size: 20, color: AppColors.textSecondary),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTask;
  const _EmptyState({required this.onCreateTask});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.explore_off_outlined,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(duration: 2.seconds, curve: Curves.easeInOut)
           .moveY(begin: -5, end: 5),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Your map is empty',
            style: Theme.of(context).textTheme.headlineSmall,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Drop a reminder at any location\nto stay on track of your tasks.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            onPressed: onCreateTask,
            icon: const Icon(Icons.add_location_alt_rounded),
            label: const Text('Add My First Task'),
          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.5),
        ],
      ),
    );
  }
}

class _TaskListView extends StatelessWidget {
  final TaskListLoaded state;
  final void Function(GeofenceTask task) onTaskTap;

  const _TaskListView({required this.state, required this.onTaskTap});

  @override
  Widget build(BuildContext context) {
    final active = state.activeTasks;
    final completed = state.completedTasks;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      physics: const BouncingScrollPhysics(),
      children: [
        if (active.isNotEmpty) ...[
          _SectionHeader(title: 'Pending Reminders', count: active.length),
          const SizedBox(height: AppSpacing.sm),
          ...active.asMap().entries.map((e) => _TaskCard(
                task: e.value,
                onTap: () => onTaskTap(e.value),
              ).animate().fadeIn(delay: (e.key * 100).ms).slideX(begin: 0.1)),
        ],
        if (completed.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'Completed', count: completed.length, isCompleted: true),
          const SizedBox(height: AppSpacing.sm),
          ...completed.map((t) => _TaskCard(
                task: t,
                onTap: () => onTaskTap(t),
              ).animate().fadeIn()),
        ],
        const SizedBox(height: 100),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isCompleted;

  const _SectionHeader({
    required this.title,
    required this.count,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? AppColors.textMuted : AppColors.textPrimary;
    
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        Text(
          '$count',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final GeofenceTask task;
  final VoidCallback onTap;

  const _TaskCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TaskListBloc>();
    final dateFormat = DateFormat('E, MMM d');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Dismissible(
        key: ValueKey(task.id),
        background: _SwipeAction(
          color: AppColors.success,
          icon: Icons.check_circle_rounded,
          alignment: Alignment.centerLeft,
        ),
        secondaryBackground: _SwipeAction(
          color: AppColors.error,
          icon: Icons.delete_sweep_rounded,
          alignment: Alignment.centerRight,
        ),
        confirmDismiss: (dir) async {
          if (dir == DismissDirection.startToEnd) {
            bloc.add(TaskCompleted(task));
            return false;
          } else {
            bloc.add(TaskDeleted(task.id));
            return true;
          }
        },
        child: GestureDetector(
          onTap: onTap,
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: task.isCompleted 
                ? AppColors.glassBase.withOpacity(0.1)
                : AppColors.glassBase,
            border: Border.all(
              color: task.isCompleted
                  ? AppColors.glassBorder.withOpacity(0.05)
                  : AppColors.glassBorder,
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? AppColors.textMuted.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    task.isCompleted ? Icons.check_circle_outline : Icons.radar_rounded,
                    color: task.isCompleted ? AppColors.textMuted : AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              color: task.isCompleted ? AppColors.textMuted : null,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.near_me_rounded, size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            '${task.radius.round()}m radius',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text('•', style: TextStyle(color: AppColors.textMuted)),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            dateFormat.format(task.createdAt),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeAction extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Alignment alignment;

  const _SwipeAction({
    required this.color,
    required this.icon,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Icon(icon, color: color, size: 32),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.5.seconds),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: TextStyle(color: AppColors.error)),
    );
  }
}
