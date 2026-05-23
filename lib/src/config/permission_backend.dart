/// Which API stack resolves runtime location permission.
enum PermissionBackend {
  /// [Geolocator.checkPermission] / [Geolocator.requestPermission] only.
  geolocator,

  /// [Permission.locationWhenInUse] via permission_handler.
  permissionHandler,

  /// Try geolocator first, then permission_handler if still denied.
  auto,
}
