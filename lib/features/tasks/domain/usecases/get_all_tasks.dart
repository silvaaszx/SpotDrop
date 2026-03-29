library;

import 'package:dartz/dartz.dart';
import 'package:spot_drop/core/error/failures.dart';
import 'package:spot_drop/core/usecases/usecase.dart';
import 'package:spot_drop/features/tasks/domain/entities/geofence_task.dart';
import 'package:spot_drop/features/tasks/domain/repositories/task_repository.dart';

class GetAllTasks extends UseCase<List<GeofenceTask>, NoParams> {
  final TaskRepository repository;
  GetAllTasks(this.repository);

  @override
  Future<Either<Failure, List<GeofenceTask>>> call(NoParams params) {
    return repository.getAllTasks();
  }
}
