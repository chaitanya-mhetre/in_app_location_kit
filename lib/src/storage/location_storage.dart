import '../models/location_fix_result.dart';

/// Persist / restore a [LocationFixResult] in the host app or package adapter.
abstract class LocationStorage {
  Future<LocationFixResult?> load();

  Future<void> save(LocationFixResult result);

  Future<void> clear();

  Future<bool> hasSaved();
}
