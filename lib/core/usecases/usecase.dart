/// Generic use-case contract.
///
/// Every feature use-case extends this, which guarantees a uniform
/// call-site: `useCase(params)` → `Future<Either<Failure, T>>`.
library;

import 'package:dartz/dartz.dart';
import 'package:spot_drop/core/error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Marker class for use-cases that take no parameters.
class NoParams {
  const NoParams();
}
