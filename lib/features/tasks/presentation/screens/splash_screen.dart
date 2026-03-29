import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:spot_drop/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTransition();
  }

  Future<void> _startTransition() async {
    await Future.delayed(3.seconds);
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Animation
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.glow,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: AppColors.scaffoldDark,
                size: 64,
              ),
            )
                .animate()
                .scale(duration: 800.ms, curve: Curves.elasticOut)
                .shimmer(delay: 1.seconds, duration: 1.5.seconds)
                .shake(delay: 2.seconds),
            
            const SizedBox(height: AppSpacing.xxl),
            
            // App Name
            Text(
              'SpotDrop',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
            )
                .animate()
                .fadeIn(delay: 400.ms)
                .slideY(begin: 0.2, curve: Curves.easeOutCubic),
            
            const SizedBox(height: AppSpacing.xs),
            
            // Tagline
            Text(
              'Precision Reminders everywhere.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
            )
                .animate()
                .fadeIn(delay: 800.ms)
                .scale(begin: const Offset(0.8, 0.8)),
                
            const SizedBox(height: 100),
            
            // Loading Indicator
            const SizedBox(
              width: 40,
              height: 2,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white10,
                color: AppColors.primary,
              ),
            )
                .animate()
                .fadeIn(delay: 1.2.seconds)
                .scale(begin: const Offset(0, 1)),
          ],
        ),
      ),
    );
  }
}
