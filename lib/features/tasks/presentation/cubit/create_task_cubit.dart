/// Create-task Cubit — drives the map-based task creation screen.
///
/// Manages the selected position, radius, and form fields. On save,
/// persists to Isar and registers the native geofence.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:spot_drop/core/platform/geofencing_platform.dart';
import 'package:spot_drop/features/tasks/domain/entities/geofence_task.dart';
import 'package:spot_drop/features/tasks/domain/usecases/create_task.dart';

// ───────────────────────── State ──────────────────────────
enum CreateTaskStatus { idle, saving, saved, error, searching }

class CreateTaskState extends Equatable {
  final LatLng center;
  final double radiusMeters;
  final String title;
  final String description;
  final CreateTaskStatus status;
  final String? errorMessage;
  final List<Location>? searchResults;

  const CreateTaskState({
    this.center = const LatLng(-23.5505, -46.6333), // São Paulo default
    this.radiusMeters = 200,
    this.title = '',
    this.description = '',
    this.status = CreateTaskStatus.idle,
    this.errorMessage,
    this.searchResults,
  });

  CreateTaskState copyWith({
    LatLng? center,
    double? radiusMeters,
    String? title,
    String? description,
    CreateTaskStatus? status,
    String? errorMessage,
    List<Location>? searchResults,
  }) {
    return CreateTaskState(
      center: center ?? this.center,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      errorMessage: errorMessage,
      searchResults: searchResults ?? this.searchResults,
    );
  }

  @override
  List<Object?> get props =>
      [center, radiusMeters, title, description, status, errorMessage, searchResults];
}

// ───────────────────────── Cubit ──────────────────────────
class CreateTaskCubit extends Cubit<CreateTaskState> {
  final CreateTask _createTask;
  final GeofencingPlatform _geofencingPlatform;

  CreateTaskCubit({
    required CreateTask createTask,
    required GeofencingPlatform geofencingPlatform,
  })  : _createTask = createTask,
        _geofencingPlatform = geofencingPlatform,
        super(const CreateTaskState());

  void updateCenter(LatLng center) {
    emit(state.copyWith(center: center));
  }

  Future<void> searchLocation(String query) async {
    if (query.trim().isEmpty) return;
    
    emit(state.copyWith(status: CreateTaskStatus.searching));
    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        emit(state.copyWith(
          center: LatLng(loc.latitude, loc.longitude),
          status: CreateTaskStatus.idle,
        ));
      } else {
        emit(state.copyWith(
          status: CreateTaskStatus.error,
          errorMessage: 'Location not found.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CreateTaskStatus.error,
        errorMessage: 'Search failed. Please try again.',
      ));
    }
  }

  void updateRadius(double radius) {
    emit(state.copyWith(radiusMeters: radius));
  }

  void updateTitle(String title) {
    emit(state.copyWith(title: title));
  }

  void updateDescription(String description) {
    emit(state.copyWith(description: description));
  }

  /// Validate, persist to Isar, register native geofence.
  Future<void> save() async {
    if (state.title.trim().isEmpty) {
      emit(state.copyWith(
        status: CreateTaskStatus.error,
        errorMessage: 'Please enter a title.',
      ));
      return;
    }

    emit(state.copyWith(status: CreateTaskStatus.saving));

    final task = GeofenceTask(
      id: 0, // auto-increment
      title: state.title.trim(),
      description:
          state.description.trim().isEmpty ? null : state.description.trim(),
      latitude: state.center.latitude,
      longitude: state.center.longitude,
      radius: state.radiusMeters,
      createdAt: DateTime.now(),
    );

    final result = await _createTask(task);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: CreateTaskStatus.error,
          errorMessage: failure.message,
        ));
      },
      (savedTask) async {
        // Register with native geofencing
        await _geofencingPlatform.registerGeofence(
          identifier: savedTask.id.toString(),
          latitude: savedTask.latitude,
          longitude: savedTask.longitude,
          radiusMeters: savedTask.radius,
          title: savedTask.title,
        );

        emit(state.copyWith(status: CreateTaskStatus.saved));
      },
    );
  }
}
