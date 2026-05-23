import '../models/location_flow_failure.dart';
import '../models/location_flow_step.dart';
import '../models/location_fix_result.dart';

/// Optional hooks for Firebase / custom analytics.
class LocationAnalyticsCallbacks {
  const LocationAnalyticsCallbacks({
    this.onStepChanged,
    this.onSuccess,
    this.onFailure,
    this.onSettingsOpened,
  });

  final void Function(LocationFlowStep step)? onStepChanged;
  final void Function(LocationFixResult result)? onSuccess;
  final void Function(LocationFlowFailure failure)? onFailure;
  final void Function(String reason)? onSettingsOpened;
}
