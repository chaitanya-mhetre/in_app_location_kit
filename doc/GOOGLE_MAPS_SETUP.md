# Google Maps setup for `in_app_location_kit`

Use this guide when you integrate **`InAppLocationMapScreen`** or run the **example** app’s **Map picker**.

---

## Do I need this?

| You use… | Need Google Maps key? |
|----------|------------------------|
| `InAppLocationButton` | No |
| `InAppLocationPermissionScreen` | No |
| `InAppLocationLoadingScreen` | No |
| `LocationBootstrap` | No |
| `InAppLocationMapScreen` | **Yes** |

---

## What happens if I skip setup?

On Android you may get a **crash** when the map widget loads:

```text
E/flutter: PlatformException(error, java.lang.IllegalStateException:
API key not found. Check that <meta-data
android:name="com.google.android.geo.API_KEY" android:value="your API key"/>
is in the <application> element of AndroidManifest.xml
```

**Fix:** Add the API key (below). In Dart, pass `googleMapsApiKey` to `InAppLocationMapScreen` so users see a setup message instead of a crash when the key is empty.

---

## 1. Create API key (Google Cloud)

1. [Google Cloud Console](https://console.cloud.google.com/)
2. **APIs & Services** → **Library**
3. Enable:
   - **Maps SDK for Android** (required for Android)
   - **Maps SDK for iOS** (required for iOS)
4. **Credentials** → **Create credentials** → **API key**
5. (Recommended) Restrict the key:
   - Android: package name + SHA-1 of your signing key
   - iOS: bundle identifier

---

## 2. Host Flutter app — Android

**`android/app/src/main/AndroidManifest.xml`** — inside `<application>`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_KEY_HERE" />
```

Optional (Khaugalli-style) — inject from `local.properties` in `build.gradle.kts`:

```kotlin
val localProps = Properties().apply {
    load(FileInputStream(rootProject.file("local.properties")))
}
manifestPlaceholders["MAPS_API_KEY"] = localProps.getProperty("MAPS_API_KEY") ?: ""
```

Manifest value:

```xml
android:value="${MAPS_API_KEY}"
```

`local.properties`:

```properties
MAPS_API_KEY=YOUR_KEY_HERE
```

---

## 3. Host Flutter app — iOS

**`ios/Runner/Info.plist`:**

```xml
<key>GMSApiKey</key>
<string>YOUR_KEY_HERE</string>
```

---

## 4. Dart — safe map screen

```dart
import 'package:in_app_location_kit/maps.dart';

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => InAppLocationMapScreen(
      googleMapsApiKey: const String.fromEnvironment('MAPS_API_KEY'),
      onConfirm: (fix) => saveAddress(fix),
    ),
  ),
);
```

If `googleMapsApiKey` is empty, the package shows **“Google Maps not configured”** instead of loading `GoogleMap`.

---

## 5. Example app — exact commands

```bash
cd example
cp android/local.properties.example android/local.properties
# Edit: MAPS_API_KEY=YOUR_KEY_HERE
flutter run --dart-define=MAPS_API_KEY=YOUR_KEY_HERE
```

**Both** must use the **same** key:

| Where | Purpose |
|-------|---------|
| `android/local.properties` | Native Android Maps SDK |
| `--dart-define=MAPS_API_KEY=...` | Dart guard before opening map |

---

## 6. Billing

Google Maps Platform has a [free monthly credit](https://developers.google.com/maps/billing-and-pricing). Enable billing on the Cloud project if Google asks for it.

---

## Still stuck?

1. `flutter clean && flutter pub get`
2. Reinstall the app on the device
3. Confirm Maps SDK is **enabled** for the key’s project
4. Open an issue with the **full** log line containing `API key not found`
