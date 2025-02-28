enum TravelStyle {
  adventure,
  relaxation,
  cultural,
  foodie,
  budget,
  luxury,
  ecotourism,
  backpacking,
  family,
  solo,
}

enum AccommodationType {
  hotel,
  hostel,
  airbnb,
  resort,
  camping,
  glamping,
  couchsurfing,
  familyFriends,
}

enum TransportationType {
  airplane,
  train,
  bus,
  car,
  motorcycle,
  bicycle,
  boat,
  walking,
  rideshare,
}

class TravelPreference {
  final String id;
  final String userId;
  final List<TravelStyle> travelStyles;
  final List<AccommodationType> accommodationTypes;
  final List<TransportationType> transportationTypes;
  final int minBudget; // Daily budget in USD
  final int maxBudget; // Daily budget in USD
  final int minTripDuration; // In days
  final int maxTripDuration; // In days
  final List<String> preferredDestinations;
  final List<String> avoidDestinations;
  final bool isFlexibleDates;
  final DateTime createdAt;
  final DateTime updatedAt;

  TravelPreference({
    required this.id,
    required this.userId,
    required this.travelStyles,
    required this.accommodationTypes,
    required this.transportationTypes,
    required this.minBudget,
    required this.maxBudget,
    required this.minTripDuration,
    required this.maxTripDuration,
    required this.preferredDestinations,
    required this.avoidDestinations,
    required this.isFlexibleDates,
    required this.createdAt,
    required this.updatedAt,
  });

  TravelPreference copyWith({
    String? id,
    String? userId,
    List<TravelStyle>? travelStyles,
    List<AccommodationType>? accommodationTypes,
    List<TransportationType>? transportationTypes,
    int? minBudget,
    int? maxBudget,
    int? minTripDuration,
    int? maxTripDuration,
    List<String>? preferredDestinations,
    List<String>? avoidDestinations,
    bool? isFlexibleDates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TravelPreference(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      travelStyles: travelStyles ?? this.travelStyles,
      accommodationTypes: accommodationTypes ?? this.accommodationTypes,
      transportationTypes: transportationTypes ?? this.transportationTypes,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      minTripDuration: minTripDuration ?? this.minTripDuration,
      maxTripDuration: maxTripDuration ?? this.maxTripDuration,
      preferredDestinations:
          preferredDestinations ?? this.preferredDestinations,
      avoidDestinations: avoidDestinations ?? this.avoidDestinations,
      isFlexibleDates: isFlexibleDates ?? this.isFlexibleDates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TravelPreference.fromJson(Map<String, dynamic> json) {
    return TravelPreference(
      id: json['id'],
      userId: json['userId'],
      travelStyles: (json['travelStyles'] as List)
          .map((e) => TravelStyle.values.firstWhere(
                (style) => style.toString() == 'TravelStyle.$e',
              ))
          .toList(),
      accommodationTypes: (json['accommodationTypes'] as List)
          .map((e) => AccommodationType.values.firstWhere(
                (type) => type.toString() == 'AccommodationType.$e',
              ))
          .toList(),
      transportationTypes: (json['transportationTypes'] as List)
          .map((e) => TransportationType.values.firstWhere(
                (type) => type.toString() == 'TransportationType.$e',
              ))
          .toList(),
      minBudget: json['minBudget'],
      maxBudget: json['maxBudget'],
      minTripDuration: json['minTripDuration'],
      maxTripDuration: json['maxTripDuration'],
      preferredDestinations: List<String>.from(json['preferredDestinations']),
      avoidDestinations: List<String>.from(json['avoidDestinations']),
      isFlexibleDates: json['isFlexibleDates'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'travelStyles':
          travelStyles.map((e) => e.toString().split('.').last).toList(),
      'accommodationTypes':
          accommodationTypes.map((e) => e.toString().split('.').last).toList(),
      'transportationTypes':
          transportationTypes.map((e) => e.toString().split('.').last).toList(),
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'minTripDuration': minTripDuration,
      'maxTripDuration': maxTripDuration,
      'preferredDestinations': preferredDestinations,
      'avoidDestinations': avoidDestinations,
      'isFlexibleDates': isFlexibleDates,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
