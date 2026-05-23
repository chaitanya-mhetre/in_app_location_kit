## 0.1.1

* Document Google Maps API key requirement prominently in README and `docs/GOOGLE_MAPS_SETUP.md`.
* Example app: setup banner, dialog with `flutter run --dart-define=MAPS_API_KEY=...` instructions.
* `InAppLocationMapScreen`: placeholder when `googleMapsApiKey` is missing.

## 0.1.0

* Initial release.
* In-app GPS enable via `location.requestService()`.
* Runtime permission via `geolocator` and/or `permission_handler`.
* `InAppLocationKit` service with step stream and reverse geocoding.
* Widgets: button, permission screen, loading screen, guard, flow builder.
* `SharedPreferencesLocationStorage` with optional Khaugalli legacy keys.
* `LocationBootstrap` for splash-style routing.
* `InAppLocationMapScreen` (Google Maps pin picker).
* `FakeInAppLocationKit` for tests.
* Riverpod providers (`package:in_app_location_kit/riverpod.dart`).
