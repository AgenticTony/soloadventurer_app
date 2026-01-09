import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip.freezed.dart';
part 'trip.g.dart';

@freezed
class Trip with _$Trip {
  const factory Trip({
    required String id,
    required String userId,
    required String title,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    required String destination,
    double? latitude,
    double? longitude,
    required String status,
    required int budget,
    String? coverImageUrl,
    List<String>? travelCompanionIds,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}
