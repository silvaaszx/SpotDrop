/// Isar collection model that maps to / from the domain [GeofenceTask].
///
/// Isar annotations live here — the domain entity stays pure.
library;

import 'package:isar/isar.dart';
import 'package:spot_drop/features/tasks/domain/entities/geofence_task.dart';

part 'geofence_task_model.g.dart';

@collection
class GeofenceTaskModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String title;

  String? description;

  late double latitude;
  late double longitude;

  /// Radius in metres.
  late double radius;

  late bool isCompleted;

  @Index()
  late DateTime createdAt;

  // ────────────── mappers ──────────────

  GeofenceTask toEntity() {
    return GeofenceTask(
      id: id,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      isCompleted: isCompleted,
      createdAt: createdAt,
    );
  }

  static GeofenceTaskModel fromEntity(GeofenceTask entity) {
    return GeofenceTaskModel()
      ..id = entity.id == 0 ? Isar.autoIncrement : entity.id
      ..title = entity.title
      ..description = entity.description
      ..latitude = entity.latitude
      ..longitude = entity.longitude
      ..radius = entity.radius
      ..isCompleted = entity.isCompleted
      ..createdAt = entity.createdAt;
  }
}
