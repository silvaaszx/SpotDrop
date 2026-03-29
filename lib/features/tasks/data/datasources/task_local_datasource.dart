/// Local data source powered by Isar.
///
/// All raw DB operations live here — the repository wraps them in
/// [Either] for the domain layer.
library;

import 'package:isar/isar.dart';
import 'package:spot_drop/features/tasks/data/models/geofence_task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<GeofenceTaskModel>> getAll();
  Future<GeofenceTaskModel?> getById(int id);
  Stream<List<GeofenceTaskModel>> watchAll();
  Future<GeofenceTaskModel> insert(GeofenceTaskModel model);
  Future<GeofenceTaskModel> update(GeofenceTaskModel model);
  Future<void> delete(int id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Isar _isar;

  TaskLocalDataSourceImpl(this._isar);

  @override
  Future<List<GeofenceTaskModel>> getAll() async {
    return _isar.geofenceTaskModels
        .where()
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<GeofenceTaskModel?> getById(int id) async {
    return _isar.geofenceTaskModels.get(id);
  }

  @override
  Stream<List<GeofenceTaskModel>> watchAll() {
    return _isar.geofenceTaskModels
        .where()
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<GeofenceTaskModel> insert(GeofenceTaskModel model) async {
    await _isar.writeTxn(() async {
      model.id = await _isar.geofenceTaskModels.put(model);
    });
    return model;
  }

  @override
  Future<GeofenceTaskModel> update(GeofenceTaskModel model) async {
    await _isar.writeTxn(() async {
      await _isar.geofenceTaskModels.put(model);
    });
    return model;
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.geofenceTaskModels.delete(id);
    });
  }
}
