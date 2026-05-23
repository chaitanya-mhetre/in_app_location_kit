import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'permission_backend.dart';
import '../analytics/location_analytics_callbacks.dart';

/// Behavior knobs for [InAppLocationKit] and bundled widgets.
class InAppLocationConfig {
  const InAppLocationConfig({
    this.gpsStabilizeDelay = const Duration(seconds: 2),
    this.accuracy = LocationAccuracy.medium,
    this.positionTimeout = const Duration(seconds: 18),
    this.reverseGeocode = true,
    this.permissionBackend = PermissionBackend.auto,
    this.requestPermissionOnGpsEnable = true,
    this.openAppSettingsOnDeniedForever = true,
    this.addressFormatter,
    this.analytics,
  });

  /// Khaugalli-style wait after user enables GPS before fetching fix.
  final Duration gpsStabilizeDelay;
  final LocationAccuracy accuracy;
  final Duration positionTimeout;
  final bool reverseGeocode;
  final PermissionBackend permissionBackend;

  /// After [Location.requestService], also call geolocator permission (iOS).
  final bool requestPermissionOnGpsEnable;
  final bool openAppSettingsOnDeniedForever;

  /// Build display address from [Placemark]. Return null to use default format.
  final String? Function(Placemark place)? addressFormatter;

  final LocationAnalyticsCallbacks? analytics;

  static const InAppLocationConfig defaults = InAppLocationConfig();

  LocationSettings get locationSettings => LocationSettings(
        accuracy: accuracy,
        timeLimit: positionTimeout,
      );
}
