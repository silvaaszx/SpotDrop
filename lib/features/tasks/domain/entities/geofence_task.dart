/// Pure domain entity for a geofence-based task.
///
/// Framework-agnostic — no Isar annotations, no Flutter imports.
/// The data layer maps to/from this via [GeofenceTaskModel].
library;

import 'package:equatable/equatable.dart';

class GeofenceTask extends Equatable {
  final int id;
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isCompleted;
  final DateTime createdAt;

  const GeofenceTask({
    required this.id,
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.isCompleted = false,
    required this.createdAt,
  });

  GeofenceTask copyWith({
    int? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    double? radius,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return GeofenceTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        latitude,
        longitude,
        radius,
        isCompleted,
        createdAt,
      ];
}
