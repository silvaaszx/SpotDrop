import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_drop/core/di/injection_container.dart';
import 'package:spot_drop/core/theme/app_theme.dart';
import 'package:spot_drop/features/tasks/domain/entities/geofence_task.dart';
import 'package:spot_drop/features/tasks/presentation/bloc/task_list_bloc.dart';
import 'package:spot_drop/features/tasks/presentation/cubit/create_task_cubit.dart';
import 'package:spot_drop/features/tasks/presentation/cubit/permission_cubit.dart';
import 'package:spot_drop/features/tasks/presentation/screens/create_task_screen.dart';
import 'package:spot_drop/features/tasks/presentation/screens/main_navigation_screen.dart';
import 'package:spot_drop/features/tasks/presentation/screens/permission_screen.dart';
import 'package:spot_drop/features/tasks/presentation/screens/splash_screen.dart';
import 'package:spot_drop/features/tasks/presentation/screens/task_detail_screen.dart';

void main() async {
  // 1. Ensure engine is ready
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Set Status Bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // 3. Init DI & Run
  await initDependencies();
  runApp(const SpotDropApp());
}

class SpotDropApp extends StatefulWidget {
  const SpotDropApp({super.key});

  @override
  State<SpotDropApp> createState() => _SpotDropAppState();
}

class _SpotDropAppState extends State<SpotDropApp> {
  bool _isInitialized = false;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Artificial delay to ensure dependencies are warm
    await Future.delayed(Duration.zero);
    debugPrint('[SpotDrop] Bootstrap: Complete.');
    setState(() => _isInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<PermissionCubit>()..checkInitialStatus()),
        BlocProvider(create: (_) => sl<TaskListBloc>()..add(const TaskListStarted())),
      ],
      child: MaterialApp(
        title: 'SpotDrop',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: _showSplash
            ? SplashScreen(onFinish: () => setState(() => _showSplash = false))
            : BlocBuilder<PermissionCubit, PermissionState>(
                builder: (context, state) {
                  if (!_isInitialized) return const _BootstrapLoader();
                  
                  if (state.step == PermissionStep.granted) {
                    return MainNavigationScreen(
                      onCreateTask: () => _navigateToCreateTask(context),
                      onTaskTap: (task) => _navigateToDetails(context, task),
                    );
                  }
                  return PermissionScreen(
                    onAllGranted: () {
                      context.read<PermissionCubit>().checkInitialStatus();
                    },
                  );
                },
              ),
      ),
    );
  }

  void _navigateToCreateTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<TaskListBloc>()),
            BlocProvider(create: (_) => sl<CreateTaskCubit>()),
          ],
          child: CreateTaskScreen(
            onSaved: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context, GeofenceTask task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TaskListBloc>(),
          child: TaskDetailScreen(task: task),
        ),
      ),
    );
  }
}

class _BootstrapLoader extends StatelessWidget {
  const _BootstrapLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
