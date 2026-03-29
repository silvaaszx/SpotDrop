/// Concrete implementation of [TaskRepository].
///
/// Wraps [TaskLocalDataSource] calls in try/catch and returns
/// [Either<Failure, T>] for clean error propagation.
library;

import 'package:dartz/dartz.dart';
import 'package:spot_drop/core/error/failures.dart';
import 'package:spot_drop/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:spot_drop/features/tasks/data/models/geofence_task_model.dart';
import 'package:spot_drop/features/tasks/domain/entities/geofence_task.dart';
import 'package:spot_drop/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource dataSource;

  TaskRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<GeofenceTask>>> getAllTasks() async {
    try {
      final models = await dataSource.getAll();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to fetch tasks: $e'));
    }
  }

  @override
  Future<Either<Failure, GeofenceTask>> getTaskById(int id) async {
    try {
      final model = await dataSource.getById(id);
      if (model == null) {
        return const Left(CacheFailure('Task not found.'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to fetch task: $e'));
    }
  }

  @override
  Stream<List<GeofenceTask>> watchAllTasks() {
    return dataSource
        .watchAll()
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, GeofenceTask>> createTask(GeofenceTask task) async {
    try {
      final model = GeofenceTaskModel.fromEntity(task);
      final saved = await dataSource.insert(model);
      return Right(saved.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to create task: $e'));
    }
  }

  @override
  Future<Either<Failure, GeofenceTask>> updateTask(GeofenceTask task) async {
    try {
      final model = GeofenceTaskModel.fromEntity(task);
      model.id = task.id;
      final updated = await dataSource.update(model);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to update task: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(int id) async {
    try {
      await dataSource.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete task: $e'));
    }
  }
}
