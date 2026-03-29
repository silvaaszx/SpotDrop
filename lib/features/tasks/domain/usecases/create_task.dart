library;

import 'package:dartz/dartz.dart';
import 'package:spot_drop/core/error/failures.dart';
import 'package:spot_drop/core/usecases/usecase.dart';
import 'package:spot_drop/features/tasks/domain/entities/geofence_task.dart';
import 'package:spot_drop/features/tasks/domain/repositories/task_repository.dart';

class CreateTask extends UseCase<GeofenceTask, GeofenceTask> {
  final TaskRepository repository;
  CreateTask(this.repository);

  @override
  Future<Either<Failure, GeofenceTask>> call(GeofenceTask params) {
    return repository.createTask(params);
  }
}
