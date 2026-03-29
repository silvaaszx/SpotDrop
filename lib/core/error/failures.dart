/// Core failure types for functional error handling with [Either].
///
/// All domain-level errors flow through these sealed types so the
/// presentation layer can pattern-match exhaustively.
library;

import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'An unexpected cache error occurred.']);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Required permission was denied.']);
}

final class GeofenceFailure extends Failure {
  const GeofenceFailure([super.message = 'Geofence operation failed.']);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}
