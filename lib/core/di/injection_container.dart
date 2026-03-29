/// Service locator — registers all dependencies via [get_it].
///
/// Call [initDependencies] once at app startup before `runApp`.
library;

import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:spot_drop/core/notifications/notification_service.dart';
import 'package:spot_drop/core/platform/geofencing_platform.dart';
import 'package:spot_drop/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:spot_drop/features/tasks/data/models/geofence_task_model.dart';
import 'package:spot_drop/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:spot_drop/features/tasks/domain/repositories/task_repository.dart';
import 'package:spot_drop/features/tasks/domain/usecases/create_task.dart';
import 'package:spot_drop/features/tasks/domain/usecases/delete_task.dart';
import 'package:spot_drop/features/tasks/domain/usecases/get_all_tasks.dart';
import 'package:spot_drop/features/tasks/domain/usecases/get_task_by_id.dart';
import 'package:spot_drop/features/tasks/domain/usecases/update_task.dart';
import 'package:spot_drop/features/tasks/domain/usecases/watch_all_tasks.dart';
import 'package:spot_drop/features/tasks/presentation/bloc/task_list_bloc.dart';
import 'package:spot_drop/features/tasks/presentation/cubit/create_task_cubit.dart';
import 'package:spot_drop/features/tasks/presentation/cubit/permission_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ───────────── External ─────────────
  final dir = await getApplicationDocumentsDirectory();
  
  // Open Isar with a safety check
  final isar = await Isar.open(
    [GeofenceTaskModelSchema],
    directory: dir.path,
    name: 'spot_drop',
  );
  
  sl.registerSingleton<Isar>(isar);

  // ───────────── Platform ─────────────
  sl.registerSingleton<GeofencingPlatform>(GeofencingPlatform.instance);

  // ───────────── Notifications ─────────────
  sl.registerSingleton<NotificationService>(NotificationService.instance);

  // ───────────── Data sources ─────────────
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(sl()),
  );

  // ───────────── Repositories ─────────────
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl()),
  );

  // ───────────── Use cases ─────────────
  sl.registerLazySingleton(() => GetAllTasks(sl()));
  sl.registerLazySingleton(() => GetTaskById(sl()));
  sl.registerLazySingleton(() => WatchAllTasks(sl()));
  sl.registerLazySingleton(() => CreateTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));

  // ───────────── BLoCs / Cubits ─────────────
  sl.registerFactory(() => TaskListBloc(
        watchAllTasks: sl(),
        updateTask: sl(),
        deleteTask: sl(),
      ));

  sl.registerFactory(() => CreateTaskCubit(
        createTask: sl(),
        geofencingPlatform: sl(),
      ));

  sl.registerFactory(() => PermissionCubit());
}
