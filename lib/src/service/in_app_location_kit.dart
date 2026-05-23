import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../config/in_app_location_config.dart';
import '../models/location_fix_result.dart';
import '../models/location_flow_failure.dart';
import '../models/location_flow_result.dart';
import '../models/location_flow_step.dart';
import '../permission/permission_coordinator.dart';
import 'gps_service.dart';
import 'location_kit_base.dart';

/// Core orchestrator: GPS on → permission → position → optional reverse geocode.
class InAppLocationKit implements LocationKitBase {
  InAppLocationKit({
    InAppLocationConfig? config,
    GpsService? gpsService,
    PermissionCoordinator? permissionCoordinator,
  })  : config = config ?? InAppLocationConfig.defaults,
        _gps = gpsService ?? GpsService(),
        _permission = permissionCoordinator ??
            PermissionCoordinator(
              (config ?? InAppLocationConfig.defaults).permissionBackend,
            );

  final InAppLocationConfig config;
  final GpsService _gps;
  final PermissionCoordinator _permission;

  final _stepController = StreamController<LocationFlowStep>.broadcast();

  /// Live step updates for fully custom UI ([InAppLocationFlow]).
  @override
  Stream<LocationFlowStep> get steps => _stepController.stream;

  LocationFlowStep _step = LocationFlowStep.idle;

  void _emit(LocationFlowStep step) {
    _step = step;
    if (!_stepController.isClosed) {
      _stepController.add(step);
    }
    config.analytics?.onStepChanged?.call(step);
  }

  /// GPS enabled and app permission granted (no position fetch).
  @override
  Future<LocationFlowResult> ensureReady({
    bool requestGpsIfDisabled = true,
  }) async {
    _emit(LocationFlowStep.checking);

    if (!await _gps.isEnabled()) {
      if (!requestGpsIfDisabled) {
        final failure = LocationFlowFailure(
          type: LocationFlowFailureType.gpsDisabled,
          message: 'Location services are disabled. Please enable GPS.',
        );
        _fail(failure);
        return LocationFlowError(failure);
      }
      _emit(LocationFlowStep.requestingGps);
      final enabled = await _gps.requestEnable();
      if (!enabled && config.requestPermissionOnGpsEnable) {
        await Geolocator.requestPermission();
        if (await _gps.isEnabled()) {
          await Future<void>.delayed(config.gpsStabilizeDelay);
        }
      } else if (enabled) {
        await Future<void>.delayed(config.gpsStabilizeDelay);
      }
      if (!await _gps.isEnabled()) {
        final failure = LocationFlowFailure(
          type: LocationFlowFailureType.gpsDisabled,
          message: 'Location services are disabled. Please enable GPS.',
        );
        _fail(failure);
        return LocationFlowError(failure);
      }
    }

    _emit(LocationFlowStep.requestingPermission);
    final permFailure = await _permission.ensureGranted();
    if (permFailure != null) {
      _fail(permFailure);
      return LocationFlowError(permFailure);
    }

    _emit(LocationFlowStep.success);
    return const LocationFlowReady();
  }

  /// Full pipeline including position and optional geocoding.
  @override
  Future<LocationFlowResult> fetchCurrentLocation({
    bool requestGpsIfDisabled = true,
  }) async {
    final ready = await ensureReady(requestGpsIfDisabled: requestGpsIfDisabled);
    if (ready is LocationFlowError) return ready;

    _emit(LocationFlowStep.fetchingPosition);
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: config.locationSettings,
      );

      LocationFixResult fix = LocationFixResult(
        latitude: position.latitude,
        longitude: position.longitude,
        detectedAt: DateTime.now(),
      );

      if (config.reverseGeocode) {
        _emit(LocationFlowStep.geocoding);
        try {
          fix = await _reverseGeocode(fix);
        } on LocationFlowFailure catch (f) {
          _fail(f);
          return LocationFlowError(f);
        }
      }

      _emit(LocationFlowStep.success);
      config.analytics?.onSuccess?.call(fix);
      return LocationFlowSuccess(fix);
    } on TimeoutException {
      final failure = LocationFlowFailure(
        type: LocationFlowFailureType.positionTimeout,
        message: 'Timed out while fetching location',
      );
      _fail(failure);
      return LocationFlowError(failure);
    } catch (e) {
      final failure = LocationFlowFailure(
        type: LocationFlowFailureType.positionUnavailable,
        message: 'Failed to get location: $e',
        cause: e,
      );
      _fail(failure);
      return LocationFlowError(failure);
    }
  }

  Future<LocationFixResult> _reverseGeocode(LocationFixResult fix) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        fix.latitude,
        fix.longitude,
      );
      if (placemarks.isEmpty) {
        throw StateError('No placemarks');
      }
      final place = placemarks.first;
      final formatted = config.addressFormatter?.call(place) ??
          _defaultAddress(place);
      return fix.copyWith(
        formattedAddress: formatted,
        city: place.locality ?? place.subAdministrativeArea,
        stateName: place.administrativeArea,
        postalCode: place.postalCode,
        country: place.country,
        placemark: place,
      );
    } catch (e) {
      throw LocationFlowFailure(
        type: LocationFlowFailureType.geocodeFailed,
        message: 'Could not determine address from location',
        cause: e,
      );
    }
  }

  String _defaultAddress(Placemark place) {
    final parts = <String>[
      if (place.name != null && place.name!.isNotEmpty) place.name!,
      if (place.subLocality != null && place.subLocality!.isNotEmpty)
        place.subLocality!,
      if (place.locality != null && place.locality!.isNotEmpty) place.locality!,
      if (place.postalCode != null && place.postalCode!.isNotEmpty)
        place.postalCode!,
    ];
    return parts.join(', ');
  }

  void _fail(LocationFlowFailure failure) {
    _emit(LocationFlowStep.failed);
    config.analytics?.onFailure?.call(failure);
  }

  /// Whether device GPS is on (does not check app permission).
  @override
  Future<bool> isGpsEnabled() => _gps.isEnabled();

  /// Whether app has when-in-use or always permission.
  @override
  Future<bool> hasPermission() => _permission.isGranted();

  @override
  Future<bool> openAppSettings() {
    config.analytics?.onSettingsOpened?.call('app_settings');
    return PermissionCoordinator.openAppSettings();
  }

  @override
  Future<bool> openLocationSettings() {
    config.analytics?.onSettingsOpened?.call('location_settings');
    return PermissionCoordinator.openLocationSettings();
  }

  @override
  LocationFlowStep get currentStep => _step;

  @override
  void dispose() {
    _stepController.close();
  }
}
