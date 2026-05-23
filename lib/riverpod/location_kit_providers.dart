import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../src/bootstrap/location_bootstrap.dart';
import '../src/config/in_app_location_config.dart';
import '../src/models/location_fix_result.dart';
import '../src/models/location_flow_result.dart';
import '../src/service/in_app_location_kit.dart';
import '../src/service/location_kit_base.dart';
import '../src/storage/location_storage.dart';
import '../src/storage/shared_preferences_location_storage.dart';

/// Default [InAppLocationConfig] for the app — override in ProviderScope.
final inAppLocationConfigProvider = Provider<InAppLocationConfig>(
  (ref) => InAppLocationConfig.defaults,
);

final locationKitProvider = Provider<LocationKitBase>((ref) {
  final config = ref.watch(inAppLocationConfigProvider);
  final kit = InAppLocationKit(config: config);
  ref.onDispose(kit.dispose);
  return kit;
});

final locationStorageProvider = Provider<LocationStorage>(
  (ref) => SharedPreferencesLocationStorage(),
);

final cachedLocationProvider = FutureProvider<LocationFixResult?>((ref) async {
  return ref.watch(locationStorageProvider).load();
});

final locationBootstrapProvider = Provider<LocationBootstrap>((ref) {
  return LocationBootstrap(
    config: ref.watch(inAppLocationConfigProvider),
    storage: ref.watch(locationStorageProvider),
    kit: ref.watch(locationKitProvider) as InAppLocationKit,
  );
});

final bootstrapRouteProvider = FutureProvider((ref) async {
  return ref.watch(locationBootstrapProvider).resolve();
});

/// Fetches current location and persists when successful.
final fetchAndSaveLocationProvider =
    FutureProvider.autoDispose<LocationFlowResult>((ref) async {
  final kit = ref.watch(locationKitProvider);
  final storage = ref.watch(locationStorageProvider);
  final result = await kit.fetchCurrentLocation();
  if (result is LocationFlowSuccess) {
    await storage.save(result.fix);
  }
  return result;
});
