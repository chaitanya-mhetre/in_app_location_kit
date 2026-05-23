# in_app_location_kit

[![pub package](https://img.shields.io/pub/v/in_app_location_kit.svg)](https://pub.dev/packages/in_app_location_kit)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Turn on **device GPS inside the app**, request **runtime permission**, fetch coordinates, and optionally **reverse-geocode** — with fully customizable UI, storage, maps, and Riverpod helpers.

---

## Important: Google Maps is optional (but required for the map screen)

| Feature | Location permission | Google Maps API key |
|--------|---------------------|---------------------|
| `InAppLocationButton`, permission screen, GPS loading, bootstrap | Yes | **No** |
| `InAppLocationMapScreen` (map pin picker) | Yes | **Yes** |

If you open the **map picker** without a Maps API key, Android/iOS can crash with:

```text
PlatformException: API key not found.
Check that <meta-data android:name="com.google.android.geo.API_KEY" .../>
```

That is **not** a bug in this package — Google Maps must be configured in **your** app. See [Google Maps setup](#google-maps-setup-required-only-for-map-picker) below.

---

## Features

- In-app GPS enable via `location.requestService()` (Android system dialog)
- Permission via `geolocator` and/or `permission_handler` (`PermissionBackend`)
- `InAppLocationKit` service with step stream for custom UI
- Widgets: button, permission screen, loading screen, guard, flow builder
- `SharedPreferencesLocationStorage` (optional Khaugalli legacy keys)
- `LocationBootstrap` for splash-style routing
- `InAppLocationMapScreen` (Google Map pin) — **needs Maps API key**
- `FakeInAppLocationKit` for tests
- Riverpod providers (`package:in_app_location_kit/riverpod.dart`)

---

## Install

```yaml
dependencies:
  in_app_location_kit: ^0.1.1
```

```bash
flutter pub get
```

---

## Run the example app

Clone the repo, then choose **one** of these:

### Option 1 — GPS / permission only (no Google Maps key)

Works for: **Use current location**, **Permission screen**, **Loading screen**, **Run bootstrap**.

```bash
git clone https://github.com/chaitanya-mhetre/in_app_location_kit.git
cd in_app_location_kit/example
flutter pub get
flutter run
```

Do **not** tap **Map picker** without completing Option 2.

### Option 2 — Full demo including Map picker

You need a [Google Cloud](https://console.cloud.google.com/) API key with **Maps SDK for Android** (and iOS if you test on iPhone).

**Step 1 — Create `local.properties`**

```bash
cd in_app_location_kit/example
cp android/local.properties.example android/local.properties
```

**Step 2 — Edit `android/local.properties`**

Replace the placeholder with your real key:

```properties
MAPS_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

**Step 3 — Run with the same key in the command**

Replace `YOUR_KEY` with the **exact same** value as in `local.properties`:

```bash
flutter run --dart-define=MAPS_API_KEY=YOUR_KEY
```

Example:

```bash
flutter run --dart-define=MAPS_API_KEY=AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567
```

**Step 4 — Pick your device** when prompted, then tap **Map picker** on the home screen.

More detail: [example/README.md](example/README.md) and [docs/GOOGLE_MAPS_SETUP.md](docs/GOOGLE_MAPS_SETUP.md).

---

## Host app setup (production)

### Android — location (required for all features)

`android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS — location (required for all features)

`ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location for delivery and nearby results.</string>
```

### Google Maps setup (required only for map picker)

**Android** — inside `<application>` in `AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY" />
```

**iOS** — in `Info.plist`:

```xml
<key>GMSApiKey</key>
<string>YOUR_GOOGLE_MAPS_API_KEY</string>
```

**Dart** — pass the key so the package shows a friendly screen instead of crashing:

```dart
import 'package:in_app_location_kit/maps.dart';

InAppLocationMapScreen(
  googleMapsApiKey: yourMapsKey, // empty → placeholder UI, no crash
  onConfirm: (fix) => save(fix),
);
```

---

## Quick start (no map)

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
  strings: const InAppLocationStrings(permissionTitle: 'Find food near you'),
  theme: const InAppLocationTheme(primaryColor: Colors.orange),
);
```

## Core service only

```dart
final kit = InAppLocationKit(
  config: const InAppLocationConfig(
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
    break;
  case LocationBootstrapAction.manualAddressRequired:
    break;
  case LocationBootstrapAction.useCachedAddress:
    break;
}
```

## Riverpod

```dart
import 'package:in_app_location_kit/riverpod.dart';

ref.watch(fetchAndSaveLocationProvider);
```

---

## Troubleshooting

### App crashes on “Map picker” with `API key not found`

**Cause:** `com.google.android.geo.API_KEY` is missing or empty in `AndroidManifest.xml`.

**Fix:**

1. Add the `<meta-data>` block under `<application>` (see above).
2. For the **example** app, set `MAPS_API_KEY` in `example/android/local.properties` **and** run:
   ```bash
   flutter run --dart-define=MAPS_API_KEY=your_key
   ```
3. Rebuild after changing the key (`flutter clean` if the old build is cached).

### Map picker button shows “needs API key” / dialog

**Expected** when you run `flutter run` without `--dart-define=MAPS_API_KEY=...`. Follow [Option 2](#option-2--full-demo-including-map-picker).

### Location works but address is empty

Enable internet for reverse geocoding, or set `reverseGeocode: false` in `InAppLocationConfig`.

### Permission denied forever

User must enable location in system **App settings**. Use `Geolocator.openAppSettings()` or the package’s settings dialog.

---

## Customization

| Type | Purpose |
|------|---------|
| `InAppLocationConfig` | timeouts, accuracy, geocode, permission backend |
| `InAppLocationStrings` | all user-visible copy |
| `InAppLocationTheme` | colors, buttons, illustration, loading |
| `SettingsDialogBuilder` | replace GPS / settings dialogs |
| `InAppLocationFlow` | build UI per `LocationFlowStep` |
| `addressFormatter` | custom address line from `Placemark` |

---

## Contributing

Issues and PRs: [github.com/chaitanya-mhetre/in_app_location_kit](https://github.com/chaitanya-mhetre/in_app_location_kit)

## License

MIT — see [LICENSE](LICENSE).
