import 'package:latlong2/latlong.dart';

enum TripStatus {
  planning,
  upcoming,
  active,
  completed,
  cancelled,
}

class Trip {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String destination;
  final LatLng? coordinates;
  final TripStatus status;
  final int budget;
  final String? coverImageUrl;
  final List<String>? travelCompanionIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Trip({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.destination,
    this.coordinates,
    required this.status,
    required this.budget,
    this.coverImageUrl,
    this.travelCompanionIds,
    required this.createdAt,
    required this.updatedAt,
  });

  Trip copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? destination,
    LatLng? coordinates,
    TripStatus? status,
    int? budget,
    String? coverImageUrl,
    List<String>? travelCompanionIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destination: destination ?? this.destination,
      coordinates: coordinates ?? this.coordinates,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      travelCompanionIds: travelCompanionIds ?? this.travelCompanionIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      destination: json['destination'],
      coordinates: json['latitude'] != null && json['longitude'] != null
          ? LatLng(json['latitude'], json['longitude'])
          : null,
      status: TripStatus.values.firstWhere(
        (status) => status.toString() == 'TripStatus.${json['status']}',
      ),
      budget: json['budget'],
      coverImageUrl: json['coverImageUrl'],
      travelCompanionIds: json['travelCompanionIds'] != null
          ? List<String>.from(json['travelCompanionIds'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'destination': destination,
      'latitude': coordinates?.latitude,
      'longitude': coordinates?.longitude,
      'status': status.toString().split('.').last,
      'budget': budget,
      'coverImageUrl': coverImageUrl,
      'travelCompanionIds': travelCompanionIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  int get durationInDays => endDate.difference(startDate).inDays + 1;

  bool get isUpcoming =>
      startDate.isAfter(DateTime.now()) && status != TripStatus.cancelled;

  bool get isActive =>
      startDate.isBefore(DateTime.now()) &&
      endDate.isAfter(DateTime.now()) &&
      status != TripStatus.cancelled;

  bool get isCompleted =>
      endDate.isBefore(DateTime.now()) || status == TripStatus.completed;
}
