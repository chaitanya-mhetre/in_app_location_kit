/// Suggested navigation after app startup location checks.
enum LocationBootstrapAction {
  /// GPS + permission OK — fetch location in background or loading screen.
  fetchGps,

  /// No GPS / permission — user must pick address manually.
  manualAddressRequired,

  /// Saved address exists — proceed with cached location.
  useCachedAddress,
}

class LocationBootstrapRoute {
  const LocationBootstrapRoute({
    required this.action,
    this.hasCachedAddress = false,
    this.gpsUsable = false,
  });

  final LocationBootstrapAction action;
  final bool hasCachedAddress;
  final bool gpsUsable;
}
