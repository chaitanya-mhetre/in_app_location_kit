# in_app_location_kit

Turn on **device GPS inside the app**, request **runtime permission**, fetch coordinates, and optionally **reverse-geocode** — with fully customizable UI, storage, maps, and Riverpod helpers.

Extracted from the Khaugalli delivery-location flow (`location` + `geolocator` + `geocoding`).

## Features

- In-app GPS enable via `location.requestService()` (Android system dialog)
- Permission via `geolocator` and/or `permission_handler` (`PermissionBackend`)
- `InAppLocationKit` service with step stream for custom UI
- Widgets: button, permission screen, loading screen, guard, flow builder
- `SharedPreferencesLocationStorage` (Khaugalli legacy keys supported)
- `LocationBootstrap` for splash-style routing
- `InAppLocationMapScreen` (Google Map pin)
- `FakeInAppLocationKit` for tests
- Riverpod providers (`lib/riverpod.dart`)

## Install

```yaml
dependencies:
  in_app_location_kit:
    path: ../in_app_location_kit   # or git / pub.dev when published
```

## Android setup (host app)

`android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

## iOS setup (host app)

`ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location for delivery and nearby results.</string>
```

## Quick start

```dart
import 'package:in_app_location_kit/in_app_location_kit.dart';

InAppLocationButton(
  onLocation: (fix) => print(fix.formattedAddress),
  storage: SharedPreferencesLocationStorage(),
);
```

## Full permission screen

```dart
InAppLocationPermissionScreen(
  onSuccess: (fix) => context.go('/home'),
  onManualEntry: () => context.go('/address-search'),
  storage: SharedPreferencesLocationStorage(),
  strings: InAppLocationStrings(permissionTitle: 'Find food near you'),
  theme: InAppLocationTheme(primaryColor: Colors.orange),
);
```

## Core service only

```dart
final kit = InAppLocationKit(
  config: InAppLocationConfig(
    gpsStabilizeDelay: Duration(seconds: 2),
    permissionBackend: PermissionBackend.auto,
    reverseGeocode: true,
  ),
);

final result = await kit.fetchCurrentLocation();
if (result is LocationFlowSuccess) {
  print(result.fix.latitude);
}
```

## Bootstrap (splash)

```dart
final bootstrap = LocationBootstrap(
  storage: SharedPreferencesLocationStorage(),
);
final route = await bootstrap.resolve();
switch (route.action) {
  case LocationBootstrapAction.fetchGps:
    // show loading screen mode=gps
  case LocationBootstrapAction.manualAddressRequired:
    // force address picker
  case LocationBootstrapAction.useCachedAddress:
    // go home
}
```

## Riverpod

```dart
import 'package:in_app_location_kit/riverpod.dart';

// ProviderScope child:
ref.watch(fetchAndSaveLocationProvider);
```

## Maps (optional export)

```dart
import 'package:in_app_location_kit/maps.dart';

InAppLocationMapScreen(
  onConfirm: (fix) => save(fix),
);
```

Requires Google Maps API key in the **host** app manifest / Info.plist.

## Customization

| Type | Purpose |
|------|---------|
| `InAppLocationConfig` | timeouts, accuracy, geocode, permission backend |
| `InAppLocationStrings` | all copy |
| `InAppLocationTheme` | colors, buttons, illustration, loading |
| `SettingsDialogBuilder` | replace GPS / settings dialogs |
| `InAppLocationFlow` | build UI per `LocationFlowStep` |
| `addressFormatter` | custom address line from `Placemark` |

## Example

```bash
cd example
flutter run
```

## License

MIT
