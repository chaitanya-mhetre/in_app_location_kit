import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../config/permission_backend.dart';
import '../models/location_flow_failure.dart';

/// Resolves runtime location permission across geolocator and permission_handler.
class PermissionCoordinator {
  PermissionCoordinator(this.backend);

  final PermissionBackend backend;

  Future<bool> isGranted() async {
    final p = await _checkGeolocator();
    return p == LocationPermission.whileInUse ||
        p == LocationPermission.always;
  }

  Future<LocationPermission> check() => _checkGeolocator();

  Future<LocationFlowFailure?> ensureGranted() async {
    switch (backend) {
      case PermissionBackend.geolocator:
        return _ensureGeolocator();
      case PermissionBackend.permissionHandler:
        return _ensurePermissionHandler();
      case PermissionBackend.auto:
        final geo = await _ensureGeolocator();
        if (geo == null) return null;
        if (geo.type == LocationFlowFailureType.permissionDenied) {
          final phResult = await _ensurePermissionHandler();
          return phResult;
        }
        return geo;
    }
  }

  Future<LocationFlowFailure?> _ensureGeolocator() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return const LocationFlowFailure(
        type: LocationFlowFailureType.permissionDenied,
        message: 'Location permission denied',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationFlowFailure(
        type: LocationFlowFailureType.permissionDeniedForever,
        message:
            'Location permissions are permanently denied. Please enable in settings.',
      );
    }
    return null;
  }

  Future<LocationFlowFailure?> _ensurePermissionHandler() async {
    var status = await ph.Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await ph.Permission.locationWhenInUse.request();
    }
    if (status.isPermanentlyDenied) {
      return const LocationFlowFailure(
        type: LocationFlowFailureType.permissionDeniedForever,
        message:
            'Location permissions are permanently denied. Please enable in settings.',
      );
    }
    if (!status.isGranted && !status.isLimited) {
      return const LocationFlowFailure(
        type: LocationFlowFailureType.permissionDenied,
        message: 'Location permission denied',
      );
    }
    return null;
  }

  Future<LocationPermission> _checkGeolocator() =>
      Geolocator.checkPermission();

  static Future<bool> openAppSettings() => Geolocator.openAppSettings();

  static Future<bool> openLocationSettings() =>
      Geolocator.openLocationSettings();
}
