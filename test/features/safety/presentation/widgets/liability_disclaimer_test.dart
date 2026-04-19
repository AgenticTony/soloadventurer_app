import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/safety/presentation/widgets/liability_disclaimer_modal.dart';

void main() {
  group('LiabilityFeature', () {
    test('has sos and shareMeetup values', () {
      expect(LiabilityFeature.values.length, 2);
      expect(LiabilityFeature.values, contains(LiabilityFeature.sos));
      expect(
          LiabilityFeature.values, contains(LiabilityFeature.shareMeetup));
    });

    test('name property is correct', () {
      expect(LiabilityFeature.sos.name, 'sos');
      expect(LiabilityFeature.shareMeetup.name, 'shareMeetup');
    });
  });
}
