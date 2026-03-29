/// Reactive task-list BLoC driven by Isar watch streams.
///
/// Subscribes to [WatchAllTasks] and re-emits whenever the DB changes.
/// Also handles inline complete/delete actions.
library;

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_drop/features/tasks/domain/entities/geofence_task.dart';
import 'package:spot_drop/features/tasks/domain/usecases/delete_task.dart';
import 'package:spot_drop/features/tasks/domain/usecases/update_task.dart';
import 'package:spot_drop/features/tasks/domain/usecases/watch_all_tasks.dart';

// ───────────────────────── Events ─────────────────────────
sealed class TaskListEvent extends Equatable {
  const TaskListEvent();
  @override
  List<Object?> get props => [];
}

final class TaskListStarted extends TaskListEvent {
  const TaskListStarted();
}

final class _TaskListUpdated extends TaskListEvent {
  final List<GeofenceTask> tasks;
  const _TaskListUpdated(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

final class TaskCompleted extends TaskListEvent {
  final GeofenceTask task;
  const TaskCompleted(this.task);
  @override
  List<Object?> get props => [task];
}

final class TaskDeleted extends TaskListEvent {
  final int taskId;
  const TaskDeleted(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

// ───────────────────────── States ─────────────────────────
sealed class TaskListState extends Equatable {
  const TaskListState();
  @override
  List<Object?> get props => [];
}

final class TaskListInitial extends TaskListState {
  const TaskListInitial();
}

final class TaskListLoading extends TaskListState {
  const TaskListLoading();
}

final class TaskListLoaded extends TaskListState {
  final List<GeofenceTask> tasks;
  const TaskListLoaded(this.tasks);

  List<GeofenceTask> get activeTasks =>
      tasks.where((t) => !t.isCompleted).toList();

  List<GeofenceTask> get completedTasks =>
      tasks.where((t) => t.isCompleted).toList();

  @override
  List<Object?> get props => [tasks];
}

final class TaskListError extends TaskListState {
  final String message;
  const TaskListError(this.message);
  @override
  List<Object?> get props => [message];
}

// ───────────────────────── BLoC ──────────────────────────
class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final WatchAllTasks _watchAllTasks;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;

  StreamSubscription<List<GeofenceTask>>? _tasksSub;

  TaskListBloc({
    required WatchAllTasks watchAllTasks,
    required UpdateTask updateTask,
    required DeleteTask deleteTask,
  })  : _watchAllTasks = watchAllTasks,
        _updateTask = updateTask,
        _deleteTask = deleteTask,
        super(const TaskListInitial()) {
    on<TaskListStarted>(_onStarted);
    on<_TaskListUpdated>(_onUpdated);
    on<TaskCompleted>(_onCompleted);
    on<TaskDeleted>(_onDeleted);
  }

  void _onStarted(TaskListStarted event, Emitter<TaskListState> emit) {
    emit(const TaskListLoading());
    _tasksSub?.cancel();
    _tasksSub = _watchAllTasks().listen(
      (tasks) => add(_TaskListUpdated(tasks)),
    );
  }

  void _onUpdated(_TaskListUpdated event, Emitter<TaskListState> emit) {
    emit(TaskListLoaded(event.tasks));
  }

  Future<void> _onCompleted(
    TaskCompleted event,
    Emitter<TaskListState> emit,
  ) async {
    final updated = event.task.copyWith(isCompleted: !event.task.isCompleted);
    await _updateTask(updated);
  }

  Future<void> _onDeleted(
    TaskDeleted event,
    Emitter<TaskListState> emit,
  ) async {
    await _deleteTask(event.taskId);
  }

  @override
  Future<void> close() {
    _tasksSub?.cancel();
    return super.close();
  }
}
