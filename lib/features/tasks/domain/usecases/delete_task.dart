library;

import 'package:dartz/dartz.dart';
import 'package:spot_drop/core/error/failures.dart';
import 'package:spot_drop/core/usecases/usecase.dart';
import 'package:spot_drop/features/tasks/domain/repositories/task_repository.dart';

class DeleteTask extends UseCase<void, int> {
  final TaskRepository repository;
  DeleteTask(this.repository);

  @override
  Future<Either<Failure, void>> call(int params) {
    return repository.deleteTask(params);
  }
}
