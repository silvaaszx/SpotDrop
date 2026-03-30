import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:spot_drop/core/theme/app_theme.dart';
import 'package:spot_drop/core/widgets/premium_widgets.dart';
import 'package:spot_drop/features/tasks/domain/entities/geofence_task.dart';
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
      const _HistoryPlaceholder(), // Adding a quick history view
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
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
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
                      
                      const SizedBox(width: 48), // Space for FAB
                      
                      _NavButton(
                        icon: Icons.history_rounded,
                        label: 'History',
                        isActive: _currentIndex == 2,
                        onTap: () => setState(() => _currentIndex = 2),
                      ),
                      _NavButton(
                        icon: Icons.settings_rounded,
                        label: 'Settings',
                        isActive: _currentIndex == 3,
                        onTap: () => setState(() => _currentIndex = 3),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          onPressed: widget.onCreateTask,
          elevation: 8,
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: AppShadows.glow,
            ),
            child: const Icon(Icons.add_location_alt_rounded, color: AppColors.scaffoldDark, size: 28),
          ),
        ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}

class _HistoryPlaceholder extends StatelessWidget {
  const _HistoryPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: const Center(child: Text('Coming Soon: Detailed Travel History 🛰️')),
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
