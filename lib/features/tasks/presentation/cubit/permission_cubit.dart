/// Permission request Cubit.
///
/// Guides the user through location-always + notification permission grants.
/// Provides a graceful fallback when permissions are denied.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

// ───────────────────────── State ──────────────────────────
enum PermissionStep { initial, locationWhenInUse, locationAlways, notification, granted, denied }

class PermissionState extends Equatable {
  final PermissionStep step;
  final String message;
  final bool isLoading;

  const PermissionState({
    this.step = PermissionStep.initial,
    this.message = '',
    this.isLoading = false,
  });

  PermissionState copyWith({
    PermissionStep? step,
    String? message,
    bool? isLoading,
  }) {
    return PermissionState(
      step: step ?? this.step,
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [step, message, isLoading];
}

// ───────────────────────── Cubit ──────────────────────────
class PermissionCubit extends Cubit<PermissionState> {
  PermissionCubit() : super(const PermissionState());

  /// Check if permissions are already granted to skip this screen.
  Future<void> checkInitialStatus() async {
    final locationWhenInUse = await Permission.locationWhenInUse.status;
    final locationAlways = await Permission.locationAlways.status;
    final notification = await Permission.notification.status;

    if (locationWhenInUse.isGranted && locationAlways.isGranted) {
      emit(state.copyWith(step: PermissionStep.granted));
    }
  }

  /// Kick off the permission flow.
  Future<void> requestPermissions() async {
    debugPrint('[SpotDrop] PermissionCubit: Starting request flow...');
    emit(state.copyWith(isLoading: true, step: PermissionStep.locationWhenInUse));

    // Step 1 — Location When In Use
    debugPrint('[SpotDrop] PermissionCubit: Requesting locationWhenInUse...');
    var status = await Permission.locationWhenInUse.request();
    debugPrint('[SpotDrop] PermissionCubit: locationWhenInUse status: $status');
    
    if (!status.isGranted && !status.isLimited) {
      debugPrint('[SpotDrop] PermissionCubit: locationWhenInUse DENIED');
      final isPermanentlyDenied = status == PermissionStatus.permanentlyDenied;
      emit(state.copyWith(
        step: PermissionStep.denied,
        message: isPermanentlyDenied 
          ? 'Location permission is PERMANENTLY DENIED. Please enable it in Settings to use the app.'
          : 'Location access is required so SpotDrop can trigger reminders when you arrive at a place.',
        isLoading: false,
      ));
      return;
    }

    // Step 2 — Location Always (background)
    debugPrint('[SpotDrop] PermissionCubit: Requesting locationAlways...');
    emit(state.copyWith(step: PermissionStep.locationAlways));
    status = await Permission.locationAlways.request();
    debugPrint('[SpotDrop] PermissionCubit: locationAlways status: $status');
    
    if (!status.isGranted) {
      debugPrint('[SpotDrop] PermissionCubit: locationAlways DENIED');
      emit(state.copyWith(
        step: PermissionStep.denied,
        message: 'Background location ("Always") is needed for geofence monitoring even when the app is closed.',
        isLoading: false,
      ));
      return;
    }

    // Step 3 — Notifications
    debugPrint('[SpotDrop] PermissionCubit: Requesting notification...');
    emit(state.copyWith(step: PermissionStep.notification));
    status = await Permission.notification.request();
    debugPrint('[SpotDrop] PermissionCubit: notification status: $status');

    debugPrint('[SpotDrop] PermissionCubit: ALL GRANTED');
    emit(state.copyWith(step: PermissionStep.granted, isLoading: false));
  }

  /// Open device settings if the user denied permanently.
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
