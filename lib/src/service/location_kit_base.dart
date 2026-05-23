import '../models/location_flow_result.dart';
import '../models/location_flow_step.dart';

/// Contract for [InAppLocationKit] and [FakeInAppLocationKit].
abstract class LocationKitBase {
  Stream<LocationFlowStep> get steps;

  LocationFlowStep get currentStep;

  Future<LocationFlowResult> ensureReady({bool requestGpsIfDisabled = true});

  Future<LocationFlowResult> fetchCurrentLocation({
    bool requestGpsIfDisabled = true,
  });

  Future<bool> isGpsEnabled();

  Future<bool> hasPermission();

  Future<bool> openAppSettings();

  Future<bool> openLocationSettings();

  void dispose();
}
