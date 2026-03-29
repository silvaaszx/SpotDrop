library;

import 'package:spot_drop/features/tasks/domain/entities/geofence_task.dart';
import 'package:spot_drop/features/tasks/domain/repositories/task_repository.dart';

class WatchAllTasks {
  final TaskRepository repository;
  WatchAllTasks(this.repository);

  Stream<List<GeofenceTask>> call() {
    return repository.watchAllTasks();
  }
}
