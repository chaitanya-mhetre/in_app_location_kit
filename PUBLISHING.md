# Publishing to pub.dev

## Prerequisites

1. [Create a pub.dev account](https://pub.dev/) (Google sign-in).
2. Verify your **publisher** (individual or organization) on pub.dev.
3. Install Flutter/Dart SDK and log in locally:

```bash
dart pub login
```

## Pre-flight checks

From the package root:

```bash
dart analyze
flutter test
dart pub publish --dry-run
```

Fix any errors before publishing. Warnings about `CHANGELOG` should be gone after this file exists.

## Publish

```bash
dart pub publish
```

Type `y` when prompted. The first upload for `in_app_location_kit` must be **0.1.0** or higher (current: **0.1.1**).

## After publish

1. Open https://pub.dev/packages/in_app_location_kit and confirm the page looks correct.
2. Tag the release in Git:

```bash
git tag v0.1.0
git push origin v0.1.0
```

3. For later versions: bump `version:` in `pubspec.yaml`, add a section to `CHANGELOG.md`, then `dart pub publish` again.

## pub.dev scoring tips

* Keep `README.md` with install snippet, platform setup, and API overview.
* Respond to issues on GitHub (linked via `issue_tracker` in `pubspec.yaml`).
* Add example screenshots on pub.dev via package page (manual upload).

## What hosts must still configure

This package does **not** replace app-level manifest / plist entries. Consumers must add location permissions and usage strings (see README).
