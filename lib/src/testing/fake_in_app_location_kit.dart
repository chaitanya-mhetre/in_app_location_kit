import '../config/in_app_location_config.dart';
import '../models/location_fix_result.dart';
import '../models/location_flow_failure.dart';
import '../models/location_flow_result.dart';
import '../models/location_flow_step.dart';
import '../service/location_kit_base.dart';

/// Test double for widget / integration tests without platform channels.
class FakeInAppLocationKit implements LocationKitBase {
  FakeInAppLocationKit({
    this.config = InAppLocationConfig.defaults,
    this.gpsEnabled = true,
    this.permissionGranted = true,
    this.fixResult,
    this.readyFailure,
    this.fetchFailure,
    this.delay = Duration.zero,
  });

  final InAppLocationConfig config;

  bool gpsEnabled;
  bool permissionGranted;
  LocationFixResult? fixResult;
  LocationFlowFailure? readyFailure;
  LocationFlowFailure? fetchFailure;
  Duration delay;

  LocationFlowStep _step = LocationFlowStep.idle;

  final List<LocationFlowStep> recordedSteps = [];

  static final LocationFixResult defaultFix = LocationFixResult(
    latitude: 18.9389,
    longitude: 72.8258,
    formattedAddress: 'Mumbai, Maharashtra, 400001',
    city: 'Mumbai',
    stateName: 'Maharashtra',
    postalCode: '400001',
    country: 'India',
    detectedAt: DateTime(2026, 1, 1),
  );

  @override
  LocationFlowStep get currentStep => _step;

  @override
  Stream<LocationFlowStep> get steps => Stream.fromIterable(recordedSteps);

  void _emit(LocationFlowStep step) {
    _step = step;
    recordedSteps.add(step);
    config.analytics?.onStepChanged?.call(step);
  }

  @override
  Future<LocationFlowResult> ensureReady({
    bool requestGpsIfDisabled = true,
  }) async {
    await Future<void>.delayed(delay);
    _emit(LocationFlowStep.checking);
    if (!gpsEnabled && requestGpsIfDisabled) {
      gpsEnabled = true;
      _emit(LocationFlowStep.requestingGps);
    }
    if (!gpsEnabled) {
      final f = readyFailure ??
          const LocationFlowFailure(type: LocationFlowFailureType.gpsDisabled);
      _emit(LocationFlowStep.failed);
      return LocationFlowError(f);
    }
    _emit(LocationFlowStep.requestingPermission);
    if (!permissionGranted) {
      final f = readyFailure ??
          const LocationFlowFailure(
            type: LocationFlowFailureType.permissionDenied,
          );
      _emit(LocationFlowStep.failed);
      return LocationFlowError(f);
    }
    _emit(LocationFlowStep.success);
    return const LocationFlowReady();
  }

  @override
  Future<LocationFlowResult> fetchCurrentLocation({
    bool requestGpsIfDisabled = true,
  }) async {
    final ready = await ensureReady(requestGpsIfDisabled: requestGpsIfDisabled);
    if (ready is LocationFlowError) return ready;
    if (fetchFailure != null) {
      _emit(LocationFlowStep.failed);
      return LocationFlowError(fetchFailure!);
    }
    _emit(LocationFlowStep.fetchingPosition);
    final fix = fixResult ?? defaultFix;
    _emit(LocationFlowStep.success);
    config.analytics?.onSuccess?.call(fix);
    return LocationFlowSuccess(fix);
  }

  @override
  Future<bool> isGpsEnabled() async => gpsEnabled;

  @override
  Future<bool> hasPermission() async => permissionGranted;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;

  @override
  void dispose() {}
}
