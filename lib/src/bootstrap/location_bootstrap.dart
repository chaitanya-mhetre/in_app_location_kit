import 'package:geolocator/geolocator.dart';

import '../config/in_app_location_config.dart';
import '../models/location_bootstrap_route.dart';
import '../storage/location_storage.dart';
import '../service/in_app_location_kit.dart';

/// Startup routing helper (Khaugalli splash-style) without app-specific routes.
class LocationBootstrap {
  LocationBootstrap({
    InAppLocationConfig? config,
    LocationStorage? storage,
    InAppLocationKit? kit,
    this.preloadDelay = const Duration(milliseconds: 320),
  })  : _kit = kit ?? InAppLocationKit(config: config),
        _storage = storage;

  final InAppLocationKit _kit;
  final LocationStorage? _storage;
  final Duration preloadDelay;

  /// Decide whether to fetch GPS, use cache, or require manual address.
  Future<LocationBootstrapRoute> resolve({
    bool requestPermissionIfGpsOn = true,
  }) async {
    await Future<void>.delayed(preloadDelay);

    var serviceEnabled = false;
    LocationPermission perm = LocationPermission.denied;

    try {
      serviceEnabled = await _kit.isGpsEnabled();
      if (serviceEnabled && requestPermissionIfGpsOn) {
        perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
      } else if (serviceEnabled) {
        perm = await Geolocator.checkPermission();
      }
    } catch (_) {
      serviceEnabled = await _kit.isGpsEnabled();
    }

    final gpsUsable = serviceEnabled &&
        perm != LocationPermission.denied &&
        perm != LocationPermission.deniedForever;

    final hasCached = _storage != null && await _storage.hasSaved();

    if (gpsUsable) {
      return LocationBootstrapRoute(
        action: LocationBootstrapAction.fetchGps,
        gpsUsable: true,
        hasCachedAddress: hasCached,
      );
    }
    if (!hasCached) {
      return const LocationBootstrapRoute(
        action: LocationBootstrapAction.manualAddressRequired,
        gpsUsable: false,
        hasCachedAddress: false,
      );
    }
    return LocationBootstrapRoute(
      action: LocationBootstrapAction.useCachedAddress,
      gpsUsable: false,
      hasCachedAddress: true,
    );
  }
}
