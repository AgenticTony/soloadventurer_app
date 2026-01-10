import 'package:freezed_annotation/freezed_annotation.dart';

part 'travel_preference.freezed.dart';
part 'travel_preference.g.dart';

@freezed
class TravelPreference with _$TravelPreference {
  const factory TravelPreference({
    required String id,
    required String userId,
    required List<String> travelStyles,
    required List<String> accommodationTypes,
    required List<String> transportationTypes,
    required int minBudget,
    required int maxBudget,
    required int minTripDuration,
    required int maxTripDuration,
    required List<String> preferredDestinations,
    required List<String> avoidDestinations,
    required bool isFlexibleDates,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TravelPreference;

  factory TravelPreference.fromJson(Map<String, dynamic> json) =>
      _$TravelPreferenceFromJson(json);
}
