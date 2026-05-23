import 'package:location/location.dart' as loc;

/// Device-level GPS / Location Services toggle (not app permission).
class GpsService {
  GpsService({loc.Location? location}) : _location = location ?? loc.Location();

  final loc.Location _location;

  Future<bool> isEnabled() => _location.serviceEnabled();

  /// Shows system UI to enable location (Android dialog; iOS may vary).
  Future<bool> requestEnable() => _location.requestService();
}
