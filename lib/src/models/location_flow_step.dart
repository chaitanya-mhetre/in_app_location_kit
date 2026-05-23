/// Steps emitted while resolving GPS, permission, position, and geocoding.
enum LocationFlowStep {
  idle,
  checking,
  requestingGps,
  requestingPermission,
  fetchingPosition,
  geocoding,
  success,
  failed,
}
