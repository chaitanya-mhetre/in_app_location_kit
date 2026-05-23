import 'location_fix_result.dart';
import 'location_flow_failure.dart';

/// Outcome of [InAppLocationKit.ensureReady] or [InAppLocationKit.fetchCurrentLocation].
sealed class LocationFlowResult {
  const LocationFlowResult();
}

class LocationFlowReady extends LocationFlowResult {
  const LocationFlowReady();
}

class LocationFlowSuccess extends LocationFlowResult {
  const LocationFlowSuccess(this.fix);

  final LocationFixResult fix;
}

class LocationFlowError extends LocationFlowResult {
  const LocationFlowError(this.failure);

  final LocationFlowFailure failure;
}
