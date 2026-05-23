import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_fix_result.dart';
import 'location_storage.dart';

/// Default persistence using SharedPreferences (Khaugalli-compatible keys).
class SharedPreferencesLocationStorage implements LocationStorage {
  SharedPreferencesLocationStorage({
    this.keyPrefix = 'in_app_location_kit',
    SharedPreferences? preferences,
  }) : _preferences = preferences;

  final String keyPrefix;
  SharedPreferences? _preferences;

  static const _legacyAddressKey = 'delivery_address';
  static const _legacyLatKey = 'delivery_latitude';
  static const _legacyLngKey = 'delivery_longitude';

  Future<SharedPreferences> get _prefs async =>
      _preferences ??= await SharedPreferences.getInstance();

  String _k(String suffix) => '${keyPrefix}_$suffix';

  @override
  Future<void> clear() async {
    final p = await _prefs;
    await p.remove(_k('json'));
    await p.remove(_legacyAddressKey);
    await p.remove(_legacyLatKey);
    await p.remove(_legacyLngKey);
  }

  @override
  Future<bool> hasSaved() async {
    final loaded = await load();
    return loaded != null &&
        (loaded.formattedAddress?.isNotEmpty ?? false);
  }

  @override
  Future<LocationFixResult?> load() async {
    final p = await _prefs;
    final jsonStr = p.getString(_k('json'));
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return LocationFixResult.fromJson(
          jsonDecode(jsonStr) as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    // Khaugalli legacy keys
    final lat = p.getDouble(_legacyLatKey);
    final lng = p.getDouble(_legacyLngKey);
    final address = p.getString(_legacyAddressKey);
    if (lat != null && lng != null) {
      return LocationFixResult(
        latitude: lat,
        longitude: lng,
        formattedAddress: address,
      );
    }
    return null;
  }

  @override
  Future<void> save(LocationFixResult result) async {
    final p = await _prefs;
    await p.setString(_k('json'), jsonEncode(result.toJson()));
    if (result.formattedAddress != null) {
      await p.setString(_legacyAddressKey, result.formattedAddress!);
    }
    await p.setDouble(_legacyLatKey, result.latitude);
    await p.setDouble(_legacyLngKey, result.longitude);
  }
}
