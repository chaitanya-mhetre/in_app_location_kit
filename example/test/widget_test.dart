import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_location_kit_example/main.dart';

void main() {
  testWidgets('Demo app builds', (tester) async {
    await tester.pumpWidget(const InAppLocationKitExampleApp());
    expect(find.text('in_app_location_kit'), findsOneWidget);
  });
}
