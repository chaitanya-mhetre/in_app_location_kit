import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_location_kit/in_app_location_kit.dart';

void main() {
  test('FakeInAppLocationKit returns success by default', () async {
    final kit = FakeInAppLocationKit();
    final result = await kit.fetchCurrentLocation();
    expect(result, isA<LocationFlowSuccess>());
    final fix = (result as LocationFlowSuccess).fix;
    expect(fix.latitude, 18.9389);
    expect(fix.formattedAddress, isNotNull);
  });

  test('FakeInAppLocationKit respects gps disabled', () async {
    final kit = FakeInAppLocationKit(gpsEnabled: false);
    final result = await kit.fetchCurrentLocation(requestGpsIfDisabled: false);
    expect(result, isA<LocationFlowError>());
    expect(
      (result as LocationFlowError).failure.type,
      LocationFlowFailureType.gpsDisabled,
    );
  });

  test('SharedPreferencesLocationStorage roundtrip json', () {
    final result = LocationFixResult(
      latitude: 1,
      longitude: 2,
      formattedAddress: 'Test',
    );
    final json = result.toJson();
    final restored = LocationFixResult.fromJson(json);
    expect(restored.latitude, 1);
    expect(restored.formattedAddress, 'Test');
  });
}
