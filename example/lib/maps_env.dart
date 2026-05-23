import 'package:in_app_location_kit/maps.dart';

/// Google Maps key for the example app.
///
/// Set via: `flutter run --dart-define=MAPS_API_KEY=your_key`
/// Also set the same key in `android/local.properties`.
const String exampleMapsApiKey = String.fromEnvironment('MAPS_API_KEY');

bool get exampleMapsConfigured =>
    MapsAvailability.isConfigured(exampleMapsApiKey);

/// Shown in dialog / placeholder when Maps is not configured.
String get exampleMapsSetupSteps {
  const placeholder = 'YOUR_KEY';
  return '''
Map picker needs a Google Maps API key.

STEP 1 — Google Cloud
• Create an API key
• Enable "Maps SDK for Android"

STEP 2 — android/local.properties
cp android/local.properties.example android/local.properties

Open android/local.properties and add:
MAPS_API_KEY=$placeholder

STEP 3 — Run the app (use YOUR real key, not $placeholder)

flutter run --dart-define=MAPS_API_KEY=$placeholder

Example:
flutter run --dart-define=MAPS_API_KEY=YOUR_KEY_HERE

Other buttons (GPS / permission) work with plain:
flutter run
''';
}

/// One-line hint for the home screen banner.
String get exampleMapsBannerMessage =>
    'Map picker needs MAPS_API_KEY. Run:\n'
    'flutter run --dart-define=MAPS_API_KEY=your_key\n'
    '(and set the same key in android/local.properties)';
