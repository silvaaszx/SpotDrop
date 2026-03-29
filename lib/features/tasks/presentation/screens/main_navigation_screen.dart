import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_drop/core/theme/app_theme.dart';
import 'package:spot_drop/core/widgets/premium_widgets.dart';
import 'package:spot_drop/features/tasks/domain/entities/geofence_task.dart';
import 'package:spot_drop/features/tasks/presentation/bloc/task_list_bloc.dart';
import 'package:spot_drop/features/tasks/presentation/screens/home_screen.dart';
import 'package:spot_drop/features/tasks/presentation/screens/map_overview_screen.dart';
import 'package:spot_drop/features/tasks/presentation/screens/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback onCreateTask;
  final void Function(GeofenceTask task) onTaskTap;

  const MainNavigationScreen({
    super.key,
    required this.onCreateTask,
    required this.onTaskTap,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onCreateTask: widget.onCreateTask, onTaskTap: widget.onTaskTap),
      MapOverviewScreen(onTaskTap: widget.onTaskTap),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            borderRadius: BorderRadius.circular(AppRadius.full),
            blur: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavButton(
                  icon: Icons.dashboard_rounded,
                  label: 'Tasks',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavButton(
                  icon: Icons.map_rounded,
                  label: 'Map',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavButton(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
        ).animate().slideY(begin: 1, duration: 600.ms, curve: Curves.easeOutQuint),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textMuted;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24)
              .animate(target: isActive ? 1 : 0)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1))
              .tint(color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isActive)
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ).animate().scale().fadeIn(),
        ],
      ),
    );
  }
}
