/// Helpers for Google Maps integration in host apps and the example.
abstract final class MapsAvailability {
  MapsAvailability._();

  /// Pass the same key you inject into Android `com.google.android.geo.API_KEY`
  /// / iOS `GMSApiKey`. Empty means maps UI should not load [GoogleMap].
  static bool isConfigured(String apiKey) =>
      apiKey.trim().isNotEmpty &&
      apiKey.trim() != 'YOUR_GOOGLE_MAPS_API_KEY_HERE';
}
