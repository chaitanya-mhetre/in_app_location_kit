/// Why the location flow could not complete.
enum LocationFlowFailureType {
  gpsDisabled,
  permissionDenied,
  permissionDeniedForever,
  positionTimeout,
  positionUnavailable,
  geocodeFailed,
  cancelled,
  unknown,
}

/// Structured failure for UI and analytics.
class LocationFlowFailure {
  const LocationFlowFailure({
    required this.type,
    this.message,
    this.cause,
  });

  final LocationFlowFailureType type;
  final String? message;
  final Object? cause;

  @override
  String toString() => message ?? type.name;
}
