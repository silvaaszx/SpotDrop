/// Platform bridge for native geofencing via [MethodChannel] / [EventChannel].
///
/// Flutter calls [registerGeofence] / [removeGeofence] which are forwarded
/// to the native Swift (iOS) and Kotlin (Android) implementations.
/// The [onGeofenceTriggered] stream receives events from the native side
/// when the user enters a monitored region.
library;

import 'dart:async';
import 'package:flutter/services.dart';

class GeofencingPlatform {
  GeofencingPlatform._();
  static final GeofencingPlatform instance = GeofencingPlatform._();

  static const _methodChannel = MethodChannel('com.spotdrop/geofencing');
  static const _eventChannel = EventChannel('com.spotdrop/geofencing_events');

  Stream<Map<String, dynamic>>? _triggerStream;

  /// Register a circular geofence with the native OS.
  Future<bool> registerGeofence({
    required String identifier,
    required double latitude,
    required double longitude,
    required double radiusMeters,
    required String title,
  }) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'registerGeofence',
        {
          'identifier': identifier,
          'latitude': latitude,
          'longitude': longitude,
          'radius': radiusMeters,
          'title': title,
        },
      );
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Remove a previously registered geofence.
  Future<bool> removeGeofence(String identifier) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'removeGeofence',
        {'identifier': identifier},
      );
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Stream of geofence trigger events from native code.
  ///
  /// Each event is a `Map` containing:
  /// - `identifier` (String)
  /// - `event` (String: "enter" | "exit")
  Stream<Map<String, dynamic>> get onGeofenceTriggered {
    _triggerStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => Map<String, dynamic>.from(event as Map));
    return _triggerStream!;
  }
}
