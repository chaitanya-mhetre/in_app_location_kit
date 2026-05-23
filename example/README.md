# Example app — how to run

This folder is a **demo** for `in_app_location_kit`. Read this before tapping **Map picker**.

---

## What works without Google Maps?

| Button | Needs Maps API key? |
|--------|---------------------|
| **Use current location** | No |
| **Permission screen** | No |
| **Loading screen (GPS)** | No |
| **Run bootstrap** | No |
| **Map picker** | **Yes** |

---

## Run without Maps (recommended first try)

From this `example/` folder:

```bash
flutter pub get
flutter run
```

Choose your phone/emulator when asked.

You can test GPS and permission flows. **Do not use Map picker** until you complete the steps below.

---

## Run with Map picker (Google Maps)

### Why this extra setup?

`Map picker` uses **Google Maps**. Google requires an API key in your Android app. Without it you may see:

```text
API key not found
IllegalStateException: com.google.android.geo.API_KEY
```

The app will **not** crash if you follow the steps here (or if you skip Map picker).

---

### Step-by-step

#### 1. Get a Google Maps API key

1. Open [Google Cloud Console](https://console.cloud.google.com/).
2. Create or select a project.
3. Go to **APIs & Services** → **Credentials** → **Create credentials** → **API key**.
4. Enable **Maps SDK for Android** (and **Maps SDK for iOS** if you test on iPhone):
   - **APIs & Services** → **Library** → search “Maps SDK for Android” → **Enable**.

Copy the key (starts with `AIzaSy...`).

#### 2. Add key to Android (`local.properties`)

```bash
# From in_app_location_kit/example/
cp android/local.properties.example android/local.properties
```

Open `android/local.properties` and set:

```properties
MAPS_API_KEY=AIzaSy_PASTE_YOUR_REAL_KEY_HERE
```

> `local.properties` is gitignored — never commit your real key.

#### 3. Run Flutter with the **same** key

The native Android build reads `local.properties`. Dart needs the key too for the safety check before opening the map.

**Copy-paste template** (replace only the key part):

```bash
flutter run --dart-define=MAPS_API_KEY=AIzaSy_PASTE_YOUR_REAL_KEY_HERE
```

**Full example** (one line):

```bash
cd ~/path/to/in_app_location_kit/example
flutter pub get
flutter run --dart-define=MAPS_API_KEY=AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567
```

#### 4. Test Map picker

1. Wait for the app to install.
2. On the home screen, the yellow banner should **disappear** when the key is set.
3. Tap **Map picker** — the map should load.

---

## Common issues

### “Map picker (needs API key)” / dialog when I tap the button

You ran only:

```bash
flutter run
```

**Fix:** Run again **with** `--dart-define`:

```bash
flutter run --dart-define=MAPS_API_KEY=YOUR_SAME_KEY_AS_local.properties
```

### App still crashes on Map picker

1. Confirm `android/local.properties` has `MAPS_API_KEY=...` (no quotes, no spaces around `=`).
2. Confirm you used the **same** key in `flutter run --dart-define=MAPS_API_KEY=...`.
3. Clean rebuild:

```bash
flutter clean
flutter pub get
flutter run --dart-define=MAPS_API_KEY=YOUR_KEY
```

4. In Google Cloud, ensure **Maps SDK for Android** is enabled for that key.
5. If the key is restricted, add your app’s package name:  
   `com.example.in_app_location_kit_example`

### Other buttons work, only map fails

That is expected — only the map needs Google Maps. GPS/permission does not.

---

## Wireless / specific device

```bash
flutter devices
flutter run -d DEVICE_ID --dart-define=MAPS_API_KEY=YOUR_KEY
```

Example:

```bash
flutter run -d 192.168.0.153:44281 --dart-define=MAPS_API_KEY=AIzaSy...
```

---

## More documentation

- Package README: [../README.md](../README.md)
- Detailed Maps guide: [../docs/GOOGLE_MAPS_SETUP.md](../docs/GOOGLE_MAPS_SETUP.md)
