/// Abstract repository contract for [GeofenceTask] operations.
///
/// Defined in the domain layer — the data layer provides the concrete
/// implementation backed by Isar.
library;

import 'package:dartz/dartz.dart';
import 'package:spot_drop/core/error/failures.dart';
import 'package:spot_drop/features/tasks/domain/entities/geofence_task.dart';

abstract class TaskRepository {
  /// Returns all tasks ordered by [createdAt] descending.
  Future<Either<Failure, List<GeofenceTask>>> getAllTasks();

  /// Returns a single task by its Isar [id].
  Future<Either<Failure, GeofenceTask>> getTaskById(int id);

  /// Reactive stream of all tasks — powered by Isar's `watchLazy`.
  Stream<List<GeofenceTask>> watchAllTasks();

  /// Persists a new task and returns it with the auto-generated [id].
  Future<Either<Failure, GeofenceTask>> createTask(GeofenceTask task);

  /// Updates an existing task (e.g. marking it completed).
  Future<Either<Failure, GeofenceTask>> updateTask(GeofenceTask task);

  /// Deletes a task by [id].
  Future<Either<Failure, void>> deleteTask(int id);
}
